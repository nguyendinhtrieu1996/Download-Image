//
//  TNDiskCache.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 01/08/2021.
//

#import "TNDiskCache.h"

#import "TNInternalMacros.h"
#import "TNEncryption.h"
#import "TNDiskCacheCleaner.h"


@interface TNDiskCache ()
{
    NSString *_cachePath;
    TNDiskCacheConfig *_config;
    NSFileManager *_fileManager;
    TNDiskCacheCleaner *_cacheCleaner;
}

@end // @interface TNDiskCache ()


@implementation TNDiskCache

#pragma mark LifeCycle

- (nonnull instancetype)initWithCachePath:(nonnull NSString *)cachePath
                                   config:(nonnull TNDiskCacheConfig *)config {
    self = [super init];
    if (self) {
        _cachePath = [cachePath copy];
        _config = [config copy];
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    if (_config.fileManager) {
        _fileManager = _config.fileManager;
    } else {
        _fileManager = [NSFileManager new];
    }
    
    _cacheCleaner = [[TNDiskCacheCleaner alloc] initWithFileManager:_fileManager
                                                          cachePath:_cachePath
                                                        cacheConfig:_config];
}

#pragma mark Check Cache

- (BOOL)containObjectForKey:(TNImageCacheKey)key {
    if (TN_EMPTY_STR(key)) {
        return NO;
    }
    
    NSString *cachePath = [self _cachePathForKey:key];
    BOOL exists = [_fileManager fileExistsAtPath:cachePath];
    
    if (!exists) {
        exists = [_fileManager fileExistsAtPath:cachePath.stringByDeletingPathExtension];
    }
    
    return exists;
}

- (id)objectForKey:(TNImageCacheKey)key {
    if (TN_EMPTY_STR(key)) {
        return nil;
    }
    
    NSString *cachePath = [self _cachePathForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:cachePath
                                          options:_config.readingOptions
                                            error:nil];
    if (data) {
        return data;
    }
    
    data = [NSData dataWithContentsOfFile:cachePath.stringByDeletingPathExtension
                                  options:_config.readingOptions
                                    error:nil];
    
    return data;
}

#pragma mark Set Cache

- (void)setObject:(id)object forKey:(TNImageCacheKey)key cost:(NSUInteger)cost {
    [self setObject:object forKey:key];
}

- (void)setObject:(id)object forKey:(TNImageCacheKey)key {
    if (TN_EMPTY_STR(key)) {
        return;
    }
    
    if (NO == TN_IS_KIND_OF_CLASS(object, NSData)) {
        return;
    }
    
    NSData *data = (NSData *)object;
    
    if (NO == [_fileManager fileExistsAtPath:_cachePath]) {
        [_fileManager createDirectoryAtPath:_cachePath
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:nil];
    }
    
    NSString *cachePath = [self _cachePathForKey:key];
    NSURL *fileURL = [NSURL fileURLWithPath:cachePath];
    [data writeToURL:fileURL options:_config.writtingOptions error:nil];
    
    if (_config.shouldDisableiCloud) {
        [fileURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
}

#pragma mark Remove Cache

- (void)removeAllObjects {
    [_fileManager removeItemAtPath:_cachePath error:nil];
    [_fileManager createDirectoryAtPath:_cachePath
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:nil];
}

- (void)removeObjectForKey:(TNImageCacheKey)key {
    if (TN_EMPTY_STR(key)) {
        return;
    }
    
    NSString *cachePath = [self _cachePathForKey:key];
    [_fileManager removeItemAtPath:cachePath error:nil];
}

- (void)removeExpiredData {
    [_cacheCleaner cleanExpiredCache];
}

#pragma mark Cache Info

- (long long)totalCount {
    NSDirectoryEnumerator *fileEnumrator = [_fileManager enumeratorAtPath:_cachePath];
    return fileEnumrator.allObjects.count;
}

- (long long)totalSize {
    long long size = 0;
    NSDirectoryEnumerator *fileEnumrator = [_fileManager enumeratorAtPath:_cachePath];
    for (NSString *fileName in fileEnumrator) {
        if (TN_EMPTY_STR(fileName)) {
            continue;
        }
        
        NSString *filePath = [_cachePath stringByAppendingPathComponent:fileName];
        NSDictionary<NSString *, id> *attrs = [_fileManager attributesOfItemAtPath:filePath error:nil];
        size += attrs.fileSize;
    }
    
    return size;
}

#pragma mark - Helper Methods

- (NSString *)_cachePathForKey:(TNImageCacheKey)key {
    return [self _cachePathForKey:key inPath:_cachePath];
}

- (NSString *)_cachePathForKey:(TNImageCacheKey)key inPath:(NSString *)path {
    NSString *fileName = [[self class] _cacheFileNameForKey:key];
    return [path stringByAppendingPathComponent:fileName];
}

+ (NSString *)_cacheFileNameForKey:(TNImageCacheKey)key {
    return [TNEncryption md5String:key];
}

@end // @implementation TNDiskCache
