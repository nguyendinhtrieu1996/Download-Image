//
//  TNDiskCacheCleaner.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 02/08/2021.
//

#import "TNDiskCacheCleaner.h"

#import "TNInternalMacros.h"


typedef NSDictionary<NSString *, id> * TNDisCacheResourceValue;
typedef NSDictionary<NSURL *, TNDisCacheResourceValue> * TNDiskCacheFiles;
typedef NSMutableDictionary<NSURL *,TNDisCacheResourceValue> * TNMutableDiskCacheFiles;


@interface TNDiskCacheCleaner ()
{
    NSFileManager *_fileManager;
    NSString *_cachePath;
    TNDiskCacheConfig *_config;
}

@end // @interface TNDiskCacheCleaner ()


@implementation TNDiskCacheCleaner

- (instancetype)initWithFileManager:(NSFileManager *)fileManager
                          cachePath:(NSString *)cachePath
                        cacheConfig:(TNDiskCacheConfig *)config {
    self = [super init];
    if (self) {
        _fileManager = fileManager;
        _cachePath = cachePath;
        _config = config;
    }
    return self;
}

- (void)cleanExpiredCache {
    NSURL *diskCacheURL = [NSURL fileURLWithPath:_cachePath];
    NSURLResourceKey cacheContentDateKey = [[self class] _cacheContentDateWithConfig:_config];
    NSArray<NSString *> *resourceKeys = @[NSURLIsDirectoryKey, cacheContentDateKey, NSURLTotalFileAllocatedSizeKey];
    
    NSDirectoryEnumerator *fileEnumrator = [_fileManager
                                            enumeratorAtURL:diskCacheURL
                                            includingPropertiesForKeys:resourceKeys
                                            options:NSDirectoryEnumerationSkipsHiddenFiles
                                            errorHandler:nil];
    
    NSDate *expirationDate = (_config.maxDiskAge < 0) ? nil : [NSDate dateWithTimeIntervalSinceNow:-_config.maxDiskAge];
    TNMutableDiskCacheFiles cacheFiles = [NSMutableDictionary new];
    long long currentCacheSize = 0;
    NSMutableArray<NSURL *> *urlsToDelete = [NSMutableArray new];
    
    for (NSURL *fileURL in fileEnumrator) {
        NSError *error = nil;
        TNDisCacheResourceValue resourceValue = [fileURL resourceValuesForKeys:resourceKeys error:&error];
        
        if (error || !resourceValue || [resourceValue[NSURLIsDirectoryKey] boolValue]) {
            continue;
        }
        
        NSDate *modicationDate = resourceValue[cacheContentDateKey];
        if (expirationDate && [[modicationDate laterDate:expirationDate] isEqual:expirationDate]) {
            [urlsToDelete addObject:fileURL];
        }
        
        NSNumber *totalAllocatedSize = resourceValue[NSURLTotalFileAllocatedSizeKey];
        currentCacheSize += totalAllocatedSize.longLongValue;
        cacheFiles[fileURL] = resourceValue;
    }
    
    [self _removeFilesAtURL:urlsToDelete];
    
    [self _tryToCleanDiskSizeWithCurrentSize:currentCacheSize
                                     maxSize:_config.maxDiskSize
                                  cacheFiles:cacheFiles
                         cacheContentDateKey:cacheContentDateKey];
}

#pragma mark Helper Methods

- (void)_removeFilesAtURL:(NSArray<NSURL *> *)urls {
    for (NSURL *url in urls) {
        [_fileManager removeItemAtURL:url error:nil];
    }
}

- (void)_tryToCleanDiskSizeWithCurrentSize:(long long)currentSize
                                   maxSize:(long long)maxSize
                                cacheFiles:(TNDiskCacheFiles)cacheFiles
                       cacheContentDateKey:(NSURLResourceKey)cacheContentDateKey {
    
    if (maxSize <= 0 || currentSize < maxSize) {
        return;
    }
    
    long long desiredCacheSize = maxSize / 2;
    
    NSArray<NSURL *> *sortedFiles = [cacheFiles
                                     keysSortedByValueWithOptions:NSSortConcurrent
                                     usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1[cacheContentDateKey] compare:obj2[cacheContentDateKey]];
    }];
    
    for (NSURL *fileURL in sortedFiles) {
        if ([_fileManager removeItemAtURL:fileURL error:nil]) {
            TNDisCacheResourceValue resourceValue = cacheFiles[fileURL];
            NSNumber *totalAllocatedSize = resourceValue[NSURLTotalFileAllocatedSizeKey];
            currentSize -= totalAllocatedSize.longLongValue;
            
            if (currentSize < desiredCacheSize) {
                break;
            }
        }
    }
}

+ (NSURLResourceKey)_cacheContentDateWithConfig:(TNDiskCacheConfig *)config {
    switch (config.expiredType) {
        case TNDiskCacheConfigExpireType_AccessDate:
            return NSURLContentAccessDateKey;
        case TNDiskCacheConfigExpireType_ModificationDate:
            return NSURLContentModificationDateKey;
        case TNDiskCacheConfigExpireType_CreationDate:
            return NSURLCreationDateKey;
        case TNDiskCacheConfigExpireType_ChangeDate:
            return NSURLAttributeModificationDateKey;
        default:
            TN_ASSERT_INCONSISTENCY
            return NSURLContentModificationDateKey;
    }
}

@end // @implementation TNDiskCacheCleaner
