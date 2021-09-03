//
//  TNMemoryCache.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 01/08/2021.
//

#import <Foundation/Foundation.h>

#import "TNCacheDefines.h"
#import "TNMemoryCacheConfig.h"


NS_ASSUME_NONNULL_BEGIN

@protocol TNMemoryCacheType <TNCacheType>

@end // @protocol TNCacheType


@interface TNMemoryCache : NSCache <TNMemoryCacheType>

- (instancetype)initWithConfig:(TNMemoryCacheConfig *)config;

@end // @interface TNMemoryCache

NS_ASSUME_NONNULL_END
