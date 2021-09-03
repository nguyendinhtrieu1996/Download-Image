//
//  TNImageDownloaderConfig.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import "TNImageDownloaderConfig.h"


static NSUInteger const kDefaultMaxConcurrentDownload = 6;
static NSTimeInterval const kDefaultDownloadTimeout = 15;


@implementation TNImageDownloaderConfig

@synthesize maxConcurrentDownload;
@synthesize downloadTimeout;
@synthesize sessionConfiguration;
@synthesize executionOrder;

+ (TNImageDownloaderConfig *)defaultDownloaderConfig {
    static TNImageDownloaderConfig *_defaultDownloaderConfig;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _defaultDownloaderConfig = [TNImageDownloaderConfig new];
    });
    
    return _defaultDownloaderConfig;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxConcurrentDownload = kDefaultMaxConcurrentDownload;
        self.downloadTimeout = kDefaultDownloadTimeout;
        self.executionOrder = TNImageDownloaderExecutionOrder_FIFO;
    }
    return self;
}

- (instancetype)_initFromOther:(TNImageDownloaderConfig *)other {
    TNImageDownloaderConfig *copy = [[[self class] alloc] init];
    
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
