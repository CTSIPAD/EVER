//
//  CFolder.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFolder : NSObject

@property (nonatomic, retain) NSString *Name;
@property (nonatomic, retain) NSMutableArray *attachments;
-(id) initWithName:(NSString*)name;
@end
