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

@synthesize cancelled = _cancelled;

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
