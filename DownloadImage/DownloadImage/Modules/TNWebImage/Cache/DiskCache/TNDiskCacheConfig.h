//
//  TNDiskCacheConfig.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 01/08/2021.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TNDiskCacheConfigExpireType) {
    TNDiskCacheConfigExpireType_AccessDate,
    TNDiskCacheConfigExpireType_ModificationDate,
    TNDiskCacheConfigExpireType_CreationDate,
    TNDiskCacheConfigExpireType_ChangeDate,
};


@interface TNDiskCacheConfig : NSObject <NSCopying>

/// Default value is NO
@property (nonatomic) BOOL shouldDisableiCloud;

/// Default value is 7 days in seconds
@property (nonatomic) NSTimeInterval maxDiskAge;

/// Default is zero meaning unlimit in bytes
@property (nonatomic) long long maxDiskSize;

/// Default value is NULL
@property (nonatomic, nullable) NSFileManager *fileManager;

/// Default is NSDataReadingMappedIfSafe
@property (nonatomic) NSDataReadingOptions readingOptions;

/// Default is NSDataWritingAtomic
@property (nonatomic) NSDataWritingOptions writtingOptions;

/// Default is 'TNDiskCacheConfigExpireType_ModificationDate'
@property (nonatomic) TNDiskCacheConfigExpireType expiredType;

/// Default is TNDiskCache
@property (nonatomic, nullable) Class cacheClass;

@property (nonatomic, class, readonly) TNDiskCacheConfig *defaultConfig;

@end // @interface TNDiskCacheConfig

NS_ASSUME_NONNULL_END
