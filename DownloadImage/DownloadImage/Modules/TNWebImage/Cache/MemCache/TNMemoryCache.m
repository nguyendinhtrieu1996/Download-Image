//
//  TNMemoryCache.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 01/08/2021.
//

#import "TNMemoryCache.h"

#import <UIKit/UIKit.h>


@interface TNMemoryCache ()
{
    TNMemoryCacheConfig *_config;
}

@end // @interface TNMemoryCache ()


@implementation TNMemoryCache

#pragma mark LifeCycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _config = [TNMemoryCacheConfig defaultCacheConfig];
    }
    return self;
}

- (instancetype)initWithConfig:(TNMemoryCacheConfig *)config {
    self = [super init];
    if (self) {
        _config = config;
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    TNMemoryCacheConfig *config = _config;
    self.totalCostLimit = config.maxCost;
    self.countLimit = config.maxCount;
    
    [NSNotificationCenter.defaultCenter
     addObserver:self
     selector:@selector(_didReceiveMemoryWarning:)
     name:UIApplicationDidReceiveMemoryWarningNotification
     object:nil];
}

#pragma mark Update Cache

- (void)setObject:(id)obj forKey:(id)key {
    [super setObject:obj forKey:key];
}

- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)cost {
    [super setObject:obj forKey:key cost:cost];
}

- (void)removeObjectForKey:(id)key {
    [super removeObjectForKey:key];
}

- (void)removeAllObjects {
    [super removeAllObjects];
}

#pragma mark Check Cache

- (nullable id)objectForKey:(TNImageCacheKey)key {
    return [super objectForKey:key];
}

- (BOOL)containObjectForKey:(nonnull TNImageCacheKey)key {
    return ([self objectForKey:key] != nil);
}

#pragma mark Helper Methods

- (void)_didReceiveMemoryWarning:(NSNotification *)notification {
    [self removeAllObjects];
}

@end // @implementation TNMemoryCache
