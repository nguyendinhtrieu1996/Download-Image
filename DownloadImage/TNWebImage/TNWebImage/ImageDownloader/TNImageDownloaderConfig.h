//
//  TNImageDownloaderConfig.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import <Foundation/Foundation.h>

#import "TNImageDownloaderDefines.h"


NS_ASSUME_NONNULL_BEGIN


@interface TNImageDownloaderConfig : NSObject <TNImageDownloaderConfigType>

+ (TNImageDownloaderConfig *)defaultDownloaderConfig;

@end // @interface TNImageDownloaderConfig

NS_ASSUME_NONNULL_END
