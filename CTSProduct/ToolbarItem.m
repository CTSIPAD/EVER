//
//  ToolbarItem.m
//  CTSProduct
//
//  Created by DNA on 7/23/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "ToolbarItem.h"

@implementation ToolbarItem
-(id)initWithName:(NSString*)name  Label:(NSString*)label Display:(BOOL)display Custom:(BOOL)custom popup:(BOOL) pop backhome:(BOOL)backh{
    self = [super init];
    if (self) {
        self.Name=name;
        self.Label=label;
        self.Display=display;
        self.Custom=custom;
        self.popup=pop;
        self.backhome=backh;
    }
    return self;

    
}
-(void) encodeWithCoder: (NSCoder *) encoder
{
    [encoder encodeObject: self.Name];
    [encoder encodeObject: self.Label];
    [encoder encodeObject: [NSNumber numberWithInt:self.Display]];
    [encoder encodeObject: [NSNumber numberWithInt:self.popup]];
    [encoder encodeObject:[NSNumber numberWithInt:self.backhome]];
    [encoder encodeObject:[NSNumber numberWithInt:self.Custom]];
}

-(id) initWithCoder: (NSCoder *) decoder
{
    self.Name=[decoder decodeObject];
    self.label=[decoder decodeObject];
    self.Display=[[decoder decodeObject]boolValue];
    self.popup=[[decoder decodeObject]boolValue];
    self.backhome=[[decoder decodeObject]boolValue];
    self.Custom=[[decoder decodeObject]boolValue];
    return self;
}

@end
