//
//  TNImageCoder.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 03/07/2021.
//

#import "TNImageCoder.h"

#import "TNInternalMacros.h"
#import "TNImageCoderHelper.h"


#pragma mark - Coder options

TNImageCoderOption const TNImageCoderDecodeScaleFactor = @"TNImageCoderDecodeScaleFactor";

TNImageCoderOption const TNImageCoderDecodeThumnailPixelSize = @"TNImageCoderDecodeThumnailPixelSize";

TNImageCoderOption const TNImageCoderDecodePreserveAspectRatio = @"TNImageCoderDecodePreserveAspectRatio";


#pragma mark - TNWebImageCoder

@implementation TNWebImageCoder

#pragma mark Decoded

- (UIImage *)decodedImageWithData:(NSData *)data
                          options:(TNImageCoderOptions *)options {
    
    ifnot (data) {
        return nil;
    }
    
    CGFloat scale = 1;
    NSNumber *scaleFactor = options[TNImageCoderDecodeScaleFactor];
    if (scaleFactor) {
        scale = MAX(scaleFactor.doubleValue, 1);
    }
    
    CGSize thumbnailSize = CGSizeZero;
    NSValue *thumbNailSizeValue = options[TNImageCoderDecodeThumnailPixelSize];
    if (thumbNailSizeValue) {
        thumbnailSize = thumbNailSizeValue.CGSizeValue;
    }
    
    BOOL preserveAspectRatio = YES;
    NSNumber *preserverAspectRatioValue = options[TNImageCoderDecodePreserveAspectRatio];
    if (preserveAspectRatio) {
        preserveAspectRatio = preserverAspectRatioValue.boolValue;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
    ifnot (source) {
        return nil;
    }
    
    UIImage *image = [self _createImageWithSource:source
                                            scale:scale
                              preserveAspectRatio:preserveAspectRatio
                                    thumbnailSize:thumbnailSize];
    
    CFRelease(source);
    
    return image;
}

#pragma mark Encoded

- (NSData *)encodedDataWithImage:(UIImage *)image
                         options:(TNImageCoderOptions *)options {
    ifnot (image) {
        return nil;
    }
    
    CGImageRef imageRef = image.CGImage;
    ifnot (imageRef) {
        return nil;
    }
    
    TNImageFormat format = TNImageFormatJPEG;
    if ([TNImageCoderHelper CGImageContainsAlpha:imageRef]) {
        format = TNImageFormatPNG;
    }
    
    NSMutableData *imageData = [NSMutableData data];
    CFStringRef imageUTType = [TNImageCoderHelper tn_UTTypeFormImageFormat:format];
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, imageUTType, 1, NULL);
    ifnot (imageDestination) {
        return nil;
    }
    
    NSUInteger pixelWidth = CGImageGetWidth(imageRef);
    NSUInteger pixelHeight = CGImageGetHeight(imageRef);
    CGSize finalPixelSize = CGSizeMake(pixelWidth, pixelHeight);
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    properties[(__bridge NSString *)kCGImageDestinationImageMaxPixelSize] = @(finalPixelSize);
    
    // Add your image to the destination.
    CGImageDestinationAddImage(imageDestination, imageRef, (__bridge CFDictionaryRef)properties);
    
    // Finalize the destination.
    if (CGImageDestinationFinalize(imageDestination) == NO) {
        // Handle failure.
        imageData = nil;
    }
    
    CFRelease(imageDestination);
    
    return [imageData copy];
    
    return nil;
}

#pragma mark - Helper

- (UIImage *)_createImageWithSource:(CGImageSourceRef)source
                              scale:(CGFloat)scale
                preserveAspectRatio:(BOOL)preserveAspectRatio
                      thumbnailSize:(CGSize)thumbnailSize {
    
    NSDictionary *properties = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, 0, nil);
    NSUInteger pixelWidth = [properties[(__bridge NSString *)kCGImagePropertyPixelWidth] unsignedIntegerValue];
    NSUInteger pixelHeight = [properties[(__bridge NSString *)kCGImagePropertyPixelHeight] unsignedIntegerValue];
    
    CGImagePropertyOrientation cgImageOriantation
    = (CGImagePropertyOrientation)[properties[(__bridge NSString *)kCGImagePropertyOrientation] unsignedIntegerValue];
    ifnot (cgImageOriantation) {
        cgImageOriantation = kCGImagePropertyOrientationUp;
    }
    
    CGImageRef imageRef = NULL;
    
    BOOL createFullImage = (thumbnailSize.width == 0
                            || thumbnailSize.height == 0
                            || pixelWidth == 0
                            || pixelHeight == 0
                            || (pixelWidth <= thumbnailSize.width && pixelHeight <= thumbnailSize.height));
    
    if (createFullImage) {
        imageRef = CGImageSourceCreateImageAtIndex(source, 0, nil);
    } else {
        CGFloat maxPixelSize = 0.0;
        
        if (preserveAspectRatio) {
            CGFloat pixelRatio = pixelWidth / pixelHeight;
            CGFloat thumbnailRatio = thumbnailSize.width / thumbnailSize.height;
            if (pixelRatio > thumbnailRatio) {
                maxPixelSize = thumbnailSize.width;
            } else {
                maxPixelSize = thumbnailSize.height;
            }
        } else {
            maxPixelSize = MAX(thumbnailSize.width, thumbnailSize.height);
        }
        
        NSMutableDictionary *decodingOptions = [NSMutableDictionary new];
        decodingOptions[(__bridge NSString *)kCGImageSourceCreateThumbnailWithTransform] = @(preserveAspectRatio);
        decodingOptions[(__bridge NSString *)kCGImageSourceThumbnailMaxPixelSize] = @(maxPixelSize);
        decodingOptions[(__bridge NSString *)kCGImageSourceCreateThumbnailFromImageAlways] = @(YES);
        
        imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)[decodingOptions copy]);
    }
    
    UIImageOrientation imageOrientation = [[self class] _imageOrientationFromCGImageOrientation:cgImageOriantation];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:imageOrientation];
    
    return image;
}

+ (UIImageOrientation)_imageOrientationFromCGImageOrientation:(CGImagePropertyOrientation)cgImageOrientation {
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    switch (cgImageOrientation) {
        case kCGImagePropertyOrientationUp:
            imageOrientation = UIImageOrientationUp;
            break;
        case kCGImagePropertyOrientationDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case kCGImagePropertyOrientationLeft:
            imageOrientation = UIImageOrientationLeft;
            break;
        case kCGImagePropertyOrientationRight:
            imageOrientation = UIImageOrientationRight;
            break;
        case kCGImagePropertyOrientationUpMirrored:
            imageOrientation = UIImageOrientationUpMirrored;
            break;
        case kCGImagePropertyOrientationDownMirrored:
            imageOrientation = UIImageOrientationDownMirrored;
            break;
        case kCGImagePropertyOrientationLeftMirrored:
            imageOrientation = UIImageOrientationLeftMirrored;
            break;
        case kCGImagePropertyOrientationRightMirrored:
            imageOrientation = UIImageOrientationRightMirrored;
            break;
        default:
            break;
    }
    return imageOrientation;
}

@end // @implementation TNWebImageCoder
