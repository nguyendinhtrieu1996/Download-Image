//
//  TNImageBaseOperation+Internal.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 03/08/2021.
//

#import "TNImageBaseOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface TNImageBaseOperation ()
{
    @public
    BOOL _executing;
    BOOL _finished;
}

- (void)_informExecuting;

- (void)_informFinished;

@end // @interface TNImageBaseOperation ()

NS_ASSUME_NONNULL_END
