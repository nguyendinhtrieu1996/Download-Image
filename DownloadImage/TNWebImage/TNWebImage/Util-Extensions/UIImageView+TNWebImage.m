//
//  UIImageView+TNWebImage.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 02/09/2021.
//

#import "UIImageView+TNWebImage.h"

#import "objc/runtime.h"

#import "TNImageManager.h"
#import "TNInternalMacros.h"


@implementation UIImageView (TNWebImage)

- (void)tn_loadImageFromURL:(NSURL *)url {
    [self tn_cancelLoadImage];
    
    TNImageOptions options = TNImage_ContinueInBackground | TNImage_ScaleDownLargeImages;
    
    id<TNCancellable> cancellable =
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
    
    [self _setTN_cancellable:cancellable];
}

- (void)tn_cancelLoadImage {
    id<TNCancellable> cancellable = [self _getTN_cancellable];
    
    @synchronized (self) {
        if (cancellable.isCancelled) {
            return;
        }
        
        [cancellable cancel];
    }
}

- (void)_setTN_cancellable:(id<TNCancellable>)cancellable {
    @synchronized (self) {
        objc_setAssociatedObject(self,
                                 @selector(_getTN_cancellable),
                                 cancellable,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (id<TNCancellable>)_getTN_cancellable {
    @synchronized (self) {
        return objc_getAssociatedObject(self, @selector(_getTN_cancellable));
    }
}

@end // @implementation UIImageView (TNWebImage)
