//
//  CFDestination.h
//  cfsPad
//
//  Created by marc balas on 09/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
