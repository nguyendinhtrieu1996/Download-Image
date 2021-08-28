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

typedef TNImageDownloaderProgressBlock TNWebImageDownloadProgressBlock;

typedef void(^TNWebImageDownloadCompletionBlock)(UIImage * _Nullable image,
                                                 NSError * _Nullable error,
                                                 TNImageCacheType cacheType,
                                                 NSURL * _Nullable imageURL);


@protocol TNImageLoaderBlock <NSObject>

@required

@property (nonatomic, nullable) TNWebImageDownloadProgressBlock progressBlock;

@property (nonatomic, nullable) TNWebImageDownloadCompletionBlock completionBlock;

@end // @protocol TNImageLoaderBlock


@interface TNWebImageLoaderBlock : NSObject <TNImageLoaderBlock>

- (instancetype)initWithProgress:(nullable TNWebImageDownloadProgressBlock)progressBlock
                      completion:(nullable TNWebImageDownloadCompletionBlock)completionBlock;

@end // @interface TNWebImageLoaderBlock

NS_ASSUME_NONNULL_END
