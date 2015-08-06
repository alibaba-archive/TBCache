//
//  ViewController.m
//  TBCache
//
//  Created by DangGu on 15/8/5.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "ViewController.h"
#import "TBMemoryCache.h"
#import "TBDiskCache.h"
#import "TBCache.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *objectString = @"TBcache";
    NSString *keyString = @"key";
//    NSLog(@"before set %d",(int)[TBMemoryCache sharedCache].cacheCount);
//    [[TBMemoryCache sharedCache] setObject:objectString
//                                    forKey:keyString
//                                completion:^(TBMemoryCache *cache, NSString *key, id object) {
//                                    NSLog(@"%@ %@ %@",cache, key, object);
//                                    NSLog(@"block in%d",(int)cache.cacheCount);
//                                }];
//    NSLog(@"block out%d",(int)[TBMemoryCache sharedCache].cacheCount);
//    [[TBMemoryCache sharedCache] removeAllCacheObjects:nil];
//    NSLog(@"remove all%d",(int)[TBMemoryCache sharedCache].cacheCount);
    
    
//    [[TBDiskCache sharedCache] setObject:objectString
//                                  forKey:keyString
//                              completion:^(TBDiskCache *cache, NSString *key, id<NSCoding> object) {
////                                  NSLog(@"%@ %@ %@",cache, key, object);
//                              }];
//    [[TBDiskCache sharedCache] objectForKey:keyString completion:^(TBDiskCache *cache, NSString *key, id<NSCoding> object) {
//        NSLog(@"%@ %@ %@",cache, key, object);
//    }];
    
    [[TBCache sharedCache] setObject:objectString
                              forKey:keyString
                          completion:^(TBCache *cache, NSString *key, id<NSCoding> object) {
                              NSLog(@"%@ %@ %@",cache, key, object);
                          }];
    
    [[TBCache sharedCache] setObject:@"2" forKey:@"key yaya" completion:^(TBCache *cache, NSString *key, id<NSCoding> object) {
        NSLog(@"%@ %@ %@",cache, key, object);
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
