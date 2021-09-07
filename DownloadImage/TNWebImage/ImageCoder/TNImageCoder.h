//
//  TNImageCoder.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 03/07/2021.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef NSString * TNImageCoderOption NS_STRING_ENUM;
typedef NSDictionary<TNImageCoderOption, id> TNImageCoderOptions;
typedef NSMutableDictionary<TNImageCoderOption, id> TNImageCoderMutableOptions;


#pragma mark - Coder options

FOUNDATION_EXPORT TNImageCoderOption const TNImageCoderDecodeScaleFactor;

FOUNDATION_EXPORT TNImageCoderOption const TNImageCoderDecodeThumnailPixelSize;

FOUNDATION_EXPORT TNImageCoderOption const TNImageCoderDecodePreserveAspectRatio;


#pragma mark - <TNImageCoder>

@protocol TNImageCoder <NSObject>

- (nullable UIImage *)decodedImageWithData:(NSData *)data
                                   options:(nullable TNImageCoderOptions *)options;

- (nullable NSData *)encodedDataWithImage:(UIImage *)image
                                  options:(nullable TNImageCoderOptions *)options;

@end // @protocol TNImageCoder


#pragma mark - TNWebImageCoder

@interface TNWebImageCoder : NSObject <TNImageCoder>

@end // @interface TNWebImageCoder

NS_ASSUME_NONNULL_END
