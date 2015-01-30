//
//	ReaderThumbFetch.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ReaderThumbQueue.h"

@class ReaderThumbRequest;

@interface ReaderThumbFetch : ReaderThumbOperation

- (id)initWithRequest:(ReaderThumbRequest *)options;

@end
