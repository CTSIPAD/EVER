//
//	ReaderThumbRequest.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReaderThumbView;

@interface ReaderThumbRequest : NSObject <NSObject>

@property (nonatomic, strong, readonly) NSURL *fileURL;
@property (nonatomic, strong, readonly) NSString *guid;
@property (nonatomic, strong, readonly) NSString *password;
@property (nonatomic, strong, readonly) NSString *cacheKey;
@property (nonatomic, strong, readonly) NSString *thumbName;
@property (nonatomic, strong, readwrite) ReaderThumbView *thumbView;
@property (nonatomic, assign, readonly) NSUInteger targetTag;
@property (nonatomic, assign, readonly) NSInteger thumbPage;
@property (nonatomic, assign, readonly) CGSize thumbSize;
@property (nonatomic, assign, readonly) CGFloat scale;

+ (id)newForView:(ReaderThumbView *)view fileURL:(NSURL *)url password:(NSString *)phrase guid:(NSString *)guid page:(NSInteger)page size:(CGSize)size;

- (id)initWithView:(ReaderThumbView *)view fileURL:(NSURL *)url password:(NSString *)phrase guid:(NSString *)guid page:(NSInteger)page size:(CGSize)size;

@end
