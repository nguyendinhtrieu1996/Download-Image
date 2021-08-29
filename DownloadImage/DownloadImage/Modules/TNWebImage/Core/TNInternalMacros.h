//
//  TNCommonMacros.h
//  DownloadImage
//
//  Created by Trieu Nguyen on 26/06/2021.
//

#ifndef TNCommonMacros_h
#define TNCommonMacros_h

#import <os/lock.h>


#define ifnot(condition)            if (!(condition))

#define safeExec(block, ...)        block ? block(__VA_ARGS__) : nil

#define WEAKSELF                    __weak typeof(self) weakSelf = self;
#define STRONGSELF_RETURN(obj)      __strong typeof(weakSelf) self = weakSelf;\
                                    ifnot (self) return obj;

#define TNImageMakeError(ErrorCode, Description) [NSError errorWithDomain:TNImageErrorDomain \
                                                                    code:ErrorCode \
                                                                userInfo:@{NSLocalizedDescriptionKey : Description}]

#define TN_LOCK_DECLARE(lock) os_unfair_lock lock
#define TN_LOCK_INIT(lock) lock = OS_UNFAIR_LOCK_INIT
#define TN_LOCK(lock) os_unfair_lock_lock(&lock)
#define TN_UNLOCK(lock) os_unfair_lock_unlock(&lock)

#define TN_OPTIONS_CONTAINS(options, value) (((options) & (value)) == (value))

#define TN_EMPTY_STR(str) (str.length == 0)
#define TN_IS_KIND_OF_CLASS(data, objectType) (data && [data isKindOfClass:[objectType class]])

#define TN_ASSERT_NONNULL(value) NSAssert(value != nil, NSInternalInconsistencyException);
#define TN_ASSRT_NONEMPTY_STR(value) NSAssert(value.length > 0, NSInternalInconsistencyException);
#define TN_ASSERT_INCONSISTENCY NSAssert(false, NSInternalInconsistencyException);

#endif /* TNCommonMacros_h */
