//
//  OfflineAction.m
//  CTSProduct
//
//  Created by DNA on 7/9/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "OfflineAction.h"

@implementation OfflineAction

-(id)initWithName:(NSString*)Id Url:(NSString*)Url Action:(NSString*)Action
{
    self = [super init];
    if (self) {
        self.Url=Url;
        self.Id=Id;
        self.Action=Action;
    }
    return self;
}
@end
