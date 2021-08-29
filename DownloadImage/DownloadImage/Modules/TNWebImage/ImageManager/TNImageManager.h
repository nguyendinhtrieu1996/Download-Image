//
//  TNImageManager.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 14/08/2021.
//

#import <Foundation/Foundation.h>

#import "TNWebImageLoaderBlock.h"


NS_ASSUME_NONNULL_BEGIN

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


@interface TNImageManager : NSObject <TNImageManagerType>

- (instancetype)initWithImageCache:(id<TNImageCache>)imageCache
                            loader:(id<TNImageDownloaderType>)loader;

@property (nonatomic, readonly, class) TNImageManager *sharedImageManager;

@end // @interface TNImageManager

NS_ASSUME_NONNULL_END
