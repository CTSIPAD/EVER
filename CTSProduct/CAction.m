//
//  CAction.m
//  CTSTest
//
//  Created by DNA on 1/17/14.
//  Copyright (c) 2014 LBI. All rights reserved.
//

#import "CAction.h"

@implementation CAction
@synthesize label,action,icon,popup,LookupId;
-(id)initWithLabel:(NSString*)actionLabel  icon:(NSString*)actionIcon  action:(NSString*)actionName popup:(BOOL) pop backhome:(BOOL)backh{
     if ((self = [super init])) {
         self.label=actionLabel;
         self.icon=actionIcon;
         self.action=actionName;
         self.popup=pop;
         self.backhome=backh;
         
     }
    return self;
}
-(id)initWithLabel:(NSString*)actionLabel  action:(NSString*)actionName popup:(BOOL) pop backhome:(BOOL)backh Custom:(BOOL)custom{
    if ((self = [super init])) {
        self.label=actionLabel;
        self.action=actionName;
        self.popup=pop;
        self.backhome=backh;
        self.Custom=custom;
        
    }
    return self;
}
-(void) encodeWithCoder: (NSCoder *) encoder
{
    [encoder encodeObject: self.label];
    [encoder encodeObject: self.icon];
    [encoder encodeObject: self.action];
    [encoder encodeObject: self.LookupId];
    [encoder encodeObject: [NSNumber numberWithInt:self.popup]];
    [encoder encodeObject:[NSNumber numberWithInt:self.backhome]];
    [encoder encodeObject:[NSNumber numberWithInt:self.Custom]];

}

-(id) initWithCoder: (NSCoder *) decoder
{
    self.label=[decoder decodeObject];
    self.icon=[decoder decodeObject];
    self.action=[decoder decodeObject];
    self.LookupId=[decoder decodeObject];
    self.popup=[[decoder decodeObject]boolValue];
    self.backhome=[[decoder decodeObject]boolValue];
    self.Custom=[[decoder decodeObject]boolValue];

    return self;
}
@end
