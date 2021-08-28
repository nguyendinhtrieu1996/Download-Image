//
//  TNWebImageDefines.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^TNWebImageNoParamsBlock)(void);
typedef NSString *TNWebImageContextOption;
typedef NSDictionary<TNWebImageContextOption, id> TNWebImageContext;
typedef NSMutableDictionary<TNWebImageContextOption, id> TNWebImageMutableContext;


typedef NS_OPTIONS(NSUInteger, TNWebImageOptions) {
    // Cache plolicy
    TNWebImage_FromCacheOnly         = 1 << 0,
    TNWebImage_FromLoaderOnly        = 1 << 1,
    
    // Download Policy
    TNWebImage_RetryFailed           = 1 << 2,
    TNWebImage_RefreshURLCached      = 1 << 3,
    TNWebImage_LoaderLowPriority     = 1 << 4,
    TNWebImage_LoaderHighPriority    = 1 << 5,
    TNWebImage_ContinueInBackground  = 1 << 6,
    TNWebImage_ScaleDownLargeImages  = 1 << 7,
};

NS_ASSUME_NONNULL_END
