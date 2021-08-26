//
//  TNDiskCacheConfig.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 01/08/2021.
//

#import "TNDiskCacheConfig.h"

#import "TNDiskCache.h"


static int const _kOneWeekInSeconds = 7 * 24 * 60 * 60;


@implementation TNDiskCacheConfig

+ (TNDiskCacheConfig *)defaultConfig {
    static TNDiskCacheConfig *config = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        config = [[self class] new];
    });
    
    return config;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shouldDisableiCloud = NO;
        _maxDiskAge = _kOneWeekInSeconds;
        _maxDiskSize = 0;
        _readingOptions = NSDataReadingMappedIfSafe;
        _writtingOptions = NSDataWritingAtomic;
        _expiredType = TNDiskCacheConfigExpireType_ModificationDate;
        _cacheClass = TNDiskCache.class;
    }
    return self;
}

- (instancetype)initFromOther:(TNDiskCacheConfig *)other {
    self = [super init];
    if (self) {
        _shouldDisableiCloud = other.shouldDisableiCloud;
        _maxDiskAge = other.maxDiskAge;
        _maxDiskSize = other.maxDiskSize;
        _fileManager = other.fileManager;
        _readingOptions = other.readingOptions;
        _writtingOptions = other.writtingOptions;
        _expiredType = other.expiredType;
        _cacheClass = other.cacheClass;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    TNDiskCacheConfig *clone = [[[self class] alloc] initFromOther:self];
    return clone;
}

@end // @implementation TNDiskCacheConfig
