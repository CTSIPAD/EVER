//
//  UserDetail.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDetail : NSObject
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *detail;
-(id)initWithName:(NSString*)title  detail:(NSString*)detail;

@end
