//
//  TNImageDownloaderOperation.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import "TNImageDownloader.h"
#import "TNImageDefines.h"
#import "TNImageBaseOperation+Internal.h"


NS_ASSUME_NONNULL_BEGIN

@interface TNImageDownloaderOperation: TNImageBaseOperation <TNImageDownloaderOperationType>

- (instancetype)initWithRequest:(NSURLRequest *)request
                      inSession:(NSURLSession *)session
                        options:(TNImageDownloaderOptions)options;

@end // @interface TNImageDownloaderOperation 

NS_ASSUME_NONNULL_END
