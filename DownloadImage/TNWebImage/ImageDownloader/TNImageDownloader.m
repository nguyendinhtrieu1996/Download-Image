//
//  TNImageDownloader.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#import "TNImageDownloader.h"

#import "TNInternalMacros.h"
#import "TNWebImageError.h"
#import "TNImageDownloaderOperation.h"
#import "TNImageDownloaderObjects.h"


static NSString * const kDownloadQueueName =  @"com.TNWebImage.WebImageDownloader";

@interface TNImageDownloader ()
<
NSURLSessionTaskDelegate
, NSURLSessionDataDelegate
>

{
    NSURLSession *_session;
    NSOperationQueue *_downloadQueue;
    NSMutableDictionary<NSURL *, NSOperation<TNImageDownloaderOperationType> *> *_URLOperation;
    TNImageDownloaderConfig *_config;
    NSURLSessionConfiguration *_sesionConfiguration;
    
    TN_LOCK_DECLARE(_operationsLock);
}


@end // @interface TNImageDownloader ()

@implementation TNImageDownloader


#pragma mark Object LifeCycle

- (instancetype)init
{
    return [self initWithConfig:TNImageDownloaderConfig.defaultDownloaderConfig];
}

- (instancetype)initWithConfig:(TNImageDownloaderConfig *)conig {
    self = [super init];
    
    if (self) {
        _config = [conig copy];
        if (!_config) {
            _config = [TNImageDownloaderConfig defaultDownloaderConfig];
        }
        
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = conig.maxConcurrentDownload;
        _downloadQueue.name = kDownloadQueueName;
        
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

+ (TNImageDownloader *)sharedDownloader {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

#pragma mark Donwload EntryPoint

- (id<TNImageDownloaderTokenType>)downloadImageWithURL:(NSURL *)url
                                          completion:(TNImageDownloaderCompletionBlock)completionBlock {
    
    return [self downloadImageWithURL:url
                              options:0
                        progressBlock:nil
                           completion:completionBlock];
}

- (id<TNImageDownloaderTokenType>)downloadImageWithURL:(NSURL *)url
                                             options:(TNImageDownloaderOptions)options
                                       progressBlock:(TNImageDownloaderProgressBlock)progressBlock
                                          completion:(TNImageDownloaderCompletionBlock)completionBlock {
    
    ifnot (url) {
        NSError *error = TNImageMakeError(TNImageError_InvalidURL, @"Image url is nil");
        
        id<TNImageDownloaderCompleteObjectType> object = [TNImageDownloaderCompleteObject new];
        object.isFinished = YES;
        object.error = error;
        
        safeExec(completionBlock, object);
        return nil;
    }
    
    TN_LOCK(_operationsLock);
    
    TNImageDownloaderIdentifier downloadIdentifier;
    NSOperation<TNImageDownloaderOperationType> *operation;
    operation = [_URLOperation objectForKey:url];
    
    if(!operation || operation.isFinished || operation.isCancelled) {
        operation = [self _createDownloadOperationWithURL:url
                                                  options:options];
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
            if (TN_OPTIONS_CONTAINS(options, TNImageDownloader_HighPriority)) {
                operation.queuePriority = NSOperationQueuePriorityHigh;
            } else if (TN_OPTIONS_CONTAINS(options, TNImageDownloader_LowPriotiry)) {
                operation.queuePriority = NSOperationQueuePriorityLow;
            } else {
                operation.queuePriority = NSOperationQueuePriorityNormal;
            }
        }
        
        downloadIdentifier = [operation addHandlerForProgress:progressBlock completion:completionBlock];
    }
    
    TNImageDownloaderToken *downloadToken = [TNImageDownloaderToken new];
    downloadToken.url = url;
    downloadToken.request = operation.request;
    downloadToken.identifier = downloadIdentifier;
    downloadToken.downloadOperation = operation;
    
    TN_UNLOCK(_operationsLock);
    
    return downloadToken;
}

#pragma mark Cancel

- (void)cancelAllDownloads {
    [_downloadQueue cancelAllOperations];
}

#pragma mark Helper Methods

- (NSOperation<TNImageDownloaderOperationType> *)_createDownloadOperationWithURL:(NSURL *)url
                                                                         options:(TNImageDownloaderOptions)options {
    
    BOOL useURLCache = TN_OPTIONS_CONTAINS(options, TNImageDownloader_UseNSURLCache);
    NSURLRequestCachePolicy cachePolicy = useURLCache ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData;
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:cachePolicy
                                                          timeoutInterval:_config.downloadTimeout];
    
    
    NSOperation<TNImageDownloaderOperationType> *operation;
    operation = [[TNImageDownloaderOperation alloc] initWithRequest:urlRequest
                                                          inSession:_session
                                                            options:options];
    
    if (TN_OPTIONS_CONTAINS(options, TNImageDownloader_HighPriority)) {
        operation.queuePriority = NSOperationQueuePriorityHigh;
    } else if (TN_OPTIONS_CONTAINS(options, TNImageDownloader_LowPriotiry)) {
        operation.queuePriority = NSOperationQueuePriorityLow;
    } else {
        operation.queuePriority = NSOperationQueuePriorityNormal;
    }
    
    if (_config.executionOrder == TNImageDownloaderExecutionOrder_LIFO) {
        for (NSOperation *pendingOperation in _downloadQueue.operations) {
            [pendingOperation addDependency:operation];
        }
    }
    
    return operation;
}

- (NSOperation<TNImageDownloaderOperationType> *)_operationByTask:(NSURLSessionTask *)task {
    ifnot (task) {
        return nil;
    }
    
    NSOperation<TNImageDownloaderOperationType> *returnOperation = nil;
    
    TN_LOCK(_operationsLock);
    
    for (NSOperation<TNImageDownloaderOperationType> *operation in _downloadQueue.operations) {
        ifnot ([operation conformsToProtocol:@protocol(TNImageDownloaderOperationType)]) {
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
    
    NSOperation<TNImageDownloaderOperationType> *operation = [self _operationByTask:dataTask];
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
    
    NSOperation<TNImageDownloaderOperationType> *operation = [self _operationByTask:task];
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
    
    NSOperation<TNImageDownloaderOperationType> *operation = [self _operationByTask:dataTask];
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

@end // @implementation TNImageDownloader
