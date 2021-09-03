//
//  TNDiskCacheCleaner.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 02/08/2021.
//

#import <Foundation/Foundation.h>

#import "TNDiskCacheConfig.h"


NS_ASSUME_NONNULL_BEGIN

@interface TNDiskCacheCleaner : NSObject

- (instancetype)initWithFileManager:(NSFileManager *)fileManager
                          cachePath:(NSString *)cachePath
                        cacheConfig:(TNDiskCacheConfig *)config;

- (void)cleanExpiredCache;

@end // @interface TNDiskCacheCleaner

NS_ASSUME_NONNULL_END
