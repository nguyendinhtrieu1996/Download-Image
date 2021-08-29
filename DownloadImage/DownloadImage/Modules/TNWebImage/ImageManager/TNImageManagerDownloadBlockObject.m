//
//  TNImageManagerDownloadBlockObject.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 15/08/2021.
//

#import "TNImageManagerDownloadBlockObject.h"

@implementation TNImageManagerDownloadBlockObject

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

@end // @implementation TNImageManagerDownloadBlockObject
