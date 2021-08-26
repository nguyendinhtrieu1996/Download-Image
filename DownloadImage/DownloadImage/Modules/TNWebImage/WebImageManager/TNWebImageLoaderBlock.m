//
//  TNWebImageLoaderBlock.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 15/08/2021.
//

#import "TNWebImageLoaderBlock.h"

@implementation TNWebImageLoaderBlock

@synthesize progressBlock;
@synthesize completionBlock;

- (instancetype)initWithProgress:(TNWebImageDownloadProgressBlock)progressBlock
                      completion:(TNWebImageDownloadCompletionBlock)completionBlock {
    self = [super init];
    if (self) {
        self.progressBlock = progressBlock;
        self.completionBlock = completionBlock;
    }
    return self;
}

@end // @implementation TNWebImageLoaderBlock
