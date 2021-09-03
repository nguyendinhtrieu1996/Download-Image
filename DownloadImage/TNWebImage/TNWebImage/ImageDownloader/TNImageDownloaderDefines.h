//
//  TNImageDownloaderDefines.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/08/2021.
//

#import <UIKit/UIKit.h>

#import "TNImageDefines.h"
#import "TNImageOperationType.h"


NS_ASSUME_NONNULL_BEGIN

@protocol TNImageDownloaderProgessObjectType;
@protocol TNImageDownloaderCompleteObjectType;


#pragma mark Defines

typedef NS_OPTIONS(NSUInteger, TNImageDownloaderOptions) {
    TNImageDownloader_LowPriotiry            = 1 << 0,
    
    TNImageDownloader_HighPriority           = 1 << 1,
    
    TNImageDownloader_UseNSURLCache          = 1 << 2,
    
    TNImageDownloader_ContinueInBackground   = 1 << 3,
    
    TNImageDownloader_ScaleDownLargeImage    = 1 << 4
};

typedef NS_ENUM(NSInteger, TNImageDownloaderExecutionOrder) {
    TNImageDownloaderExecutionOrder_FIFO,
    TNImageDownloaderExecutionOrder_LIFO,
};


typedef NSString * TNImageDownloaderIdentifier;

typedef void(^TNImageDownloaderProgressBlock)(id<TNImageDownloaderProgessObjectType> progressObj);
typedef void(^TNImageDownloaderCompletionBlock)(id<TNImageDownloaderCompleteObjectType> completionObj);


#pragma mark Objects

@protocol TNImageDownloaderProgessObjectType <NSObject>

@required

@property (nonatomic) NSInteger expectedSize;

@property (nonatomic) NSInteger receiveSize;

@property (nonatomic, nullable) NSURL *targetURL;

@end // @protocol TNImageDownloaderProgessObjectType


@protocol TNImageDownloaderCompleteObjectType <NSObject>

@required

@property (nonatomic, nullable) NSData *data;

@property (nonatomic, nullable) UIImage *image;

@property (nonatomic, nullable) NSError *error;

@property (nonatomic) BOOL isFinished;

@property (nonatomic) BOOL isCancelled;

@end // @protocol TNImageDownloaderCompletionObject


#pragma mark Operation

@protocol TNImageDownloaderOperationType
<
NSURLSessionTaskDelegate
, NSURLSessionDataDelegate
, TNImageOperationType
>

@property (nonatomic, nullable) NSURLRequest *request;
@property (nonatomic, nullable) NSURLResponse *response;
@property (nonatomic, nullable) NSURLSession *session;
@property (nonatomic, nullable) NSURLSessionDataTask *dataTask;

@property (nonatomic) double mininumProgressInterval;
@property (nonatomic) TNImageDownloaderOptions options;

- (TNImageDownloaderIdentifier)addHandlerForProgress:(nullable TNImageDownloaderProgressBlock)progressBlock
                                          completion:(nullable TNImageDownloaderCompletionBlock)completionBlock;

- (BOOL)cancel:(TNImageDownloaderIdentifier)identifier;

@end // @protocol TNWebImageDownloaderOperationProtocol


#pragma mark Download Token

@protocol TNImageDownloaderTokenType <TNImageOperationType>

@required

@property (nonatomic, nullable) NSURL *url;
@property (nonatomic, nullable) NSURLRequest *request;
@property (nonatomic, nullable) NSURLResponse *response;
@property (nonatomic, nullable) TNImageDownloaderIdentifier identifier;
@property (nonatomic, weak) NSOperation<TNImageDownloaderOperationType> *downloadOperation;

@end // @protocol TNImageDownloaderTokenType


#pragma mark Config

@protocol  TNImageDownloaderConfigType <NSObject, NSCopying>

@required

@property (nonatomic) NSUInteger maxConcurrentDownload;
@property (nonatomic) NSTimeInterval downloadTimeout;
@property (nonatomic, nullable) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic) TNImageDownloaderExecutionOrder executionOrder;

@end // @interface TNImageDownloaderConfigType


#pragma mark Downloader

@protocol TNImageDownloaderType <NSObject>

@required

- (nullable id<TNImageDownloaderTokenType>)downloadImageWithURL:(NSURL *)url
                                                   completion:(TNImageDownloaderCompletionBlock)completionBlock;

- (nullable id<TNImageDownloaderTokenType>)downloadImageWithURL:(NSURL *)url
                                                      options:(TNImageDownloaderOptions)options
                                                progressBlock:(nullable TNImageDownloaderProgressBlock)progressBlock
                                                   completion:(nullable TNImageDownloaderCompletionBlock)completionBlock;

- (void)cancelAllDownloads;

@end // @protocol TNImageDownloader

NS_ASSUME_NONNULL_END
