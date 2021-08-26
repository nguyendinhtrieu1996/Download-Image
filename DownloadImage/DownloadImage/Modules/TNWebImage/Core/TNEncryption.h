//
//  TNEncryption.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 01/08/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TNEncryption : NSObject

+ (NSString *)md5String:(NSString *)string;

@end // @interface TNEncryption

NS_ASSUME_NONNULL_END
