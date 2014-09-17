//
//  LookUpObject.m
//  CTSProduct
//
//  Created by DNA on 9/4/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "LookUpObject.h"

@implementation LookUpObject
-(id)initWithName:(NSString*)key  value:(NSString*)value{
    self = [super init];
    if (self) {
        
        self.key=key;
        self.value=value;
    }
    return self;
}

@end
