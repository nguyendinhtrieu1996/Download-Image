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

@protocol TNMemoryCache <TNCache>

@required

- (instancetype)initWithConfig:(TNMemoryCacheConfig *)config;

@end // @protocol TNMemoryCache


@interface TNMemoryCache : NSCache <TNMemoryCache>

@end // @interface TNMemoryCache

NS_ASSUME_NONNULL_END
