//
//  TNWebImageManager.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 14/08/2021.
//

#import <Foundation/Foundation.h>

#import "TNWebImageLoaderBlock.h"


NS_ASSUME_NONNULL_BEGIN

@protocol TNWebImageManagerProtocol <NSObject>

@required

- (nullable id<TNWebImageOperation>)loadImageWithURL:(NSURL *)url
                                             options:(TNWebImageOptions)options
                                            progress:(nullable TNWebImageDownloadProgressBlock)progressBlock
                                          completion:(nullable TNWebImageDownloadCompletionBlock)completionBlock;

- (void)cancelAll;

- (void)removeFailedURL:(NSURL *)url;

- (void)removeAllFailedURLs;

@end // @protocol TNWebImageManagerProtocol


@interface TNWebImageManager : NSObject <TNWebImageManagerProtocol>

- (instancetype)initWithImageCache:(id<TNImageCache>)imageCache
                            loader:(id<TNImageDownloader>)loader;

+ (instancetype)defaultWebImageDownloader;

@end // @interface TNWebImageManager

NS_ASSUME_NONNULL_END
