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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleApplicationEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - response method
- (void)handleMemoryWarning{
    [self transferMemoryCacheToDisk];
    [_memoryCache removeAllCacheObjects:nil];
}

- (void)handleApplicationEnterBackground{
    [self transferMemoryCacheToDisk];
    [_memoryCache removeAllCacheObjects:nil];
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
        completion(strongSelf, key, object);
    }];
}

#pragma mark - private method
- (void)transferMemoryCacheToDisk{
    [_memoryCache enumertateCacheUsingBlock:^(NSString *key, id object, BOOL *stop) {
        [_diskCache setObject:object forKey:key completion:nil];
    }];
}
@end
