//
//  CMenu.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMenu : NSObject
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, assign) NSInteger menuId;

@property (nonatomic, retain) NSMutableArray *correspondenceList;

-(id) initWithName:(NSString*)name Id:(NSInteger)menuId Icon:(NSString*)icon ;
@end
