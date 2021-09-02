//
//  UIImageView+TNWebImage.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 02/09/2021.
//

#import "UIImageView+TNWebImage.h"

#import "TNImageManager.h"
#import "TNInternalMacros.h"


@implementation UIImageView (TNWebImage)

- (void)tn_loadImageFromURL:(NSURL *)url {
    TNImageOptions options = TNImage_ContinueInBackground | TNImage_ScaleDownLargeImages;
    
    [TNImageManager.sharedImageManager
     loadImageWithURL:url
     options:options
     cacheType:TNImageCacheType_All
     progress:^(NSUInteger expectSize,
                NSUInteger receivedSize,
                NSURL * _Nullable targetURL) {
        
        double progress = (double)receivedSize / (double)expectSize;
        NSLog(@"url: %@ - progress: %f", targetURL.absoluteString, progress);
    }
     completion:^(UIImage * _Nullable image,
                  NSError * _Nullable error,
                  TNImageCacheType cacheType,
                  NSURL * _Nullable imageURL) {
        
        NSLog(@"url: %@ - finished with error: %@", imageURL.absoluteString, error.localizedDescription);
        
        WEAKSELF
        dispatch_async(dispatch_get_main_queue(), ^{
            STRONGSELF_RETURN()
            self.image = image;
        });
        
    }];
}

@end // @implementation UIImageView (TNWebImage)
