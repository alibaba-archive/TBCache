//
//  TBCache.m
//  TBCache
//
//  Created by DangGu on 15/8/5.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TBCache.h"
#import "TBDiskCache.h"
#import "TBMemoryCache.h"

@interface TBCache()

@end

@implementation TBCache

+ (TBCache *)sharedCache {
    static TBCache *sharedCache = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        sharedCache = [[TBCache alloc] init];
    });
    return sharedCache;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _diskCache = [TBDiskCache sharedCache];
        _memoryCache = [TBMemoryCache sharedCache];
    }
    return self;
}

- (void)objectForKey:(NSString *)key completion:(TBCacheObjectBlock)completion {
    if (!key || !completion) {
        return;
    }
    
    __weak TBCache *weakSelf = self;
    [_memoryCache objectForKey:key completion:^(TBMemoryCache *cache, NSString *key, id object) {
        TBCache *strongSelf = weakSelf;
        completion(strongSelf,key,object);
    }];
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key completion:(TBCacheObjectBlock)completion {
    if (!object || !key) {
        return;
    }
    
    __weak TBCache *weakSelf = self;
    [_memoryCache setObject:object forKey:key completion:^(TBMemoryCache *cache, NSString *key, id object) {
        TBCache *strongSelf = weakSelf;
        completion(strongSelf, key, object);
    }];
}
@end
