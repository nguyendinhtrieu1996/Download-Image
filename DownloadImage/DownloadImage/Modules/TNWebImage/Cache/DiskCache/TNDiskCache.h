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


@protocol TNDiskCache <TNCache>

@required

@property (nonatomic, readonly) long long totalCount;

@property (nonatomic, readonly) long long totalSize;

- (instancetype)initWithCachePath:(NSString *)cachePath
                           config:(TNDiskCacheConfig *)config;

- (void)removeExpiredData;

@end // @protocol TNDiskCache


@interface TNDiskCache : NSObject <TNDiskCache>

@end // @interface TNDiskCache

NS_ASSUME_NONNULL_END
