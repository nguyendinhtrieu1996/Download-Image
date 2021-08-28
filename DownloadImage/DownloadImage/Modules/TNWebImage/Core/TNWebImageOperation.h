//
//  TNWebImageOperation.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol TNCancellable <NSObject>

- (void)cancel;

@end // @protocol TNCancellable


@protocol TNWebImageOperation <TNCancellable>

@end // @protocol TNWebImageOperation


@interface NSOperation (TNWebImageOperation)
<
TNWebImageOperation
>

@end // @interface NSOperation (TNWebImageOperation)


NS_ASSUME_NONNULL_END
