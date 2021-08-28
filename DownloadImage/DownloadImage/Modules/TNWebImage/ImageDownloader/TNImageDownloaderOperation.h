//
//  TNImageDownloaderOperation.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import "TNImageDownloader.h"
#import "TNWebImageDefines.h"
#import "TNWebImageBaseOperation+Internal.h"


NS_ASSUME_NONNULL_BEGIN

@interface TNImageDownloaderOperation: TNWebImageBaseOperation <TNImageDownloaderOperationType>

- (instancetype)initWithRequest:(NSURLRequest *)request
                      inSession:(NSURLSession *)session
                        options:(TNImageDownloaderOptions)options;

@end // @interface TNImageDownloaderOperation 

NS_ASSUME_NONNULL_END
