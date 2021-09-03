//
//  TNImageCacheConfig.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 03/08/2021.
//

#import "TNImageCacheConfig.h"

@implementation TNImageCacheConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _memoryCacheConfig = TNMemoryCacheConfig.defaultCacheConfig;
        _diskCacheConfig = TNDiskCacheConfig.defaultConfig;
    }
    return self;
}

- (instancetype)initFromOther:(TNImageCacheConfig *)other {
    self = [super init];
    
    if (self) {
        _memoryCacheConfig = [other.memoryCacheConfig copy];
        _diskCacheConfig = [other.diskCacheConfig copy];
    }
    
    return self;
}

+ (TNImageCacheConfig *)defaultCacheConfig {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    TNImageCacheConfig *clone = [[[self class] alloc] initFromOther:self];
    return clone;
}

@end // @implementation TNImageCacheConfig
