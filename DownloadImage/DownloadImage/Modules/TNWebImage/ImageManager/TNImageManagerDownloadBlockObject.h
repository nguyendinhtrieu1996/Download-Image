//
//  TNImageManagerDownloadBlockObject.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 15/08/2021.
//

#import <UIKit/UIKit.h>

#import "TNImageManagerDefines.h"


NS_ASSUME_NONNULL_BEGIN

@interface TNImageManagerDownloadBlockObject : NSObject <TNImageManagerDownloadBlockObjectType>

- (instancetype)initWithProgress:(nullable TNImageManagerProgressBlock)progressBlock
                      completion:(nullable TNImageManagerCompletionBlock)completionBlock;

@end // @interface TNImageManagerDownloadBlockObject

NS_ASSUME_NONNULL_END
