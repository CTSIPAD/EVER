//
//  CSearchType.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "CSearchType.h"

@implementation CSearchType
-(id) initWithId:(NSInteger)typeId label:(NSString*)label icon:(NSString*)icon{
    
    if ((self = [super init])) {
        self.typeId=typeId;
        self.label=label;
        self.icon=icon;
	}
    return self;
	
}
@end
