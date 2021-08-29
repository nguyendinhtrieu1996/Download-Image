//
//  TNImageDownloaderOperation.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import "TNImageDownloaderOperation.h"

#import "TNInternalMacros.h"
#import "TNWebImageError.h"
#import "TNImageCoder.h"
#import "TNImageDownloaderObjects.h"
#import "TNImageBaseOperation+Internal.h"


static const CGFloat kBytesPerMB = 1024.0f * 1024.0f;
static CGFloat kDestImageLimitBytes = 6.f * kBytesPerMB;


static NSString * const kProgressCallbackKey = @"progress";
static NSString * const kCompletionCallbackKey = @"completed";
static NSString * const kCallbackQueueName =  @"com.TNWebImage.DownloaderOperationCallbackQueue";

typedef NSMutableDictionary<NSString *, id> TNCallbacksDictionary;
typedef NSMutableDictionary<TNImageDownloaderIdentifier, TNCallbacksDictionary *> TNCallbackBlocks;


@interface TNImageDownloaderOperation ()
{
    // Synthesize
    NSURLRequest *_request;
    NSURLResponse *_response;
    NSURLSession *_session;
    NSURLSessionDataTask *_dataTask;
    double _mininumProgressInterval;
    TNImageDownloaderOptions _options;
    
    NSOperationQueue *_callbackQueue;
    TNCallbackBlocks *_callbackBlocks;
    UIBackgroundTaskIdentifier _backgroundTaskId;
    
    double _previousProgress;
    NSUInteger _expectedSize;
    NSUInteger _receivedSize;
    NSMutableData *_accumulateImageData;
    
    TNWebImageCoder *_imageCoder;
}

@end // @interface TNImageDownloaderOperation ()


@implementation TNImageDownloaderOperation

@synthesize request = _request;
@synthesize response = _response;
@synthesize session = _session;
@synthesize dataTask = _dataTask;
@synthesize mininumProgressInterval = _mininumProgressInterval;
@synthesize options = _options;

#pragma mark LifeCycle

- (instancetype)initWithRequest:(NSURLRequest *)request
                      inSession:(NSURLSession *)session
                        options:(TNImageDownloaderOptions)options {
    
    self = [super init];
    
    if (self) {
        _request = [request copy];
        
        _session = session;
        _options = options;
        
        _callbackQueue = [NSOperationQueue new];
        _callbackQueue.name = kCallbackQueueName;
        _callbackQueue.maxConcurrentOperationCount = 1;
        
        _callbackBlocks = [NSMutableDictionary new];
        _backgroundTaskId = UIBackgroundTaskInvalid;
        
        _imageCoder = [TNWebImageCoder new];
    }
    
    return self;
}

#pragma mark Public Method

- (TNImageDownloaderIdentifier)addHandlerForProgress:(TNImageDownloaderProgressBlock)progressBlock
                                          completion:(TNImageDownloaderCompletionBlock)completionBlock {
    
    TNImageDownloaderIdentifier identifier = [self _generateDownloadIdentifier];
    TNCallbacksDictionary *callbackDict = [NSMutableDictionary new];
    
    if (progressBlock) {
        callbackDict[kProgressCallbackKey] = progressBlock;
    }
    if (completionBlock) {
        callbackDict[kCompletionCallbackKey] = completionBlock;
    }
    
    @synchronized (self) {
        _callbackBlocks[identifier] = callbackDict;
    }
    
    return identifier;
}

#pragma mark - Operation LifeCycle

- (BOOL)isConcurrent {
    return YES;
}

- (void)start {
    @synchronized (self) {
        [self _internalStartDownload];
    }
}

- (void)_internalStartDownload {
    if (self.isCancelled) {
        NSError *error = TNImageMakeError(TNImageError_Cancelled, @"Downloader cancelled");
        [self _completeWithError:error];
        return;
    }
    
    WEAKSELF
    UIApplication *app = UIApplication.sharedApplication;
    _backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
        STRONGSELF_RETURN()
        [self cancel];
    }];
    
    NSURLSession *session = self.session;
    ifnot (session.delegate) {
        NSError *error = TNImageMakeError(TNImageError_InvalidDownloadOperation, @"Session delegate is nil");
        [self _completeWithError:error];
        return;
    }
    
    _dataTask = [session dataTaskWithRequest:self.request];
    [self _informExecuting];
    
    ifnot (_dataTask) {
        NSError *error = TNImageMakeError(TNImageError_InvalidDownloadOperation, @"DataTask can't be initialized");
        [self _completeWithError:error];
        return;
    }
    
    if (self.options & TNImageDownloader_HighPriority) {
        _dataTask.priority = NSURLSessionTaskPriorityHigh;
    } else if (self.options & TNImageDownloader_LowPriotiry) {
        _dataTask.priority = NSURLSessionTaskPriorityLow;
    } else {
        _dataTask.priority = NSURLSessionTaskPriorityDefault;
    }
    
    [_dataTask resume];
    
    [self _informProgressBlockWithReceiveSize:0
                                   expectSize:NSURLResponseUnknownLength
                                          url:self.request.URL];
}

#pragma mark Cancel

- (BOOL)cancel:(TNImageDownloaderIdentifier)identifier {
    ifnot (identifier) {
        return NO;
    }
    
    @synchronized (self) {
        TNCallbacksDictionary *callbacksDict = [_callbackBlocks objectForKey:identifier];
        ifnot (callbacksDict) {
            return NO;
        }
        
        [_callbackBlocks removeObjectForKey:identifier];
        
        if (_callbackBlocks.count == 0) {
            [self cancel];
        }
        
        TNImageDownloaderCompletionBlock completionBlock = [callbacksDict objectForKey:kCompletionCallbackKey];
        if (completionBlock) {
            NSError *error = TNImageMakeError(TNImageError_Cancelled,
                                              @"Operation canclled by user during sending the request");
            TNImageDownloaderCompleteObject *completionObj = [TNImageDownloaderCompleteObject new];
            completionObj.error = error;
            completionObj.isFinished = YES;
            
            completionBlock(completionObj);
        }
    }
    
    return YES;
}

- (void)cancel {
    @synchronized (self) {
        [self _internalCancel];
    }
}

- (void)_internalCancel {
    if (self.isFinished || self.isCancelled) {
        return;
    }
    
    [super cancel];
    
    if (_dataTask) {
        [_dataTask cancel];
    }
    
    if (self.isExecuting) {
        [self _informExecuting];
    }
    
    ifnot (self.isFinished) {
        [self _informFinished];
    }
    
    NSError *error = TNImageMakeError(TNImageError_Cancelled,
                                      @"Operation canclled by user during sending the request");
    [self _informCompletionBlockWithError:error];
    
    [self _reset];
}

#pragma mark Progress Handler

- (void)_informProgressBlockWithReceiveSize:(NSUInteger)receiveSize
                                 expectSize:(NSUInteger)expectSize
                                        url:(nullable NSURL *)url {
    
    NSArray *progressBlocks = [self _callbackForKey:kProgressCallbackKey];
    for (TNImageDownloaderProgressBlock progressBlock in progressBlocks) {
        
        TNImageDownloaderProgressObject *progressObj = [TNImageDownloaderProgressObject new];
        progressObj.expectedSize = expectSize;
        progressObj.receiveSize = receiveSize;
        progressObj.targetURL = url;
        
        progressBlock(progressObj);
    }
}

#pragma mark Completion Handler

- (void)_completeWithError:(NSError *)error {
    ifnot (self.isFinished) {
        [self _informFinished];
    }
    
    [self _informCompletionBlockWithError:error];
}

- (void)_informCompletionBlockWithError:(NSError *)error {
    [self _informCompletionnBlockWithImage:nil
                                 imageData:nil
                                     error:error
                                  finished:YES];
}

- (void)_informCompletionnBlockWithImage:(nullable UIImage *)image
                               imageData:(nullable NSData *)imageData
                                   error:(nullable NSError *)error
                                finished:(BOOL)finished {
    
    NSArray *completionBlocks = [self _callbackForKey:kCompletionCallbackKey];
    [_callbackQueue addOperationWithBlock:^{
        for (TNImageDownloaderCompletionBlock completion in completionBlocks) {
            
            TNImageDownloaderCompleteObject *completionObj = [TNImageDownloaderCompleteObject new];
            completionObj.image = image;
            completionObj.data = imageData;
            completionObj.error = error;
            completionObj.isFinished = YES;
            completion(completionObj);
        }
    }];
}

#pragma mark Helper Methods

- (NSArray *)_callbackForKey:(NSString *)queryKey {
    NSMutableArray *callbacks = [NSMutableArray new];
    @synchronized (self) {
        [_callbackBlocks enumerateKeysAndObjectsUsingBlock:^(TNImageDownloaderIdentifier _Nonnull key,
                                                             TNCallbacksDictionary * _Nonnull obj,
                                                             BOOL * _Nonnull stop) {
            @autoreleasepool {
                id callback = [[obj valueForKey:queryKey] copy];
                if (callback) {
                    [callbacks addObject:callback];
                }
            }
        }];
    }
    return callbacks;
}

- (void)_done {
    _finished = YES;
    _executing = NO;
    [self _reset];
}

- (void)_reset {
    @synchronized (self) {
        [_callbackBlocks removeAllObjects];
        _dataTask = nil;
        
        if (_backgroundTaskId != UIBackgroundTaskInvalid) {
            UIApplication *app = UIApplication.sharedApplication;
            [app endBackgroundTask:_backgroundTaskId];
            _backgroundTaskId = UIBackgroundTaskInvalid;
        }
    }
}

- (TNImageDownloaderIdentifier)_generateDownloadIdentifier {
    return [[NSUUID UUID] UUIDString];
}

#pragma mark Decode Image

- (UIImage *)_decodeImageFromData:(NSData *)data {
    NSMutableDictionary *decodingOptions = [NSMutableDictionary new];
    
    if (TN_OPTIONS_CONTAINS(_options, TNImageDownloader_ScaleDownLargeImage)) {
        CGFloat numberBytesPerPixel = 4.0;
        CGFloat thumbnailPixels = kDestImageLimitBytes / numberBytesPerPixel;
        CGFloat dimension = ceil(sqrtl(thumbnailPixels));
        CGSize thumbnailSize = CGSizeMake(dimension, dimension);
        
        decodingOptions[TNImageCoderDecodeThumnailPixelSize] = @(thumbnailSize);
    }
    
    return [_imageCoder decodedImageWithData:data options:decodingOptions];
}

#pragma mark - <NSURLSessionTaskDelegate>

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    NSURLSessionResponseDisposition dispostion = NSURLSessionResponseAllow;
    
    NSInteger expected = (NSInteger)response.expectedContentLength;
    expected = MAX(expected, 0);
    
    @synchronized (self) {
        _expectedSize = expected;
        _response = response;
    }
    
    safeExec(completionHandler, dispostion);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    
    if (self.isFinished || self.isCancelled) {
        return;
    }
    
    if (error) {
        [self _informCompletionBlockWithError:error];
    } else {
        BOOL hasCompletionCallback = ([self _callbackForKey:kCompletionCallbackKey].count > 0);
        if (hasCompletionCallback) {
            UIImage *image = [self _decodeImageFromData:_accumulateImageData];
            [self _informCompletionnBlockWithImage:image
                                         imageData:_accumulateImageData
                                             error:nil
                                          finished:YES];
        }
    }
    
    [self _done];
}

#pragma mark - <NSURLSessionDataDelegate>

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    ifnot (_accumulateImageData) {
        _accumulateImageData = [NSMutableData dataWithCapacity:_expectedSize];
    }
    [_accumulateImageData appendData:data];
    
    _receivedSize = _accumulateImageData.length;
    
    if (_expectedSize == 0) {
        [self _informProgressBlockWithReceiveSize:_receivedSize
                                       expectSize:_expectedSize
                                              url:_request.URL];
        return;
    }
    
    double currentProgress = (double)_receivedSize / (double)_expectedSize;
    double previousProgress = _previousProgress;
    
    double progressInterval = currentProgress - previousProgress;
    if (progressInterval < self.mininumProgressInterval) {
        return;
    }
    
    _previousProgress = currentProgress;
    [self _informProgressBlockWithReceiveSize:_receivedSize
                                   expectSize:_expectedSize
                                          url:_request.URL];
}

@end // @implementation TNImageDownloaderOperation
