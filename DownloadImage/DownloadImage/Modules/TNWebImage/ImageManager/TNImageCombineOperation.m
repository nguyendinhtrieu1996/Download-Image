//
//  TNImageCombineOperation.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 14/08/2021.
//

#import "TNImageCombineOperation.h"


@interface TNImageCombineOperation ()
{
    BOOL _cancelled;
}

@end // @interface TNImageCombineOperation ()


@implementation TNImageCombineOperation

@synthesize cacheOperation;
@synthesize downloaderOperation;
@synthesize cancelled = _cancelled;

- (instancetype)initWithCacheOperation:(id<TNImageOperationType>)cacheOperation
                       loaderOperation:(id<TNImageOperationType>)loaderOperation {
    
    self = [super init];
    if (self) {
        self.cacheOperation = cacheOperation;
        self.downloaderOperation = loaderOperation;
    }
    return self;
}

- (void)cancel {
    @synchronized (self) {
        if (self.isCancelled) {
            return;
        }
        
        _cancelled = YES;
        
        if (self.cacheOperation) {
            [self.cacheOperation cancel];
            self.cacheOperation = nil;
        }
        
        if (self.downloaderOperation) {
            [self.downloaderOperation cancel];
            self.downloaderOperation = nil;
        }
    }
}

@end // @implementation TNImageCombineOperation
