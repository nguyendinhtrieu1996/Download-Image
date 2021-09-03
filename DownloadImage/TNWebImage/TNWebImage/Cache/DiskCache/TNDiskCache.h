//
//  TNDiskCache.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 01/08/2021.
//

#import <Foundation/Foundation.h>

#import "TNCacheDefines.h"
#import "TNDiskCacheConfig.h"


NS_ASSUME_NONNULL_BEGIN


@protocol TNDiskCacheType <TNCacheType>

@required

@property (nonatomic, readonly) long long totalCount;

@property (nonatomic, readonly) long long totalSize;

- (void)removeExpiredData;

@end // @protocol TNDiskCacheType


@interface TNDiskCache : NSObject <TNDiskCacheType>

- (instancetype)initWithCachePath:(NSString *)cachePath
                           config:(TNDiskCacheConfig *)config;

@end // @interface TNDiskCache

NS_ASSUME_NONNULL_END
