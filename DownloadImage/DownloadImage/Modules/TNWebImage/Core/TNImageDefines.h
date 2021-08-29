//
//  TNImageDefines.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^TNImageNoParamsBlock)(void);
typedef NSString *TNImageContextOption;
typedef NSDictionary<TNImageContextOption, id> TNImageContext;
typedef NSMutableDictionary<TNImageContextOption, id> TNImageMutableContext;


typedef NS_OPTIONS(NSUInteger, TNImageOptions) {
    // Cache plolicy
    TNImage_FromCacheOnly         = 1 << 0,
    TNImage_FromLoaderOnly        = 1 << 1,
    
    // Download Policy
    TNImage_RetryFailed           = 1 << 2,
    TNImage_RefreshURLCached      = 1 << 3,
    TNImage_LoaderLowPriority     = 1 << 4,
    TNImage_LoaderHighPriority    = 1 << 5,
    TNImage_ContinueInBackground  = 1 << 6,
    TNImage_ScaleDownLargeImages  = 1 << 7,
};

NS_ASSUME_NONNULL_END
