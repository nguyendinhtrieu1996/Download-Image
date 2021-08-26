//
//  TNCacheDefines.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 01/08/2021.
//

#import <UIKit/UIKit.h>

#import "TNWebImageDefines.h"
#import "TNWebImageOperation.h"
#import "TNImageCacheConfig.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Defines

typedef NS_ENUM(NSInteger, TNImageCacheType) {
    TNImageCacheType_None       = 0,
    TNImageCacheType_Memory     = 1,
    TNImageCacheType_Disk       = 2,
    TNImageCacheType_All        = 3,
};


typedef NSString * TNImageCacheKey;

typedef void(^TNImageCacheQueryCompletionBlock)(UIImage * _Nullable image,
                                                NSData * _Nullable data,
                                                TNImageCacheType cacheType);

typedef void(^TNImageCacheContainCompletionBock)(TNImageCacheType cacheType);

typedef void(^TBWebImageCacheCalculateSizeBlock)(long long fileCount, long long totalSize);


#pragma mark - <TNCache>

@protocol TNCache <NSObject>

@required

- (BOOL)containObjectForKey:(TNImageCacheKey)key;

- (nullable id)objectForKey:(TNImageCacheKey)key;

- (void)setObject:(id)object forKey:(TNImageCacheKey)key;

- (void)setObject:(id)object
           forKey:(TNImageCacheKey)key
             cost:(NSUInteger)cost;

- (void)removeObjectForKey:(TNImageCacheKey)key;

- (void)removeAllObjects;

@end // @protocol TNCache


#pragma mark - <TNImageCache>

@protocol TNImageCache <NSObject>

@required

#pragma mark Cache Info

@property (nonatomic, readonly) NSUInteger totalDiskSize;

@property (nonatomic, readonly) NSUInteger totalDiskCount;

- (void)calculateSizeWithCompletionBlock:(nullable TBWebImageCacheCalculateSizeBlock)completionBlock;

#pragma mark LifeCycle

- (instancetype)initWithDirectory:(NSString *)directory;

- (instancetype)initWithDirectory:(NSString *)directory
                           config:(TNImageCacheConfig *)config;

#pragma mark Query Cache

- (nullable id<TNWebImageOperation>)queryImageForKey:(TNImageCacheKey)key
                                          completion:(nullable TNImageCacheQueryCompletionBlock)completionBlock;

- (nullable id<TNWebImageOperation>)queryImageForKey:(TNImageCacheKey)key
                                           cacheType:(TNImageCacheType)cacheType
                                          completion:(nullable TNImageCacheQueryCompletionBlock)completionBlock;

#pragma mark Store Cache

- (nullable id<TNWebImageOperation>)storeImage:(nullable UIImage *)image
                                     imageData:(nullable NSData *)imageData
                                        forKey:(TNImageCacheKey)key
                                     cacheType:(TNImageCacheType)cacheType
                                    completion:(nullable TNWebImageNoParamsBlock)completionBlock;

#pragma mark Remove Cache

- (nullable id<TNWebImageOperation>)removeImageForKey:(TNImageCacheKey)key
                                            cacheType:(TNImageCacheType)cacheType
                                           completion:(nullable TNWebImageNoParamsBlock)completionBlock;

- (nullable id<TNWebImageOperation>)clearWithCacheType:(TNImageCacheType)cacheType
                                            completion:(nullable TNWebImageNoParamsBlock)completionBlock;

#pragma mark Check Cache

- (nullable id<TNWebImageOperation>)containImageForKey:(TNImageCacheKey)key
                                             cacheType:(TNImageCacheType)cacheType
                                            completion:(nullable TNImageCacheContainCompletionBock)completionBlock;

@end // @protocol TNImageCache

NS_ASSUME_NONNULL_END
