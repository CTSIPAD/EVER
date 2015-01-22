//
//  note.h
//  CTSProduct
//
//  Created by DNA on 7/4/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSCoder.h>

@interface note : NSObject<NSCoding>
@property int PageNb;
@property int AttachmentId;
@property double abscissa;
@property double ordinate;
@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *Id;
-(id)initWithName:(double )abscisa ordinate:(double )ordinat note:(NSString *)notes PageNb:(int)Pagenb AttachmentId:(int)Attachmentid Id:(NSString*)Id;
@end
