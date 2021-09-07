//
//  TNMemoryCacheConfig.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 01/08/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TNMemoryCacheConfig : NSObject <NSCopying>

/// Default value is @YES
@property (nonatomic) BOOL isEnable;

/// Maximum amount of cache objects. Default value is unlimited
@property (nonatomic) long long maxCount;

/// Max memory cost use in bytes. Default value is unlimited
@property (nonatomic) long long maxCost;

/// Default value is TNMemoryCache class
@property (nonatomic, nullable) Class cacheClass;

/// Singleton object will return default config
@property (nonatomic, class, readonly) TNMemoryCacheConfig *defaultCacheConfig;

@end // @interface TNMemoryCacheConfig 

NS_ASSUME_NONNULL_END
