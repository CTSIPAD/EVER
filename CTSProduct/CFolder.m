//
//  CFolder.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "CFolder.h"

@implementation CFolder

-(id) initWithName:(NSString*)name{
    if ((self = [super init])) {
        self.Name = name;
    }
    return self;
}

@end
