//
//  CFDestination.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "CDestination.h"


@implementation CDestination

@synthesize name,rid;

-(id)initWithName:(NSString*)_name  Id:(NSString*)_rid
{
	if ((self = [super init])) {
        self.name = _name;
		self.rid = _rid;
	}
    return self;
	
}

- (void) dealloc {
	self.name = nil;
	self.rid = nil;
		
	
    
}
@end
