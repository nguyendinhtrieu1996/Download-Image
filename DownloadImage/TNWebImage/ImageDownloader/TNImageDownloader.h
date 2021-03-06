//
//  TNImageDownloader.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import <UIKit/UIKit.h>

#import "TNImageDefines.h"
#import "TNImageOperationType.h"
#import "TNImageDownloaderConfig.h"
#import "TNImageDownloaderDefines.h"


NS_ASSUME_NONNULL_BEGIN


@interface TNImageDownloader : NSObject <TNImageDownloaderType>

@property (nonatomic, readonly, class) TNImageDownloader *sharedDownloader;

- (instancetype)initWithConfig:(nullable TNImageDownloaderConfig *)conig;

@end // @interface TNImageDownloader

NS_ASSUME_NONNULL_END
