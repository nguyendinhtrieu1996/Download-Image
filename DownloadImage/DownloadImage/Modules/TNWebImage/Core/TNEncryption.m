//
//  TNEncryption.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 01/08/2021.
//

#import "TNEncryption.h"

#import <CommonCrypto/CommonDigest.h>


@implementation TNEncryption

+ (NSString *)md5String:(NSString *)string {
    const char *str = string.UTF8String;
    if (str == NULL) {
        return NULL;
    }
    
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
            r[11], r[12], r[13], r[14], r[15]];
}

@end // @implementation TNEncryption
