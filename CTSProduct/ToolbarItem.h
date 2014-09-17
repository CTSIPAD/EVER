//
//  ToolbarItem.h
//  CTSProduct
//
//  Created by DNA on 7/23/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSCoder.h>
@interface ToolbarItem : NSObject<NSCoding>
@property (nonatomic, retain) NSString *Name;
@property (nonatomic, retain) NSString *Label;
@property(nonatomic,assign)BOOL Display;
@property(nonatomic,assign)BOOL Custom;
@property (nonatomic, assign) BOOL popup;
@property (nonatomic, assign) BOOL backhome;
@property (nonatomic, retain) NSString * LookupId;
-(id)initWithName:(NSString*)name  Label:(NSString*)label Display:(BOOL)display Custom:(BOOL)custom popup:(BOOL) pop backhome:(BOOL)backh;
@end
