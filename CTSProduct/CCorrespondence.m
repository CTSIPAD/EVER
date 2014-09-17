//
//  CCorrespondence.m
//  CTSTest
//
//  Created by DNA on 12/12/13.
//  Copyright (c) 2013 LBI. All rights reserved.
//

#import "CCorrespondence.h"
#import "CParser.h"
#import "CFPendingAction.h"
#import "CUser.h"
#import "AppDelegate.h"

@implementation CCorrespondence

-(id) initWithId:(NSString*)correspondenceId Priority:(BOOL)priority New:(BOOL)isNew  SHOWLOCK:(BOOL)showlock {
    if ((self = [super init])) {
        self.QuickActions=[[NSMutableArray alloc]init];
        self.Id=correspondenceId;
        self.Priority=priority;
        self.New=isNew;
        self.ShowLocked = showlock;
    }
    return self;
}


-(BOOL)performCorrespondenceAction:(NSString*)action{
    
    BOOL isPerformed=NO;
    NSString* url;
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(appDelegate.SupportsServlets)
        url=[NSString stringWithFormat:@"http://%@?action=%@&token=%@&transferId=%@",appDelegate.serverUrl,action,appDelegate.user.token,self.TransferId];
    else
        url=[NSString stringWithFormat:@"http://%@/%@?token=%@&transferId=%@",appDelegate.serverUrl,action,appDelegate.user.token,self.TransferId];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:0 timeoutInterval:appDelegate.Request_timeOut];
    NSData *lockXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //NSURL *xmlUrl = [NSURL URLWithString:url];
  //  NSData *lockXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
    
    NSString *validationResult=[CParser ValidateWithData:lockXmlData];
    if(![validationResult isEqualToString:@"OK"]){
        if([validationResult isEqualToString:@"Cannot access to the server"])
            isPerformed=NO;
    }
    else
        isPerformed=YES;
    
    return isPerformed;
}


@end
