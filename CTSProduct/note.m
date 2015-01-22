//
//  note.m
//  CTSProduct
//
//  Created by DNA on 7/4/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "note.h"

@implementation note
@synthesize note,ordinate,abscissa,status,PageNb,AttachmentId;

-(id)initWithName:(double )abscisa ordinate:(double )ordinat note:(NSString *)notes PageNb:(int)Pagenb AttachmentId:(int)Attachmentid Id:(NSString*)Id
{
    self = [super init];
    if (self) {
        self.PageNb=Pagenb;
        self.abscissa = abscisa;
        self.ordinate = ordinat;
        self.note = notes;
        self.status=@"NEW";
        self.AttachmentId=Attachmentid;
        self.Id=Id;
    }
    return self;
}
-(void) encodeWithCoder: (NSCoder *) encoder
{
    [encoder encodeObject: self.status];
    [encoder encodeObject: self.Id];
    [encoder encodeObject: self.note];
    [encoder encodeObject: [NSNumber numberWithInt:self.abscissa]];
    [encoder encodeObject:[NSNumber numberWithInt:self.ordinate]];
    [encoder encodeObject:[NSNumber numberWithInt:self.AttachmentId]];
    [encoder encodeObject:[NSNumber numberWithInt:self.PageNb]];
    
    
    
}

-(id) initWithCoder: (NSCoder *) decoder
{
    self.status=[decoder decodeObject];
    self.Id=[decoder decodeObject];
    self.note=[decoder decodeObject];
    self.abscissa=[[decoder decodeObject]doubleValue];
    self.ordinate=[[decoder decodeObject]doubleValue];
    self.AttachmentId=[[decoder decodeObject]intValue];
    self.PageNb=[[decoder decodeObject]intValue];
    
    return self;
}
@end
