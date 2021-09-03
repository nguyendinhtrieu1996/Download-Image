//
//  TNImageManageLoaderObject.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 15/08/2021.
//

#import <UIKit/UIKit.h>

#import "TNImageManagerDefines.h"


NS_ASSUME_NONNULL_BEGIN

@interface TNImageManagerDownloaderBlockObject : NSObject <TNImageManagerDownloaderBlockObjectType>

- (instancetype)initWithProgress:(nullable TNImageManagerProgressBlock)progressBlock
                      completion:(nullable TNImageManagerCompletionBlock)completionBlock;

@end // @interface TNImageManagerDownloaderBlockObject


@interface TNImageManagerDownloaderObject : NSObject <TNImageManagerLoaderObjectType>

- (instancetype)initWithURL:(NSURL *)url
                    options:(TNImageOptions)options
                  cacheType:(TNImageCacheType)cacheType
                   blockObj:(nullable id<TNImageManagerDownloaderBlockObjectType>)blockObj;

@end // @interface TNImageManagerDownloaderObject

NS_ASSUME_NONNULL_END
