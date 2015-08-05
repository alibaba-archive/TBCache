//
//  TBDiskCache.m
//  TBCache
//
//  Created by DangGu on 15/8/5.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#define kTBDiskCachePrefix  @"com.teambition.TBDiskCache"
#define kTBDiskCacheName    @"TBDiskCache"

#import "TBDiskCache.h"

@interface TBDiskCache()

@property (nonatomic, strong, readwrite) NSURL                  *cacheURL;
@property (nonatomic, strong, readwrite) NSURL                  *rootPath;
@property (nonatomic, strong, readwrite) NSMutableDictionary    *cacheDate;
@property (nonatomic, strong, readwrite) dispatch_queue_t       cacheQueue;

@property (nonatomic, assign, readwrite) NSUInteger             cacheCount;
@property (nonatomic, assign, readwrite) BOOL                   needConfigCache;
@end

@implementation TBDiskCache

+ (TBDiskCache *)sharedCache {
    static TBDiskCache *sharedCache = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        sharedCache = [[TBDiskCache alloc] init];
    });
    return sharedCache;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //path init
        _rootPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cacheDirectoryName = [NSString stringWithFormat:@"%@.%@",kTBDiskCachePrefix,kTBDiskCacheName];
        _cacheURL = [NSURL fileURLWithPathComponents:@[_rootPath, cacheDirectoryName]];
        
        //property init
        _cacheDate = [[NSMutableDictionary alloc] init];
        _cacheQueue = dispatch_queue_create([kTBDiskCachePrefix UTF8String], DISPATCH_QUEUE_SERIAL);
        _cacheCount = 0;
        _needConfigCache = YES;
        
        __weak TBDiskCache *weakSelf = self;
        dispatch_async(_cacheQueue, ^{
            TBDiskCache *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf createDiskCacheDirectory];
            [strongSelf configDiskCache];
        });
    }
    return self;
}

#pragma mark - cache init method
- (BOOL)createDiskCacheDirectory {
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:_cacheURL.path];
    if (existed) {
        _needConfigCache = YES;
        return NO;
    }
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:_cacheURL
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:&error];
    _needConfigCache = NO;
    return success;
}

- (void)configDiskCache {
    if (!_needConfigCache) {
        return;
    }
    NSArray *propertyKeys = @[NSURLContentModificationDateKey];
    
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:_cacheURL
                                                   includingPropertiesForKeys:propertyKeys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    for (NSURL *fileURL in files) {
        NSString *key = [self keyForEncodedFileURL:fileURL];
        NSError *error;
        NSDictionary *propertyDictionary = [fileURL resourceValuesForKeys:propertyKeys error:&error];
        
        NSDate *modifiedDate = [propertyDictionary objectForKey:key];
        if (modifiedDate && key) {
            [_cacheDate setObject:modifiedDate forKey:key];
        }
        
    }
}


#pragma mark - public method

- (void)objectForKey:(NSString *)key completion:(TBDiskCacheObjectBlock)completion {
    if (!key || !completion) {
        return;
    }
    
    NSURL *fileURL = [self encodedFileURLForKey:key];
    __weak TBDiskCache *weakSelf = self;
    
    dispatch_async(_cacheQueue, ^{
        TBDiskCache *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        id<NSCoding> object = nil;
        BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path];
        if (existed) {
            object = [NSKeyedUnarchiver unarchiveObjectWithFile:fileURL.path];
            NSDate *now = [NSDate date];
            [strongSelf setFileModificationDate:now forURL:fileURL];
        }
        completion(strongSelf, key, object);
    });
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key completion:(TBDiskCacheObjectBlock)completion {
    if (!object || !key) {
        return;
    }
    NSURL *fileURL = [self encodedFileURLForKey:key];
    
    __weak TBDiskCache *weakSelf = self;
    dispatch_async(_cacheQueue, ^{
        TBDiskCache *strongSelf = weakSelf;
        BOOL success = [NSKeyedArchiver archiveRootObject:object toFile:fileURL.path];
        if (success) {
            NSDate *now = [NSDate date];
            [_cacheDate setObject:now forKey:key];
        }
        if (completion) {
            completion(strongSelf, key, object);
        }
    });
}

- (void)removeObjectForKey:(NSString *)key completion:(TBDiskCacheObjectBlock)completion{
    if (!key) {
        return;
    }
    NSURL *fileURL = [self encodedFileURLForKey:key];
    
    __weak TBDiskCache *weakSelf = self;
    dispatch_async(_cacheQueue, ^{
        TBDiskCache *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path];
        if (existed) {
            NSError *error;
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:fileURL.path error:&error];
            if (success) {
                [_cacheDate removeObjectForKey:key];
            }
        }
        completion(strongSelf, key, nil);
        
    });
}

#pragma mark - private method
- (BOOL)setFileModificationDate:(NSDate *)date forURL:(NSURL *)fileURL
{
    if (!date || !fileURL) {
        return NO;
    }
    
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] setAttributes:@{ NSFileModificationDate: date }
                                                    ofItemAtPath:[fileURL path]
                                                           error:&error];
    if (success) {
        NSString *key = [self keyForEncodedFileURL:fileURL];
        if (key) {
            [_cacheDate setObject:date forKey:key];
        }
    }
    return success;
}

#pragma mark - setters and getters

#pragma mark - url encode and decode

// These method are copied from TMCache
- (NSURL *)encodedFileURLForKey:(NSString *)key
{
    if (![key length])
        return nil;
    
    return [_cacheURL URLByAppendingPathComponent:[self encodedString:key]];
}

- (NSString *)keyForEncodedFileURL:(NSURL *)url
{
    NSString *fileName = [url lastPathComponent];
    if (!fileName)
        return nil;
    
    return [self decodedString:fileName];
}

- (NSString *)encodedString:(NSString *)string
{
    if (![string length])
        return @"";
    
    CFStringRef static const charsToEscape = CFSTR(".:/");
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (__bridge CFStringRef)string,
                                                                        NULL,
                                                                        charsToEscape,
                                                                        kCFStringEncodingUTF8);
    return (__bridge_transfer NSString *)escapedString;
}

- (NSString *)decodedString:(NSString *)string
{
    if (![string length])
        return @"";
    
    CFStringRef unescapedString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                          (__bridge CFStringRef)string,
                                                                                          CFSTR(""),
                                                                                          kCFStringEncodingUTF8);
    return (__bridge_transfer NSString *)unescapedString;
}

@end
