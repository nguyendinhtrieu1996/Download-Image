//
//  TNWebImageDownloaderConfig.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, TNWebImageDownloaderExecutionOrder) {
    TNWebImageDownloaderExecutionOrder_FIFO,
    TNWebImageDownloaderExecutionOrder_LIFO,
};


@interface TNWebImageDownloaderConfig : NSObject <NSCopying>

@property (nonatomic, class, readonly) TNWebImageDownloaderConfig *defaultDownloaderConfig;

@property (nonatomic) NSUInteger maxConcurrentDownload;
@property (nonatomic) NSTimeInterval downloadTimeout;
@property (nonatomic, nullable) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic) TNWebImageDownloaderExecutionOrder executionOrder;

@end // @interface TNWebImageDownloaderConfig

NS_ASSUME_NONNULL_END
