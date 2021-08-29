//
//  TNWebImageError.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


FOUNDATION_EXPORT NSErrorDomain const TNImageErrorDomain;

typedef NS_ERROR_ENUM(TNImageErrorDomain, TNWebImageError) {
    TNImageError_InvalidURL                          = 1000,
    TNImageError_Cancelled                           = 1001,
    TNImageError_InvalidDownloadOperation            = 1002,
    TNImageError_BlackListed                         = 1003,
};


NS_ASSUME_NONNULL_END
