//
//  OfflineAction.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OfflineAction : NSObject
@property (nonatomic, retain) NSString *Id;
@property (nonatomic, retain) NSString *Url;
@property (nonatomic, retain) NSString *Action;

-(id)initWithName:(NSString*)Id Url:(NSString*)Url Action:(NSString*)Action;
@end
