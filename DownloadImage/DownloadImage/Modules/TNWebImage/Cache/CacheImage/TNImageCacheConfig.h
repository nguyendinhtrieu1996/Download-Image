//
//  TNImageCacheConfig.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 03/08/2021.
//

#import <Foundation/Foundation.h>

#import "TNDiskCacheConfig.h"
#import "TNMemoryCacheConfig.h"


NS_ASSUME_NONNULL_BEGIN

@interface TNImageCacheConfig : NSObject <NSCopying>

@property (nonatomic) TNMemoryCacheConfig *memoryCacheConfig;

@property (nonatomic) TNDiskCacheConfig *diskCacheConfig;

@property (nonatomic, class, readonly) TNImageCacheConfig *defaultCacheConfig;

@end // @interface TNImageCacheConfig

NS_ASSUME_NONNULL_END
