//
//  LookUpObject.h
//  CTSProduct
//
//  Created by DNA on 9/4/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LookUpObject : NSObject
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *value;
-(id)initWithName:(NSString*)key  value:(NSString*)value;

@end
