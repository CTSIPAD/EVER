//
//  Highlight.m
//  CTSProduct
//
//  Created by DNA on 7/4/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "HighlightClass.h"

@implementation HighlightClass
@synthesize ordinate,abscissa,x1,y1,status,PageNb,AttachmentId;

-(id)initWithName:(double )abscisa ordinate:(double )ordinat height:(double)h width:(double)w PageNb:(int)Pagenb AttachmentId:(int)Attachmentid
{
    self = [super init];
    if (self) {
        self.PageNb=Pagenb;
        self.abscissa = abscisa;
        self.ordinate = ordinat;
        self.x1 = h;
        self.y1=w;
        self.status=@"NEW";
        self.AttachmentId=Attachmentid;
    }
    return self;
}
-(void) encodeWithCoder: (NSCoder *) encoder
{
    [encoder encodeObject: self.status];
    [encoder encodeObject: [NSNumber numberWithInt:self.abscissa]];
    [encoder encodeObject:[NSNumber numberWithInt:self.ordinate]];
    [encoder encodeObject:[NSNumber numberWithInt:self.x1]];
    [encoder encodeObject:[NSNumber numberWithInt:self.y1]];
    [encoder encodeObject:[NSNumber numberWithInt:self.AttachmentId]];
    [encoder encodeObject:[NSNumber numberWithInt:self.PageNb]];


    
}

-(id) initWithCoder: (NSCoder *) decoder
{
    self.status=[decoder decodeObject];
    self.abscissa=[[decoder decodeObject]doubleValue];
    self.ordinate=[[decoder decodeObject]doubleValue];
    self.x1=[[decoder decodeObject]doubleValue];
    self.y1=[[decoder decodeObject]doubleValue];
    self.AttachmentId=[[decoder decodeObject]intValue];
    self.PageNb=[[decoder decodeObject]intValue];

    return self;
}

@end
