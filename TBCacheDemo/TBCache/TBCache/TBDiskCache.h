//
//  TBDiskCache.h
//  TBCache
//
//  Created by DangGu on 15/8/5.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBDiskCache;
typedef void (^TBDiskCacheBlock) (TBDiskCache *cache);
typedef void (^TBDiskCacheObjectBlock) (TBDiskCache *cache, NSString *key, id<NSCoding> object);

@interface TBDiskCache : NSObject

@property (nonatomic, strong, readonly) NSURL *cacheURL;

+ (TBDiskCache *)sharedCache;


- (void)objectForKey:(NSString *)key completion:(TBDiskCacheObjectBlock)completion;
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key completion:(TBDiskCacheObjectBlock)completion;
- (void)removeObjectForKey:(NSString *)key completion:(TBDiskCacheObjectBlock)completion;

@end
