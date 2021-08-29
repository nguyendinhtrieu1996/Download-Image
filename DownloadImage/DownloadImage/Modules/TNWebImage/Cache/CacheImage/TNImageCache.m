//
//  TNImageCache.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 03/08/2021.
//

#import "TNImageCache.h"

#import "TNImageCoder.h"
#import "TNInternalMacros.h"
#import "TNDiskCache.h"
#import "TNMemoryCache.h"


@interface TNImageCache ()
{
    id<TNDiskCacheType> _diskCache;
    id<TNMemoryCacheType> _memoryCache;
    TNImageCacheConfig *_config;
    NSString *_diskCachePath;
    NSOperationQueue *_executeQueue;
    id<TNImageCoder> _imageCoder;
}

@end // @interface TNImageCache ()


@implementation TNImageCache

#pragma mark LifeCycle

+ (instancetype)sharedImageCache {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init
{
    return [[self.class alloc] initWithDirectory:@"default"];
}

- (instancetype)initWithDirectory:(NSString *)directory {
    return [self initWithDirectory:directory
                            config:TNImageCacheConfig.defaultCacheConfig];
}

- (instancetype)initWithDirectory:(NSString *)directory
                           config:(TNImageCacheConfig *)config {
    
    TN_ASSERT_NONNULL(config);
    TN_ASSRT_NONEMPTY_STR(directory);
    
    self = [super init];
    if (self) {
        _config = [config copy];
        _diskCachePath = [directory copy];
        
        [self _commonInit];
    }
    
    return self;
}

- (void)_commonInit {
    TNMemoryCacheConfig *memoryCacheConfig = _config.memoryCacheConfig;
    TN_ASSERT_NONNULL(memoryCacheConfig);
    TN_ASSERT_NONNULL(memoryCacheConfig.cacheClass);
    _memoryCache = [[memoryCacheConfig.cacheClass alloc] initWithConfig:memoryCacheConfig];
    
    TNDiskCacheConfig *diskCacheConfig = _config.diskCacheConfig;
    TN_ASSERT_NONNULL(diskCacheConfig);
    TN_ASSERT_NONNULL(diskCacheConfig.cacheClass);
    _diskCache = [[diskCacheConfig.cacheClass alloc] initWithCachePath:_diskCachePath
                                                                config:diskCacheConfig];
    _executeQueue = [NSOperationQueue new];
    _executeQueue.maxConcurrentOperationCount = 1;
    
    _imageCoder = [TNWebImageCoder new];
}

#pragma mark Query

- (id<TNImageOperationType>)queryImageForKey:(TNImageCacheKey)key
                                  completion:(nullable TNImageCacheQueryCompletionBlock)completionBlock {
    return [self queryImageForKey:key
                        cacheType:TNImageCacheType_All
                       completion:completionBlock];
}

- (id<TNImageOperationType>)queryImageForKey:(TNImageCacheKey)key
                                   cacheType:(TNImageCacheType)cacheType
                                  completion:(nullable TNImageCacheQueryCompletionBlock)completionBlock {
    TN_ASSRT_NONEMPTY_STR(key);
    
    if (cacheType == TNImageCacheType_None) {
        safeExec(completionBlock, nil, nil, cacheType);
        return nil;
    }
    
    __block  UIImage *image;
    
    if (cacheType == TNImageCacheType_Memory) {
        image = [self _imageForMemoryCacheForKey:key];
        safeExec(completionBlock, image, nil, cacheType);
        return nil;
    }
    
    if (cacheType == TNImageCacheType_All) {
        image = [self _imageForMemoryCacheForKey:key];
    }
    
    WEAKSELF
    id<TNImageOperationType> operation = [self _executeOperationWithBlock:^{
        STRONGSELF_RETURN()
        id value = [self->_diskCache objectForKey:key];
        
        if (TN_IS_KIND_OF_CLASS(value, NSData)) {
            NSData *data = (NSData *)value;
            image = [self->_imageCoder decodedImageWithData:data options:@{}];
        }
        
        safeExec(completionBlock, image, nil, cacheType);
    }];
    
    return operation;
}

- (nullable UIImage *)_imageForMemoryCacheForKey:(TNImageCacheKey)key {
    id cacheData = [_memoryCache objectForKey:key];
    
    if (TN_IS_KIND_OF_CLASS(cacheData, UIImage)) {
        return (UIImage *)cacheData;
    }
    
    return nil;
}

#pragma mark Store

- (id<TNImageOperationType>)storeImage:(nullable UIImage *)image
                             imageData:(nullable NSData *)imageData
                                forKey:(nonnull TNImageCacheKey)key
                             cacheType:(TNImageCacheType)cacheType
                            completion:(TNImageNoParamsBlock)completionBlock {
    
    BOOL toMemory = NO;
    BOOL toDisk = NO;
    
    switch (cacheType) {
        case TNImageCacheType_None:
            break;
        case TNImageCacheType_Memory:
            toMemory = YES;
            break;
        case TNImageCacheType_Disk:
            toDisk = YES;
            break;
        case TNImageCacheType_All:
            toMemory = YES;
            toDisk = YES;
            break;
        default:
            TN_ASSERT_INCONSISTENCY
            break;
    }
    
    return [self _storeImage:image
                   imageData:imageData
                      forKey:key
                    toMemory:toMemory
                      toDisk:toDisk
                  completion:completionBlock];
}

- (id<TNImageOperationType>)_storeImage:(nullable UIImage *)image
                              imageData:(nullable NSData *)imageData
                                 forKey:(nonnull TNImageCacheKey)key
                               toMemory:(BOOL)toMemory
                                 toDisk:(BOOL)toDisk
                             completion:(TNImageNoParamsBlock)completionBlock {
    
    if (NO == toMemory && NO == toDisk) {
        safeExec(completionBlock);
        return nil;
    }
    
    if (toMemory && _config.memoryCacheConfig.isEnable) {
        [_memoryCache setObject:image forKey:key];
    }
    
    ifnot (toDisk) {
        safeExec(completionBlock);
        return nil;
    }
    
    id<TNImageOperationType> operation = [self _executeOperationWithBlock:^{
        NSData *data = imageData;
        
        if (NULL == data && image) {
            data = [self->_imageCoder encodedDataWithImage:image options:nil];
            if (data) {
                [self->_diskCache setObject:data forKey:key];
            }
            
            safeExec(completionBlock);
        }
    }];
    
    return operation;
}

#pragma mark Remove

- (nullable id<TNImageOperationType>)removeImageForKey:(TNImageCacheKey)key
                                             cacheType:(TNImageCacheType)cacheType
                                            completion:(TNImageNoParamsBlock)completionBlock {
    
    if (TN_EMPTY_STR(key)) {
        safeExec(completionBlock);
        return nil;
    }
    
    BOOL fromMemory = NO;
    BOOL fromDisk = NO;
    
    switch (cacheType) {
        case TNImageCacheType_None:
            break;
        case TNImageCacheType_Memory:
            fromMemory = YES;
            break;
        case TNImageCacheType_Disk:
            fromDisk = YES;
            break;
        case TNImageCacheType_All: {
            fromMemory = YES;
            fromDisk = YES;
            break;
        }
        default:
            TN_ASSERT_INCONSISTENCY
            break;
    }
    
    return [self _removeImageForKey:key
                         fromMemory:fromMemory
                           fromDisk:fromDisk
                         completion:completionBlock];
}

- (nullable id<TNImageOperationType>)_removeImageForKey:(TNImageCacheKey)key
                                             fromMemory:(BOOL)fromMemory
                                               fromDisk:(BOOL)fromDisk
                                             completion:(TNImageNoParamsBlock)completionBlock {
    
    if (NO == fromMemory && NO == fromDisk) {
        safeExec(completionBlock);
        return nil;
    }
    
    if (fromMemory) {
        [_memoryCache removeObjectForKey:key];
    }
    
    id<TNImageOperationType> operation = nil;
    
    if (fromDisk) {
        WEAKSELF
        operation = [self _executeOperationWithBlock:^{
            STRONGSELF_RETURN()
            [self->_diskCache removeObjectForKey:key];
            
            safeExec(completionBlock);
        }];
    } else {
        safeExec(completionBlock);
    }
    
    return operation;
}

#pragma mark Clear

- (nullable id<TNImageOperationType>)clearWithCacheType:(TNImageCacheType)cacheType
                                             completion:(TNImageNoParamsBlock)completionBlock {
    
    switch (cacheType) {
        case TNImageCacheType_None: {
            safeExec(completionBlock);
            break;
        }
        case TNImageCacheType_Memory: {
            WEAKSELF
            [_executeQueue addOperationWithBlock:^{
                STRONGSELF_RETURN()
                [self->_memoryCache removeAllObjects];
            }];
            
            safeExec(completionBlock);
            break;
        }
        case TNImageCacheType_Disk: {
            WEAKSELF
            [_executeQueue addOperationWithBlock:^{
                STRONGSELF_RETURN()
                [self->_diskCache removeAllObjects];
            }];
            
            safeExec(completionBlock);
            break;
        }
        case TNImageCacheType_All: {
            WEAKSELF
            [_executeQueue addOperationWithBlock:^{
                STRONGSELF_RETURN()
                [self->_memoryCache removeAllObjects];
                [self->_diskCache removeAllObjects];
            }];
            
            safeExec(completionBlock);
            break;
        }
        default:
            safeExec(completionBlock);
            break;
    }
    
    return nil;
}

#pragma mark Check

- (nullable id<TNImageOperationType>)containImageForKey:(nonnull TNImageCacheKey)key
                                              cacheType:(TNImageCacheType)cacheType
                                             completion:(TNImageCacheContainCompletionBock)completionBlock {
    id<TNImageOperationType> operation = nil;
    
    switch (cacheType) {
        case TNImageCacheType_None: {
            safeExec(completionBlock, cacheType);
            break;
        }
        case TNImageCacheType_Memory: {
            BOOL isInMemoryCache = [_memoryCache objectForKey:key] != nil;
            safeExec(completionBlock, isInMemoryCache ? TNImageCacheType_Memory : TNImageCacheType_None);
            break;
        }
        case TNImageCacheType_Disk: {
            __block BOOL isInDiskCache = NO;
            
            WEAKSELF
            operation = [self _executeOperationWithBlock:^{
                STRONGSELF_RETURN()
                isInDiskCache = [self->_diskCache containObjectForKey:key];
            }];
            
            safeExec(completionBlock, isInDiskCache ? TNImageCacheType_Disk : TNImageCacheType_None);
            break;
        }
        case TNImageCacheType_All: {
            BOOL isInMemoryCache = [_memoryCache objectForKey:key] != nil;
            if (isInMemoryCache) {
                safeExec(completionBlock, isInMemoryCache ? TNImageCacheType_Memory : TNImageCacheType_None);
                return nil;
            }
            
            __block BOOL isInDiskCache;
            
            WEAKSELF
            operation = [self _executeOperationWithBlock:^{
                STRONGSELF_RETURN()
                isInDiskCache = [self->_diskCache containObjectForKey:key];
            }];
            
            safeExec(completionBlock, isInDiskCache ? TNImageCacheType_Disk : TNImageCacheType_None);
            break;
        }
        default:
            safeExec(completionBlock, TNImageCacheType_None);
            break;
    }
    
    return operation;
}

#pragma mark Cache Info

- (NSUInteger)totalDiskSize {
    __block NSUInteger size = 0;
    
    [_executeQueue addOperationWithBlock:^{
        size = [self->_diskCache totalSize];
    }];
    
    [_executeQueue waitUntilAllOperationsAreFinished];
    
    return size;
}

- (NSUInteger)totalDiskCount {
    __block NSUInteger count = 0;
    
    [_executeQueue addOperationWithBlock:^{
        count = [self->_diskCache totalCount];
    }];
    
    [_executeQueue waitUntilAllOperationsAreFinished];
    
    return count;
}

- (void)calculateSizeWithCompletionBlock:(TBWebImageCacheCalculateSizeBlock)completionBlock {
    [_executeQueue addOperationWithBlock:^{
        NSUInteger fileCount = [self->_diskCache totalCount];
        NSUInteger fileSize = [self->_diskCache totalSize];
        safeExec(completionBlock, fileCount, fileSize);
    }];
}

#pragma mark Common Helper

- (id<TNImageOperationType>)_executeOperationWithBlock:(TNImageNoParamsBlock)block {
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:block];
    [_executeQueue addOperation:operation];
    return operation;
}

@end // @implementation TNImageCache
