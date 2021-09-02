//
//  TNImageOperationType.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol TNCancellable <NSObject>

@property (nonatomic, readonly) BOOL isCancelled;

- (void)cancel;

@end // @protocol TNCancellable


@protocol TNImageOperationType <TNCancellable>

@end // @protocol TNImageOperationType


@interface NSOperation (TNImageOperationType)
<
TNImageOperationType
>

@end // @interface NSOperation (TNImageOperationType)


NS_ASSUME_NONNULL_END
