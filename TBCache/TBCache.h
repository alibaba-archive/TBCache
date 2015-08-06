//
//  TBCache.h
//  TBCache
//
//  Created by DangGu on 15/8/5.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBCache,TBDiskCache,TBMemoryCache;
typedef void (^TBCacheBlock) (TBCache *cache);
typedef void (^TBCacheObjectBlock) (TBCache *cache, NSString *key, id<NSCoding>object);

@interface TBCache : NSObject
@property (nonatomic, strong, readonly) TBDiskCache   *diskCache;
@property (nonatomic, strong, readonly) TBMemoryCache *memoryCache;

+ (TBCache *)sharedCache;
@end
