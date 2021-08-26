//
//  TNWebImageError.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


FOUNDATION_EXPORT NSErrorDomain const TNWebImageErrorDomain;

typedef NS_ERROR_ENUM(TNWebImageErrorDomain, TNWebImageError) {
    TNWebImageError_InavlidURL                          = 1000,
    TNWebImageError_Cancelled                           = 1001,
    TNWebImageError_InvalidDownloadOperation            = 1002,
    TNWebImageError_BlackListed                         = 1003,
};


NS_ASSUME_NONNULL_END
