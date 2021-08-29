//
//  TNImageManager.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 14/08/2021.
//

#import <Foundation/Foundation.h>

#import "TNImageManagerDefines.h"


NS_ASSUME_NONNULL_BEGIN

@interface TNImageManager : NSObject <TNImageManagerType>

- (instancetype)initWithImageCache:(id<TNImageCache>)imageCache
                            loader:(id<TNImageDownloaderType>)loader;

@property (nonatomic, readonly, class) TNImageManager *sharedImageManager;

@end // @interface TNImageManager

NS_ASSUME_NONNULL_END
