//
//  TNWebImageLoaderBlock.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 15/08/2021.
//

#import <UIKit/UIKit.h>

#import "TNCacheDefines.h"
#import "TNWebImageDefines.h"
#import "TNImageDownloader.h"


NS_ASSUME_NONNULL_BEGIN

typedef TNImageDownloaderProgressBlock TNImageManagerProgressBlock;

typedef void(^TNImageManagerCompletionBlock)(UIImage * _Nullable image,
                                             NSError * _Nullable error,
                                             TNImageCacheType cacheType,
                                             NSURL * _Nullable imageURL);


@protocol TNImageLoaderBlockObjectType <NSObject>

@required

@property (nonatomic, nullable) TNImageManagerProgressBlock progressBlock;

@property (nonatomic, nullable) TNImageManagerCompletionBlock completionBlock;

@end // @protocol TNImageLoaderBlockObjectType


@interface TNWebImageLoaderBlock : NSObject <TNImageLoaderBlockObjectType>

- (instancetype)initWithProgress:(nullable TNImageManagerProgressBlock)progressBlock
                      completion:(nullable TNImageManagerCompletionBlock)completionBlock;

@end // @interface TNWebImageLoaderBlock

NS_ASSUME_NONNULL_END
