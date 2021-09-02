//
//  UIImageView+TNWebImage.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 02/09/2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (TNWebImage)

- (void)tn_loadImageFromURL:(NSURL *)url;

@end // @interface UIImageView (TNWebImage)

NS_ASSUME_NONNULL_END
