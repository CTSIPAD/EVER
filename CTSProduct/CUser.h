//
//  CFUser.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CFPendingAction;

@interface CUser : NSObject
@property (nonatomic, retain) NSString *ServerMessage;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *loginName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString *language;
@property (nonatomic, retain) NSString *serviceType;
@property (nonatomic, retain) NSMutableArray *menu;
@property (nonatomic, retain) NSString *signature;
@property (nonatomic, retain) NSString *signatureId;
@property (nonatomic, retain) NSString *pincode;
@property (nonatomic, retain) NSArray* routeLabels;
//@property (nonatomic, retain) NSArray* destinations;
@property (nonatomic, retain) NSMutableDictionary* destinations;
@property (nonatomic, retain) NSMutableArray *actions;
@property (nonatomic, retain) NSMutableArray *UserDetails;
@property (nonatomic, retain) NSMutableArray* Sections;



-(id) initWithName:(NSString*)firstName LastName:(NSString*)lastName UserId:(NSString*)userId Token:(NSString *)token Language:(NSString*)language;
-(BOOL)processSingleAction:(CFPendingAction*) action;
-(BOOL)processPendingActions;
@end
