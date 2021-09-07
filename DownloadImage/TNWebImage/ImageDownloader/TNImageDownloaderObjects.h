//
//  TNImageDownloaderObjects.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/08/2021.
//

#import <UIKit/UIKit.h>

#import "TNImageDownloaderDefines.h"


NS_ASSUME_NONNULL_BEGIN

@interface TNImageDownloaderProgressObject : NSObject <TNImageDownloaderProgessObjectType>

- (instancetype)initWithExpectedSize:(NSInteger)expectedSize
                        receivedSize:(NSInteger)receivedSize
                           targetURL:(nullable NSURL *)targetURL;

@end // @interface TNImageDownloaderProgressObject


@interface TNImageDownloaderCompleteObject : NSObject <TNImageDownloaderCompleteObjectType>

- (instancetype)initWithImageData:(nullable NSData *)data
                            image:(nullable UIImage *)image
                            error:(nullable NSError *)error
                       isFinished:(BOOL)isFinished;

- (instancetype)initWithImageData:(nullable NSData *)data
                            image:(nullable UIImage *)image
                            error:(nullable NSError *)error
                       isFinished:(BOOL)isFinished
                      isCancelled:(BOOL)isCancelled;

@end // @interface TNImageDownloaderCompleteObject


@interface TNImageDownloaderToken : NSObject <TNImageDownloaderTokenType>

@end // @interface TNWebImageDownloadToken

NS_ASSUME_NONNULL_END
