//
//  TNImageManager.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 14/08/2021.
//

#import "TNImageManager.h"

#import "TNImageCache.h"
#import "TNWebImageError.h"
#import "TNImageDownloader.h"
#import "TNInternalMacros.h"
#import "TNImageManagerDownloadBlockObject.h"
#import "TNImageCombineOperation.h"


@interface TNImageManager ()
{
    id<TNImageCacheType> _imageCache;
    id<TNImageDownloaderType> _imageDownloader;
    
    NSMutableSet<NSURL *> *_failedURLs;
    NSMutableDictionary<NSURL *, TNImageCombineOperation *> *_runningOperations;
    NSMutableDictionary<NSURL *, NSMutableArray<id<TNImageManagerDownloadBlockObjectType>> *> *_runningBlockObjs;
    
    TN_LOCK_DECLARE(_failedURLLock);
    TN_LOCK_DECLARE(_runningOperationsLock);
    TN_LOCK_DECLARE(_runningBlockObjsLock);
}

@end // @interface TNImageManager ()


@implementation TNImageManager

#pragma mark LifeCycle

- (instancetype)init
{
    return [self initWithImageCache:TNImageCache.sharedImageCache
                             loader:TNImageDownloader.sharedDownloader];
}

- (instancetype)initWithImageCache:(id<TNImageCacheType>)imageCache
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

+ (instancetype)sharedImageManager {
    static dispatch_once_t once;
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}

#pragma mark - <TNWebImageManagerProtocol>

- (id<TNWebImageOperation>)loadImageWithURL:(nonnull NSURL *)url
                                    options:(TNWebImageOptions)options
                                   progress:(nullable TNImageManagerProgressBlock)progressBlock
                                 completion:(nullable TNImageManagerCompletionBlock)completionBlock {
    
    ifnot (TN_IS_KIND_OF_CLASS(url, NSURL)) {
        NSError *error = TNWebImageMakeError(TNWebImageError_InvalidURL, @"Image url is invalid");
        safeExec(completionBlock, NULL, error, TNImageCacheType_None, NULL);
        return nil;
    }
    
    BOOL isFailedURL = [self _isFailedURL:url];
    if (isFailedURL && NO == TN_OPTIONS_CONTAINS(options, TNWebImage_RetryFailed)) {
        NSError *error = TNWebImageMakeError(TNWebImageError_BlackListed, @"Image url is blacklisted");
        safeExec(completionBlock, NULL, error, TNImageCacheType_None, NULL);
        return nil;
    }
    
    TNImageCombineOperation *runningOperation = [self _runningOperationByURL:url];
    if (runningOperation) {
        [self _addProgressBlockWithProgress:progressBlock completion:completionBlock url:url];
        return runningOperation;
    }
    
    runningOperation = [TNImageCombineOperation new];
    [self _addRunningOperation:runningOperation withURL:url];
    
    TNImageManagerDownloadBlockObject *loaderBlock = [TNImageManagerDownloadBlockObject new];
    loaderBlock.progressBlock = progressBlock;
    loaderBlock.completionBlock = completionBlock;
    
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
    TNImageCombineOperation *runningOperation = [self _runningOperationByURL:url];
    NSString *cacheKey = [self _cacheKeyForURL:url];
    
    WEAKSELF
    id<TNWebImageOperation> operation = [_imageCache
                                         queryImageForKey:cacheKey
                                         completion:^(UIImage * _Nullable image,
                                                      NSData * _Nullable data,
                                                      TNImageCacheType cacheType) {
        STRONGSELF_RETURN()
        if (NULL == runningOperation || runningOperation.isCancelled) {
            [self _informCompletionBlockWithURL:url completeObj:nil];
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
    
    TNImageCombineOperation *runningOperation = [self _runningOperationByURL:url];
    
    WEAKSELF
    runningOperation.loaderOperation
    = [imageDownloader
       downloadImageWithURL:url
       options:[self _downloaderOptionsFromImageOptions:options]
       progressBlock:^(id<TNImageDownloaderProgessObjectType> progressObj) {
        STRONGSELF_RETURN()
        
        if (!runningOperation || runningOperation.isCancelled) {
            [self _completeOperationByURL:url];
            return;
        }
        
        [self _informProgressBlockWithURL:url progressObj:progressObj];
        
    } completion:^(id<TNImageDownloaderCompleteObjectType> completeObj) {
        STRONGSELF_RETURN()
                          
        [self _storeCacheForURL:url options:options completeObj:completeObj];
        [self _informCompletionBlockWithURL:url completeObj:completeObj];
        [self _removeOperationByURL:url];
    }];
}

#pragma mark Cache

- (void)_storeCacheForURL:(NSURL *)url
                  options:(TNWebImageOptions)options
              completeObj:(id<TNImageDownloaderCompleteObjectType>)completeObj {
    
    ifnot (completeObj) {
        return;
    }
    
    NSString *cacheKey = [self _cacheKeyForURL:url];
    
    [_imageCache
     storeImage:completeObj.image
     imageData:completeObj.data
     forKey:cacheKey
     cacheType:TNImageCacheType_All
     completion:^{
            
    }];
}

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

- (TNImageDownloaderOptions)_downloaderOptionsFromImageOptions:(TNWebImageOptions)options {
    TNImageDownloaderOptions downloaderOptions = 0;
    
    if (options & TNWebImage_LoaderLowPriority) {
        downloaderOptions |= TNImageDownloader_LowPriotiry;
    }
    
    if (options & TNWebImage_LoaderHighPriority) {
        downloaderOptions |= TNImageDownloader_HighPriority;
    }
    
    if (options & TNWebImage_ContinueInBackground) {
        downloaderOptions |= TNImageDownloader_ContinueInBackground;
    }
    
    if (options & TNWebImage_RefreshURLCached) {
        downloaderOptions |= TNImageDownloader_UseNSURLCache;
    }
    
    if (options & TNWebImage_ScaleDownLargeImages) {
        downloaderOptions |= TNImageDownloader_ScaleDownLargeImage;
    }
    
    return downloaderOptions;
}

#pragma mark Operation Helper

- (BOOL)_isURLRunning:(NSURL *)url {
    return [self _runningOperationByURL:url] != NULL;
}

- (BOOL)_isCancelledOperationByURL:(NSURL *)url {
    TN_LOCK(_runningOperationsLock);
    TNImageCombineOperation *operation = [_runningOperations objectForKey:url];
    BOOL isCancelled = operation.isCancelled;
    TN_UNLOCK(_runningOperationsLock);
    
    return isCancelled;
}

- (TNImageCombineOperation *)_runningOperationByURL:(NSURL *)url {
    TN_LOCK(_runningOperationsLock);
    TNImageCombineOperation *operation = _runningOperations[url];
    TN_UNLOCK(_runningOperationsLock);
    
    return operation;
}

- (void)_addRunningOperation:(TNImageCombineOperation *)operation
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

- (void)_addProgressBlockWithProgress:(nullable TNImageManagerProgressBlock)progressBlock
                           completion:(nullable TNImageManagerCompletionBlock)completionBlock
                                  url:(NSURL *)url {
    
    TN_LOCK(_runningBlockObjsLock);
    NSMutableArray *runningBlocks = _runningBlockObjs[url];
    
    ifnot (runningBlocks) {
        TN_ASSERT_INCONSISTENCY
        return;
    }
    
    id<TNImageManagerDownloadBlockObjectType> loaderBlock = [[TNImageManagerDownloadBlockObject alloc]
                                          initWithProgress:progressBlock
                                          completion:completionBlock];
    [runningBlocks addObject:loaderBlock];
    TN_UNLOCK(_runningBlockObjsLock);
}

- (void)_removeProgressBlockByURL:(NSURL *)url {
    TN_LOCK(_runningBlockObjsLock);
    [_runningBlockObjs removeObjectForKey:url];
    TN_UNLOCK(_runningBlockObjsLock);
}

- (void)_completeOperationByURL:(NSURL *)url {
    [self _removeOperationByURL:url];
    [self _removeProgressBlockByURL:url];
}

#pragma mark Block Objs Helper

- (NSArray<id<TNImageManagerDownloadBlockObjectType>> *)_runningBlockObjsByURL:(NSURL *)url {
    NSArray<id<TNImageManagerDownloadBlockObjectType>> *objs = nil;
    
    TN_LOCK(_runningBlockObjsLock);
    objs = [[_runningBlockObjs objectForKey:url] copy];
    TN_UNLOCK(_runningBlockObjsLock);
    
    return objs;
}

- (void)_addRunningBlock:(TNImageManagerDownloadBlockObject *)block withURL:(NSURL *)url {
    TN_LOCK(_runningBlockObjsLock);
    [_runningBlockObjs setObject:block forKey:url];
    TN_UNLOCK(_runningBlockObjsLock);
}

#pragma mark Inform Progress Block

- (void)_informProgressBlockWithURL:(NSURL *)url
                        progressObj:(id<TNImageDownloaderProgessObjectType>)progressObj {
    
    NSArray<id<TNImageManagerDownloadBlockObjectType>> *objs = [self _runningBlockObjsByURL:url];
    for (id<TNImageManagerDownloadBlockObjectType> blockObj in objs) {
        safeExec(blockObj.progressBlock,
                 progressObj.expectedSize,
                 progressObj.receiveSize,
                 progressObj.targetURL);
    }
}

- (void)_informCompletionBlockWithURL:(NSURL *)url
                          completeObj:(id<TNImageDownloaderCompleteObjectType>)completionObj  {
    
    NSArray<id<TNImageManagerDownloadBlockObjectType>> *objs = [self _runningBlockObjsByURL:url];
    for (id<TNImageManagerDownloadBlockObjectType> blockObj in objs) {
        
        safeExec(blockObj.completionBlock,
                 completionObj.image,
                 completionObj.error,
                 TNImageCacheType_All,
                 nil);
    }
}

@end // @implementation TNImageManager
