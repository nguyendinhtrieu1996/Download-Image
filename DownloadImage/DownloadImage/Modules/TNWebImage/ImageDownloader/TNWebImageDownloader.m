//
//  TNWebImageDownloader.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import "TNWebImageDownloader.h"

#import "TNInternalMacros.h"
#import "TNWebImageError.h"
#import "TNWebImageDownloaderOperation.h"


@interface TNWebImageDownloadToken ()

@property (nonatomic, readwrite, nullable) NSURL *url;
@property (nonatomic, readwrite, nullable) NSURLRequest *request;
@property (nonatomic, readwrite, nullable) NSURLResponse *response;

@property (nonatomic, weak) NSOperation<TNWebImageDownloaderOperationProtocol> *downloadOperation;
@property (nonatomic, getter=isCancelled) BOOL cancelled;

@end // @interface TNWebImageDownloadToken ()

@implementation TNWebImageDownloadToken

- (void)cancel {
    @synchronized (self) {
        if (self.isCancelled) {
            return;
        }
        
        self.cancelled = YES;
        [self.downloadOperation cancel:_identifier];
    }
}

@end // @implementation TNWebImageDownloadToken


#pragma mark - [TNWebImageDownloader]


@interface TNWebImageDownloader ()
<
NSURLSessionTaskDelegate
, NSURLSessionDataDelegate
>

{
    NSURLSession *_session;
    NSOperationQueue *_downloadQueue;
    NSMutableDictionary<NSURL *, NSOperation<TNWebImageDownloaderOperationProtocol> *> *_URLOperation;
    
    TN_LOCK_DECLARE(_operationsLock);
}


@end // @interface TNWebImageDownloader ()

@implementation TNWebImageDownloader


#pragma mark Object LifeCycle

- (instancetype)initWithConfig:(TNWebImageDownloaderConfig *)conig {
    self = [super init];
    
    if (self) {
        _config = [conig copy];
        if (!_config) {
            _config = [TNWebImageDownloaderConfig defaultDownloaderConfig];
        }
        
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = conig.maxConcurrentDownload;
        _downloadQueue.name = @"com.TNWebImage.WebImageDownloader";
        
        _URLOperation = [NSMutableDictionary new];
        
        NSURLSessionConfiguration *sessionConfiguration = _config.sessionConfiguration;
        if (!sessionConfiguration) {
            sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
        
        TN_LOCK_INIT(_operationsLock);
    }
    
    return self;
}

+ (TNWebImageDownloader *)sharedDownloader {
    static dispatch_once_t once;
    static TNWebImageDownloader *instance;
    dispatch_once(&once, ^{
        instance = [[[self class] alloc] initWithConfig:[TNWebImageDownloaderConfig defaultDownloaderConfig]];
    });
    return instance;
}

#pragma mark Donwload EntryPoint

- (TNWebImageDownloadToken *)downloadImageWithURL:(NSURL *)url
                                       completion:(TNWebImageDownloaderCompletionBlock)completionBlock {
    return [self downloadImageWithURL:url
                              options:0
                              context:nil
                        progressBlock:nil
                           completion:completionBlock];
}

- (TNWebImageDownloadToken *)downloadImageWithURL:(NSURL *)url
                                          options:(TNWebImageDownloaderOptions)options
                                          context:(TNWebImageContext *)context
                                    progressBlock:(TNWebImageDownloaderProgressBlock)progressBlock
                                       completion:(TNWebImageDownloaderCompletionBlock)completionBlock {
    
    ifnot (url) {
        NSError *error = TNWebImageMakeError(TNWebImageError_InavlidURL, @"Image url is nil");
        safeExec(completionBlock, nil, nil, error, YES);
        return nil;
    }
    
    TN_LOCK(_operationsLock);
    
    TNImageDownloaderIdentifier *downloadIdentifier;
    NSOperation<TNWebImageDownloaderOperationProtocol> *operation;
    operation = [_URLOperation objectForKey:url];
    
    if(!operation || operation.isFinished || operation.isCancelled) {
        operation = [self _createDownloadOperationWithURL:url
                                                  options:options
                                                  context:context];
        WEAKSELF
        operation.completionBlock = ^{
            STRONGSELF_RETURN()
            
            TN_LOCK(self->_operationsLock);
            [self->_URLOperation removeObjectForKey:url];
            TN_UNLOCK(self->_operationsLock);
        };
        
        downloadIdentifier = [operation addHandlerForProgress:progressBlock completion:completionBlock];
        
        _URLOperation[url] = operation;
        [_downloadQueue addOperation:operation];
    } else {
        ifnot (operation.isExecuting) {
            if (TN_OPTIONS_CONTAINS(options, TNWebImageDownloader_HighPriority)) {
                operation.queuePriority = NSOperationQueuePriorityHigh;
            } else if (TN_OPTIONS_CONTAINS(options, TNWebImageDownloader_LowPriotiry)) {
                operation.queuePriority = NSOperationQueuePriorityLow;
            } else {
                operation.queuePriority = NSOperationQueuePriorityNormal;
            }
        }
        
        downloadIdentifier = [operation addHandlerForProgress:progressBlock completion:completionBlock];
    }
    
    TNWebImageDownloadToken *downloadToken = [TNWebImageDownloadToken new];
    downloadToken.url = url;
    downloadToken.request = operation.request;
    downloadToken.identifier = downloadIdentifier;
    downloadToken.downloadOperation = operation;
    
    TN_UNLOCK(_operationsLock);
    
    return downloadToken;
}

#pragma mark Cancel

- (void)cancelALlDownloads {
    [_downloadQueue cancelAllOperations];
}

#pragma mark Helper Methods

- (NSOperation<TNWebImageDownloaderOperationProtocol> *)_createDownloadOperationWithURL:(NSURL *)url
                                                                                options:(TNWebImageDownloaderOptions)options
                                                                                context:(TNWebImageContext *)context {
    
    BOOL useURLCache = TN_OPTIONS_CONTAINS(options, TNWebImageDownloader_UseNSURLCache);
    NSURLRequestCachePolicy cachePolicy = useURLCache ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData;
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:cachePolicy
                                                          timeoutInterval:_config.downloadTimeout];
    
    
    NSOperation<TNWebImageDownloaderOperationProtocol> *operation;
    operation = [[TNWebImageDownloaderOperation alloc] initWithRequest:urlRequest
                                                             inSession:_session
                                                               options:options
                                                               context:context];
    
    if (TN_OPTIONS_CONTAINS(options, TNWebImageDownloader_HighPriority)) {
        operation.queuePriority = NSOperationQueuePriorityHigh;
    } else if (TN_OPTIONS_CONTAINS(options, TNWebImageDownloader_LowPriotiry)) {
        operation.queuePriority = NSOperationQueuePriorityLow;
    } else {
        operation.queuePriority = NSOperationQueuePriorityNormal;
    }
    
    if (self.config.executionOrder == TNWebImageDownloaderExecutionOrder_LIFO) {
        for (NSOperation *pendingOperation in _downloadQueue.operations) {
            [pendingOperation addDependency:operation];
        }
    }
    
    return operation;
}

- (NSOperation<TNWebImageDownloaderOperationProtocol> *)_operationByTask:(NSURLSessionTask *)task {
    ifnot (task) {
        return nil;
    }
    
    NSOperation<TNWebImageDownloaderOperationProtocol> *returnOperation = nil;
    
    TN_LOCK(_operationsLock);
    
    for (NSOperation<TNWebImageDownloaderOperationProtocol> *operation in _downloadQueue.operations) {
        ifnot ([operation conformsToProtocol:@protocol(TNWebImageDownloaderOperationProtocol)]) {
            NSAssert(false, NSInternalInconsistencyException);
            continue;
        }
        
        if (operation.dataTask.taskIdentifier == task.taskIdentifier) {
            returnOperation = operation;
            break;
        }
    }
    
    TN_UNLOCK(_operationsLock);
    
    return returnOperation;
}

#pragma mark - <NSURLSessionTaskDelegate>

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    NSOperation<TNWebImageDownloaderOperationProtocol> *operation = [self _operationByTask:dataTask];
    ifnot (operation) {
        return;
    }
    
    SEL sel = @selector(URLSession:dataTask:didReceiveResponse:completionHandler:);
    if ([operation respondsToSelector:sel]) {
        [operation URLSession:session
                     dataTask:dataTask
           didReceiveResponse:response
            completionHandler:completionHandler];
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    
    NSOperation<TNWebImageDownloaderOperationProtocol> *operation = [self _operationByTask:task];
    ifnot (operation) {
        return;
    }
    
    SEL sel = @selector(URLSession:task:didCompleteWithError:);
    if ([operation respondsToSelector:sel]) {
        [operation URLSession:session task:task didCompleteWithError:error];
    }
}

#pragma mark - <NSURLSessionDataDelegate>

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    NSOperation<TNWebImageDownloaderOperationProtocol> *operation = [self _operationByTask:dataTask];
    ifnot (operation) {
        return;
    }
    
    SEL sel = @selector(URLSession:dataTask:didReceiveData:);
    if ([operation respondsToSelector:sel]) {
        [operation URLSession:session
                     dataTask:dataTask
               didReceiveData:data];
    }
}

@end // @implementation TNWebImageDownloader
