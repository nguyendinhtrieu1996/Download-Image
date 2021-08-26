//
//  TNWebImageCombineOperation.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 14/08/2021.
//

#import <Foundation/Foundation.h>

#import "TNWebImageOperation.h"


NS_ASSUME_NONNULL_BEGIN

@interface TNWebImageCombineOperation : NSOperation <TNWebImageOperation>

@property (nonatomic, nullable) id<TNWebImageOperation> cacheOperation;

@property (nonatomic, nullable) id<TNWebImageOperation> loaderOperation;

@end // @interface TNWebImageCombineOperation

NS_ASSUME_NONNULL_END
