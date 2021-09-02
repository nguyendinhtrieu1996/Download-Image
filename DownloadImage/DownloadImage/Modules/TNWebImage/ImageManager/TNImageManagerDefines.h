//
//  TNImageManagerDefines.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 29/08/2021.
//

#import <UIKit/UIKit.h>

#import "TNCacheDefines.h"
#import "TNImageDefines.h"
#import "TNImageOperationType.h"
#import "TNImageDownloaderDefines.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Combine Operation

@protocol TNImageCombineOperationType <TNImageOperationType>

@property (nonatomic, nullable) id<TNImageOperationType> cacheOperation;

@property (nonatomic, nullable) id<TNImageOperationType> downloaderOperation;

@end // @protocol TNImageCombineOperationType


#pragma mark - Downloader Block

typedef void(^TNImageManagerProgressBlock)(NSUInteger expectSize,
                                           NSUInteger receivedSize,
                                           NSURL * _Nullable targetURL);

typedef void(^TNImageManagerCompletionBlock)(UIImage * _Nullable image,
                                             NSError * _Nullable error,
                                             TNImageCacheType cacheType,
                                             NSURL * _Nullable imageURL);


@protocol TNImageManagerDownloaderBlockObjectType <NSObject>

@required

@property (nonatomic, nullable) TNImageManagerProgressBlock progressBlock;

@property (nonatomic, nullable) TNImageManagerCompletionBlock completionBlock;

@end // @protocol TNImageManagerDownloadBlockObjectType


#pragma mark - Loader Object

@protocol TNImageManagerLoaderObjectType <TNCancellable>

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) TNImageOptions options;
@property (nonatomic, readonly) TNImageCacheType cacheType;
@property (nonatomic, readonly) id<TNImageCombineOperationType> combineOperation;
@property (nonatomic, readonly) id<TNImageManagerDownloaderBlockObjectType> blockObject;

- (void)updateCacheOperation:(id<TNImageOperationType>)cacheOperation;

- (void)updateDownloaderOperation:(id<TNImageOperationType>)downloaderOperation;

@end // @protocol TNImageManagerLoaderObjectType


#pragma mark - Image Manager

@protocol TNImageManagerType <NSObject>

@required

- (id<TNCancellable>)loadImageWithURL:(NSURL *)url
                              options:(TNImageOptions)options
                            cacheType:(TNImageCacheType)cacheType
                             progress:(nullable TNImageManagerProgressBlock)progressBlock
                           completion:(nullable TNImageManagerCompletionBlock)completionBlock;

- (void)cancelAll;

- (void)removeFailedURL:(NSURL *)url;

- (void)removeAllFailedURLs;

@end // @protocol TNImageManagerType

NS_ASSUME_NONNULL_END
