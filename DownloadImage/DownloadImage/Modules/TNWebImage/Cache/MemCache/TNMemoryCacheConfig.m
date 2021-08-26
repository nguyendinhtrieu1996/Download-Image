//
//  TNMemoryCacheConfig.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 01/08/2021.
//

#import "TNMemoryCacheConfig.h"

#import "TNMemoryCache.h"


@implementation TNMemoryCacheConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isEnable = YES;
        _cacheClass = TNMemoryCache.class;
    }
    return self;
}

- (instancetype)initFromOther:(TNMemoryCacheConfig *)other {
    self = [super init];
    if (self) {
        _isEnable = other.isEnable;
        _maxCost = other.maxCost;
        _maxCount = other.maxCount;
        _cacheClass = other.cacheClass;
    }
    return self;
}

+ (TNMemoryCacheConfig *)defaultCacheConfig {
    static TNMemoryCacheConfig *defaultConfig = nil;
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
        defaultConfig = [[self class] new];
    });
    
    return defaultConfig;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    TNMemoryCacheConfig *clone = [[[self class] alloc] initFromOther:self];
    return clone;
}

@end // @implementation TNMemoryCacheConfig
