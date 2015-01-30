//
//  CFDestination.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CDestination : NSObject {
	NSString* name;
	NSString* rid;
}
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* rid;


-(id)initWithName:(NSString*)_name  Id:(NSString*)_rid;



@end
