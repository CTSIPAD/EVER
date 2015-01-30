//
//	ReaderThumbQueue.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReaderThumbQueue : NSObject <NSObject>

+ (ReaderThumbQueue *)sharedInstance;

- (void)addLoadOperation:(NSOperation *)operation;

- (void)addWorkOperation:(NSOperation *)operation;

- (void)cancelOperationsWithGUID:(NSString *)guid;

- (void)cancelAllOperations;

@end

#pragma mark -

//
//	ReaderThumbOperation class interface
//

@interface ReaderThumbOperation : NSOperation

@property (nonatomic, strong, readonly) NSString *guid;

- (id)initWithGUID:(NSString *)guid;

@end
