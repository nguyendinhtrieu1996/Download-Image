//
//  TNImageDownloaderObjects.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/08/2021.
//

#import "TNImageDownloaderObjects.h"


@implementation TNImageDownloaderProgressObject

@dynamic expectedSize;
@dynamic receiveSize;
@dynamic targetURL;

- (instancetype)initWithExpectedSize:(NSInteger)expectedSize
                        receivedSize:(NSInteger)receivedSize
                           targetURL:(NSURL *)targetURL {
    self = [super init];
    if (self) {
        self.expectedSize = expectedSize;
        self.receiveSize = receivedSize;
        self.targetURL = targetURL;
    }
    return self;
}

@end // @implementation TNImageDonwloaderProgressObject


@implementation TNImageDownloaderCompleteObject

@dynamic data;
@dynamic image;
@dynamic error;
@dynamic isFinished;

- (instancetype)initWithImageData:(NSData *)data
                            image:(UIImage *)image
                            error:(NSError *)error
                       isFinished:(BOOL)isFinished {
    
    self = [super init];
    if (self) {
        self.data = data;
        self.image = image;
        self.error = error;
        self.isFinished = isFinished;
    }
    return self;
}

@end // @implementation TNImageDownloaderCompleteObject


@interface TNImageDownloadToken ()

@property (nonatomic, getter=isCancelled) BOOL cancelled;

@end // @interface TNImageDownloadToken ()


@implementation TNImageDownloadToken

@dynamic url;
@dynamic request;
@dynamic response;
@dynamic identifier;
@dynamic downloadOperation;

- (void)cancel {
    @synchronized (self) {
        if (self.isCancelled) {
            return;
        }
        
        self.cancelled = YES;
        [self.downloadOperation cancel:self.identifier];
    }
}

@end // @implementation TNImageDownloadToken
