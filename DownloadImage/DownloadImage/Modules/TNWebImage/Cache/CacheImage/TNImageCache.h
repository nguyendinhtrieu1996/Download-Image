//
//  TNImageCache.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 03/08/2021.
//

#import <Foundation/Foundation.h>

#import "TNCacheDefines.h"


NS_ASSUME_NONNULL_BEGIN

@interface TNImageCache : NSObject <TNImageCache>

+ (instancetype)sharedImageCache;

@end // @interface TNImageCache

NS_ASSUME_NONNULL_END
