//
//  TNImageManagerDownloaderBlockObject.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 15/08/2021.
//

#import "TNImageManageLoaderObject.h"

#import "TNInternalMacros.h"
#import "TNImageCombineOperation.h"


@implementation TNImageManagerDownloaderBlockObject

@synthesize progressBlock;
@synthesize completionBlock;

- (instancetype)initWithProgress:(TNImageManagerProgressBlock)progressBlock
                      completion:(TNImageManagerCompletionBlock)completionBlock {
    self = [super init];
    if (self) {
        self.progressBlock = progressBlock;
        self.completionBlock = completionBlock;
    }
    return self;
}

@end // @implementation TNImageManagerDownloaderBlockObject


@interface TNImageManagerDownloaderObject ()
{
    BOOL _isCancelled;
    
    // Synthesize
    NSURL *_url;
    TNImageOptions _options;
    TNImageCacheType _cacheType;
    id<TNImageCombineOperationType> _combineOperation;
    id<TNImageManagerDownloaderBlockObjectType> _blockObject;
}

@end // @interface TNImageManagerDownloaderObject ()

@implementation TNImageManagerDownloaderObject

@synthesize isCancelled = _isCancelled;

@synthesize url = _url;
@synthesize options = _options;
@synthesize cacheType = _cacheType;
@synthesize combineOperation = _combineOperation;
@synthesize blockObject = _blockObject;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _combineOperation = [TNImageCombineOperation new];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url
                    options:(TNImageOptions)options
                  cacheType:(TNImageCacheType)cacheType
                   blockObj:(id<TNImageManagerDownloaderBlockObjectType>)blockObj {
    
    self = [self init];
    if (self) {
        _url = url;
        _options = options;
        _cacheType = cacheType;
        _blockObject = blockObj;
    }
    return self;
}

- (void)updateCacheOperation:(id<TNImageOperationType>)cacheOperation {
    self.combineOperation.cacheOperation = cacheOperation;
}

- (void)updateDownloaderOperation:(id<TNImageOperationType>)downloaderOperation {
    self.combineOperation.downloaderOperation = downloaderOperation;
}

- (void)cancel {
    @synchronized (self) {
        if (self.isCancelled) {
            return;
        }
        
        _isCancelled = YES;
        [self.combineOperation cancel];
    }
}

@end // TNImageManagerDownloaderObject
