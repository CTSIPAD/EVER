//
//  CFRouteLabel.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CRouteLabel : NSObject {

	NSString* name;
	NSString* labelId;
    NSString* note;
	
}
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* labelId;
@property (nonatomic, retain) NSString* note;


-(id)initWithName:(NSString*)_name  Id:(NSString*)_id;

@end
