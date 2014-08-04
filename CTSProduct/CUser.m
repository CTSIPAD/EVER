//
//  CFUser.m
//  iBoard
//
//  Created by DNA on 11/5/13.
//  Copyright (c) 2013 LBI. All rights reserved.
//

#import "CUser.h"
#import "CFPendingAction.h"
#import "GDataXMLNode.h"


@implementation CUser

-(id) initWithName:(NSString*)firstName LastName:(NSString*)lastName UserId:(NSString*)userId Token:(NSString *)token Language:(NSString*)language{
    
    if ((self = [super init])) {
        self.lastName = lastName;
		self.firstName = firstName;
        self.userId = userId;
        self.token=token;
        self.language=language;
        self.actions = [[NSMutableArray alloc] init];
        self.UserDetails = [[NSMutableArray alloc] init];

	}
    return self;
	
}

-(BOOL)processSingleAction:(CFPendingAction*)pa
{
	

	@try {
        NSString *post =[NSString stringWithFormat:@"%@",pa.actionUrl];
        
        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
        
    	NSString *serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
    

        NSString* fullUrl=[NSString stringWithFormat:@"http://%@",serverUrl];
        
        [request setURL:[NSURL URLWithString:fullUrl]];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        
        NSError *requestError;
        
        NSData *response = [ NSURLConnection sendSynchronousRequest: request returningResponse: nil error: &requestError ];
        
        
        
        if(response == nil )
        {
            if(requestError != nil)
            {
                NSLog(@"error in pending process, retry later");
            }
            
            //not processed so add it to queue
          //  [self addPendingAction:pa];
            
            
            return NO;
            //save local xml file now?
            
        }
        else {
            NSString * bigString2 = [[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding];
            NSLog(@"request: %@",post);
            NSLog(@"url: %@",request);
            NSLog(@"response to post %@",bigString2);
            
            
//            if([pa.type caseInsensitiveCompare:@"ROUTE"] == NSOrderedSame || [pa.type caseInsensitiveCompare:@"SUBMIT"] == NSOrderedSame )
//                [self updateUserAfterAction:pa];
            
        }
        
        
        
        return YES;
        
        
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
        
    }
}



- (NSString *)dataFilePath:(BOOL)forSave {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory
							   stringByAppendingPathComponent:[NSString stringWithFormat:@"%@pending.xml",self.userId]];
    if (forSave || [[NSFileManager defaultManager] fileExistsAtPath:documentsPath])
	{
        return documentsPath;
    } else {
        return [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@pending",self.userId] ofType:@"xml"];
    }
	
}
-(BOOL)processPendingActions
{
    //static URL where pending are saved
	
    //loop in actions
	BOOL success =YES;
	
	NSMutableArray* actionToKeep = [[NSMutableArray alloc] init];
    
	
	for( CFPendingAction* pa in self.actions)
	{
		//and send action url request
		//add token value to url
		
		
		if(![self processSingleAction:pa])
		{
			//pending action to keep
			[actionToKeep addObject:pa];
			
		}
        
		
	}
	
	
	//delete all action && pendingfile.xml
	[self.actions removeAllObjects];
	if(actionToKeep.count >0)
	{
		[self.actions setArray:actionToKeep];
		success = NO;
	}
	
	//AppDelegate *mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//RootViewController* rvc = mainDelegate.rootViewController;
	
	//[rvc.tableView reloadData];
	
	
	return success;
	
}


@end
