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
#import "TNImageCombineOperation.h"
#import "TNImageManageLoaderObject.h"


typedef NSMutableArray<id<TNImageManagerLoaderObjectType>> * TNImageRunningLoaderObjects;


@interface TNImageManager ()
{
    id<TNImageCacheType> _imageCache;
    id<TNImageDownloaderType> _imageDownloader;
    
    TN_LOCK_DECLARE(_failedURLLock);
    NSMutableSet<NSURL *> *_failedURLs;
    
    TN_LOCK_DECLARE(_urlToDownloadersLock);
    TNImageRunningLoaderObjects _runningLoaderObjects;
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
        _runningLoaderObjects = [NSMutableArray new];
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

- (id<TNCancellable>)loadImageWithURL:(nonnull NSURL *)url
                              options:(TNImageOptions)options
                            cacheType:(TNImageCacheType)cacheType
                             progress:(nullable TNImageManagerProgressBlock)progressBlock
                           completion:(nullable TNImageManagerCompletionBlock)completionBlock {
    
    ifnot (TN_IS_KIND_OF_CLASS(url, NSURL)) {
        NSError *error = TNImageMakeError(TNImageError_InvalidURL, @"Image url is invalid");
        safeExec(completionBlock, NULL, error, TNImageCacheType_None, NULL);
        return nil;
    }
    
    BOOL isFailedURL = [self _isFailedURL:url];
    if (isFailedURL && NO == TN_OPTIONS_CONTAINS(options, TNImage_RetryFailed)) {
        NSError *error = TNImageMakeError(TNImageError_BlackListed, @"Image url is blacklisted");
        safeExec(completionBlock, NULL, error, TNImageCacheType_None, NULL);
        return nil;
    }
    
    id<TNImageManagerLoaderObjectType> loaderObj = [self
                                                    _addRunningLoaderObjtWithURL:url
                                                    options:options
                                                    cacheType:cacheType
                                                    progress:progressBlock
                                                    completion:completionBlock];
    
    [self _executeLoadImageWithLoaderObj:loaderObj];
    
    return loaderObj;
}

- (void)cancelAll {
    
}

- (void)removeAllFailedURLs {
    
}

- (void)removeFailedURL:(nonnull NSURL *)url {
    
}

#pragma mark Load Image

- (void)_executeLoadImageWithLoaderObj:(id<TNImageManagerLoaderObjectType>)loaderObj {
    BOOL shouldLoadCache = TN_OPTIONS_NOT_CONTAINS(loaderObj.options, TNImage_FromLoaderOnly);
    BOOL shouldDownload = TN_OPTIONS_NOT_CONTAINS(loaderObj.options, TNImage_FromCacheOnly);
    
    if (shouldLoadCache) {
        WEAKSELF
        [self
         _executeLoadImageFromCacheWithLoaderObj:loaderObj
         completion:^(id<TNCacheQueryResponseType>  cacheQueryResponse) {
            STRONGSELF_RETURN()
            
            if (loaderObj.isCancelled) {
                [self
                 _completeLoadImageWithLoaderObject:loaderObj
                 cacheQueryResponse:cacheQueryResponse
                 error:nil];
                
                return;
            }
            
            if (shouldDownload) {
                [self _executeDownloadImageWithLoaderObject:loaderObj
                                         cacheQueryResponse:cacheQueryResponse];
            }
        }];
        
        return;
    }
    
    ifnot (shouldDownload) {
        TN_ASSERT_INCONSISTENCY
        return;
    }
    
    [self _executeLoadImageWithLoaderObj:loaderObj];
}

- (void)_executeLoadImageFromCacheWithLoaderObj:(id<TNImageManagerLoaderObjectType>)loaderObj
                                     completion:(TNImageCacheQueryCompletionBlock)completionBlock {
    
    NSURL *url = loaderObj.url;
    NSString *cacheKey = [self _cacheKeyForURL:url];
    
    id<TNImageOperationType> operation = [_imageCache
                                          queryImageForKey:cacheKey
                                          cacheType:loaderObj.cacheType
                                          completion:completionBlock];
    
    [loaderObj updateCacheOperation:operation];
}

- (void)_executeDownloadImageWithLoaderObject:(id<TNImageManagerLoaderObjectType>)loaderObject {
    [self _executeDownloadImageWithLoaderObject:loaderObject
                              cacheQueryResponse:nil];
}

- (void)_executeDownloadImageWithLoaderObject:(id<TNImageManagerLoaderObjectType>)loaderObject
                           cacheQueryResponse:(id<TNCacheQueryResponseType>)cacheQueryResponse {
    
    id<TNImageDownloaderType> imageDownloader = _imageDownloader;
    NSURL *url = loaderObject.url;
    TNImageDownloaderOptions downloaderOptions = [self _downloaderOptionsFromImageOptions:loaderObject.options];
    
    WEAKSELF
    id<TNImageOperationType> downloadOperation = [imageDownloader
                                                  downloadImageWithURL:url
                                                  options:downloaderOptions
                                                  progressBlock:^(id<TNImageDownloaderProgessObjectType> progressObj) {
        STRONGSELF_RETURN()
        
        if (loaderObject.isCancelled) {
            [self
             _completeLoadImageWithLoaderObject:loaderObject
             cacheQueryResponse:cacheQueryResponse
             error:nil];
            
            return;
        }
        
        
    } completion:^(id<TNImageDownloaderCompleteObjectType> completeObj) {
        STRONGSELF_RETURN()
        
        [self _completeLoadImageWithLoaderObject:loaderObject
                              cacheQueryResponse:cacheQueryResponse
                          downloadCompleteObject:completeObj
                                           error:nil];
    }];
    
    [loaderObject updateDownloaderOperation:downloadOperation];
}

#pragma mark Cache

- (void)_storeCacheForURL:(NSURL *)url
                  options:(TNImageOptions)options
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

- (TNImageDownloaderOptions)_downloaderOptionsFromImageOptions:(TNImageOptions)options {
    TNImageDownloaderOptions downloaderOptions = 0;
    
    if (options & TNImage_LoaderLowPriority) {
        downloaderOptions |= TNImageDownloader_LowPriotiry;
    }
    
    if (options & TNImage_LoaderHighPriority) {
        downloaderOptions |= TNImageDownloader_HighPriority;
    }
    
    if (options & TNImage_ContinueInBackground) {
        downloaderOptions |= TNImageDownloader_ContinueInBackground;
    }
    
    if (options & TNImage_RefreshURLCached) {
        downloaderOptions |= TNImageDownloader_UseNSURLCache;
    }
    
    if (options & TNImage_ScaleDownLargeImages) {
        downloaderOptions |= TNImageDownloader_ScaleDownLargeImage;
    }
    
    return downloaderOptions;
}

#pragma mark Complete Helper

- (void)_completeLoadImageWithLoaderObject:(id<TNImageManagerLoaderObjectType>)loaderObject
                        cacheQueryResponse:(id<TNCacheQueryResponseType>)cacheQueryResponse
                                     error:(NSError *)error {
    
    [self _completeLoadImageWithLoaderObject:loaderObject
                          cacheQueryResponse:cacheQueryResponse
                      downloadCompleteObject:nil
                                       error:error];
}

- (void)_completeLoadImageWithLoaderObject:(id<TNImageManagerLoaderObjectType>)loaderObject
                        cacheQueryResponse:(id<TNCacheQueryResponseType>)cacheQueryResponse
                    downloadCompleteObject:(id<TNImageDownloaderCompleteObjectType>)downloadCompleteObject
                                     error:(NSError *)error {
    
}

#pragma mark Running Loader Helper

- (id<TNImageManagerLoaderObjectType>)_addRunningLoaderObjtWithURL:(NSURL *)url
                                                           options:(TNImageOptions)options
                                                         cacheType:(TNImageCacheType)cacheType
                                                          progress:(TNImageManagerProgressBlock)progressBlock
                                                        completion:(TNImageManagerCompletionBlock)completionBlock {
    
    id<TNImageManagerDownloaderBlockObjectType> downloaderBlockObj
    = [[TNImageManagerDownloaderBlockObject alloc]
       initWithProgress:progressBlock
       completion:completionBlock];
    
    id<TNImageManagerLoaderObjectType> loaderObj = [[TNImageManagerDownloaderObject alloc]
                                                    initWithURL:url
                                                    options:options
                                                    cacheType:cacheType
                                                    blockObj:downloaderBlockObj];
    
    TN_LOCK(_failedURLLock);
    [_runningLoaderObjects addObject:loaderObj];
    TN_UNLOCK(_failedURLLock);
    
    return loaderObj;
}

- (void)_removeLoaderObj:(id<TNImageManagerLoaderObjectType>)loaderObj {
    TN_LOCK(_failedURLLock);
    [_runningLoaderObjects addObject:loaderObj];
    TN_UNLOCK(_failedURLLock);
}

#pragma mark Inform Progress Block

- (void)_informProgressBlockWithURL:(NSURL *)url
                        progressObj:(id<TNImageDownloaderProgessObjectType>)progressObj {
    
}

- (void)_informCompletionBlockWithURL:(NSURL *)url
                          completeObj:(id<TNImageDownloaderCompleteObjectType>)completionObj  {
    
    
}

@end // @implementation TNImageManager
