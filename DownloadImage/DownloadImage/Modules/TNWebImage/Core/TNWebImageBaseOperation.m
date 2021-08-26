//
//  TNWebImageBaseOperation.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 03/08/2021.
//

#import "TNWebImageBaseOperation.h"

#import "TNWebImageBaseOperation+Internal.h"


@implementation TNWebImageBaseOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)_informExecuting {
    self.executing = YES;
}

- (void)_informFinished {
    self.finished = YES;
}

@end // @implementation TNWebImageBaseOperation
