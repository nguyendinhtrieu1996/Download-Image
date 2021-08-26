//
//  TNWebImageDownloaderOperation.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import "TNWebImageDownloader.h"
#import "TNWebImageDefines.h"
#import "TNWebImageBaseOperation+Internal.h"


NS_ASSUME_NONNULL_BEGIN

@protocol TNWebImageDownloaderOperationProtocol
<
NSURLSessionTaskDelegate
, NSURLSessionDataDelegate
>

@property (nonatomic, readonly, nullable) NSURLRequest *request;
@property (nonatomic, readonly, nullable) NSURLResponse *response;
@property (nonatomic, readonly, nullable) NSURLSession *session;
@property (nonatomic, readonly, nullable) NSURLSessionDataTask *dataTask;

@property (nonatomic) double mininumProgressInterval;
@property (nonatomic) TNWebImageDownloaderOptions options;
@property (nonatomic, nullable) TNWebImageContext *context;

- (instancetype)initWithRequest:(nullable NSURLRequest *)request
                      inSession:(nullable NSURLSession *)session
                        options:(TNWebImageDownloaderOptions)options;

- (instancetype)initWithRequest:(nullable NSURLRequest *)request
                      inSession:(nullable NSURLSession *)session
                        options:(TNWebImageDownloaderOptions)options
                        context:(nullable TNWebImageContext *)context;

- (TNImageDownloaderIdentifier *)addHandlerForProgress:(nullable TNWebImageDownloaderProgressBlock)progressBlock
                                            completion:(nullable TNWebImageDownloaderCompletionBlock)completionBlock;

- (BOOL)cancel:(TNImageDownloaderIdentifier *)identifier;

@end // @protocol TNWebImageDownloaderOperationProtocol


@interface TNWebImageDownloaderOperation: TNWebImageBaseOperation <TNWebImageDownloaderOperationProtocol>

@end // @interface TNWebImageDownloaderOperation 

NS_ASSUME_NONNULL_END
