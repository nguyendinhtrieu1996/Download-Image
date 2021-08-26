//
//  TNMemoryCache.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 01/08/2021.
//

#import <Foundation/Foundation.h>

#import "SDMemoryCacheConfig.h"
#import "TNCacheTypeProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@protocol TNMemoryCache <TNCacheTypeProtocol>

@required

- (instancetype)initWithConfig:(SDMemoryCacheConfig *)config;

- (void)setObject:(id)object forKey:(TNCacheKey)key cost:(NSUInteger)cost;

@end // @protocol TNMemoryCache


@interface SDMemoryCache : NSCache <TNMemoryCache>

@end // @interface TNMemoryCache

NS_ASSUME_NONNULL_END
