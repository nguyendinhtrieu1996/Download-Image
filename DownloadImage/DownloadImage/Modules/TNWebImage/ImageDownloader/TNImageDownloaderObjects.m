//
//  TNImageDownloaderObjects.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/08/2021.
//

#import "TNImageDownloaderObjects.h"


@implementation TNImageDownloaderProgressObject

@synthesize expectedSize;
@synthesize receiveSize;
@synthesize targetURL;

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

@synthesize data;
@synthesize image;
@synthesize error;
@synthesize isFinished;
@synthesize isCancelled;

- (instancetype)initWithImageData:(NSData *)data
                            image:(UIImage *)image
                            error:(NSError *)error
                       isFinished:(BOOL)isFinished {
    
    return [self initWithImageData:data
                             image:image error:error
                        isFinished:isFinished
                       isCancelled:NO];
}

- (instancetype)initWithImageData:(NSData *)data
                            image:(UIImage *)image
                            error:(NSError *)error
                       isFinished:(BOOL)isFinished
                      isCancelled:(BOOL)isCancelled {
    
    self = [super init];
    if (self) {
        self.data = data;
        self.image = image;
        self.error = error;
        self.isFinished = isFinished;
        self.isCancelled = isCancelled;
    }
    return self;
}

@end // @implementation TNImageDownloaderCompleteObject


@interface TNImageDownloaderToken ()

@property (nonatomic, getter=isCancelled) BOOL cancelled;

@end // @interface TNImageDownloaderToken ()


@implementation TNImageDownloaderToken

@synthesize url;
@synthesize request;
@synthesize response;
@synthesize identifier;
@synthesize downloadOperation;
@synthesize isCancelled;

- (void)cancel {
    @synchronized (self) {
        if (self.isCancelled) {
            return;
        }
        
        self.cancelled = YES;
        [self.downloadOperation cancel:self.identifier];
    }
}

@end // @implementation TNImageDownloaderToken
