//
//  BuiltInActions.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BuiltInActions : NSObject
@property (nonatomic, retain) NSString *Id;
@property (nonatomic, retain) NSString *Action;
@property (nonatomic, retain) NSData *xml;

-(id)initWithName:(NSString*)Id  Action:(NSString*)Action xml:(NSData*)xml;

@end
