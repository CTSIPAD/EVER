//
//  Highlight.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSCoder.h>

@interface HighlightClass : NSObject<NSCoding>
@property int PageNb;
@property int index;
@property int AttachmentId;
@property double abscissa;
@property double ordinate;
@property double x1;
@property double y1;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *Id;
-(id)initWithName:(double )abscisa ordinate:(double )ordinat height:(double)h width:(double)w PageNb:(int)Pagenb AttachmentId:(int)Attachmentid Id:(NSString*)Id;
@end
