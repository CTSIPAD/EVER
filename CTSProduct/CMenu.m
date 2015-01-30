//
//  CMenu.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "CMenu.h"

@implementation CMenu

-(id) initWithName:(NSString*)name Id:(NSInteger)menuId Icon:(NSString*)icon{
    if ((self = [super init])) {
        self.name = name;
		self.icon = icon;
        self.menuId=menuId;
	}
    return self;
}
@end
