//
//  TBCache.m
//  TBCache
//
//  Created by DangGu on 15/8/5.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//
#import <UIKit/UIKit.h>
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
        _diskCache.memoryCache = _memoryCache;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleApplicationEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleApplicationWillEnterForegounrd)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - response method
- (void)handleMemoryWarning {
    [_memoryCache transferMemoryCacheToDiskCache:_diskCache andClearMemoryCache:YES];
}

- (void)handleApplicationEnterBackground {
    [_memoryCache transferMemoryCacheToDiskCache:_diskCache andClearMemoryCache:YES];
}

- (void)handleApplicationWillEnterForegounrd {
    [_diskCache transferDiskCacheToMemoryCache:_memoryCache];
}

#pragma mark - public method
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
        if (completion) {
            completion(strongSelf, key, object);
        }
    }];
}

#pragma mark - private method

#pragma mark - setters and getters
- (void)setExpiredTime:(NSTimeInterval)expiredTime {
    _expiredTime = expiredTime;
    _memoryCache.expiredTime = expiredTime;
    _diskCache.expiredTime = expiredTime;
}
@end
