//
//  TNImageCoderHelper.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 04/08/2021.
//

#import "TNImageCoderHelper.h"

#import "TNInternalMacros.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation TNImageCoderHelper

+ (BOOL)CGImageContainsAlpha:(CGImageRef)cgImage {
    ifnot (cgImage) {
        return NO;
    }
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}

+ (CFStringRef)tn_UTTypeFormImageFormat:(TNImageFormat)format {
    switch (format) {
        case TNImageFormatJPEG:
            return kUTTypeJPEG;
        case TNImageFormatPNG:
            return kUTTypePNG;
        default:
            return kUTTypeJPEG;
    }
}

@end // @implementation TNImageCoderHelper
