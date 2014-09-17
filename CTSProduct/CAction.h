//
//  CAction.h
//  CTSTest
//
//  Created by DNA on 1/17/14.
//  Copyright (c) 2014 LBI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSCoder.h>
@interface CAction : NSObject<NSCoding>
{

NSString* label;
NSString* icon;
NSString* action;

}
@property (nonatomic, retain) NSString* label;
@property (nonatomic, retain) NSString* icon;
@property (nonatomic, retain) NSString* action;
@property (nonatomic, retain) NSString * LookupId;
@property (nonatomic, assign) BOOL Custom;
@property (nonatomic, assign) BOOL popup;
@property (nonatomic, assign) BOOL backhome;
@property (nonatomic, assign) BOOL Show;



-(id)initWithLabel:(NSString*)label  icon:(NSString*)icon  action:(NSString*)action popup:(BOOL) pop backhome:(BOOL)backh;
-(id)initWithLabel:(NSString*)label   action:(NSString*)action popup:(BOOL) pop backhome:(BOOL)backh Custom:(BOOL)custom;

@end
