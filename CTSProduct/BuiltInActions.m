//
//  BuiltInActions.m
//  CTSProduct
//
//  Created by DNA on 7/9/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "BuiltInActions.h"

@implementation BuiltInActions

-(id)initWithName:(NSString*)Id  Action:(NSString*)Action xml:(NSData*)xml
{
    self = [super init];
    if (self) {
        self.Id=Id;
        self.Action=Action;
        self.xml=xml;
    }
    return self;
}

@end
