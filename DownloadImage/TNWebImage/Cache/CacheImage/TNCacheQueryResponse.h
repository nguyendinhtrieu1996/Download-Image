//
//  TNCacheQueryResponse.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 02/09/2021.
//

#import "TNCacheDefines.h"


#define TN_CreateCacheQueryResponseNULLData(cacheType)    [[TNCacheQueryResponse alloc] \
                                                          initWithImage:nil \
                                                          data:nil\
                                                          cacheType:cacheType]

#define TN_CreateCacheQueryResponse(image, data, cacheType)    [[TNCacheQueryResponse alloc] \
                                                               initWithImage:image \
                                                               data:data\
                                                               cacheType:cacheType]


NS_ASSUME_NONNULL_BEGIN

@interface TNCacheQueryResponse : NSObject <TNCacheQueryResponseType>

- (instancetype)initWithImage:(nullable UIImage *)image
                         data:(nullable NSData *)data
                    cacheType:(TNImageCacheType)cacheType;

@end // @interface TNCacheQueryResponse

NS_ASSUME_NONNULL_END
