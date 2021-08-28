//
//  TNWebImageManager.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 14/08/2021.
//

#import "TNWebImageManager.h"

#import "TNImageCache.h"
#import "TNWebImageError.h"
#import "TNInternalMacros.h"
#import "TNWebImageCombineOperation.h"


@interface TNWebImageManager ()
{
    id<TNImageCache> _imageCache;
    id<TNImageDownloaderType> _imageDownloader;
    
    NSMutableSet<NSURL *> *_failedURLs;
    NSMutableDictionary<NSURL *, TNWebImageCombineOperation *> *_runningOperations;
    NSMutableDictionary<NSURL *, NSMutableArray<id<TNImageLoaderBlock>> *> *_runningProgressBlocks;
    
    TN_LOCK_DECLARE(_failedURLLock);
    TN_LOCK_DECLARE(_runningOperationsLock);
    TN_LOCK_DECLARE(_runningProgressBlocksLock);
}

@end // @interface TNWebImageManager ()


@implementation TNWebImageManager

#pragma mark LifeCycle

- (instancetype)initWithImageCache:(id<TNImageCache>)imageCache
                            loader:(id<TNImageDownloaderType>)loader {
    
    TN_ASSERT_NONNULL(imageCache);
    TN_ASSERT_NONNULL(loader);
    
    self = [super init];
    if (self) {
        _imageCache = imageCache;
        _imageDownloader = loader;
        _failedURLs = [NSMutableSet new];
        _runningOperations = [NSMutableDictionary new];
    }
    return self;
}

+ (instancetype)defaultWebImageDownloader {
    static id instance = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        instance = [[TNWebImageManager alloc]
                    initWithImageCache:[TNImageCache new]
                    loader:[TNImageDownloader new]];
    });
    
    return instance;
}

#pragma mark - <TNWebImageManagerProtocol>

- (id<TNWebImageOperation>)loadImageWithURL:(nonnull NSURL *)url
                                    options:(TNWebImageOptions)options
                                   progress:(nullable TNWebImageDownloadProgressBlock)progressBlock
                                 completion:(nullable TNWebImageDownloadCompletionBlock)completionBlock {
    
    ifnot (TN_IS_KIND_OF_CLASS(url, NSURL)) {
        NSError *error = TNWebImageMakeError(TNWebImageError_InavlidURL, @"Image url is invalid");
        safeExec(completionBlock, NULL, error, TNImageCacheType_None, NULL);
        return nil;
    }
    
    BOOL isFailedURL = [self _isFailedURL:url];
    if (isFailedURL && NO == TN_OPTIONS_CONTAINS(options, TNWebImage_RetryFailed)) {
        NSError *error = TNWebImageMakeError(TNWebImageError_BlackListed, @"Image url is blacklisted");
        safeExec(completionBlock, NULL, error, TNImageCacheType_None, NULL);
        return nil;
    }
    
    TNWebImageCombineOperation *runningOperation = [self _runningOperationByURL:url];
    if (runningOperation) {
        [self _addProgressBlockWithProgress:progressBlock completion:completionBlock url:url];
        return runningOperation;
    }
    
    runningOperation = [TNWebImageCombineOperation new];
    [self _addRunningOperation:runningOperation withURL:url];
    
    [self _executeLoadImageWitURL:url options:options];
    
    return runningOperation;
}

- (void)cancelAll {
    
}

- (void)removeAllFailedURLs {
    
}

- (void)removeFailedURL:(nonnull NSURL *)url {
    
}

#pragma mark Load Image

- (void)_executeLoadImageWitURL:(NSURL *)url options:(TNWebImageOptions)options {
    if (TN_OPTIONS_CONTAINS(options, TNWebImage_FromLoaderOnly)) {
        [self _loadImageFromCacheWithURL:url options:options];
        return;
    }
    
    [self _loadImageFromCacheWithURL:url options:options];
}

- (void)_loadImageFromCacheWithURL:(NSURL *)url options:(TNWebImageOptions)options {
    TNWebImageCombineOperation *runningOperation = [self _runningOperationByURL:url];
    NSString *cacheKey = [self _cacheKeyForURL:url];
    
    WEAKSELF
    id<TNWebImageOperation> operation = [_imageCache
                                         queryImageForKey:cacheKey
                                         completion:^(UIImage * _Nullable image,
                                                      NSData * _Nullable data,
                                                      TNImageCacheType cacheType) {
        STRONGSELF_RETURN()
        if (NULL == runningOperation || runningOperation.isCancelled) {
            [self _informCompletionBlockWithURL:url];
            [self _completeOperationByURL:url];
            return;
        }
        
        [self _downloadImageFromURL:url
                            options:options
                         cacheImage:image
                          cacheData:data
                          cacheType:cacheType];
    }];
    
    runningOperation.cacheOperation = operation;
}

- (void)_downloadImageFromURL:(NSURL *)url options:(TNWebImageOptions)options {
    [self _downloadImageFromURL:url
                        options:options
                     cacheImage:NULL
                      cacheData:NULL
                      cacheType:TNImageCacheType_None];
}

- (void)_downloadImageFromURL:(NSURL *)url
                      options:(TNWebImageOptions)options
                   cacheImage:(UIImage *)cacheImage
                    cacheData:(NSData *)cacheData
                    cacheType:(TNImageCacheType)cacheType {
    
    id<TNImageDownloaderType> imageDownloader = _imageDownloader;
    
    TNWebImageCombineOperation *runningOperation = [self _runningOperationByURL:url];
    
    WEAKSELF
    runningOperation.loaderOperation
    = [imageDownloader
       downloadImageWithURL:url
       options:options
       progressBlock:^(id<TNImageDownloaderProgessObjectType> progressObj) {
        STRONGSELF_RETURN()
        
        if (!runningOperation || runningOperation.isCancelled) {
            [self _completeOperationByURL:url];
            return;
        }
    } completion:^(id<TNImageDownloaderCompleteObjectType> completionObj) {
        
    }];
}

#pragma mark Cache


#pragma mark Private Helper

- (BOOL)_isFailedURL:(NSURL *)url {
    TN_LOCK(_failedURLLock);
    BOOL isFailed = [_failedURLs containsObject:url];
    TN_UNLOCK(_failedURLLock);
    return isFailed;
}

- (NSString *)_cacheKeyForURL:(NSURL *)url {
    return url.absoluteString;
}

#pragma mark Operation Helper

- (BOOL)_isURLRunning:(NSURL *)url {
    return [self _runningOperationByURL:url] != NULL;
}

- (BOOL)_isCancelledOperationByURL:(NSURL *)url {
    TN_LOCK(_runningOperationsLock);
    TNWebImageCombineOperation *operation = [_runningOperations objectForKey:url];
    BOOL isCancelled = operation.isCancelled;
    TN_UNLOCK(_runningOperationsLock);
    return isCancelled;
}

- (TNWebImageCombineOperation *)_runningOperationByURL:(NSURL *)url {
    TN_LOCK(_runningOperationsLock);
    TNWebImageCombineOperation *operation = _runningOperations[url];
    TN_UNLOCK(_runningOperationsLock);
    return operation;
}

- (void)_addRunningOperation:(TNWebImageCombineOperation *)operation
                     withURL:(NSURL *)url {
    TN_LOCK(_runningOperationsLock);
    _runningOperations[url] = operation;
    TN_UNLOCK(_runningOperationsLock);
}

- (void)_removeOperationByURL:(NSURL *)url {
    TN_LOCK(_runningOperationsLock);
    [_runningOperations removeObjectForKey:url];
    TN_UNLOCK(_runningOperationsLock);
}

- (void)_addProgressBlockWithProgress:(nullable TNWebImageDownloadProgressBlock)progressBlock
                           completion:(nullable TNWebImageDownloadCompletionBlock)completionBlock
                                  url:(NSURL *)url {
    
    TN_LOCK(_runningProgressBlocksLock);
    NSMutableArray *runningBlocks = _runningProgressBlocks[url];
    
    ifnot (runningBlocks) {
        TN_ASSERT_INCONSISTENCY
        return;
    }
    
    id<TNImageLoaderBlock> loaderBlock = [[TNWebImageLoaderBlock alloc]
                                          initWithProgress:progressBlock
                                          completion:completionBlock];
    [runningBlocks addObject:loaderBlock];
    TN_UNLOCK(_runningProgressBlocksLock);
}

- (void)_removeProgressBlockByURL:(NSURL *)url {
    TN_LOCK(_runningProgressBlocksLock);
    [_runningProgressBlocks removeObjectForKey:url];
    TN_UNLOCK(_runningProgressBlocksLock);
}

- (void)_completeOperationByURL:(NSURL *)url {
    [self _removeOperationByURL:url];
    [self _removeProgressBlockByURL:url];
}

#pragma mark Inform Progress Block

- (void)_informProgressBlockWithURL:(NSURL *)url {
    
}

- (void)_informCompletionBlockWithURL:(NSURL *)url {
    
}

@end // @implementation TNWebImageManager
