//
//	ReaderThumbCache.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ReaderThumbRequest.h"

@interface ReaderThumbCache : NSObject <NSObject>

+ (ReaderThumbCache *)sharedInstance;

+ (void)touchThumbCacheWithGUID:(NSString *)guid;

+ (void)createThumbCacheWithGUID:(NSString *)guid;

+ (void)removeThumbCacheWithGUID:(NSString *)guid;

+ (void)purgeThumbCachesOlderThan:(NSTimeInterval)age;

+ (NSString *)thumbCachePathForGUID:(NSString *)guid;

- (id)thumbRequest:(ReaderThumbRequest *)request priority:(BOOL)priority;

- (void)setObject:(UIImage *)image forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

- (void)removeNullForKey:(NSString *)key;

- (void)removeAllObjects;

@end
