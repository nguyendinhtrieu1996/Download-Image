//
//  TNWebImageDownloader.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import <UIKit/UIKit.h>

#import "TNWebImageDefines.h"
#import "TNWebImageOperation.h"
#import "TNWebImageDownloaderConfig.h"


NS_ASSUME_NONNULL_BEGIN


typedef NS_OPTIONS(NSUInteger, TNWebImageDownloaderOptions) {
    TNWebImageDownloader_LowPriotiry            = 1 << 0,
    
    TNWebImageDownloader_UseNSURLCache          = 1 << 1,
    
    TNWebImageDownloader_ContinueInBackground   = 1 << 2,
    
    TNWebImageDownloader_HighPriority           = 1 << 3,
    
    TNWebImageDownloader_ScaleDownLargeImage    = 1 << 4
};


typedef void(^TNWebImageDownloaderProgressBlock)(NSInteger receiveSize, NSInteger expectedSize, NSURL * _Nullable targetURL);
typedef void(^TNWebImageDownloaderCompletionBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finish);


@interface TNWebImageDownloadToken : NSObject <TNWebImageOperation>

@property (nonatomic, readonly, nullable) NSURL *url;
@property (nonatomic, readonly, nullable) NSURLRequest *request;
@property (nonatomic, readonly, nullable) NSURLResponse *response;
@property (nonatomic, nullable) TNImageDownloaderIdentifier *identifier;

@end // @interface TNWebImageDownloadToken


@protocol TNImageDownloader <NSObject>

@required

- (nullable TNWebImageDownloadToken *)downloadImageWithURL:(NSURL *)url
                                                completion:(TNWebImageDownloaderCompletionBlock)completionBlock;

- (nullable TNWebImageDownloadToken *)downloadImageWithURL:(NSURL *)url
                                                   options:(TNWebImageDownloaderOptions)options
                                                   context:(nullable TNWebImageContext *)context
                                             progressBlock:(nullable TNWebImageDownloaderProgressBlock)progressBlock
                                                completion:(TNWebImageDownloaderCompletionBlock)completionBlock;

- (void)cancelALlDownloads;


@end // @protocol TNImageDownloader


@interface TNWebImageDownloader : NSObject <TNImageDownloader>

@property (nonatomic, readonly, copy) TNWebImageDownloaderConfig *config;
@property (nonatomic, readonly) NSURLSessionConfiguration *sesionConfiguration;
@property (nonatomic, readonly, class) TNWebImageDownloader *sharedDownloader;

- (instancetype)initWithConfig:(nullable TNWebImageDownloaderConfig *)conig;

@end // @interface TNWebImageDownloader

NS_ASSUME_NONNULL_END
