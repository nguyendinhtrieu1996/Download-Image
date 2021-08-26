//
//  TNDiskCacheConfig.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 01/08/2021.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface TNDiskCacheConfig : NSObject <NSCopying>

/// Default @NO
@property (nonatomic) BOOL shouldDisableiCloud;

@property (nonatomic) NSTimeInterval maxDiskAge;

/// In Bytes
@property (nonatomic) long long maxDiskSize;

@property (nonatomic, nullable) Class cacheClass;

@property (nonatomic, class, readonly) TNDiskCacheConfig *defaultConfig;

@end // @interface TNDiskCacheConfig

NS_ASSUME_NONNULL_END
