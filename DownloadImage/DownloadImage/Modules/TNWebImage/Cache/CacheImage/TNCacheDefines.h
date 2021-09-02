//
//  TNCacheDefines.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 01/08/2021.
//

#import <UIKit/UIKit.h>

#import "TNImageDefines.h"
#import "TNImageOperationType.h"
#import "TNImageCacheConfig.h"


@protocol TNCacheQueryResponseType;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Defines

typedef NS_ENUM(NSInteger, TNImageCacheType) {
    TNImageCacheType_None       = 0,
    TNImageCacheType_Memory     = 1,
    TNImageCacheType_Disk       = 2,
    TNImageCacheType_All        = 3,
};


typedef NSString * TNImageCacheKey;

typedef void(^TNImageCacheQueryCompletionBlock)(id<TNCacheQueryResponseType> cacheQueryResponse);

typedef void(^TNImageCacheContainCompletionBock)(TNImageCacheType cacheType);

typedef void(^TBWebImageCacheCalculateSizeBlock)(long long fileCount, long long totalSize);


#pragma mark - <TNCacheQueryResponseType>

@protocol TNCacheQueryResponseType <NSObject>

@property (nonatomic, readonly, nullable) UIImage *image;

@property (nonatomic, readonly, nullable) NSData *data;

@property (nonatomic, readonly) TNImageCacheType cacheType;

@end // @protocol TNCacheQueryResponse


#pragma mark - <TNCacheType>

@protocol TNCacheType <NSObject>

@required

- (BOOL)containObjectForKey:(TNImageCacheKey)key;

- (nullable id)objectForKey:(TNImageCacheKey)key;

- (void)setObject:(id)object forKey:(TNImageCacheKey)key;

- (void)setObject:(id)object
           forKey:(TNImageCacheKey)key
             cost:(NSUInteger)cost;

- (void)removeObjectForKey:(TNImageCacheKey)key;

- (void)removeAllObjects;

@end // @protocol TNCacheType


#pragma mark - <TNImageCacheType>

@protocol TNImageCacheType <NSObject>

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

- (nullable id<TNImageOperationType>)queryImageForKey:(TNImageCacheKey)key
                                           completion:(nullable TNImageCacheQueryCompletionBlock)completionBlock;

- (nullable id<TNImageOperationType>)queryImageForKey:(TNImageCacheKey)key
                                            cacheType:(TNImageCacheType)cacheType
                                           completion:(nullable TNImageCacheQueryCompletionBlock)completionBlock;

#pragma mark Store Cache

- (nullable id<TNImageOperationType>)storeImage:(nullable UIImage *)image
                                      imageData:(nullable NSData *)imageData
                                         forKey:(TNImageCacheKey)key
                                      cacheType:(TNImageCacheType)cacheType
                                     completion:(nullable TNImageNoParamsBlock)completionBlock;

#pragma mark Remove Cache

- (nullable id<TNImageOperationType>)removeImageForKey:(TNImageCacheKey)key
                                             cacheType:(TNImageCacheType)cacheType
                                            completion:(nullable TNImageNoParamsBlock)completionBlock;

- (nullable id<TNImageOperationType>)clearWithCacheType:(TNImageCacheType)cacheType
                                             completion:(nullable TNImageNoParamsBlock)completionBlock;

#pragma mark Check Cache

- (nullable id<TNImageOperationType>)containImageForKey:(TNImageCacheKey)key
                                              cacheType:(TNImageCacheType)cacheType
                                             completion:(nullable TNImageCacheContainCompletionBock)completionBlock;

@end // @protocol TNImageCacheType

NS_ASSUME_NONNULL_END
