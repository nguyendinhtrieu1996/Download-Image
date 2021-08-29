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
@synthesize loaderOperation;
@synthesize cancelled = _cancelled;

- (instancetype)initWithCacheOperation:(id<TNWebImageOperation>)cacheOperation
                       loaderOperation:(id<TNWebImageOperation>)loaderOperation {
    
    self = [super init];
    if (self) {
        self.cacheOperation = cacheOperation;
        self.loaderOperation = loaderOperation;
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
        
        if (self.loaderOperation) {
            [self.loaderOperation cancel];
            self.loaderOperation = nil;
        }
    }
}

@end // @implementation TNImageCombineOperation
