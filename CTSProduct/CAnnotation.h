//
//  CFAnnotation.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAnnotation : NSObject

@property (nonatomic, retain) NSString* note;
@property (nonatomic, retain) NSString* securityLevel;
@property (nonatomic, retain) NSString* Author;
@property (nonatomic, retain) NSString* CreationDate;
@property (nonatomic, assign) BOOL owner;
//@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger noteId;


-(id)initWithId:(NSInteger)noteId author:(NSString*)author securityLevel:(NSString*)security  note:(NSString*)note creationDate:(NSString*)date owner:(BOOL)isOwner;

@end
