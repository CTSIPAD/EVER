//
//  UserDetail.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "UserDetail.h"

@implementation UserDetail
-(id)initWithName:(NSString*)title  detail:(NSString*)detail{
    self = [super init];
    if (self) {
        self.title=title;
        self.detail=detail;
        
    }
    return self;

}

@end
