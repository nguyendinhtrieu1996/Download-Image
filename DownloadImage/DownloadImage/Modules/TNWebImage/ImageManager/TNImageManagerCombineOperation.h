//
//  TNImageManagerCombineOperation.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 14/08/2021.
//

#import <Foundation/Foundation.h>

#import "TNImageManagerDefines.h"


NS_ASSUME_NONNULL_BEGIN

@interface TNImageManagerCombineOperation : NSOperation <TNImageManagerCombineOperationType>

- (instancetype)initWithCacheOperation:(id<TNImageOperationType>)cacheOperation
                       loaderOperation:(id<TNImageOperationType>)loaderOperation;

@end // @interface TNImageManagerCombineOperation

NS_ASSUME_NONNULL_END
