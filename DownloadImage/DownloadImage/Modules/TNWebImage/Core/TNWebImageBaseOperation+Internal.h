//
//  TNWebImageBaseOperation+Internal.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 03/08/2021.
//

#import "TNWebImageBaseOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface TNWebImageBaseOperation ()
{
    @public
    BOOL _executing;
    BOOL _finished;
}

- (void)_informExecuting;

- (void)_informFinished;

@end // @interface TNWebImageBaseOperation ()

NS_ASSUME_NONNULL_END
