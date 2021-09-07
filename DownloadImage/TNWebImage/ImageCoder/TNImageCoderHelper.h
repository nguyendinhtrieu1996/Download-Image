//
//  TNImageCoderHelper.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 04/08/2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSInteger TNImageFormat NS_TYPED_EXTENSIBLE_ENUM;
static const TNImageFormat TNImageFormatUndefined = -1;
static const TNImageFormat TNImageFormatJPEG = 0;
static const TNImageFormat TNImageFormatPNG = 1;

@protocol TBWebImageCoderHelper <NSObject>

@required

+ (BOOL)CGImageContainsAlpha:(CGImageRef)cgImage;

+ (CFStringRef)tn_UTTypeFormImageFormat:(TNImageFormat)format;

@end // @protocol TBWebImageCoderHelper


@interface TNImageCoderHelper : NSObject <TBWebImageCoderHelper>

@end // @interface TNImageCoderHelper

NS_ASSUME_NONNULL_END
