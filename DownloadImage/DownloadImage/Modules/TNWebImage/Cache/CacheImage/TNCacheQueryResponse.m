//
//  TNCacheQueryResponse.m
//  DownloadImage
//
//  Created by Trieu Nguyen on 02/09/2021.
//

#import "TNCacheQueryResponse.h"


@interface TNCacheQueryResponse ()
{
    UIImage *_image;
    NSData *_data;
    TNImageCacheType _cacheType;
}

@end // @interface TNCacheQueryResponse


@implementation TNCacheQueryResponse

@synthesize image = _image;
@synthesize data = _data;
@synthesize cacheType = _cacheType;

- (instancetype)initWithImage:(UIImage *)image
                         data:(NSData *)data
                    cacheType:(TNImageCacheType)cacheType {
    
    self = [super init];
    if (self) {
        _image = image;
        _data = data;
        _cacheType = cacheType;
    }
    return self;
}

@end // @implementation TNCacheQueryResponse
