//
//  TNImageCombineOperation.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 14/08/2021.
//

#import <Foundation/Foundation.h>

#import "TNImageManagerDefines.h"


NS_ASSUME_NONNULL_BEGIN

@interface TNImageCombineOperation : NSOperation <TNImageCombineOperationType>

- (instancetype)initWithCacheOperation:(id<TNWebImageOperation>)cacheOperation
                       loaderOperation:(id<TNWebImageOperation>)loaderOperation;

@end // @interface TNImageCombineOperation

NS_ASSUME_NONNULL_END