//
//  TNWebImageDownloaderConfig.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import "TNWebImageDownloaderConfig.h"


static NSUInteger const kDefaultMaxConcurrentDownload = 6;
static NSTimeInterval const kDefaultDownloadTimeout = 15;


@implementation TNWebImageDownloaderConfig

+ (TNWebImageDownloaderConfig *)defaultDownloaderConfig {
    static TNWebImageDownloaderConfig *_defaultDownloaderConfig;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _defaultDownloaderConfig = [TNWebImageDownloaderConfig new];
    });
    
    return _defaultDownloaderConfig;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxConcurrentDownload = kDefaultMaxConcurrentDownload;
        _downloadTimeout = kDefaultDownloadTimeout;
        _executionOrder = TNWebImageDownloaderExecutionOrder_FIFO;
    }
    return self;
}

- (instancetype)_initFromOther:(TNWebImageDownloaderConfig *)other {
    TNWebImageDownloaderConfig *copy = [[[self class] alloc] init];
    
    copy.maxConcurrentDownload = other.maxConcurrentDownload;
    copy.downloadTimeout = other.downloadTimeout;
    copy.sessionConfiguration = [other.sessionConfiguration copy];
    copy.executionOrder = other.executionOrder;
    
    return copy;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] _initFromOther:self];
}

@end // @implementation TNWebImageDownloaderConfig
