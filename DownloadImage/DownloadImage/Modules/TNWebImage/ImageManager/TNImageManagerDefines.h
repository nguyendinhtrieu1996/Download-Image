//
//  TNImageManagerDefines.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 29/08/2021.
//

#import <UIKit/UIKit.h>

#import "TNCacheDefines.h"
#import "TNWebImageDefines.h"
#import "TNWebImageOperation.h"
#import "TNImageDownloaderDefines.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark - TNImageCombineOperationType

@protocol TNImageCombineOperationType <TNWebImageOperation>

@property (nonatomic, nullable) id<TNWebImageOperation> cacheOperation;

@property (nonatomic, nullable) id<TNWebImageOperation> loaderOperation;

@end // @protocol TNImageCombineOperationType


#pragma mark - TNImageLoaderBlockObjectType

typedef void(^TNImageManagerProgressBlock)(NSUInteger expectSize,
                                           NSUInteger receivedSize,
                                           NSURL * _Nullable targetURL);

typedef void(^TNImageManagerCompletionBlock)(UIImage * _Nullable image,
                                             NSError * _Nullable error,
                                             TNImageCacheType cacheType,
                                             NSURL * _Nullable imageURL);


@protocol TNImageManagerDownloadBlockObjectType <NSObject>

@required

@property (nonatomic, nullable) TNImageManagerProgressBlock progressBlock;

@property (nonatomic, nullable) TNImageManagerCompletionBlock completionBlock;

@end // @protocol TNImageManagerDownloadBlockObjectType


#pragma mark - TNImageManagerType

@protocol TNImageManagerType <NSObject>

@required

- (nullable id<TNWebImageOperation>)loadImageWithURL:(NSURL *)url
                                             options:(TNWebImageOptions)options
                                            progress:(nullable TNImageManagerProgressBlock)progressBlock
                                          completion:(nullable TNImageManagerCompletionBlock)completionBlock;

- (void)cancelAll;

- (void)removeFailedURL:(NSURL *)url;

- (void)removeAllFailedURLs;

@end // @protocol TNImageManagerType

NS_ASSUME_NONNULL_END