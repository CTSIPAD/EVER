//
//  CParser.m
//  CTSTest
//
//  Created by DNA on 12/12/13.
//  Copyright (c) 2013 LBI. All rights reserved.
//

#import "CParser.h"
#import "AppDelegate.h"
#import "GDataXMLNode.h"
#import "CUser.h"
#import "CMenu.h"
#import "CCorrespondence.h"
#import "CFolder.h"
#import "CAttachment.h"
#import "CDestination.h"
#import "CRouteLabel.h"
#import "CAction.h"
#import "CAnnotation.h"
#import "CSearchCriteria.h"
#import "CSearch.h"
#import "CSearchType.h"
#import "NSData+Base64.h"
#import "OfflineAction.h"
#import "BuiltInActions.h"
#import "UserDetail.h"
#import "HighlightClass.h"
#import "note.h"
#import "ToolbarItem.h"
@implementation CParser{
    AppDelegate *mainDelegate;
    
}

+(void)ClearCache{
    
    /**************************** DELETE ALL RECORDS IN COREDATA *****************************/
    AppDelegate* objAppdelegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    NSError * error;
    // retrieve the store URL
    NSURL * storeURL = [[[objAppdelegate managedObjectContext] persistentStoreCoordinator] URLForPersistentStore:[[[[objAppdelegate managedObjectContext] persistentStoreCoordinator] persistentStores] lastObject]];
    // lock the current context
    [[objAppdelegate managedObjectContext] lock];
    [[objAppdelegate managedObjectContext] reset];//to drop pending changes
    //delete the store from the current managedObjectContext
    if ([[[objAppdelegate managedObjectContext] persistentStoreCoordinator] removePersistentStore:[[[[objAppdelegate managedObjectContext] persistentStoreCoordinator] persistentStores] lastObject] error:&error])
    {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        //recreate the store like in the  appDelegate method
        [[[objAppdelegate managedObjectContext] persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
    }
    [[objAppdelegate managedObjectContext] unlock];
    
    /***************************************************************************************/
}
+(void)ShowMessage:(NSString*)message{
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Alert",@"Alert")
                          message: message
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK",@"OK")
                          otherButtonTitles: nil];
    [alert show];
}

-(void)jess : (NSString *)path{
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.docUrl = [mainDelegate.docUrl stringByReplacingOccurrencesOfString:@"%5C" withString:@"\\"];
    
    for(CMenu* inbox in mainDelegate.user.menu)
    {
        if (inbox.correspondenceList.count>0)
        {
            for(CCorrespondence* correspondence in inbox.correspondenceList)
            {
                if (correspondence.attachmentsList.count>0)
                {
                    for(CAttachment* doc in correspondence.attachmentsList)
                    {
                        if([doc.url isEqualToString:mainDelegate.docUrl]){
                            doc.url = path;
                        }
                    }
                }
            }
        }
    }
}

-(void)john:(NSData *)xmlData{
    NSError *error;
    GDataXMLDocument *doc= [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    NSString* path;
    NSArray *signedfileinfo = [doc nodesForXPath:@"//URL" error:nil];
    if(signedfileinfo.count>0){
    GDataXMLElement *signedfileinfoXML =  [signedfileinfo objectAtIndex:0];
    path=signedfileinfoXML.stringValue;
    }
    [self jess:path];
    
}

+(NSMutableDictionary*)IsLockedCorrespondence:(NSString *)url {
    NSString* lockedby;
    NSString* userid;
    NSString* Islocked;
    NSError *myError;
    NSMutableDictionary* dict=[[NSMutableDictionary alloc]init];
    AppDelegate * mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // NSURL *xmlUrl = [NSURL URLWithString:url];
    // NSData *searchXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
    NSData *searchXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&myError];
    NSError *error;
    GDataXMLDocument *doc= [[GDataXMLDocument alloc] initWithData:searchXmlData options:0 error:&error];
    
     if(doc==nil)
    {
        NSLog(@"Error: failed to de-seriaize xml.");
        if (myError.code==NSURLErrorTimedOut) {
            NSLog(@"Error: Request timed out.");
            [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:NSLocalizedString(@"RequestTimedOut", @"request timed out") waitUntilDone:YES];
        }
    else
    {
        NSLog(@"Error: failed to connect to server.");
       [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:NSLocalizedString(@"UnableToConnect", @"unable to connect server") waitUntilDone:YES];
       
    }
         return nil;
        }
    NSArray *result = [doc nodesForXPath:@"//Result" error:nil];
    for (GDataXMLElement *res in result) {
        NSArray *ISLocked = [res elementsForName:@"IsLocked"];
        if(ISLocked.count>0){
            GDataXMLElement *isLockedEl = (GDataXMLElement *) [ISLocked objectAtIndex:0];
            Islocked = isLockedEl.stringValue;
            
        }
        NSArray *Lockedby = [res elementsForName:@"LockedBy"];
        if(Lockedby.count>0){
            GDataXMLElement *LockedbyEl = (GDataXMLElement *) [Lockedby objectAtIndex:0];
            lockedby = LockedbyEl.stringValue;
            
        }
        NSArray *LockedbyId = [res elementsForName:@"UserId"];
        if(LockedbyId.count>0){
            GDataXMLElement *LockedbyidEl = (GDataXMLElement *) [LockedbyId objectAtIndex:0];
            userid = LockedbyidEl.stringValue;
            
        }
        
    }
    if([Islocked boolValue] && lockedby!=nil){
        [dict setObject:lockedby forKey:@"lockedby"];
        [dict setObject:userid forKey:@"UserId"];
        
    }
    [dict setObject:Islocked forKey:@"IsLocked"];
    
    return dict;
}
+(CAttachment*)LoadNewAttachmentResults:(NSData *)xmlData docId:(NSString*)docid{
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
														   options:0 error:&error];
	NSArray *results = [doc nodesForXPath:@"//Result" error:nil];
	GDataXMLElement *resultXML =  [results objectAtIndex:0];
    
    NSArray *Folders = [resultXML elementsForName:@"Folder"];
    AppDelegate * mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CCorrespondence *correspondence=mainDelegate.searchModule.correspondenceList[docid.intValue];
    for(GDataXMLElement *FoldersEl in Folders) {
        NSString* folderName = [FoldersEl attributeForName:@"Name"].stringValue;
        NSString* folderId = [FoldersEl attributeForName:@"Id"].stringValue;
//        for(CAttachment* attach in correspondence.attachmentsList){
//            if([attach.FolderId isEqualToString: folderId]){
//                folderName=attach.FolderName;
//            }
//        }
        NSArray *attachmentXML = [FoldersEl elementsForName:@"Attachment"];
        

        for(GDataXMLElement *attachment in attachmentXML)
        {
            NSString *urlattach;
            NSString *idattach;
            NSString *thumbnailurlattach;
            NSString* FileName;
            NSString* isOriginalMail;
            NSString* attachmentStatus;
            
                NSArray *ids = [attachment elementsForName:@"AttachmentId"];
                if (ids.count > 0) {
                    GDataXMLElement *idEl = (GDataXMLElement *) [ids objectAtIndex:0];
                    idattach = idEl.stringValue;
                }
                
                NSArray *urls = [attachment elementsForName:@"URL"];
                if (urls.count > 0) {
                    GDataXMLElement *urlEl = (GDataXMLElement *) [urls objectAtIndex:0];
                    urlattach = urlEl.stringValue;
                }
                
                NSArray *thumbnailurls = [attachment elementsForName:@"ThumbnailURL"];
                if (thumbnailurls.count > 0) {
                    GDataXMLElement *thumbnailurlEl = (GDataXMLElement *) [thumbnailurls objectAtIndex:0];
                    thumbnailurlattach = thumbnailurlEl.stringValue;
                }
                NSArray *FileNames = [attachment elementsForName:@"FileName"];
                if (FileNames.count > 0) {
                    GDataXMLElement *FileNameEL = (GDataXMLElement *) [FileNames objectAtIndex:0];
                    FileName = FileNameEL.stringValue;
                }
            
                NSArray *isOriginalMails = [attachment elementsForName:@"IsOriginalMail"];
                if (isOriginalMails.count > 0) {
                    GDataXMLElement *isOriginalMailEl= (GDataXMLElement *) [isOriginalMails objectAtIndex:0];
                    isOriginalMail = isOriginalMailEl.stringValue;
                }
            NSArray *statusArray=[attachment elementsForName:@"Status"];
            if (statusArray.count>0) {
                GDataXMLElement *statusEl=(GDataXMLElement*)[statusArray objectAtIndex:0];
                attachmentStatus=statusEl.stringValue;
            }
            
            
            
            CAttachment* attachment=[[CAttachment alloc]initWithTitle:FileName docId:docid url:urlattach AttachmentId:idattach ThubnailUrl:thumbnailurlattach isOriginalMail:isOriginalMail FolderName:folderName];
            [attachment setFolderId:folderId];
            [attachment setStatus:attachmentStatus];

            if(correspondence.attachmentsList==nil){
                correspondence.attachmentsList=[[NSMutableArray alloc]init];
                mainDelegate.FolderName=folderName;
                mainDelegate.FolderId=folderId;
            }
            if(correspondence.attachmentsList.count==1){
                if(((CAttachment*)correspondence.attachmentsList[0]).AttachmentId.intValue==-1){
                    [correspondence.attachmentsList removeAllObjects];
                }
            }
            [correspondence.attachmentsList addObject:attachment];
            

            return attachment;
        }
    }
    return nil;
}
+(NSString*)ValidateWithData:(NSData *)xmlData{
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
														   options:0 error:&error];
    if (doc == nil) {
        NSLog(@"Error: failed to de-seriaize xml.");
        if (error.code==NSURLErrorTimedOut) {
            NSLog(@"Error: Request timed out.");
            [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:NSLocalizedString(@"RequestTimedOut", @"request timed out") waitUntilDone:YES];
            return NSLocalizedString(@"RequestTimedOut", @"request timed out");
        }
        else{
            NSLog(@"Error: failed to connect to server.");
            NSString* ErrorMessage=@"Unable to connect Server";
            [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:ErrorMessage waitUntilDone:YES];
            return @"Unable to connect Server";
        }
        NSLog(@"Error:%@",error);
    }
    
    
	NSArray *results = [doc nodesForXPath:@"//Result" error:nil];
    if(results.count==0)
        return @"Unkown Server Error occured";
	GDataXMLElement *resultXML =  [results objectAtIndex:0];
    NSString* status=[(GDataXMLElement *) [resultXML attributeForName:@"Status"] stringValue];
    NSString* ErrorMessage=NSLocalizedString(@"UnkownError",@"Unkown Server Error occured");
    NSArray *Message = [resultXML elementsForName:@"ErrorMessage"];
    if (Message.count > 0) {
        GDataXMLElement *msgEl = (GDataXMLElement *) [Message objectAtIndex:0];
        ErrorMessage = msgEl.stringValue;
    }
    
    if([[status uppercaseString] isEqualToString:@"ERROR"]){
        return ErrorMessage;
    }
    return @"OK";
}
+(NSMutableArray*)loadRecipients:(NSString*) url section:(NSString*)section{
    NSData *xmlData ;
    AppDelegate * mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error;
    NSError* myError;
    NSMutableArray* destinations = [[NSMutableArray alloc] init];
    
    if(!mainDelegate.isOfflineMode){
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[url  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
        
        xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&myError];
        if (myError.code==NSURLErrorTimedOut) {
             [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:NSLocalizedString(@"RequestTimedOut", @"request timed out") waitUntilDone:YES];
        }
        else
        {
        
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                               options:0 error:&error];
        
        NSArray *results = [doc nodesForXPath:@"//Result" error:nil];
        GDataXMLElement *recipients =  [results objectAtIndex:0];
        NSString* status=[(GDataXMLElement *) [recipients attributeForName:@"Status"] stringValue];
        NSString* ErrorMessage=NSLocalizedString(@"UnkownError",@"Unkown Server Error occured");
        NSArray *Message = [recipients elementsForName:@"ErrorMessage"];
        if (Message.count > 0) {
            GDataXMLElement *msgEl = (GDataXMLElement *) [Message objectAtIndex:0];
            ErrorMessage = msgEl.stringValue;
        }
        
        if([[status uppercaseString] isEqualToString:@"ERROR"]){
            [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:ErrorMessage waitUntilDone:YES];

        }
        NSArray *Destinations =[recipients elementsForName:@"Destinations"];
        for (GDataXMLElement *destEl in Destinations) {
            NSArray* dests=[destEl nodesForXPath:@"Destination" error:nil];
            for(GDataXMLElement* item in dests){
                NSString *DestId=[(GDataXMLElement *) [item attributeForName:@"Id"] stringValue ];
                NSString* value = item.stringValue;
                CDestination* dest = [[CDestination alloc] initWithName:value Id:DestId];
                [destinations addObject:dest];
            }
            
        }
    }
    }
    else{
        destinations=[self LoadCachedDestinations:section];
    }
    return destinations;
	
    
}

+ (CUser *)loadUserWithData:(NSString *)url {
    NSLog(@"Info: Enter Method LoadUserWithData");
    NSLog(@"Parameters: URL=%@",url);
    NSData *xmlData ;
    AppDelegate * mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    NSString* IconsCached = [defaults objectForKey:@"iconsCache"];
    NSError *error;
    NSError *myError;
    if(!mainDelegate.isOfflineMode){
        NSLog(@"Info: Online Mode.");
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
        NSLog(@"Info:Preparing and Calling Request.");
        // NSURL *xmlUrl = [NSURL URLWithString:url];
        //xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&myError];
        NSLog(@"Caching Login XML");
        [self cacheXml:@"Login" xml:xmlData nb:@"0" name:@""];
    }
    else{
        NSLog(@"Offline Mode");
        NSLog(@"Loading Xml from cache.");
        xmlData=[self LoadXML:@"Login" nb:@"0" name:@""];
    }
    NSLog(@"Info: parsing returned data to XML.");
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
														   options:0 error:&error];
    NSLog(@"Info:Reading Result Tag");
	NSArray *results = [doc nodesForXPath:@"//Result" error:nil];
	
    
    
	//LOAD first user in XML
	GDataXMLElement *userXML =  [results objectAtIndex:0];
    
    NSLog(@"Info:Reading Lookups Tag from xml.");
    NSArray *Lookups =[userXML elementsForName:@"Lookups"];
    NSMutableDictionary* allLookups = [[NSMutableDictionary alloc] init];
    for (GDataXMLElement *LookupEl in Lookups) {
        NSArray *Lookup =[LookupEl elementsForName:@"Lookup"];
        for(GDataXMLElement* LookupItem in Lookup){
            NSMutableDictionary* LookupList = [[NSMutableDictionary alloc] init];
            
            NSString *LookupId=[(GDataXMLElement *) [LookupItem attributeForName:@"Id"] stringValue ];
            NSArray* LookupItems=[LookupItem nodesForXPath:@"Item" error:nil];
            for(GDataXMLElement* item in LookupItems){
                
                NSString* ItemId=[(GDataXMLElement *) [item attributeForName:@"Id"] stringValue ];
                NSString* value = item.stringValue;
                [LookupList setObject:value forKey:ItemId];
            }
            [allLookups setObject:LookupList forKey:LookupId];
            
        }
        
    }
    mainDelegate.Lookups=[[NSMutableDictionary alloc]init];
    mainDelegate.Lookups=allLookups;
    
    NSLog(@"Info:Reading Status tag.");
    NSString* status=[(GDataXMLElement *) [userXML attributeForName:@"Status"] stringValue];
    if([status isEqualToString:@"OK"]){
        NSLog(@"Info:Status OK!");
        //fill by user data
        NSString* firstName;
        NSString* userId;
        NSString* lastName;
        NSString * token;
        NSString *language;
        NSString *signature;
        NSString *signatureId;
        NSString *pincode;
        NSString *serviceType;
        NSString* logo;
        NSMutableDictionary* destDict = [[NSMutableDictionary alloc] init];
        
        NSMutableArray* destinations = [[NSMutableArray alloc] init];
        NSMutableArray* routesLabel = [[NSMutableArray alloc] init];
        NSMutableArray* userdetails = [[NSMutableArray alloc] init];
        
        NSArray *UserDetails =[doc nodesForXPath:@"//UserDetails" error:nil];
        for (GDataXMLElement *userdetail in UserDetails) {
            NSArray *IconsList = [userdetail elementsForName:@"Item"];
            if(IconsList.count>0){
                for (GDataXMLElement *actionItem in IconsList) {
                    
                    NSString *title;
                    NSString * detail;
                    
                    NSArray *titles = [actionItem elementsForName:@"Key"];
                    if (titles.count > 0) {
                        GDataXMLElement *titleEl = (GDataXMLElement *) [titles objectAtIndex:0];
                        title = titleEl.stringValue;
                    }
                    NSArray *details = [actionItem elementsForName:@"Value"];
                    if (details.count > 0) {
                        GDataXMLElement *detailEl = (GDataXMLElement *) [details objectAtIndex:0];
                        detail = detailEl.stringValue;
                    }
                    UserDetail* obj=[[UserDetail alloc]initWithName:title detail:detail];
                    [userdetails addObject:obj];
                }
            }
        }
        
        NSArray *tokens = [userXML elementsForName:@"Token"];
        if (tokens.count > 0) {
            GDataXMLElement *tokenEl = (GDataXMLElement *) [tokens objectAtIndex:0];
            token = tokenEl.stringValue;
        }
        
        NSArray *userIds = [userXML elementsForName:@"UserId"];
        if  (userIds.count > 0) {
            GDataXMLElement *userIdEl = (GDataXMLElement *) [userIds objectAtIndex:0];
            userId = userIdEl.stringValue;
            //userId=@"201";
        }
        
        NSArray *firstNames = [userXML elementsForName:@"FirstName"];
        if (firstNames.count > 0) {
            GDataXMLElement *firstNameEl = (GDataXMLElement *) [firstNames objectAtIndex:0];
            firstName = firstNameEl.stringValue;
        }
        NSArray *signatures = [userXML elementsForName:@"Signature"];
        if  (signatures.count > 0) {
            GDataXMLElement *signatureEl = (GDataXMLElement *) [signatures objectAtIndex:0];
            signature = signatureEl.stringValue;
        }
        NSArray *SignatureId = [userXML elementsForName:@"SignatureId"];
        if  (SignatureId.count > 0) {
            GDataXMLElement *signatureIdEl = (GDataXMLElement *) [SignatureId objectAtIndex:0];
            signatureId = signatureIdEl.stringValue;
        }
        NSArray *pincodes = [userXML elementsForName:@"Pincode"];
        if  (pincodes.count > 0) {
            GDataXMLElement *pincodeEl = (GDataXMLElement *) [pincodes objectAtIndex:0];
            pincode = pincodeEl.stringValue;
        }
        
        if([IconsCached isEqualToString:@"NO"]||[IconsCached isEqualToString:@""] || IconsCached==nil){
            NSArray *icons = [userXML elementsForName:@"Logo"];
            if (icons.count > 0) {
                GDataXMLElement *iconEl = (GDataXMLElement *) [icons objectAtIndex:0];
                logo = iconEl.stringValue;
                NSData * data= [NSData dataWithBase64EncodedString:logo];
                
                [self cacheIcon:@"logo" value:data];
                mainDelegate.logo=data;
                
                
            }
        }
        else{
            mainDelegate.logo=[self LoadCachedIcons:@"logo"];
        }
        NSArray *lastNames = [userXML elementsForName:@"LastName"];
        if  (lastNames.count > 0) {
            GDataXMLElement *lastNameEl = (GDataXMLElement *) [lastNames objectAtIndex:0];
            lastName = lastNameEl.stringValue;
        }
        
        NSArray *languages = [userXML elementsForName:@"Language"];
        if  (languages.count > 0) {
            GDataXMLElement *languageEl = (GDataXMLElement *) [languages objectAtIndex:0];
            language = languageEl.stringValue;
        }
        
        
        NSArray *services = [userXML elementsForName:@"ServiceType"];
        if  (services.count > 0) {
            GDataXMLElement *serviceEl = (GDataXMLElement *) [services objectAtIndex:0];
            serviceType = serviceEl.stringValue;
        }
        if([IconsCached isEqualToString:@"NO"]||[IconsCached isEqualToString:@""]|| IconsCached==nil){
            NSArray *MoreIcons =[doc nodesForXPath:@"//CustomActions" error:nil];
            for (GDataXMLElement *MoreIcon in MoreIcons) {
                NSArray *IconsList = [MoreIcon elementsForName:@"CustomAction"];
                if(IconsList.count>0){
                    for (GDataXMLElement *actionItem in IconsList) {
                        
                        NSString *action;
                        NSString * icon;
                        
                        NSArray *actions = [actionItem elementsForName:@"Name"];
                        if (actions.count > 0) {
                            GDataXMLElement *actionEl = (GDataXMLElement *) [actions objectAtIndex:0];
                            action = actionEl.stringValue;
                        }
                        NSArray *icons = [actionItem elementsForName:@"Icon"];
                        if (icons.count > 0) {
                            GDataXMLElement *iconEl = (GDataXMLElement *) [icons objectAtIndex:0];
                            icon = iconEl.stringValue;
                        }
                        NSData * icondata= [NSData dataWithBase64EncodedString:icon];
                        
                        [self cacheIcon:action value:icondata];
                        
                    }
                }
            }
        }
        NSArray *routes = [doc nodesForXPath:@"//TransferData" error:nil];
        NSMutableArray* Sections=[[NSMutableArray alloc]init];

        for (GDataXMLElement *route in routes) {
            
            
            NSArray *destinationsList = [route elementsForName:@"Sections"];
            
            NSArray *routeLabelList = [route elementsForName:@"Purposes"];
            
            NSMutableArray* keys=[[NSMutableArray alloc]init];
            NSMutableArray* values=[[NSMutableArray alloc]init];
            if (destinationsList.count > 0) {
                
                GDataXMLElement *destinationsXml = (GDataXMLElement *) [destinationsList objectAtIndex:0];
                
                NSArray *destinationsEl = [destinationsXml elementsForName:@"Section"];
                
                for (GDataXMLElement * destEl in destinationsEl) {
                    NSArray *SectionsList = [destEl elementsForName:@"Destination"];
                    NSString* SectionId = [destEl attributeForName:@"Id"].stringValue;
                    NSString* SectionValue=destEl.stringValue;
                    LookUpObject* sect=[[LookUpObject alloc]initWithName:SectionId value:SectionValue];
                    [Sections addObject:sect];

                    if(SectionsList.count>0){
                        for (GDataXMLElement *destinationItem in SectionsList) {
                            
                            NSString* destId = [destinationItem attributeForName:@"Id"].stringValue;
                            NSString* value = destinationItem.stringValue;
                            CDestination* dest = [[CDestination alloc] initWithName:value Id:destId];
                            [destinations addObject:dest];
                        }
                    }
                    [keys addObject:SectionId];
                    [values addObject:[destinations copy]];
                    
                    [destinations removeAllObjects];
                    
                }
                for(int i=0;i<keys.count;i++)
                    [destDict setObject:values[i] forKey:keys[i]];
            }
            
            if (routeLabelList.count > 0) {
                
                GDataXMLElement *labels = (GDataXMLElement *) [routeLabelList objectAtIndex:0];
                
                NSArray *labelsEl = [labels elementsForName:@"Purpose"];
                
                for (GDataXMLElement * destEl in labelsEl) {
                    
                    NSString* destId = [destEl attributeForName:@"Id"].stringValue;
                    NSString* value = destEl.stringValue;
                    
                    CRouteLabel* rlabel = [[CRouteLabel alloc] initWithName:value Id:destId];
                    [routesLabel addObject:rlabel];
                    
                }
            }
           // CRouteLabel* rlabel = [[CRouteLabel alloc] initWithName:@"NO LABEL" Id:@"NONE"];
            //[routesLabel addObject:rlabel];
        }
        NSMutableArray *menuItems;
        if([IconsCached isEqualToString:@"NO"]||[IconsCached isEqualToString:@""] || IconsCached==nil){
            [defaults setObject:@"YES" forKey:@"iconsCache"];
            [defaults synchronize];
            
            NSArray *menus =[doc nodesForXPath:@"//Inbox/InboxItems/InboxItem" error:nil];
            menuItems =  [self loadMenuListWith:menus];
        }
        else{
            menuItems =  [self LoadInboxItems];
            
        }
        
        CUser *user = [[CUser alloc] initWithName:firstName LastName:lastName UserId:userId Token:token Language:language];
        [user setServiceType:serviceType];
        [user setMenu:menuItems];
        [user setSignature:signature];
        [user setPincode:pincode];
        [user setDestinations:destDict];
        [user setRouteLabels:routesLabel];
        [user setUserDetails:userdetails];
        [user setServerMessage:status];
        [user setSections:Sections];
        [user setSignatureId:signatureId];
        return user;
    }
    else{
        NSLog(@"Info:Status Error!");

        CUser *user = [[CUser alloc] init ];
        NSString* ErrorMessage;
        if (myError.code==NSURLErrorTimedOut) {
            NSLog(@"Error: Request timed out");
             ErrorMessage=NSLocalizedString(@"RequestTimedOut", @"request timed out");
        }
        else
        {
            ErrorMessage=NSLocalizedString(@"UnableToConnect", @"unable to connect server");
            NSArray *Message = [userXML elementsForName:@"ErrorMessage"];
            if (Message.count > 0) {
                GDataXMLElement *msgEl = (GDataXMLElement *) [Message objectAtIndex:0];
                ErrorMessage = msgEl.stringValue;
            }
            NSLog(@"Error:%@",ErrorMessage);
        }
        [user setServerMessage:ErrorMessage];
        return user;
    }
}

+(void)LoadDepartmentChanges:(NSData *) xmlData{
    AppDelegate * mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
														   options:0 error:&error];
    
	NSArray *results = [doc nodesForXPath:@"//Result" error:nil];
	
	GDataXMLElement *userXML =  [results objectAtIndex:0];
    NSString* status=[(GDataXMLElement *) [userXML attributeForName:@"Status"] stringValue];
    if([status isEqualToString:@"OK"]){
        
        NSString* lastName;
        
        
        NSMutableArray* routesLabel = [[NSMutableArray alloc] init];
        NSArray *lastNames = [userXML elementsForName:@"DepartmentName"];
        if  (lastNames.count > 0) {
            GDataXMLElement *lastNameEl = (GDataXMLElement *) [lastNames objectAtIndex:0];
            lastName = lastNameEl.stringValue;
        }
        
        NSArray *routes = [doc nodesForXPath:@"//TransferData" error:nil];
        
        for (GDataXMLElement *route in routes) {
            
            
            
            NSArray *routeLabelList = [route elementsForName:@"Purposes"];
            
            if (routeLabelList.count > 0) {
                
                GDataXMLElement *labels = (GDataXMLElement *) [routeLabelList objectAtIndex:0];
                
                NSArray *labelsEl = [labels elementsForName:@"Purpose"];
                
                for (GDataXMLElement * destEl in labelsEl) {
                    
                    NSString* destId = [destEl attributeForName:@"Id"].stringValue;
                    NSString* value = destEl.stringValue;
                    
                    CRouteLabel* rlabel = [[CRouteLabel alloc] initWithName:value Id:destId];
                    [routesLabel addObject:rlabel];
                    
                }
            }
           // CRouteLabel* rlabel = [[CRouteLabel alloc] initWithName:@"NO LABEL" Id:@"NONE"];
            //[routesLabel addObject:rlabel];
        }
        NSMutableArray* menuItems = [[NSMutableArray alloc] init];
        
        NSFetchRequest *fetchRequest;
        NSError *error;
        NSEntityDescription *entity;
        id delegate = [[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
        
        fetchRequest = [[NSFetchRequest alloc] init];
        entity = [NSEntityDescription
                  entityForName:@"InboxItems" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        NSMutableDictionary * cachedmenuItems=[[NSMutableDictionary alloc]init];
        NSString * menuId;
        NSString *icon;
        
        for (NSManagedObject *obj in fetchedObjects) {
            
            menuId=[obj valueForKey:@"id"];
            icon=[obj valueForKey:@"icon"];
            [cachedmenuItems setObject:icon forKey:menuId];
            
        }
        [self DeleteOfflineActions:@"InboxItems"];
        NSArray *menus =[doc nodesForXPath:@"//Inbox/InboxItems/InboxItem" error:nil];
        if (menus.count > 0) {
            
            
            for (GDataXMLElement *menuItem in menus) {
                
                NSInteger menuId;
                NSString *name;
                NSString *icon;
                
                NSArray *menuIds = [menuItem elementsForName:@"InboxId"];
                GDataXMLElement *menuIdEl = (GDataXMLElement *) [menuIds objectAtIndex:0];
                menuId = [menuIdEl.stringValue integerValue];
                
                
                NSArray *names = [menuItem elementsForName:@"Name"];
                if (names.count > 0) {
                    GDataXMLElement *nameEl = (GDataXMLElement *) [names objectAtIndex:0];
                    name = nameEl.stringValue;
                }
                
                icon = [cachedmenuItems objectForKey:menuIdEl.stringValue];
                
                [self cacheInboxItem:menuIdEl.stringValue icon:icon name:name];
                CMenu* menu = [[CMenu alloc] initWithName:name Id:menuId Icon:icon];
                
                [menuItems addObject:menu];
            }
            
        }
        [mainDelegate.user setMenu:menuItems];
        [mainDelegate.user setLastName:lastName];
        [mainDelegate.user setRouteLabels:routesLabel];
    }
    
    
}
+(NSData*)LoadCachedIcons:(NSString*)key{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSPredicate *predicate;
    NSEntityDescription *entity;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"ICONS" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:@"key==%@",key];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"key" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSData * data;
    for (NSManagedObject *obj in fetchedObjects) {
        
        data=[obj valueForKey:@"value"];
        
    }
    return data;
}
+(NSMutableArray*)LoadInboxItems{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSEntityDescription *entity;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"InboxItems" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray * menuItems=[[NSMutableArray alloc]init];
    NSInteger menuId;
    NSString *name;
    NSString *icon;
    
    for (NSManagedObject *obj in fetchedObjects) {
        
        menuId=[[obj valueForKey:@"id"]integerValue];
        name=[obj valueForKey:@"name"];
        icon=[obj valueForKey:@"icon"];
        
        CMenu* menu = [[CMenu alloc] initWithName:name Id:menuId Icon:icon];
        
        [menuItems addObject:menu];
        
    }
    return menuItems;
}

+(void)cacheInboxItem:(NSString*)Inboxid icon:(NSString*)icon name:(NSString*)name{
    NSError *error;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    NSManagedObject *dataRecord = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"InboxItems"
                                   inManagedObjectContext:managedObjectContext];
    [dataRecord setValue:Inboxid forKey:@"id"];
    [dataRecord setValue:name forKey:@"name"];
    [dataRecord setValue:icon forKey:@"icon"];
    
    if (![managedObjectContext save:&error]) {
        
        NSLog(@"Error:%@", error);
    }
    
}
+(void)cacheOfflineActions:(NSString*)Id url:(NSString*)url action:(NSString*)action{
    NSError *error;
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    NSManagedObject *dataRecord = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"OfflineActions"
                                   inManagedObjectContext:managedObjectContext];
    [dataRecord setValue:Id forKey:@"id"];
    [dataRecord setValue:url forKey:@"url"];
    [dataRecord setValue:action forKey:@"action"];
    //  [self LoadXML:Id nb:nb];
    if (![managedObjectContext save:&error]) {
        
        NSLog(@"Error:%@", error);
    }
    
}
+(void)cacheBuiltInActions:(NSString*)Id action:(NSString*)action xml:(NSData*)xml{
    NSError *error;
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    NSManagedObject *dataRecord = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"BuiltInActions"
                                   inManagedObjectContext:managedObjectContext];
    [dataRecord setValue:Id forKey:@"id"];
    [dataRecord setValue:action forKey:@"action"];
    [dataRecord setValue:xml forKey:@"xml"];
    
    if (![managedObjectContext save:&error]) {
        
        NSLog(@"Error:%@", error);
    }
    
}
+(void)DeleteOfflineActions:(NSString*)name{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSArray *fetchedObjects;
    NSEntityDescription *entity;
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:name inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in fetchedObjects) {
        [managedObjectContext deleteObject:obj];
    }
    
}
+(int)EntitySize:(NSString*)name{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSEntityDescription *entity;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:name inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return [fetchedObjects count];
}
+(NSMutableArray*)LoadOfflineActions{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSEntityDescription *entity;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"OfflineActions" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray* offlineActions=[[NSMutableArray alloc]init];
    
    for (NSManagedObject *obj in fetchedObjects) {
        NSString* url=[obj valueForKey:@"url"];
        NSString* Id=[obj valueForKey:@"Id"];
        NSString* action=[obj valueForKey:@"action"];
        
        OfflineAction* obj=[[OfflineAction alloc]initWithName:Id Url:url Action:action];
        [offlineActions addObject:obj];
        
    }
    return offlineActions;
}
+(NSMutableArray*)LoadBuiltInActions{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSEntityDescription *entity;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"BuiltInActions" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray* BuiltinActions=[[NSMutableArray alloc]init];
    
    for (NSManagedObject *obj in fetchedObjects) {
        NSString* Id=[obj valueForKey:@"Id"];
        NSString* action=[obj valueForKey:@"action"];
        NSData* xml=[obj valueForKey:@"xml"];
        BuiltInActions* obj=[[BuiltInActions alloc]initWithName:Id Action:action xml:xml];
        [BuiltinActions addObject:obj];
        
    }
    // [self DeleteOfflineActions:@"BuiltInActions"];
    return BuiltinActions;
}

+(void)cacheXml:(NSString*)Id xml:(NSData*)xml nb:(NSString*)nb name:(NSString*)name{
    [self DeleteXML:Id nb:nb name:name];
    NSError *error;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    NSManagedObject *dataRecord = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"XMLS"
                                   inManagedObjectContext:managedObjectContext];
    [dataRecord setValue:Id forKey:@"id"];
    [dataRecord setValue:xml forKey:@"xml"];
    [dataRecord setValue:nb forKey:@"nb"];
    [dataRecord setValue:name forKey:@"name"];
    if (![managedObjectContext save:&error]) {
        
        NSLog(@"Error:%@", error);
    }
    
}
+(void)cacheLogin:(NSString*)username password:(NSString*)password {
    [self DeleteLogin];
    NSError *error;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    NSManagedObject *dataRecord = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"Login"
                                   inManagedObjectContext:managedObjectContext];
    [dataRecord setValue:password forKey:@"password"];
    [dataRecord setValue:username forKey:@"username"];
    if (![managedObjectContext save:&error]) {
        
        NSLog(@"Error:%@", error);
    }
    
}
+(BOOL)LoadLogin:(NSString*)username password:(NSString*)password{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSPredicate *predicate;
    NSEntityDescription *entity;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"Login" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:@"(username = %@) AND (password = %@)",username,password];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects.count;
}
+(void)DeleteLogin{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSArray *fetchedObjects;
    NSEntityDescription *entity;
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"Login" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in fetchedObjects) {
        [managedObjectContext deleteObject:obj];
    }
    
}
+(void)cacheCorrespondence:(NSString*)correspondenceId Status:(NSString*)Status InboxId:(NSString*)InboxId priority:(NSString*)priority new:(NSString*)new showlock:(NSString*)showlock transferId:(NSString*)transferId thumbnailurl:(NSString*)thumbnailurl SystemProperties:(NSData*)SystemProperties Properties:(NSData*)properties toolbarItems:(NSData*)toolbarItems CustomActions:(NSData*)CustomActions SignActions:(NSData*)SignActions
           AttachmentsList:(NSData*)AttachmentsList AnnotationsList:(NSData*)AnnotationsList CustomItemsList:(NSData*)CustomItemsList QuickActions:(NSData*)QuickActions{
    
    [self DeleteCorrespondence:correspondenceId inboxId:InboxId];
    NSError *error;
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    NSManagedObject *dataRecord = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"Correspondences"
                                   inManagedObjectContext:managedObjectContext];
    [dataRecord setValue:correspondenceId forKey:@"correspondenceid"];
    [dataRecord setValue:InboxId forKey:@"inboxid"];
    [dataRecord setValue:Status forKey:@"status"];
    [dataRecord setValue:priority forKey:@"priority"];
    [dataRecord setValue:new forKey:@"new"];
    [dataRecord setValue:showlock forKey:@"showlock"];
    [dataRecord setValue:transferId forKey:@"transferid"];
    [dataRecord setValue:thumbnailurl forKey:@"thumbnailurl"];
    [dataRecord setValue:SystemProperties forKey:@"systemproperties"];
    [dataRecord setValue:properties forKey:@"Properties"];
    [dataRecord setValue:toolbarItems forKey:@"toolbaritems"];
    [dataRecord setValue:CustomActions forKey:@"customactions"];
    [dataRecord setValue:SignActions forKey:@"signactions"];
    [dataRecord setValue:AttachmentsList forKey:@"attachmentslist"];
    [dataRecord setValue:AnnotationsList forKey:@"annotationslist"];
    [dataRecord setValue:CustomItemsList forKey:@"customitemslist"];
    [dataRecord setValue:QuickActions forKey:@"quickactions"];
//    if (![managedObjectContext save:&error]) {
//        
//        NSLog(@"Error:%@", error);
//    }
    
}
+(void)DeleteCorrespondence:(NSString*)CorrespondenceId inboxId:(NSString*)InboxId{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSPredicate *predicate;
    NSArray *fetchedObjects;
    NSEntityDescription *entity;
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"Correspondences" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:@"(correspondenceid = %@) AND (inboxid = %@)", CorrespondenceId,InboxId];
    [fetchRequest setPredicate:predicate];
    fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in fetchedObjects) {
        [managedObjectContext deleteObject:obj];
    }
    
}

+(NSMutableDictionary*)LoadCorrespondences:(int)inboxId{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSEntityDescription *entity;
    NSPredicate* predicate;
    NSString* InboxId=[NSString stringWithFormat:@"%d",inboxId];
    AppDelegate* mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"Correspondences" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:@"(inboxid = %@)",InboxId];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"correspondenceid" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSString* transferId;
    NSString *Id;
    BOOL Priority;
    BOOL New;
    BOOL SHOWLOCK;
    NSString* thumbnailUrl;
    NSString* Status;
    NSMutableArray* Allcorrespondences = [[NSMutableArray alloc] init];
    NSMutableDictionary* allInboxes = [[NSMutableDictionary alloc] init];
    mainDelegate.InboxTotalCorr=fetchedObjects.count;
    for (NSManagedObject *obj in fetchedObjects) {
        
        //   xml=[obj valueForKey:@"xml"];
        NSMutableDictionary *toolbarItems=[[NSMutableDictionary alloc] init];
        NSMutableDictionary *systemPropertiesList=[[NSMutableDictionary alloc] init];
        NSMutableArray *toolbarActions= [[NSMutableArray alloc] init];
        NSMutableArray *signActions= [[NSMutableArray alloc] init];
        NSMutableDictionary *propertiesList=[[NSMutableDictionary alloc] init];
        NSMutableArray *AttachmentsList=[[NSMutableArray alloc]init];
        NSMutableArray* AnnotationsList=[[NSMutableArray alloc]init];
        NSMutableDictionary* CustomItemsList=[[NSMutableDictionary alloc]init];
        NSMutableDictionary* QuickActionsList=[[NSMutableDictionary alloc]init];
        New=[[obj valueForKey:@"new"]boolValue];
        Id=[obj valueForKey:@"correspondenceid"];
        SHOWLOCK=[[obj valueForKey:@"showlock"]boolValue];
        Priority=[[obj valueForKey:@"priority"]boolValue];
        transferId=[obj valueForKey:@"transferid"];
        thumbnailUrl=[obj valueForKey:@"thumbnailurl"];
        Status=[obj valueForKey:@"status"];
        systemPropertiesList=[NSKeyedUnarchiver unarchiveObjectWithData:[obj valueForKey:@"systemproperties"]];
        propertiesList=[NSKeyedUnarchiver unarchiveObjectWithData:[obj valueForKey:@"Properties"]];
        toolbarItems=[NSKeyedUnarchiver unarchiveObjectWithData:[obj valueForKey:@"toolbaritems"]];
        toolbarActions=[NSKeyedUnarchiver unarchiveObjectWithData:[obj valueForKey:@"customactions"]];
        signActions=[NSKeyedUnarchiver unarchiveObjectWithData:[obj valueForKey:@"signactions"]];
        AttachmentsList=[NSKeyedUnarchiver unarchiveObjectWithData:[obj valueForKey:@"attachmentslist"]];
        AnnotationsList=[NSKeyedUnarchiver unarchiveObjectWithData:[obj valueForKey:@"annotationslist"]];
        CustomItemsList=[NSKeyedUnarchiver unarchiveObjectWithData:[obj valueForKey:@"customitemslist"]];
        QuickActionsList=[NSKeyedUnarchiver unarchiveObjectWithData:[obj valueForKey:@"quickactions"]];

        
        
        CCorrespondence  *newCorrespondence = [[CCorrespondence alloc] initWithId:Id Priority:Priority New:New  SHOWLOCK:SHOWLOCK];
        [newCorrespondence setStatus:Status];
        [newCorrespondence setTransferId:transferId];
        [newCorrespondence setInboxId:InboxId];
        [newCorrespondence setThumnailUrl:thumbnailUrl];
        [newCorrespondence setSystemProperties:[systemPropertiesList copy]];
        [newCorrespondence setProperties:[propertiesList copy]];
        [newCorrespondence setToolbar:[toolbarItems copy]];
        [newCorrespondence setActions:[toolbarActions copy]];
        [newCorrespondence setSignActions:[signActions copy]];
        [newCorrespondence setAttachmentsListMenu:[AttachmentsList copy]];
        [newCorrespondence setAnnotationsList:[AnnotationsList copy]];
        [newCorrespondence setCustomItemsList:[CustomItemsList copy]];
        [newCorrespondence setQuickActions:[QuickActionsList copy]];
        [Allcorrespondences addObject:newCorrespondence];
        [allInboxes setObject:Allcorrespondences forKey:InboxId];
    }
    return allInboxes;
}

+(void)DeleteXML:(NSString*)Id nb:(NSString*)nb name:(NSString*)name{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSPredicate *predicate;
    NSArray *fetchedObjects;
    NSEntityDescription *entity;
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"XMLS" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:@"(id = %@) AND (nb = %@) AND (name = %@)", Id,nb,name];
    [fetchRequest setPredicate:predicate];
    fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in fetchedObjects) {
        [managedObjectContext deleteObject:obj];
    }
    
}

+(NSData*)LoadXML:(NSString*)Id nb:(NSString*)nb name:(NSString*)name{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSEntityDescription *entity;
    NSPredicate* predicate;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"XMLS" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:@"(id = %@) AND (nb = %@) AND (name = %@)", Id,nb,name];
    [fetchRequest setPredicate:predicate];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSData* xml;
    
    for (NSManagedObject *obj in fetchedObjects) {
        
        xml=[obj valueForKey:@"xml"];
        
    }
    return xml;
}

+(void)cacheIcon:(NSString*)key value:(NSData*)value{
    NSError *error;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    NSManagedObject *dataRecord = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"ICONS"
                                   inManagedObjectContext:managedObjectContext];
    [dataRecord setValue:key forKey:@"key"];
    [dataRecord setValue:value forKey:@"value"];
    
    //NSData *imageData = UIImageJPEGRepresentation(node.image,0.2);
    
    
    if (![managedObjectContext save:&error]) {
        
        NSLog(@"Error:%@", error);
    }
    
}
+ (NSMutableArray *)loadMenuListWith:(NSArray*) menus {
    
	
	NSMutableArray* menuItems = [[NSMutableArray alloc] init];
	
	for (GDataXMLElement *menuItem in menus) {
		
        NSInteger menuId;
        NSString *name;
        NSString *icon;
        
        NSArray *menuIds = [menuItem elementsForName:@"InboxId"];
		GDataXMLElement *menuIdEl = (GDataXMLElement *) [menuIds objectAtIndex:0];
		menuId = [menuIdEl.stringValue integerValue];
		
        
        NSArray *names = [menuItem elementsForName:@"Name"];
		if (names.count > 0) {
			GDataXMLElement *nameEl = (GDataXMLElement *) [names objectAtIndex:0];
			name = nameEl.stringValue;
		}
        
        NSArray *icons = [menuItem elementsForName:@"Icon"];
		if (icons.count > 0) {
			GDataXMLElement *iconEl = (GDataXMLElement *) [icons objectAtIndex:0];
			icon = iconEl.stringValue;
		}
        [self cacheInboxItem:menuIdEl.stringValue icon:icon name:name];
        CMenu* menu = [[CMenu alloc] initWithName:name Id:menuId Icon:icon];
        
        [menuItems addObject:menu];
    }
    return menuItems;
}

+(NSMutableDictionary *)loadItems:(NSArray*) arrayItems{
    
    NSMutableDictionary* property = [[NSMutableDictionary alloc] init];
    // NSArray *items=((GDataXMLElement*)arrayItems[0]).children;
    for(GDataXMLElement *prop in arrayItems)
    {
        NSString* Name=[(GDataXMLElement *) [prop attributeForName:@"Name"] stringValue];
        // NSString* Label=[(GDataXMLElement *) [prop attributeForName:@"Label"] stringValue];
        NSString* Display=[(GDataXMLElement *) [prop attributeForName:@"Display"] stringValue];
        NSArray *Subitems=prop.children;
        for(GDataXMLElement *item in Subitems)
        {
            
        }
        [property setObject:Display forKey:Name];
        
    }
    return property;
}

+ (NSMutableArray *)loadActionsWith:(NSString*)name label:(NSString*)label display:(BOOL)display popup:(BOOL)popup backhome:(BOOL)backhome {
    
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    
    CAction* menu = [[CAction alloc] initWithLabel:label action:name popup:popup backhome:backhome Custom:NO];
    
    [actions addObject:menu];
    return actions;
}
+(NSMutableDictionary *)loadCorrespondencesWithData:(NSData*)xmlData {
    NSLog(@"Info:Enter LoadCorrespondenceWithData Method");
    NSError *error;
    NSString* TotalCorrnb;
    AppDelegate * mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSLog(@"Converting NSData result to XML");
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    if (doc == nil)
    {
        NSLog(@"Error:failed to convert data to XML");
        return nil;
    }
    NSArray *results = [doc nodesForXPath:@"//Result" error:nil];
    
    GDataXMLElement *correspondencesXML =  [results objectAtIndex:0];
    
    NSString* status=[(GDataXMLElement *) [correspondencesXML attributeForName:@"Status"] stringValue];
    
    if([status isEqualToString:@"ERROR"]){
        NSString* ErrorMessage=@"Unable to connect Server";
        NSArray *Message = [correspondencesXML elementsForName:@"ErrorMessage"];
        if (Message.count > 0) {
            GDataXMLElement *msgEl = (GDataXMLElement *) [Message objectAtIndex:0];
            ErrorMessage = msgEl.stringValue;
        }
        [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:ErrorMessage waitUntilDone:YES];
        return nil;
        
    }
    
    NSArray *inboxes =[correspondencesXML elementsForName:@"Inbox"];
    NSMutableDictionary* allInboxes = [[NSMutableDictionary alloc] init];
	
	for (GDataXMLElement *inbox in inboxes) {
        
        NSString *inboxId=[(GDataXMLElement *) [inbox attributeForName:@"Id"] stringValue ];
        NSArray *totalCorrNb = [inbox elementsForName:@"Total"];
        if (totalCorrNb.count > 0) {
            GDataXMLElement *totalEl = (GDataXMLElement *) [totalCorrNb objectAtIndex:0];
            TotalCorrnb = totalEl.stringValue;
            mainDelegate.InboxTotalCorr=[TotalCorrnb intValue];
        }
        
        NSArray *correspondences =[inbox nodesForXPath:@"Correspondences/Correspondence" error:nil];
        NSMutableArray* Allcorrespondences = [[NSMutableArray alloc] init];
        
        for (GDataXMLElement *correspondence in correspondences) {
            
            NSString* transferId;
            NSString *Id;
            BOOL Priority;
            BOOL New;
            BOOL SHOWLOCK;
            NSString* thumbnailUrl;
            NSString* Status;
            
            
            NSArray *transferIds = [correspondence elementsForName:@"TransferId"];
            if (transferIds.count > 0) {
                GDataXMLElement *transferIdEl = (GDataXMLElement *) [transferIds objectAtIndex:0];
                transferId = transferIdEl.stringValue;
            }
            
            NSArray *thumbnailUrls = [correspondence elementsForName:@"ThumbnailUrl"];
            if (thumbnailUrls.count > 0) {
                GDataXMLElement *thumbnailUrlEl= (GDataXMLElement *) [thumbnailUrls objectAtIndex:0];
                thumbnailUrl = thumbnailUrlEl.stringValue;
            }
            else
                thumbnailUrl=@"";
            
            NSArray *correspondenceIds = [correspondence elementsForName:@"CorrespondenceId"];
            if (correspondenceIds.count > 0) {
                GDataXMLElement *correspondenceIdEl = (GDataXMLElement *) [correspondenceIds objectAtIndex:0];
                Id = correspondenceIdEl.stringValue;
            }
            
            NSArray *StatusArray = [correspondence elementsForName:@"Status"];
            if (StatusArray.count > 0) {
                GDataXMLElement *StatusEl = (GDataXMLElement *) [StatusArray objectAtIndex:0];
                Status = StatusEl.stringValue;
            }
            
            NSArray *priorities = [correspondence elementsForName:@"IsHighPriority"];
            if (priorities.count > 0) {
                GDataXMLElement *priorityEl = (GDataXMLElement *) [priorities objectAtIndex:0];
                Priority = [priorityEl.stringValue boolValue];
            }
            
            GDataXMLElement *newEl = (GDataXMLElement *) [[correspondence elementsForName:@"IsNew"]objectAtIndex:0];
            New = [newEl.stringValue boolValue];
            
            GDataXMLElement *showlockedEl = (GDataXMLElement *) [[correspondence elementsForName:@"IsLocked"]objectAtIndex:0];
            SHOWLOCK = [showlockedEl.stringValue boolValue];
            
            
            //********GRIDINFO**********
            NSArray *systemProperties =[correspondence nodesForXPath:@"GridInfo" error:nil];
            NSMutableDictionary *systemPropertiesList=[[NSMutableDictionary alloc] init] ;
            if (systemProperties.count > 0) {
                systemPropertiesList=[self loadItemsByOrder:systemProperties];
            }
            //********METADATA**********
            NSArray *properties = [correspondence elementsForName:@"Metadata"];
            NSMutableDictionary *propertiesList=[[NSMutableDictionary alloc] init];
            if (properties.count > 0) {
                propertiesList=[self loadItemsByOrder:properties];
            }
            // NSArray *xx=correspondence.children;
            NSArray *Maintoolbar =[correspondence nodesForXPath:@"ToolbarItems" error:nil];
            NSMutableDictionary *toolbarItems=[[NSMutableDictionary alloc] init],*CustomItemsList=[[NSMutableDictionary alloc] init];
            NSMutableArray *toolbarActions=[[NSMutableArray alloc] init];
            NSMutableArray *signActions=[[NSMutableArray alloc]init] ,*AnnotationsList=[[NSMutableArray alloc]init],*AttachmentsList=[[NSMutableArray alloc]init],*QuickActions=[[NSMutableArray alloc]init];
            int key=-1;
            for(GDataXMLElement * element in Maintoolbar){
                NSArray *toolbar=element.children;
                for(GDataXMLElement *prop in toolbar)
                {
                    if([prop.name isEqualToString:@"CustomToolbarItem"]){
                        
                        key++;
                        NSMutableArray *CustomItemsArray=[[NSMutableArray alloc]init];
                        NSString* Name=[(GDataXMLElement *) [prop attributeForName:@"Name"] stringValue];
                        NSString* Label=[(GDataXMLElement *) [prop attributeForName:@"Label"] stringValue];
                        BOOL Display=[[(GDataXMLElement *) [prop attributeForName:@"Display"] stringValue]boolValue];
                        BOOL QuickAction=[[(GDataXMLElement *) [prop attributeForName:@"QuickAction"] stringValue]boolValue];
                        BOOL popup=[[(GDataXMLElement *) [prop attributeForName:@"ShowPopup"] stringValue]boolValue];
                        BOOL backhome=[[(GDataXMLElement *) [prop attributeForName:@"ReturnHome"] stringValue]boolValue];
                        NSString* LookupId=[(GDataXMLElement *) [prop attributeForName:@"LookupId"] stringValue];
                        
                        ToolbarItem* item=[[ToolbarItem alloc]initWithName:Name Label:Label Display:Display Custom:YES popup:popup backhome:backhome ];
                        [item setLookupId:LookupId];
                        if (Display) {
                            [toolbarItems setValue:item forKey:[NSString stringWithFormat:@"%d",key]];
                            if(QuickAction)
                            {
                                CAction* Qact = [[CAction alloc] initWithLabel:Label action:Name popup:popup backhome:backhome Custom:YES];
                                [Qact setLookupId:LookupId];
                                if(prop.children.count<=0)
                                    [QuickActions addObject:Qact];
                            }
                        }
                        
                        NSArray *Subitems=prop.children;
                        if(Subitems.count>0){
                            for(GDataXMLElement *item in Subitems)
                            {   NSArray *toolbarItem=item .children;
                                
                                for(GDataXMLElement *item1 in toolbarItem)
                                {
                                    
                                    if([item1.name isEqualToString:@"CustomToolbarItem"])
                                    {
                                        NSString* Namee=[(GDataXMLElement *) [item1 attributeForName:@"Name"] stringValue];
                                        NSString* Labell=[(GDataXMLElement *) [item1 attributeForName:@"Label"] stringValue];
                                        BOOL Displayy=[[(GDataXMLElement *) [item1 attributeForName:@"Display"] stringValue]boolValue];
                                        BOOL QuickActionn=[[(GDataXMLElement *) [prop attributeForName:@"QuickAction"] stringValue]boolValue];
                                        BOOL popup=[[(GDataXMLElement *) [item1 attributeForName:@"ShowPopup"] stringValue]boolValue];
                                        BOOL returnHome=[[(GDataXMLElement *) [item1 attributeForName:@"ReturnHome"] stringValue]boolValue];
                                        NSString* LookupId=[(GDataXMLElement *) [item1 attributeForName:@"LookupId"] stringValue];
                                        
                                        if (Displayy){
                                            CAction* menu = [[CAction alloc] initWithLabel:Labell action:Namee popup:popup backhome:returnHome Custom:YES];
                                            [menu setLookupId:LookupId];
                                            [CustomItemsArray addObject:menu];
                                            if(QuickActionn)
                                            {
                                                [QuickActions addObject:menu];
                                            }
                                        }
                                    }
                                }
                                [CustomItemsList setObject:CustomItemsArray forKey:Name];
                            }
                        }
                    }
                    else
                        if([prop.name isEqualToString:@"ToolbarItem"]){
                            
                            key++;
                            NSString* Name=[(GDataXMLElement *) [prop attributeForName:@"Name"] stringValue];
                            NSString* Label=[(GDataXMLElement *) [prop attributeForName:@"Label"] stringValue];
                            BOOL Display=[[(GDataXMLElement *) [prop attributeForName:@"Display"] stringValue]boolValue];
                            BOOL QuickAction=[[(GDataXMLElement *) [prop attributeForName:@"QuickAction"] stringValue]boolValue];
                            NSString* LookupId=[(GDataXMLElement *) [prop attributeForName:@"LookupId"] stringValue];
                            
                            ToolbarItem* item=[[ToolbarItem alloc]initWithName:Name Label:Label Display:Display Custom:NO popup:NO backhome:NO ];
                            [item setLookupId:LookupId];
                            if (Display) {
                                [toolbarItems setValue:item forKey:[NSString stringWithFormat:@"%d",key]];
                                if(QuickAction)
                                {
                                    CAction* Qact = [[CAction alloc] initWithLabel:Label action:Name popup:NO backhome:NO Custom:NO];
                                    [Qact setLookupId:LookupId];
                                    if(prop.children.count<=0)
                                        [QuickActions addObject:Qact];
                                }
                            }
                            NSArray *Subitems=prop.children;
                            if(Subitems.count>0){
                                for(GDataXMLElement *item in Subitems)
                                {   NSArray *toolbarItem=item .children;
                                    
                                    for(GDataXMLElement *item1 in toolbarItem)
                                    {
                                        if([item1.name isEqualToString:@"ToolbarItem"]){
                                            NSString* Namee=[(GDataXMLElement *) [item1 attributeForName:@"Name"] stringValue];
                                            NSString* Labell=[(GDataXMLElement *) [item1 attributeForName:@"Label"] stringValue];
                                            BOOL Displayy=[[(GDataXMLElement *) [item1 attributeForName:@"Display"] stringValue]boolValue];
                                            BOOL QuickAction=[[(GDataXMLElement *) [item1 attributeForName:@"QuickAction"] stringValue]boolValue];
                                            NSString* LookupId=[(GDataXMLElement *) [item1 attributeForName:@"LookupId"] stringValue];
                                            
                                            if (Displayy){
                                                
                                                if(![Name isEqualToString:@"More"]){
                                                    CAction* menu = [[CAction alloc] initWithLabel:Labell action:Namee popup:NO backhome:NO Custom:NO];
                                                    [menu setLookupId:LookupId];
                                                    if(QuickAction)
                                                    {
                                                        
                                                        [QuickActions addObject:menu];
                                                    }
                                                    if([Name isEqualToString:@"Annotations"]){
                                                        [AnnotationsList addObject:menu];
                                                    }
                                                    else if ([Name isEqualToString:@"Attachments"])
                                                        [AttachmentsList addObject:menu];
                                                    else if ([Name isEqualToString:@"Signature"])
                                                        [signActions addObject:menu];
                                                    
                                                }
                                                else{
                                                    BOOL popup=[[(GDataXMLElement *) [item1 attributeForName:@"ShowPopup"] stringValue]boolValue];
                                                    BOOL returnHome=[[(GDataXMLElement *) [item1 attributeForName:@"ReturnHome"] stringValue]boolValue];
                                                    CAction* menu = [[CAction alloc] initWithLabel:Labell action:Namee popup:popup backhome:returnHome Custom:NO];
                                                    [menu setLookupId:LookupId];
                                                    if(QuickAction)
                                                    {
                                                        [QuickActions addObject:menu];
                                                    }
                                                    [toolbarActions addObject:menu];
                                                }
                                            }
                                            
                                        }
                                        
                                        if([item1.name isEqualToString:@"CustomToolbarItem"])
                                        {
                                            NSString* Namee=[(GDataXMLElement *) [item1 attributeForName:@"Name"] stringValue];
                                            NSString* Labell=[(GDataXMLElement *) [item1 attributeForName:@"Label"] stringValue];
                                            BOOL Displayy=[[(GDataXMLElement *) [item1 attributeForName:@"Display"] stringValue]boolValue];
                                            BOOL QuickActionn=[[(GDataXMLElement *) [item1 attributeForName:@"QuickAction"] stringValue]boolValue];
                                            BOOL popup=[[(GDataXMLElement *) [item1 attributeForName:@"ShowPopup"] stringValue]boolValue];
                                            BOOL returnHome=[[(GDataXMLElement *) [item1 attributeForName:@"ReturnHome"] stringValue]boolValue];
                                            NSString* LookupId=[(GDataXMLElement *) [item1 attributeForName:@"LookupId"] stringValue];
                                            
                                            if (Displayy){
                                                CAction* menu = [[CAction alloc] initWithLabel:Labell action:Namee popup:popup backhome:returnHome Custom:YES];
                                                [menu setLookupId:LookupId];
                                                if(QuickActionn)
                                                {
                                                    [QuickActions addObject:menu];
                                                }
                                                if([Name isEqualToString:@"Annotations"]){
                                                    [AnnotationsList addObject:menu];
                                                }
                                                else if ([Name isEqualToString:@"Attachments"])
                                                    [AttachmentsList addObject:menu];
                                                else if ([Name isEqualToString:@"Signature"])
                                                    [signActions addObject:menu];
                                                else
                                                    if([Name isEqualToString:@"More"])
                                                        [toolbarActions addObject:menu];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                }
                
            }
            
            
            
            CCorrespondence  *newCorrespondence = [[CCorrespondence alloc] initWithId:Id Priority:Priority New:New SHOWLOCK:SHOWLOCK];
            [newCorrespondence setStatus:Status];
            [newCorrespondence setTransferId:transferId];
            [newCorrespondence setSystemProperties:systemPropertiesList];   /*NSMutableDictionary*/
            [newCorrespondence setProperties:propertiesList];               /*NSMutableDictionary*/
            [newCorrespondence setToolbar:toolbarItems];                    /*NSMutableDictionary*/
            [newCorrespondence setActions:toolbarActions];                  /*NSMutableArray*/
            [newCorrespondence setSignActions:signActions];                 /*NSMutableArray*/
            [newCorrespondence setInboxId:inboxId];                         /*NSString*/
            [newCorrespondence setThumnailUrl:thumbnailUrl];                /*NSString*/
            [newCorrespondence setAttachmentsListMenu:AttachmentsList];     /*NSMutableArray*/
            [newCorrespondence setAnnotationsList:AnnotationsList];         /*NSMutableArray*/
            [newCorrespondence setCustomItemsList:CustomItemsList];         /*NSMutableDictionary*/
            [newCorrespondence setQuickActions:QuickActions];
            //  [newCorrespondence setActionsMenu:toolbarMenuActions];
            NSData* signactiondata=[NSKeyedArchiver archivedDataWithRootObject:signActions];
            NSData* customdata=[NSKeyedArchiver archivedDataWithRootObject:toolbarActions];
            NSData* toolbardata=[NSKeyedArchiver archivedDataWithRootObject:toolbarItems];
            NSData* systempropertiesdata=[NSKeyedArchiver archivedDataWithRootObject:systemPropertiesList];
            NSData* PropertiesListdata=[NSKeyedArchiver archivedDataWithRootObject:propertiesList];
            NSData* AttachmentsListData=[NSKeyedArchiver archivedDataWithRootObject:AttachmentsList];
            NSData* AnnotationsListData=[NSKeyedArchiver archivedDataWithRootObject:AnnotationsList];
            NSData* CustomItemsListData=[NSKeyedArchiver archivedDataWithRootObject:CustomItemsList];
            NSData* QuickActionsData=[NSKeyedArchiver archivedDataWithRootObject:QuickActions];

            [self cacheCorrespondence:Id Status:Status InboxId:inboxId priority:[NSString stringWithFormat:@"%hhd",Priority] new:[NSString stringWithFormat:@"%hhd",New] showlock:[NSString stringWithFormat:@"%hhd",SHOWLOCK] transferId:transferId thumbnailurl:thumbnailUrl SystemProperties:systempropertiesdata Properties:PropertiesListdata toolbarItems:toolbardata CustomActions:customdata SignActions:signactiondata AttachmentsList:AttachmentsListData AnnotationsList:AnnotationsListData CustomItemsList:CustomItemsListData QuickActions:QuickActionsData];
            [Allcorrespondences addObject:newCorrespondence];
            
        }
        [allInboxes setObject:Allcorrespondences forKey:inboxId];
    }
    return allInboxes;
}
+(void)Download:(NSData*)xmlData {
    
    
    NSError *error;
    NSString* TotalCorrnb;
    
    AppDelegate * mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.downloadSuccess=YES;

    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    
    if (doc == nil) {mainDelegate.downloadSuccess=NO; return; }
    
    NSArray *results = [doc nodesForXPath:@"//Result" error:nil];
    
    GDataXMLElement *correspondencesXML =  [results objectAtIndex:0];
    
    NSString* status=[(GDataXMLElement *) [correspondencesXML attributeForName:@"Status"] stringValue];
    
    if([status isEqualToString:@"ERROR"]){
        NSMutableDictionary* dict=[[NSMutableDictionary alloc]init];
        NSString* ErrorMessage=NSLocalizedString(@"UnableToConnect", @"unable to connect server");
        NSArray *Message = [correspondencesXML elementsForName:@"ErrorMessage"];
        if (Message.count > 0) {
            GDataXMLElement *msgEl = (GDataXMLElement *) [Message objectAtIndex:0];
            ErrorMessage = msgEl.stringValue;
        }
        [dict setObject:ErrorMessage forKey:@"error"];
        return ;
        
    }
    //    NSArray *Destinations =[correspondencesXML elementsForName:@"Destinations"];
    //    for (GDataXMLElement *destEl in Destinations) {
    //        NSArray* dests=[destEl nodesForXPath:@"Destination" error:nil];
    //        for(GDataXMLElement* item in dests){
    //            NSString *DestId=[(GDataXMLElement *) [item attributeForName:@"Id"] stringValue ];
    //            NSString* value = item.stringValue;
    //            [self cacheDestination:DestId value:value];
    //        }
    //
    //    }
    NSArray *destinationsList = [correspondencesXML elementsForName:@"Sections"];
    
    if (destinationsList.count > 0) {
        
        GDataXMLElement *destinationsXml = (GDataXMLElement *) [destinationsList objectAtIndex:0];
        
        NSArray *destinationsEl = [destinationsXml elementsForName:@"Section"];
        
        for (GDataXMLElement * destEl in destinationsEl) {
            NSArray *SectionsList = [destEl elementsForName:@"Destination"];
            NSString* SectionId = [destEl attributeForName:@"Id"].stringValue;
            
            if(SectionsList.count>0){
                for (GDataXMLElement *destinationItem in SectionsList) {
                    
                    NSString* destId = [destinationItem attributeForName:@"Id"].stringValue;
                    NSString* value = destinationItem.stringValue;
                    [self cacheDestination:destId value:value section:SectionId];
                }
            }
            
        }
        
    }
    NSArray *inboxess =[correspondencesXML elementsForName:@"Inboxes"];
	
	for (GDataXMLElement *Inbox in inboxess) {
        NSArray *inboxes =[Inbox elementsForName:@"Inbox"];
        
        for (GDataXMLElement *inbox in inboxes) {
            
            NSString *inboxId=[(GDataXMLElement *) [inbox attributeForName:@"Id"] stringValue ];
            NSArray *totalCorrNb = [inbox elementsForName:@"Total"];
            if (totalCorrNb.count > 0) {
                GDataXMLElement *totalEl = (GDataXMLElement *) [totalCorrNb objectAtIndex:0];
                TotalCorrnb = totalEl.stringValue;
                mainDelegate.InboxTotalCorr=[TotalCorrnb intValue];
            }
            
            NSArray *DataItem =[inbox nodesForXPath:@"DataItems/DataItem" error:nil];
            
            for (GDataXMLElement *Item in DataItem) {
                
                NSString* transferId;
                NSString *Id;
                BOOL Priority;
                BOOL New;
                BOOL SHOWLOCK;
                NSString* thumbnailUrl;
                NSString* Status;
                NSArray *correspondences =[Item nodesForXPath:@"Correspondence" error:nil];
                for (GDataXMLElement *correspondence in correspondences) {
                    
                    NSArray *transferIds = [correspondence elementsForName:@"TransferId"];
                    if (transferIds.count > 0) {
                        GDataXMLElement *transferIdEl = (GDataXMLElement *) [transferIds objectAtIndex:0];
                        transferId = transferIdEl.stringValue;
                    }
                    
                    NSArray *thumbnailUrls = [correspondence elementsForName:@"ThumbnailUrl"];
                    if (thumbnailUrls.count > 0) {
                        GDataXMLElement *thumbnailUrlEl= (GDataXMLElement *) [thumbnailUrls objectAtIndex:0];
                        thumbnailUrl = thumbnailUrlEl.stringValue;
                    }
                    else
                        thumbnailUrl=@"";
                    
                    NSArray *correspondenceIds = [correspondence elementsForName:@"CorrespondenceId"];
                    if (correspondenceIds.count > 0) {
                        GDataXMLElement *correspondenceIdEl = (GDataXMLElement *) [correspondenceIds objectAtIndex:0];
                        Id = correspondenceIdEl.stringValue;
                    }
                    
                    NSArray *StatusArray = [correspondence elementsForName:@"Status"];
                    if (StatusArray.count > 0) {
                        GDataXMLElement *StatusEl = (GDataXMLElement *) [StatusArray objectAtIndex:0];
                        Status = StatusEl.stringValue;
                    }
                    
                    NSArray *priorities = [correspondence elementsForName:@"IsHighPriority"];
                    if (priorities.count > 0) {
                        GDataXMLElement *priorityEl = (GDataXMLElement *) [priorities objectAtIndex:0];
                        Priority = [priorityEl.stringValue boolValue];
                    }
                    
                    GDataXMLElement *newEl = (GDataXMLElement *) [[correspondence elementsForName:@"IsNew"]objectAtIndex:0];
                    New = [newEl.stringValue boolValue];
                    
                    GDataXMLElement *showlockedEl = (GDataXMLElement *) [[correspondence elementsForName:@"ShowLock"]objectAtIndex:0];
                    SHOWLOCK = [showlockedEl.stringValue boolValue];
                    
                    
                    //********GRIDINFO**********
                    NSArray *systemProperties =[correspondence nodesForXPath:@"GridInfo" error:nil];
                    NSMutableDictionary *systemPropertiesList=[[NSMutableDictionary alloc] init] ;
                    if (systemProperties.count > 0) {
                        systemPropertiesList=[self loadItemsByOrder:systemProperties];
                    }
                    //********METADATA**********
                    NSArray *properties = [correspondence elementsForName:@"Metadata"];
                    NSMutableDictionary *propertiesList=[[NSMutableDictionary alloc] init];
                    if (properties.count > 0) {
                        propertiesList=[self loadItemsByOrder:properties];
                    }
                    // NSArray *xx=correspondence.children;
                    NSArray *Maintoolbar =[correspondence nodesForXPath:@"ToolbarItems" error:nil];
                    NSMutableDictionary *toolbarItems=[[NSMutableDictionary alloc] init],*CustomItemsList=[[NSMutableDictionary alloc] init];
                    NSMutableArray *toolbarActions=[[NSMutableArray alloc] init];
                    NSMutableArray *signActions=[[NSMutableArray alloc]init] ,*AnnotationsList=[[NSMutableArray alloc]init],*AttachmentsList=[[NSMutableArray alloc]init],*QuickActions=[[NSMutableArray alloc]init];
                    int key=-1;
                    for(GDataXMLElement * element in Maintoolbar){
                        NSArray *toolbar=element.children;
                        for(GDataXMLElement *prop in toolbar)
                        {
                            if([prop.name isEqualToString:@"CustomToolbarItem"]){
                                
                                key++;
                                NSMutableArray *CustomItemsArray=[[NSMutableArray alloc]init];
                                NSString* Name=[(GDataXMLElement *) [prop attributeForName:@"Name"] stringValue];
                                NSString* Label=[(GDataXMLElement *) [prop attributeForName:@"Label"] stringValue];
                                BOOL Display=[[(GDataXMLElement *) [prop attributeForName:@"Display"] stringValue]boolValue];
                                BOOL QuickAction=[[(GDataXMLElement *) [prop attributeForName:@"QuickAction"] stringValue]boolValue];
                                BOOL popup=[[(GDataXMLElement *) [prop attributeForName:@"ShowPopup"] stringValue]boolValue];
                                BOOL backhome=[[(GDataXMLElement *) [prop attributeForName:@"ReturnHome"] stringValue]boolValue];
                                NSString* LookupId=[(GDataXMLElement *) [prop attributeForName:@"LookupId"] stringValue];
                                
                                ToolbarItem* item=[[ToolbarItem alloc]initWithName:Name Label:Label Display:Display Custom:YES popup:popup backhome:backhome ];
                                [item setLookupId:LookupId];
                                if (Display) {
                                    [toolbarItems setValue:item forKey:[NSString stringWithFormat:@"%d",key]];
                                    if(QuickAction)
                                    {
                                        CAction* Qact = [[CAction alloc] initWithLabel:Label action:Name popup:popup backhome:backhome Custom:YES];
                                        [Qact setLookupId:LookupId];
                                        if(prop.children.count<=0)
                                            [QuickActions addObject:Qact];
                                    }
                                }
                                
                                NSArray *Subitems=prop.children;
                                if(Subitems.count>0){
                                    for(GDataXMLElement *item in Subitems)
                                    {   NSArray *toolbarItem=item .children;
                                        
                                        for(GDataXMLElement *item1 in toolbarItem)
                                        {
                                            
                                            if([item1.name isEqualToString:@"CustomToolbarItem"])
                                            {
                                                NSString* Namee=[(GDataXMLElement *) [item1 attributeForName:@"Name"] stringValue];
                                                NSString* Labell=[(GDataXMLElement *) [item1 attributeForName:@"Label"] stringValue];
                                                BOOL Displayy=[[(GDataXMLElement *) [item1 attributeForName:@"Display"] stringValue]boolValue];
                                                BOOL QuickActionn=[[(GDataXMLElement *) [prop attributeForName:@"QuickAction"] stringValue]boolValue];
                                                BOOL popup=[[(GDataXMLElement *) [item1 attributeForName:@"ShowPopup"] stringValue]boolValue];
                                                BOOL returnHome=[[(GDataXMLElement *) [item1 attributeForName:@"ReturnHome"] stringValue]boolValue];
                                                NSString* LookupId=[(GDataXMLElement *) [item1 attributeForName:@"LookupId"] stringValue];
                                                
                                                if (Displayy){
                                                    CAction* menu = [[CAction alloc] initWithLabel:Labell action:Namee popup:popup backhome:returnHome Custom:YES];
                                                    [menu setLookupId:LookupId];
                                                    [CustomItemsArray addObject:menu];
                                                    if(QuickActionn)
                                                    {
                                                        [QuickActions addObject:menu];
                                                    }
                                                }
                                            }
                                        }
                                        [CustomItemsList setObject:CustomItemsArray forKey:Name];
                                    }
                                }
                            }
                            else
                                if([prop.name isEqualToString:@"ToolbarItem"]){
                                    
                                    key++;
                                    NSString* Name=[(GDataXMLElement *) [prop attributeForName:@"Name"] stringValue];
                                    NSString* Label=[(GDataXMLElement *) [prop attributeForName:@"Label"] stringValue];
                                    BOOL Display=[[(GDataXMLElement *) [prop attributeForName:@"Display"] stringValue]boolValue];
                                    BOOL QuickAction=[[(GDataXMLElement *) [prop attributeForName:@"QuickAction"] stringValue]boolValue];
                                    NSString* LookupId=[(GDataXMLElement *) [prop attributeForName:@"LookupId"] stringValue];
                                    
                                    ToolbarItem* item=[[ToolbarItem alloc]initWithName:Name Label:Label Display:Display Custom:NO popup:NO backhome:NO ];
                                    [item setLookupId:LookupId];
                                    if (Display) {
                                        [toolbarItems setValue:item forKey:[NSString stringWithFormat:@"%d",key]];
                                        if(QuickAction)
                                        {
                                            CAction* Qact = [[CAction alloc] initWithLabel:Label action:Name popup:NO backhome:NO Custom:NO];
                                            [Qact setLookupId:LookupId];
                                            if(prop.children.count<=0)
                                                [QuickActions addObject:Qact];
                                        }
                                    }
                                    NSArray *Subitems=prop.children;
                                    if(Subitems.count>0){
                                        for(GDataXMLElement *item in Subitems)
                                        {   NSArray *toolbarItem=item .children;
                                            
                                            for(GDataXMLElement *item1 in toolbarItem)
                                            {
                                                if([item1.name isEqualToString:@"ToolbarItem"]){
                                                    NSString* Namee=[(GDataXMLElement *) [item1 attributeForName:@"Name"] stringValue];
                                                    NSString* Labell=[(GDataXMLElement *) [item1 attributeForName:@"Label"] stringValue];
                                                    BOOL Displayy=[[(GDataXMLElement *) [item1 attributeForName:@"Display"] stringValue]boolValue];
                                                    BOOL QuickAction=[[(GDataXMLElement *) [item1 attributeForName:@"QuickAction"] stringValue]boolValue];
                                                    NSString* LookupId=[(GDataXMLElement *) [item1 attributeForName:@"LookupId"] stringValue];
                                                    
                                                    if (Displayy){
                                                        
                                                        if(![Name isEqualToString:@"More"]){
                                                            CAction* menu = [[CAction alloc] initWithLabel:Labell action:Namee popup:NO backhome:NO Custom:NO];
                                                            [menu setLookupId:LookupId];
                                                            if(QuickAction)
                                                            {
                                                                
                                                                [QuickActions addObject:menu];
                                                            }
                                                            if([Name isEqualToString:@"Annotations"]){
                                                                [AnnotationsList addObject:menu];
                                                            }
                                                            else if ([Name isEqualToString:@"Attachments"])
                                                                [AttachmentsList addObject:menu];
                                                            else if ([Name isEqualToString:@"Signature"])
                                                                [signActions addObject:menu];
                                                            
                                                        }
                                                        else{
                                                            BOOL popup=[[(GDataXMLElement *) [item1 attributeForName:@"ShowPopup"] stringValue]boolValue];
                                                            BOOL returnHome=[[(GDataXMLElement *) [item1 attributeForName:@"ReturnHome"] stringValue]boolValue];
                                                            CAction* menu = [[CAction alloc] initWithLabel:Labell action:Namee popup:popup backhome:returnHome Custom:NO];
                                                            [menu setLookupId:LookupId];
                                                            if(QuickAction)
                                                            {
                                                                [QuickActions addObject:menu];
                                                            }
                                                            [toolbarActions addObject:menu];
                                                        }
                                                    }
                                                    
                                                }
                                                
                                                if([item1.name isEqualToString:@"CustomToolbarItem"])
                                                {
                                                    NSString* Namee=[(GDataXMLElement *) [item1 attributeForName:@"Name"] stringValue];
                                                    NSString* Labell=[(GDataXMLElement *) [item1 attributeForName:@"Label"] stringValue];
                                                    BOOL Displayy=[[(GDataXMLElement *) [item1 attributeForName:@"Display"] stringValue]boolValue];
                                                    BOOL QuickActionn=[[(GDataXMLElement *) [item1 attributeForName:@"QuickAction"] stringValue]boolValue];
                                                    BOOL popup=[[(GDataXMLElement *) [item1 attributeForName:@"ShowPopup"] stringValue]boolValue];
                                                    BOOL returnHome=[[(GDataXMLElement *) [item1 attributeForName:@"ReturnHome"] stringValue]boolValue];
                                                    NSString* LookupId=[(GDataXMLElement *) [item1 attributeForName:@"LookupId"] stringValue];
                                                    
                                                    if (Displayy){
                                                        CAction* menu = [[CAction alloc] initWithLabel:Labell action:Namee popup:popup backhome:returnHome Custom:YES];
                                                        [menu setLookupId:LookupId];
                                                        if(QuickActionn)
                                                        {
                                                            [QuickActions addObject:menu];
                                                        }
                                                        if([Name isEqualToString:@"Annotations"]){
                                                            [AnnotationsList addObject:menu];
                                                        }
                                                        else if ([Name isEqualToString:@"Attachments"])
                                                            [AttachmentsList addObject:menu];
                                                        else if ([Name isEqualToString:@"Signature"])
                                                            [signActions addObject:menu];
                                                        else
                                                            if([Name isEqualToString:@"More"])
                                                                [toolbarActions addObject:menu];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                        }
                        
                    }
                    
                    NSData* signactiondata=[NSKeyedArchiver archivedDataWithRootObject:signActions];
                    NSData* customdata=[NSKeyedArchiver archivedDataWithRootObject:toolbarActions];
                    NSData* toolbardata=[NSKeyedArchiver archivedDataWithRootObject:toolbarItems];
                    NSData* systempropertiesdata=[NSKeyedArchiver archivedDataWithRootObject:systemPropertiesList];
                    NSData* PropertiesListdata=[NSKeyedArchiver archivedDataWithRootObject:propertiesList];
                    NSData* AttachmentsListData=[NSKeyedArchiver archivedDataWithRootObject:AttachmentsList];
                    NSData* AnnotationsListData=[NSKeyedArchiver archivedDataWithRootObject:AnnotationsList];
                    NSData* CustomItemsListData=[NSKeyedArchiver archivedDataWithRootObject:CustomItemsList];
                    NSData* QuickActionsData=[NSKeyedArchiver archivedDataWithRootObject:QuickActions];
                    
                    [self cacheCorrespondence:Id Status:Status InboxId:inboxId priority:[NSString stringWithFormat:@"%hhd",Priority] new:[NSString stringWithFormat:@"%hhd",New] showlock:[NSString stringWithFormat:@"%hhd",SHOWLOCK] transferId:transferId thumbnailurl:thumbnailUrl SystemProperties:systempropertiesdata Properties:PropertiesListdata toolbarItems:toolbardata CustomActions:customdata SignActions:signactiondata AttachmentsList:AttachmentsListData AnnotationsList:AnnotationsListData CustomItemsList:CustomItemsListData QuickActions:QuickActionsData];
                    
                }
                /***************************************************************/
                NSArray *Attachments =[Item nodesForXPath:@"Folders" error:nil];
                
                if (Attachments.count > 0) {
                    GDataXMLElement *AttachmentsXML =  [Attachments objectAtIndex:0];
                    NSArray *Folders = [AttachmentsXML elementsForName:@"Folder"];
                    
                    for(GDataXMLElement *FoldersEl in Folders) {
                        NSString* folderName = [FoldersEl attributeForName:@"Name"].stringValue;
                        NSString* folderId = [FoldersEl attributeForName:@"Id"].stringValue;

                        NSArray *Folderxml = [FoldersEl elementsForName:@"Attachments"];
                        for(GDataXMLElement *folders in Folderxml)
                        {
                            
                            NSArray *attachmentXML = [folders elementsForName:@"Attachment"];
                            
                            for(GDataXMLElement *attachment in attachmentXML)
                            {
                                
                                [mainDelegate.IncomingHighlights removeAllObjects];
                                [mainDelegate.IncomingNotes removeAllObjects];
                                mainDelegate.IncomingNotes=[[NSMutableArray alloc]init];
                                mainDelegate.IncomingHighlights=[[NSMutableArray alloc]init];
                                NSString* fileUri;
                                NSString* FileName;
                                NSString* url;
                                NSString* SiteId;
                                NSString* FileId;
                                NSString* FileUrl;
                                NSString* thumbnailUrl;
                                NSString* isOriginalMail;
                                NSString* AttachmentId;
                                NSString* AttachmentStatus;
                                NSArray *fileUris = [attachment elementsForName:@"DocId"];
                                if (fileUris.count > 0) {
                                    GDataXMLElement *fileUriEl = (GDataXMLElement *) [fileUris objectAtIndex:0];
                                    fileUri = fileUriEl.stringValue;
                                }
                                NSArray *attachid = [attachment elementsForName:@"AttachmentId"];
                                if (attachid.count > 0) {
                                    GDataXMLElement *attachidEl = (GDataXMLElement *) [attachid objectAtIndex:0];
                                    AttachmentId = attachidEl.stringValue;
                                }
                                NSArray *FileNames = [attachment elementsForName:@"FileName"];
                                if (FileNames.count > 0) {
                                    GDataXMLElement *FileNameEL = (GDataXMLElement *) [FileNames objectAtIndex:0];
                                    FileName = FileNameEL.stringValue;
                                }
                                NSArray *statusArray=[attachment elementsForName:@"Status"];
                                if (statusArray.count>0) {
                                    GDataXMLElement *statusEl=(GDataXMLElement*)[statusArray objectAtIndex:0];
                                    AttachmentStatus=statusEl.stringValue;
                                }
                                NSArray *urls = [attachment elementsForName:@"URL"];
                                if (urls.count > 0) {
                                    GDataXMLElement *urlEl = (GDataXMLElement *) [urls objectAtIndex:0];
                                    NSLog(@"%@",urlEl.stringValue);
                                    url = urlEl.stringValue;
                                    
                                    
                                    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                    NSString* tempPdfLocation=@"";
                                    
                                    NSString*strUrl;
                                    NSString* CorrespondenceId=Id;
                                    strUrl= [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//url where the file located
                                    NSURL *url=[NSURL URLWithString:strUrl];
                                    
                                    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];// /Users/dna/Library/Application Support/iPhone Simulator/7.0.3/Applications/9A637052-BDFD-4567-B3AC-6B01DDFD5430/Library/Caches
                                    
                                    NSString *path = [cachesDirectory stringByAppendingPathComponent:CorrespondenceId];//append correspondence number
                                    NSError *error;
                                    if (![[NSFileManager defaultManager] fileExistsAtPath:path])    //Does directory already exist?
                                    {
                                        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                                                       withIntermediateDirectories:NO
                                                                                        attributes:nil
                                                                                             error:&error])
                                        {
                                            NSLog(@"Create directory error: %@", error);
                                        }
                                    }
                                    
                                    
                                    NSString* pdfCacheName = [url lastPathComponent];//take the name of the file
                                    
                                    tempPdfLocation = [path stringByAppendingPathComponent:pdfCacheName];//compute the full path for the file
                                    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:tempPdfLocation];//check if file if already exists
                                    if(!fileExists){//write file to cache if not exist
                                        
                                        NSData *data = [NSData dataWithContentsOfURL:url ];
                                        if(data.length!=0)
                                            [data writeToFile:tempPdfLocation atomically:TRUE];
                                        else tempPdfLocation=@"";
                                    }
                                    
                                    
                                    
                                }
                                
                                NSArray *ServerFileInfo = [attachment nodesForXPath:@"ServerFileInfo" error:nil];
                                GDataXMLElement *ServerFileInfoXML;
                                
                                if(ServerFileInfo.count>0){
                                    
                                    ServerFileInfoXML = [ServerFileInfo objectAtIndex:0];
                                    
                                    NSArray *SiteIds = [ServerFileInfoXML elementsForName:@"SiteId"];
                                    if (SiteIds.count > 0) {
                                        GDataXMLElement *SiteIdEl = (GDataXMLElement *) [SiteIds objectAtIndex:0];
                                        SiteId = SiteIdEl.stringValue;
                                    }
                                    
                                    NSArray *FileIds = [ServerFileInfoXML elementsForName:@"FileId"];
                                    if (FileIds.count > 0) {
                                        GDataXMLElement *FileIdEl = (GDataXMLElement *) [FileIds objectAtIndex:0];
                                        FileId = FileIdEl.stringValue;
                                    }
                                    
                                    NSArray *FileUrls = [ServerFileInfoXML elementsForName:@"FileURL"];
                                    if (FileUrls.count > 0) {
                                        GDataXMLElement *FileUrlEl = (GDataXMLElement *) [FileUrls objectAtIndex:0];
                                        FileUrl = FileUrlEl.stringValue;
                                    }
                                }
                                NSArray *thumbnailUrls = [attachment elementsForName:@"ThumbnailURL"];
                                if (thumbnailUrls.count > 0) {
                                    GDataXMLElement *thumbnailUrlEl= (GDataXMLElement *) [thumbnailUrls objectAtIndex:0];
                                    thumbnailUrl = thumbnailUrlEl.stringValue;
                                }
                                
                                NSArray *isOriginalMails = [attachment elementsForName:@"IsOriginalMail"];
                                if (isOriginalMails.count > 0) {
                                    GDataXMLElement *isOriginalMailEl= (GDataXMLElement *) [isOriginalMails objectAtIndex:0];
                                    isOriginalMail = isOriginalMailEl.stringValue;
                                }
                                
                                
                                //     NSMutableArray* annotations = [[NSMutableArray alloc] init];
                                NSArray *annotationsXml = [attachment elementsForName:@"Annotations"];
                                
                                if (annotationsXml.count > 0) {
                                    GDataXMLElement *annotationsEl = (GDataXMLElement *) [annotationsXml objectAtIndex:0];
                                    NSArray *Notes = [annotationsEl nodesForXPath:@"Notes" error:nil];
                                    
                                    
                                    
                                    GDataXMLElement *NotesXML;
                                    
                                    if(Notes.count>0){
                                        
                                        NotesXML = [Notes objectAtIndex:0];
                                        
                                    }
                                    
                                    NSArray *noteXML = [NotesXML elementsForName:@"Note"];
                                    
                                    NSString *noteX;
                                    
                                    NSString *noteId;
                                    
                                    NSString *noteY;
                                    
                                    NSString *notepage;
                                    
                                    NSString *noteMSG;
                                    
                                    for(GDataXMLElement *notee in noteXML)
                                        
                                    {
                                        NSArray *noteXs = [notee elementsForName:@"X"];
                                        
                                        if (noteXs.count > 0) {
                                            
                                            GDataXMLElement *noteXEl = (GDataXMLElement *) [noteXs objectAtIndex:0];
                                            
                                            noteX = noteXEl.stringValue;
                                            
                                        }
                                        
                                        
                                        
                                        NSArray *noteYs = [notee elementsForName:@"Y"];
                                        
                                        if (noteYs.count > 0) {
                                            
                                            GDataXMLElement *noteYEl = (GDataXMLElement *) [noteYs objectAtIndex:0];
                                            
                                            noteY = noteYEl.stringValue;
                                            
                                        }
                                        NSArray *Ids = [notee elementsForName:@"AnnotationId"];
                                        
                                        if (Ids.count > 0) {
                                            
                                            GDataXMLElement *IdEl = (GDataXMLElement *) [Ids objectAtIndex:0];
                                            
                                            noteId = IdEl.stringValue;
                                            
                                        }
                                        NSArray *pages = [notee elementsForName:@"Page"];
                                        
                                        if (pages.count > 0) {
                                            
                                            GDataXMLElement *pageEl = (GDataXMLElement *) [pages objectAtIndex:0];
                                            
                                            notepage = pageEl.stringValue;
                                            
                                        }
                                        
                                        NSArray *noteMSGs = [notee elementsForName:@"Text"];
                                        
                                        if (noteMSGs.count > 0) {
                                            
                                            GDataXMLElement *noteMSGEl = (GDataXMLElement *) [noteMSGs objectAtIndex:0];
                                            
                                            noteMSG = noteMSGEl.stringValue;
                                            
                                        }
                                        
                                        CGPoint ptLeftTop;
                                        
                                        ptLeftTop.x=[noteX intValue];
                                        
                                        ptLeftTop.y=[noteY intValue];
                                        
                                        note* noteObj=[[note alloc]initWithName:ptLeftTop.x ordinate:ptLeftTop.y note:noteMSG PageNb:notepage.intValue AttachmentId:AttachmentId.intValue Id:noteId];
                                        [mainDelegate.IncomingNotes addObject:noteObj];
                                        
                                    }
                                    
                                    NSArray *Highlights = [annotationsEl nodesForXPath:@"Highlights" error:nil];
                                    
                                    GDataXMLElement *HighlightsXML;
                                    
                                    if(Highlights.count>0){
                                        
                                        HighlightsXML = [Highlights objectAtIndex:0];
                                        
                                    }
                                    
                                    NSArray *HighlightXML = [HighlightsXML elementsForName:@"Highlight"];
                                    
                                    NSString *HighlightX1;
                                    
                                    NSString *HighlightY1;
                                    
                                    NSString *HighlightX2;
                                    
                                    NSString *HighlightY2;
                                    
                                    NSString *Highlightpage;
                                    
                                    NSString *HighlightId;
                                    
                                    for(GDataXMLElement *Highlight in HighlightXML)
                                    {
                                        NSArray *HighlightX1s = [Highlight elementsForName:@"X"];
                                        
                                        if (HighlightX1s.count > 0) {
                                            
                                            GDataXMLElement *HighlightX1El = (GDataXMLElement *) [HighlightX1s objectAtIndex:0];
                                            
                                            HighlightX1= HighlightX1El.stringValue;
                                            
                                        }
                                        
                                        
                                        NSArray *HighlightX2s = [Highlight elementsForName:@"Y"];
                                        
                                        if (HighlightX2s.count > 0) {
                                            
                                            GDataXMLElement *HighlightX2El = (GDataXMLElement *) [HighlightX2s objectAtIndex:0];
                                            
                                            HighlightX2= HighlightX2El.stringValue;
                                            
                                        }
                                        
                                        
                                        NSArray *HighlightY1s = [Highlight elementsForName:@"Z"];
                                        
                                        if (HighlightY1s.count > 0) {
                                            
                                            GDataXMLElement *HighlightY1El = (GDataXMLElement *) [HighlightY1s objectAtIndex:0];
                                            
                                            HighlightY1= HighlightY1El.stringValue;
                                            
                                        }
                                        
                                        NSArray *HighlightY2s = [Highlight elementsForName:@"W"];
                                        
                                        if (HighlightY2s.count > 0) {
                                            
                                            GDataXMLElement *HighlightY2El = (GDataXMLElement *) [HighlightY2s objectAtIndex:0];
                                            
                                            HighlightY2= HighlightY2El.stringValue;
                                            
                                        }
                                        
                                        NSArray *Ids = [Highlight elementsForName:@"AnnotationId"];
                                        
                                        if (Ids.count > 0) {
                                            
                                            GDataXMLElement *IdEl = (GDataXMLElement *) [Ids objectAtIndex:0];
                                            
                                            HighlightId = IdEl.stringValue;
                                            
                                        }
                                        NSArray *Highlightpages = [Highlight elementsForName:@"Page"];
                                        
                                        if (Highlightpages.count > 0) {
                                            
                                            GDataXMLElement *HighlightpageEl = (GDataXMLElement *) [Highlightpages objectAtIndex:0];
                                            
                                            Highlightpage = HighlightpageEl.stringValue;
                                            
                                        }
                                        
                                        
                                        CGPoint ptLeftTop;
                                        
                                        CGPoint ptRightBottom;
                                        
                                        ptLeftTop.x=[HighlightX1 intValue];
                                        
                                        ptLeftTop.y=[HighlightY1 intValue];
                                        
                                        ptRightBottom.x=[HighlightX2 intValue];
                                        
                                        ptRightBottom.y=[HighlightY2 intValue];
                                        
                                        HighlightClass* obj=[[HighlightClass alloc]initWithName:ptLeftTop.x ordinate:ptRightBottom.x height:ptLeftTop.y width:ptRightBottom.y PageNb:Highlightpage.intValue AttachmentId:AttachmentId.intValue Id:HighlightId];
                                        [mainDelegate.IncomingHighlights addObject:obj];
                                        
                                    }
                                }
                                
                                NSData* NoteAnnotationsData=[NSKeyedArchiver archivedDataWithRootObject:[mainDelegate.IncomingNotes copy]];
                                NSData* HighlightAnnotationsData=[NSKeyedArchiver archivedDataWithRootObject:[mainDelegate.IncomingHighlights copy]];
                                
                                [self cacheAttachment:AttachmentId CorrespondenceId:Id FileName:FileName fileuri:fileUri url:url siteId:SiteId FileId:FileId thumbnailurl:thumbnailUrl FileUrl:FileUrl IsOriginalMail:isOriginalMail FolderName:folderName FolderId:folderId NoteAnnotations:NoteAnnotationsData HighlightAnnotations:HighlightAnnotationsData Status:AttachmentStatus];
                                
                            }}}}
                
                
            }
        }}
}
+(void)cacheDestination:(NSString*)DestinationId value:(NSString*)value section:(NSString*)section {
    [self DeleteDestination:DestinationId section:section];
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    NSManagedObject *dataRecord = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"Destinations"
                                   inManagedObjectContext:managedObjectContext];
    [dataRecord setValue:DestinationId forKey:@"id"];
    [dataRecord setValue:value forKey:@"value"];
    [dataRecord setValue:section forKey:@"section"];
}
+(void)DeleteDestination:(NSString*)Id section:(NSString*)section{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSPredicate *predicate;
    NSArray *fetchedObjects;
    NSEntityDescription *entity;
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"Destinations" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:@"(id = %@) AND (section = %@)", Id,section];
    [fetchRequest setPredicate:predicate];
    fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in fetchedObjects) {
        [managedObjectContext deleteObject:obj];
    }
    
}
+(NSMutableArray*)LoadCachedDestinations:(NSString*)section{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSPredicate* predicate;
    NSEntityDescription *entity;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"Destinations" inManagedObjectContext:managedObjectContext];
    predicate = [NSPredicate predicateWithFormat:@"(section = %@)",section];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray * data=[[NSMutableArray alloc]init];
    for (NSManagedObject *obj in fetchedObjects) {
        
        NSString *DestId=[obj valueForKey:@"id"];
        NSString* value = [obj valueForKey:@"value"];
        CDestination* dest = [[CDestination alloc] initWithName:value Id:DestId];
        [data addObject:dest];
        
    }
    return data;
}
+(void)GetFolderAttachment:(NSString*)url Id:(int)Id{
    NSLog(@"Info:Enter GetfolderAttachment method.");
    AppDelegate* mainDelegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    CCorrespondence *correspondence=mainDelegate.searchModule.correspondenceList[Id];
    NSString* urlTextEscaped = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // NSURL *xmlUrl = [NSURL URLWithString:urlTextEscaped];
    // NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
    NSError* myError;
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlTextEscaped] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
    NSData *xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&myError];
    if (myError.code==NSURLErrorTimedOut) {
        NSLog(@"Error: Request timed out");
        [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:NSLocalizedString(@"RequestTimedOut", @"request timed out") waitUntilDone:YES];
    }
    else
    {
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    
    NSArray *Attachments = [doc nodesForXPath:@"//Attachments" error:nil];
    
    GDataXMLElement *AttachmentsXML;
    if (Attachments.count > 0) {
        AttachmentsXML =  [Attachments objectAtIndex:0];
    }
    
    NSArray *attachmentXML = [AttachmentsXML elementsForName:@"Attachment"];
    
    NSString *urlattach;
    NSString *idattach;
    NSString *thumbnailurlattach;
    NSString *attachmentStatus;
    for(GDataXMLElement *attachment in attachmentXML)
    {
        NSArray *ids = [attachment elementsForName:@"AttachmentId"];
        if (ids.count > 0) {
            GDataXMLElement *idEl = (GDataXMLElement *) [ids objectAtIndex:0];
            idattach = idEl.stringValue;
        }
        
        NSArray *urls = [attachment elementsForName:@"URL"];
        if (urls.count > 0) {
            GDataXMLElement *urlEl = (GDataXMLElement *) [urls objectAtIndex:0];
            urlattach = urlEl.stringValue;
        }
        
        
        NSArray *thumbnailurls = [attachment elementsForName:@"ThumbnailURL"];
        if (thumbnailurls.count > 0) {
            GDataXMLElement *thumbnailurlEl = (GDataXMLElement *) [thumbnailurls objectAtIndex:0];
            thumbnailurlattach = thumbnailurlEl.stringValue;
        }
        NSArray *statusArray=[attachment elementsForName:@"Status"];
        if (statusArray.count>0) {
            GDataXMLElement *statusEl=(GDataXMLElement*)[statusArray objectAtIndex:0];
            attachmentStatus=statusEl.stringValue;
        }
        for(CAttachment* doc in correspondence.attachmentsList)
        {
            if([doc.AttachmentId isEqualToString: idattach]){
                doc.ThubnailUrl = thumbnailurlattach;
                doc.url = urlattach;
                doc.Status=attachmentStatus;
            }
        }
    }
}
}
+(NSMutableArray*)loadSpecifiqueAttachment:(NSData*)xmlData CorrespondenceId:(NSString*)Id{

    NSError *error;
    
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    
    if (doc == nil) {
        NSLog(@"Error: failed to de-seriaize xml.");
        if (error.code==NSURLErrorTimedOut) {
            NSLog(@"Error: Request timed out.");
            [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:NSLocalizedString(@"RequestTimedOut", @"request timed out") waitUntilDone:YES];
        }
        else{
            NSLog(@"Error: failed to connect to server.");
            NSString* ErrorMessage=@"Unable to connect Server";
            [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:ErrorMessage waitUntilDone:YES];
            return nil;
        }
        NSLog(@"Error:%@",error);
    }
    
    NSArray *Attachments = [doc nodesForXPath:@"//Folders" error:nil];
    NSMutableArray* attachments = [[NSMutableArray alloc] init];
    
    
    if (Attachments.count > 0) {
        GDataXMLElement *AttachmentsXML =  [Attachments objectAtIndex:0];
        attachments=[self loadAttachmentListWith:AttachmentsXML CorrespondenceId:Id];
    }
    if(Attachments.count==0){
        
        NSArray *results = [doc nodesForXPath:@"//Result" error:nil];
        
        GDataXMLElement *resultxml =  [results objectAtIndex:0];
        
        NSString* status=[(GDataXMLElement *) [resultxml attributeForName:@"Status"] stringValue];
        if([[status lowercaseString] isEqualToString:@"error"]){
            NSString* ErrorMessage=NSLocalizedString(@"UnableToConnect", @"unable to connect server");
        NSArray *Message = [resultxml elementsForName:@"ErrorMessage"];
        if (Message.count > 0) {
            GDataXMLElement *msgEl = (GDataXMLElement *) [Message objectAtIndex:0];
            ErrorMessage = msgEl.stringValue;
        }
        [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:ErrorMessage waitUntilDone:YES];
            return nil;
        }
    }
    return attachments;
    
    
    
}


//+(NSMutableDictionary *)GetPropertiesFrom:(GDataXMLElement*) element{
//
//    NSMutableDictionary* properties = [[NSMutableDictionary alloc] init];
//    NSInteger i=0;
//    NSArray *propertyXML = [element elementsForName:@"MetadataItem"];
//    if (propertyXML.count > 0) {
//
//        for(GDataXMLElement *prop in propertyXML)
//        {
//            // NSLog(@"prop element %@", prop);
//             NSMutableDictionary* property = [[NSMutableDictionary alloc] init];
//            NSArray *pnames = [prop elementsForName:@"Label"];
//            if (pnames.count > 0) {
//
//                GDataXMLElement *pEl = (GDataXMLElement *) [pnames objectAtIndex:0];
//
//                GDataXMLElement* valueEl = [[prop elementsForName:@"Value"] objectAtIndex:0];
//
//                [property setObject:valueEl.stringValue forKey:pEl.stringValue];
//                NSString *s=[NSString stringWithFormat:@"%d",i];
//                [properties setObject:property forKey:s];
//                i++;
//            }
//
//        }
//
//    }
//    return properties;
//}

+(NSMutableDictionary *)loadItemsByOrder:(NSArray*) arrayItems{
    
    NSMutableDictionary* properties = [[NSMutableDictionary alloc] init];
    NSInteger i=0;
    
    NSArray *items=((GDataXMLElement*)arrayItems[0]).children;
    for(GDataXMLElement *prop in items)
    {
        NSString* label=@"",*value=@"";
        NSMutableDictionary* item = [[NSMutableDictionary alloc] init];
        NSArray *labels = [prop elementsForName:@"Label"];
        if (labels.count > 0) {
            
            GDataXMLElement *pEl = (GDataXMLElement *) [labels objectAtIndex:0];
            if(pEl!=nil)
                label=pEl.stringValue;
            NSArray* values=[[NSArray alloc]init];
            values=[prop elementsForName:@"Value"];
            if(values.count>0){
                GDataXMLElement* valueEl = [values objectAtIndex:0];
                value=valueEl.stringValue;
            }
            [item setObject:value forKey:pEl.stringValue];
        }
        NSString *s=[NSString stringWithFormat:@"%d",i];
        [properties setObject:item forKey:s];
        i++;
    }
    return properties;
}

//+ (NSMutableArray *)loadFoldersListWith:(NSArray*) folders {
//
//
//	NSMutableArray* Allfolders = [[NSMutableArray alloc] init];
//
//	for (GDataXMLElement *folder in folders) {
//
//        NSString *name;
//
//
//        NSArray *names = [folder elementsForName:@"Name"];
//        if (names.count > 0) {
//            GDataXMLElement *namesEl = (GDataXMLElement *) [names objectAtIndex:0];
//            name = namesEl.stringValue;
//        }
//
//        NSMutableArray* attachments = [[NSMutableArray alloc] init];
//        NSArray *attachmentsXml = [folder elementsForName:@"Attachments"];
//        if (attachmentsXml.count > 0) {
//            GDataXMLElement *attachmentsEl = (GDataXMLElement *) [attachmentsXml objectAtIndex:0];
//            attachments=[self loadAttachmentListWith:attachmentsEl];
//        }
//
//
//        CFolder* newFolder = [[CFolder alloc] initWithName:name];
//        [newFolder setAttachments:attachments];
//        [Allfolders addObject:newFolder];
//    }
//
//
//
//    return Allfolders;
//
//}





+(NSMutableArray*)loadAttachmentListWith:(GDataXMLElement*)attachmentEl CorrespondenceId:(NSString*)CorrespondenceId{
    AppDelegate *mainDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSMutableArray* attachments = [[NSMutableArray alloc] init];
    NSArray *Folders = [attachmentEl elementsForName:@"Folder"];
    for(GDataXMLElement *FoldersEl in Folders) {
        NSString* folderName = [FoldersEl attributeForName:@"Name"].stringValue;
        NSString* folderId = [FoldersEl attributeForName:@"Id"].stringValue;

        NSArray *Folderxml = [FoldersEl elementsForName:@"Attachments"];
        for(GDataXMLElement *folders in Folderxml)
        {
            
            NSArray *attachmentXML = [folders elementsForName:@"Attachment"];
            
            for(GDataXMLElement *attachment in attachmentXML)
            {
                
                [mainDelegate.IncomingHighlights removeAllObjects];
                [mainDelegate.IncomingNotes removeAllObjects];
                mainDelegate.IncomingNotes=[[NSMutableArray alloc]init];
                mainDelegate.IncomingHighlights=[[NSMutableArray alloc]init];
                NSString* fileUri;
                NSString* FileName;
                NSString* url;
                NSString* SiteId;
                NSString* FileId;
                NSString* FileUrl;
                NSString* thumbnailUrl;
                NSString* isOriginalMail;
                NSString* AttachmentId;
                NSString* AttachmentStatus;
                
                NSArray *fileUris = [attachment elementsForName:@"DocId"];
                if (fileUris.count > 0) {
                    GDataXMLElement *fileUriEl = (GDataXMLElement *) [fileUris objectAtIndex:0];
                    fileUri = fileUriEl.stringValue;
                }
                NSArray *attachid = [attachment elementsForName:@"AttachmentId"];
                if (attachid.count > 0) {
                    GDataXMLElement *attachidEl = (GDataXMLElement *) [attachid objectAtIndex:0];
                    AttachmentId = attachidEl.stringValue;
                }
                NSArray *FileNames = [attachment elementsForName:@"FileName"];
                if (FileNames.count > 0) {
                    GDataXMLElement *FileNameEL = (GDataXMLElement *) [FileNames objectAtIndex:0];
                    FileName = FileNameEL.stringValue;
                }
                NSArray *urls = [attachment elementsForName:@"URL"];
                if (urls.count > 0) {
                    GDataXMLElement *urlEl = (GDataXMLElement *) [urls objectAtIndex:0];
                    url = urlEl.stringValue;
                }
                NSArray *ServerFileInfo = [attachment nodesForXPath:@"ServerFileInfo" error:nil];
                GDataXMLElement *ServerFileInfoXML;
                
                NSArray *StatusArray=[attachment elementsForName:@"Status"];
                if (StatusArray.count>0) {
                    GDataXMLElement *statusEl = (GDataXMLElement *) [StatusArray objectAtIndex:0];
                    AttachmentStatus = statusEl.stringValue;
                }
                if(ServerFileInfo.count>0){
                    
                    ServerFileInfoXML = [ServerFileInfo objectAtIndex:0];
                    
                    NSArray *SiteIds = [ServerFileInfoXML elementsForName:@"SiteId"];
                    if (SiteIds.count > 0) {
                        GDataXMLElement *SiteIdEl = (GDataXMLElement *) [SiteIds objectAtIndex:0];
                        SiteId = SiteIdEl.stringValue;
                    }
                    
                    NSArray *FileIds = [ServerFileInfoXML elementsForName:@"FileId"];
                    if (FileIds.count > 0) {
                        GDataXMLElement *FileIdEl = (GDataXMLElement *) [FileIds objectAtIndex:0];
                        FileId = FileIdEl.stringValue;
                    }
                    
                    NSArray *FileUrls = [ServerFileInfoXML elementsForName:@"FileURL"];
                    if (FileUrls.count > 0) {
                        GDataXMLElement *FileUrlEl = (GDataXMLElement *) [FileUrls objectAtIndex:0];
                        FileUrl = FileUrlEl.stringValue;
                    }
                }
                NSArray *thumbnailUrls = [attachment elementsForName:@"ThumbnailURL"];
                if (thumbnailUrls.count > 0) {
                    GDataXMLElement *thumbnailUrlEl= (GDataXMLElement *) [thumbnailUrls objectAtIndex:0];
                    thumbnailUrl = thumbnailUrlEl.stringValue;
                }
                
                NSArray *isOriginalMails = [attachment elementsForName:@"IsOriginalMail"];
                if (isOriginalMails.count > 0) {
                    GDataXMLElement *isOriginalMailEl= (GDataXMLElement *) [isOriginalMails objectAtIndex:0];
                    isOriginalMail = isOriginalMailEl.stringValue;
                }
                
                
                //     NSMutableArray* annotations = [[NSMutableArray alloc] init];
                NSArray *annotationsXml = [attachment elementsForName:@"Annotations"];
                
                if (annotationsXml.count > 0) {
                    GDataXMLElement *annotationsEl = (GDataXMLElement *) [annotationsXml objectAtIndex:0];
                    NSArray *Notes = [annotationsEl nodesForXPath:@"Notes" error:nil];
                    
                    
                    
                    GDataXMLElement *NotesXML;
                    
                    if(Notes.count>0){
                        
                        NotesXML = [Notes objectAtIndex:0];
                        
                    }
                    
                    NSArray *noteXML = [NotesXML elementsForName:@"Note"];
                    
                    NSString *noteX;
                    
                    NSString *noteY;
                    
                    NSString *notepage;
                    
                    NSString *noteMSG;
                    NSString *noteId;
                    
                    for(GDataXMLElement *notee in noteXML)
                        
                    {
                        NSArray *noteXs = [notee elementsForName:@"X"];
                        
                        if (noteXs.count > 0) {
                            
                            GDataXMLElement *noteXEl = (GDataXMLElement *) [noteXs objectAtIndex:0];
                            
                            noteX = noteXEl.stringValue;
                            
                        }
                        
                        NSArray *noteYs = [notee elementsForName:@"Y"];
                        
                        if (noteYs.count > 0) {
                            
                            GDataXMLElement *noteYEl = (GDataXMLElement *) [noteYs objectAtIndex:0];
                            
                            noteY = noteYEl.stringValue;
                            
                        }
                        
                        NSArray *Ids = [notee elementsForName:@"AnnotationId"];
                        
                        if (Ids.count > 0) {
                            
                            GDataXMLElement *IdEl = (GDataXMLElement *) [Ids objectAtIndex:0];
                            
                            noteId = IdEl.stringValue;
                            
                        }
                        
                        NSArray *pages = [notee elementsForName:@"Page"];
                        
                        if (pages.count > 0) {
                            
                            GDataXMLElement *pageEl = (GDataXMLElement *) [pages objectAtIndex:0];
                            
                            notepage = pageEl.stringValue;
                            
                        }
                        
                        NSArray *noteMSGs = [notee elementsForName:@"Text"];
                        
                        if (noteMSGs.count > 0) {
                            
                            GDataXMLElement *noteMSGEl = (GDataXMLElement *) [noteMSGs objectAtIndex:0];
                            
                            noteMSG = noteMSGEl.stringValue;
                            
                        }
                        
                        CGPoint ptLeftTop;
                        
                        ptLeftTop.x=[noteX intValue];
                        
                        ptLeftTop.y=[noteY intValue];
                        
                        note* noteObj=[[note alloc]initWithName:ptLeftTop.x ordinate:ptLeftTop.y note:noteMSG PageNb:notepage.intValue AttachmentId:AttachmentId.intValue Id:noteId];
                        [mainDelegate.IncomingNotes addObject:noteObj];
                        
                    }
                    
                    NSArray *Highlights = [annotationsEl nodesForXPath:@"Highlights" error:nil];
                    
                    GDataXMLElement *HighlightsXML;
                    
                    if(Highlights.count>0){
                        
                        HighlightsXML = [Highlights objectAtIndex:0];
                        
                    }
                    
                    NSArray *HighlightXML = [HighlightsXML elementsForName:@"Highlight"];
                    
                    NSString *HighlightX1;
                    
                    NSString *HighlightY1;
                    
                    NSString *HighlightX2;
                    
                    NSString *HighlightY2;
                    
                    NSString *Highlightpage;
                    
                    NSString *HighlightId;
                    for(GDataXMLElement *Highlight in HighlightXML)
                    {
                        NSArray *HighlightX1s = [Highlight elementsForName:@"X"];
                        
                        if (HighlightX1s.count > 0) {
                            
                            GDataXMLElement *HighlightX1El = (GDataXMLElement *) [HighlightX1s objectAtIndex:0];
                            
                            HighlightX1= HighlightX1El.stringValue;
                            
                        }
                        
                        
                        NSArray *HighlightX2s = [Highlight elementsForName:@"Y"];
                        
                        if (HighlightX2s.count > 0) {
                            
                            GDataXMLElement *HighlightX2El = (GDataXMLElement *) [HighlightX2s objectAtIndex:0];
                            
                            HighlightX2= HighlightX2El.stringValue;
                            
                        }
                        
                        
                        NSArray *HighlightY1s = [Highlight elementsForName:@"Z"];
                        
                        if (HighlightY1s.count > 0) {
                            
                            GDataXMLElement *HighlightY1El = (GDataXMLElement *) [HighlightY1s objectAtIndex:0];
                            
                            HighlightY1= HighlightY1El.stringValue;
                            
                        }
                        
                        NSArray *HighlightY2s = [Highlight elementsForName:@"W"];
                        
                        if (HighlightY2s.count > 0) {
                            
                            GDataXMLElement *HighlightY2El = (GDataXMLElement *) [HighlightY2s objectAtIndex:0];
                            
                            HighlightY2= HighlightY2El.stringValue;
                            
                        }
                        
                        
                        NSArray *Highlightpages = [Highlight elementsForName:@"Page"];
                        
                        if (Highlightpages.count > 0) {
                            
                            GDataXMLElement *HighlightpageEl = (GDataXMLElement *) [Highlightpages objectAtIndex:0];
                            
                            Highlightpage = HighlightpageEl.stringValue;
                            
                        }
                        NSArray *Ids = [Highlight elementsForName:@"AnnotationId"];
                        
                        if (Ids.count > 0) {
                            
                            GDataXMLElement *IdEl = (GDataXMLElement *) [Ids objectAtIndex:0];
                            
                            HighlightId = IdEl.stringValue;
                            
                        }
                        
                        CGPoint ptLeftTop;
                        
                        CGPoint ptRightBottom;
                        
                        ptLeftTop.x=[HighlightX1 intValue];
                        
                        ptLeftTop.y=[HighlightY1 intValue];
                        
                        ptRightBottom.x=[HighlightX2 intValue];
                        
                        ptRightBottom.y=[HighlightY2 intValue];
                        
                        HighlightClass* obj=[[HighlightClass alloc]initWithName:ptLeftTop.x ordinate:ptRightBottom.x height:ptLeftTop.y width:ptRightBottom.y PageNb:Highlightpage.intValue AttachmentId:AttachmentId.intValue Id:HighlightId];
                        [mainDelegate.IncomingHighlights addObject:obj];
                        
                    }
                }
                
                CAttachment* newAttachment = [[CAttachment alloc] initWithTitle:FileName docId:fileUri url:url SiteId:SiteId FileId:FileId AttachmentId:AttachmentId FileUrl:FileUrl ThubnailUrl:thumbnailUrl isOriginalMail:isOriginalMail FolderName:folderName ];
                [newAttachment setStatus:AttachmentStatus];
                [newAttachment setFolderId:folderId];
                // [newAttachment setAnnotations:annotations];
                [newAttachment setNoteAnnotations:[mainDelegate.IncomingNotes copy]];
                [newAttachment setHighlightAnnotations:[mainDelegate.IncomingHighlights copy]];
                [attachments addObject:newAttachment];
                NSData* NoteAnnotationsData=[NSKeyedArchiver archivedDataWithRootObject:newAttachment.NoteAnnotations];
                NSData* HighlightAnnotationsData=[NSKeyedArchiver archivedDataWithRootObject:newAttachment.HighlightAnnotations];
                
                [self cacheAttachment:AttachmentId CorrespondenceId:CorrespondenceId FileName:FileName fileuri:fileUri url:url siteId:SiteId FileId:FileId thumbnailurl:thumbnailUrl FileUrl:FileUrl IsOriginalMail:isOriginalMail FolderName:folderName FolderId:folderId NoteAnnotations:NoteAnnotationsData HighlightAnnotations:HighlightAnnotationsData Status:AttachmentStatus ];
                
            }}}
    
    return attachments;
    
}
+(NSMutableArray*)LoadAttachments:(NSString*)CorrespondenceId{
    NSMutableArray* Attachments = [[NSMutableArray alloc] init];
    
    
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSEntityDescription *entity;
    NSPredicate* predicate;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"Attachments" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:@"(correspondenceid = %@)",CorrespondenceId];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"attachmentid" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSString* fileUri;
    NSString* FileName;
    NSString* FolderId;
    NSString* url;
    NSString* SiteId;
    NSString* FileId;
    NSString* FileUrl;
    NSString* thumbnailUrl;
    NSString* isOriginalMail;
    NSString* AttachmentId;
    NSString* FolderName;
    NSString* Status;

    for (NSManagedObject *obj in fetchedObjects) {
        
        //   xml=[obj valueForKey:@"xml"];
        NSMutableArray *NoteAnnotations=[[NSMutableArray alloc] init];
        NSMutableArray *HighlightAnnotations=[[NSMutableArray alloc] init];
        
        fileUri=[obj valueForKey:@"fileuri"];
        FileName=[obj valueForKey:@"filename"];
        url=[obj valueForKey:@"url"];
        SiteId=[obj valueForKey:@"siteid"];
        FileId=[obj valueForKey:@"fileid"];
        FileUrl=[obj valueForKey:@"fileurl"];
        thumbnailUrl=[obj valueForKey:@"thumbnailurl"];
        isOriginalMail=[obj valueForKey:@"isoriginalmail"];
        AttachmentId=[obj valueForKey:@"attachmentid"];
        FolderName=[obj valueForKey:@"foldername"];
        FolderId=[obj valueForKey:@"folderid"];
        Status=[obj valueForKey:@"status"];

        NoteAnnotations=[NSKeyedUnarchiver unarchiveObjectWithData:[obj valueForKey:@"noteannotations"]];
        HighlightAnnotations=[NSKeyedUnarchiver unarchiveObjectWithData:[obj valueForKey:@"highlightannotations"]];
        
        CAttachment* newAttachment = [[CAttachment alloc] initWithTitle:FileName docId:fileUri url:url SiteId:SiteId FileId:FileId AttachmentId:AttachmentId FileUrl:FileUrl ThubnailUrl:thumbnailUrl isOriginalMail:isOriginalMail FolderName:FolderName];
        [newAttachment setFolderId:FolderId];
        [newAttachment setStatus:Status];
        [newAttachment setNoteAnnotations:[NoteAnnotations copy]];
        [newAttachment setHighlightAnnotations:[HighlightAnnotations copy]];
        [Attachments addObject:newAttachment];
        
    }
 
    
    return  Attachments;
}
+(void)cacheAttachment:(NSString*)AttachmentId CorrespondenceId:(NSString*)CorrespondenceId FileName:(NSString*)filename fileuri:(NSString*)fileuri url:(NSString*)url siteId:(NSString*)siteId FileId:(NSString*)fileid thumbnailurl:(NSString*)thumbnailurl FileUrl:(NSString*)fileurl IsOriginalMail:(NSString*)isoriginalmail FolderName:(NSString*)foldername FolderId:(NSString*)folderId NoteAnnotations:(NSData*)NoteAnnotations HighlightAnnotations:(NSData*)HighlightAnnotations Status:(NSString*)Status{
    
    [self DeleteAttachment:AttachmentId FolderName:foldername CorrespondenceId:CorrespondenceId];
    NSError *error;
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    NSManagedObject *dataRecord = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"Attachments"
                                   inManagedObjectContext:managedObjectContext];
    [dataRecord setValue:AttachmentId forKey:@"attachmentid"];
    [dataRecord setValue:CorrespondenceId forKey:@"correspondenceid"];
    [dataRecord setValue:filename forKey:@"filename"];
    [dataRecord setValue:fileuri forKey:@"fileuri"];
    [dataRecord setValue:fileurl forKey:@"fileurl"];
    [dataRecord setValue:url forKey:@"url"];
    [dataRecord setValue:siteId forKey:@"siteid"];
    [dataRecord setValue:fileid forKey:@"fileid"];
    [dataRecord setValue:thumbnailurl forKey:@"thumbnailurl"];
    [dataRecord setValue:isoriginalmail forKey:@"isoriginalmail"];
    [dataRecord setValue:foldername forKey:@"foldername"];
    [dataRecord setValue:folderId forKey:@"folderid"];
    [dataRecord setValue:NoteAnnotations forKey:@"noteannotations"];
    [dataRecord setValue:HighlightAnnotations forKey:@"highlightannotations"];
    [dataRecord setValue:Status forKey:@"status"];
    if (![managedObjectContext save:&error]) {
        
        NSLog(@"Error:%@", error);
    }
    
}
+(void)DeleteAttachment:(NSString*)AttachmentId FolderName:(NSString*)foldername CorrespondenceId:(NSString*)CorrespondenceId{
    NSFetchRequest *fetchRequest;
    NSError *error;
    NSPredicate *predicate;
    NSArray *fetchedObjects;
    NSEntityDescription *entity;
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = [delegate managedObjectContext];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"Attachments" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:@"(attachmentid = %@) AND (foldername = %@) AND (correspondenceid = %@)", AttachmentId,foldername,CorrespondenceId];
    [fetchRequest setPredicate:predicate];
    fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in fetchedObjects) {
        [managedObjectContext deleteObject:obj];
    }
    
}
+(NSInteger)GetNoteIdWithData:(NSData *) xmlData {
    
    
    // NSURL *xmlUrl = [NSURL URLWithString:url];
    // NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
    NSError *error;
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
														   options:0 error:&error];
    
    
	NSArray *results = [doc nodesForXPath:@"//Result" error:nil];
	
	GDataXMLElement *noteXml =  [results objectAtIndex:0];
    
    
    NSInteger noteId;
    
	
    NSArray *noteIds = [noteXml elementsForName:@"NoteId"];
	GDataXMLElement *noteEl = (GDataXMLElement *) [noteIds objectAtIndex:0];
	noteId = [noteEl.stringValue integerValue];
    
    
    return noteId;
}

+(NSString*)loadPdfFile:(NSString*)fileUrl inDirectory:(NSString*)dirName{
    //NSString*strUrl;
    //  strUrl= [fileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // NSURL *url=[NSURL URLWithString:strUrl];
    
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *path = [cachesDirectory stringByAppendingPathComponent:dirName];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])    //Does directory already exist?
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"Create directory error: %@", error);
        }
    }
    
    
    NSString* pdfCacheName = [fileUrl lastPathComponent];
    
    NSString *tempPdfLocation = [path stringByAppendingPathComponent:pdfCacheName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:tempPdfLocation];
    if(!fileExists){
        //jen
        NSString*strUrl;
        strUrl=[fileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url=[NSURL URLWithString:strUrl];
        NSData *data = [NSData dataWithContentsOfURL:url ];
        if(data.length!=0)
            [data writeToFile:tempPdfLocation atomically:TRUE];
        else tempPdfLocation=@"";    }
    
    return tempPdfLocation;
}

+(NSString*)loadSignature:(NSData*)xmlData {
    
    NSError *error;
    
    GDataXMLDocument *signatureXML = [[GDataXMLDocument alloc] initWithData:xmlData
                                                                    options:0 error:&error];
    
    
    NSString* signature;
    
    NSArray *signatures = [signatureXML nodesForXPath:@"//signature" error:nil];
    if (signatures.count > 0) {
        GDataXMLElement *signatureEl = (GDataXMLElement *) [signatures objectAtIndex:0];
        
        signature = signatureEl.stringValue;
        
        
    }
    
    return signature;
}

+(CSearch *)loadSearchWithData:(NSData*)xmlData {
    NSLog(@"Info:Enter loadSerchWithData");
    NSMutableArray *searchCriteriaProp=[[NSMutableArray alloc]init];
    NSError *error;
    NSLog(@"Converting NSData result to XML");
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
														   options:0 error:&error];
    
    if (doc == nil)
    {
        NSLog(@"Error:failed to convert data to XML");
        return nil;
    }
    
	NSArray *results = [doc nodesForXPath:@"//Result" error:nil];
	
    
	GDataXMLElement *searchXML =  [results objectAtIndex:0];
    NSMutableArray *searchTypesList=[[NSMutableArray alloc]init];
    NSArray *searchTypesEl =[searchXML nodesForXPath:@"SearchTypes/SearchType" error:nil];
    
    for (GDataXMLElement * typeEl in searchTypesEl) {
        
        NSInteger typeId = [[typeEl attributeForName:@"Id"].stringValue integerValue];
        NSString* label = [[[typeEl elementsForName:@"Label"] objectAtIndex:0] stringValue];
        NSString* icon = [[[typeEl elementsForName:@"Icon"]objectAtIndex:0] stringValue];
        CSearchType* searchType=[[CSearchType alloc]initWithId:typeId label:label icon:icon];
        [searchTypesList addObject:searchType];
    }
    
    
    
    NSArray *searchCriteriaEl =[searchXML nodesForXPath:@"Controls/Control" error:nil];
    for(GDataXMLElement * criteriaEl in searchCriteriaEl){
        NSString* criteriaId=[criteriaEl attributeForName:@"Id"].stringValue;
        NSString* label=[criteriaEl attributeForName:@"Label"].stringValue;
        NSString* type=[criteriaEl attributeForName:@"Type"].stringValue;
        NSMutableDictionary* options = [[NSMutableDictionary alloc] init];
        NSArray *optionsList=criteriaEl.children;
        if(optionsList.count>0){
            for(GDataXMLElement *item in optionsList)
            {   NSArray *Option=item.children;
                for (GDataXMLElement * optionEl in Option) {
                    
                    NSString* optionId = [optionEl attributeForName:@"Value"].stringValue;
                    NSString* value = [optionEl attributeForName:@"Text"].stringValue;
                    
                    [options setObject:value forKey:optionId];
                    
                }
                
            }
            
        }
        CSearchCriteria* searchCriteria=[[CSearchCriteria alloc]initWithId:criteriaId label:label type:type options:options];
        [searchCriteriaProp addObject:searchCriteria];
    }
    
    CSearch *search=[[CSearch alloc]init];
    [search setSearchTypes:searchTypesList];
    [search setCriterias:searchCriteriaProp];
    return search;
    
}

+(NSMutableArray*)loadSearchCorrespondencesWithData:(NSData*)xmlData {
    NSError *error;
    NSString* TotalCorrnb;
    AppDelegate * mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    
    if (doc == nil) { return nil; }
    
    NSArray *results = [doc nodesForXPath:@"//Result" error:nil];
    
    GDataXMLElement *correspondencesXML =  [results objectAtIndex:0];
    
    NSString* status=[(GDataXMLElement *) [correspondencesXML attributeForName:@"Status"] stringValue];
    
    if([status isEqualToString:@"ERROR"]){
        NSMutableDictionary* dict=[[NSMutableDictionary alloc]init];
        NSString* ErrorMessage=NSLocalizedString(@"UnableToConnect", @"unable to connect server");
        NSArray *Message = [correspondencesXML elementsForName:@"ErrorMessage"];
        if (Message.count > 0) {
            GDataXMLElement *msgEl = (GDataXMLElement *) [Message objectAtIndex:0];
            ErrorMessage = msgEl.stringValue;
        }
        [dict setObject:ErrorMessage forKey:@"error"];
        return nil;
        
    }
    NSArray *totalCorrNb = [correspondencesXML elementsForName:@"Total"];
    if (totalCorrNb.count > 0) {
        GDataXMLElement *totalEl = (GDataXMLElement *) [totalCorrNb objectAtIndex:0];
        TotalCorrnb = totalEl.stringValue;
        mainDelegate.InboxTotalCorr=[TotalCorrnb intValue];
    }
    NSArray *correspondences =[correspondencesXML nodesForXPath:@"Correspondences/Correspondence" error:nil];
    NSMutableArray* Allcorrespondences = [[NSMutableArray alloc] init];
    
    for (GDataXMLElement *correspondence in correspondences) {
        
        NSString* transferId;
        NSString *Id;
        BOOL Priority;
        BOOL New;
        BOOL SHOWLOCK;
        NSString* thumbnailUrl;
        NSString* Status;
        
        
        NSArray *transferIds = [correspondence elementsForName:@"TransferId"];
        if (transferIds.count > 0) {
            GDataXMLElement *transferIdEl = (GDataXMLElement *) [transferIds objectAtIndex:0];
            transferId = transferIdEl.stringValue;
        }
        
        NSArray *thumbnailUrls = [correspondence elementsForName:@"ThumbnailUrl"];
        if (thumbnailUrls.count > 0) {
            GDataXMLElement *thumbnailUrlEl= (GDataXMLElement *) [thumbnailUrls objectAtIndex:0];
            thumbnailUrl = thumbnailUrlEl.stringValue;
        }
        else
            thumbnailUrl=@"";
        
        NSArray *correspondenceIds = [correspondence elementsForName:@"CorrespondenceId"];
        if (correspondenceIds.count > 0) {
            GDataXMLElement *correspondenceIdEl = (GDataXMLElement *) [correspondenceIds objectAtIndex:0];
            Id = correspondenceIdEl.stringValue;
        }
        
        NSArray *StatusArray = [correspondence elementsForName:@"Status"];
        if (StatusArray.count > 0) {
            GDataXMLElement *StatusEl = (GDataXMLElement *) [StatusArray objectAtIndex:0];
            Status = StatusEl.stringValue;
        }
        
        NSArray *priorities = [correspondence elementsForName:@"IsHighPriority"];
        if (priorities.count > 0) {
            GDataXMLElement *priorityEl = (GDataXMLElement *) [priorities objectAtIndex:0];
            Priority = [priorityEl.stringValue boolValue];
        }
        
        GDataXMLElement *newEl = (GDataXMLElement *) [[correspondence elementsForName:@"IsNew"]objectAtIndex:0];
        New = [newEl.stringValue boolValue];
        
        GDataXMLElement *showlockedEl = (GDataXMLElement *) [[correspondence elementsForName:@"IsLocked"]objectAtIndex:0];
        SHOWLOCK = [showlockedEl.stringValue boolValue];
        
        
        //********GRIDINFO**********
        NSArray *systemProperties =[correspondence nodesForXPath:@"GridInfo" error:nil];
        NSMutableDictionary *systemPropertiesList=[[NSMutableDictionary alloc] init] ;
        if (systemProperties.count > 0) {
            systemPropertiesList=[self loadItemsByOrder:systemProperties];
        }
        //********METADATA**********
        NSArray *properties = [correspondence elementsForName:@"Metadata"];
        NSMutableDictionary *propertiesList=[[NSMutableDictionary alloc] init];
        if (properties.count > 0) {
            propertiesList=[self loadItemsByOrder:properties];
        }
        
        
        
        NSArray *Maintoolbar =[correspondence nodesForXPath:@"ToolbarItems" error:nil];
        NSMutableDictionary *toolbarItems=[[NSMutableDictionary alloc] init],*CustomItemsList=[[NSMutableDictionary alloc] init];
        NSMutableArray *toolbarActions=[[NSMutableArray alloc] init];
        NSMutableArray *signActions=[[NSMutableArray alloc]init] ,*AnnotationsList=[[NSMutableArray alloc]init],*AttachmentsList=[[NSMutableArray alloc]init],*QuickActions=[[NSMutableArray alloc]init];
        int key=-1;
        for(GDataXMLElement * element in Maintoolbar){
            NSArray *toolbar=element.children;
            for(GDataXMLElement *prop in toolbar)
            {
                if([prop.name isEqualToString:@"CustomToolbarItem"]){
                    
                    key++;
                    NSMutableArray *CustomItemsArray=[[NSMutableArray alloc]init];
                    NSString* Name=[(GDataXMLElement *) [prop attributeForName:@"Name"] stringValue];
                    NSString* Label=[(GDataXMLElement *) [prop attributeForName:@"Label"] stringValue];
                    BOOL Display=[[(GDataXMLElement *) [prop attributeForName:@"Display"] stringValue]boolValue];
                    BOOL QuickAction=[[(GDataXMLElement *) [prop attributeForName:@"QuickAction"] stringValue]boolValue];
                    BOOL popup=[[(GDataXMLElement *) [prop attributeForName:@"ShowPopup"] stringValue]boolValue];
                    BOOL backhome=[[(GDataXMLElement *) [prop attributeForName:@"ReturnHome"] stringValue]boolValue];
                    NSString* LookupId=[(GDataXMLElement *) [prop attributeForName:@"LookupId"] stringValue];
                    
                    ToolbarItem* item=[[ToolbarItem alloc]initWithName:Name Label:Label Display:Display Custom:YES popup:popup backhome:backhome ];
                    [item setLookupId:LookupId];
                    if (Display) {
                        [toolbarItems setValue:item forKey:[NSString stringWithFormat:@"%d",key]];
                        if(QuickAction)
                        {
                            CAction* Qact = [[CAction alloc] initWithLabel:Label action:Name popup:popup backhome:backhome Custom:YES];
                            [Qact setLookupId:LookupId];
                            if(prop.children.count<=0)
                                [QuickActions addObject:Qact];
                        }
                    }
                    
                    NSArray *Subitems=prop.children;
                    if(Subitems.count>0){
                        for(GDataXMLElement *item in Subitems)
                        {   NSArray *toolbarItem=item .children;
                            
                            for(GDataXMLElement *item1 in toolbarItem)
                            {
                                
                                if([item1.name isEqualToString:@"CustomToolbarItem"])
                                {
                                    NSString* Namee=[(GDataXMLElement *) [item1 attributeForName:@"Name"] stringValue];
                                    NSString* Labell=[(GDataXMLElement *) [item1 attributeForName:@"Label"] stringValue];
                                    BOOL Displayy=[[(GDataXMLElement *) [item1 attributeForName:@"Display"] stringValue]boolValue];
                                    BOOL QuickActionn=[[(GDataXMLElement *) [prop attributeForName:@"QuickAction"] stringValue]boolValue];
                                    BOOL popup=[[(GDataXMLElement *) [item1 attributeForName:@"ShowPopup"] stringValue]boolValue];
                                    BOOL returnHome=[[(GDataXMLElement *) [item1 attributeForName:@"ReturnHome"] stringValue]boolValue];
                                    NSString* LookupId=[(GDataXMLElement *) [item1 attributeForName:@"LookupId"] stringValue];
                                    
                                    if (Displayy){
                                        CAction* menu = [[CAction alloc] initWithLabel:Labell action:Namee popup:popup backhome:returnHome Custom:YES];
                                        [menu setLookupId:LookupId];
                                        [CustomItemsArray addObject:menu];
                                        if(QuickActionn)
                                        {
                                            [QuickActions addObject:menu];
                                        }
                                    }
                                }
                            }
                            [CustomItemsList setObject:CustomItemsArray forKey:Name];
                        }
                    }
                }
                else
                    if([prop.name isEqualToString:@"ToolbarItem"]){
                        
                        key++;
                        NSString* Name=[(GDataXMLElement *) [prop attributeForName:@"Name"] stringValue];
                        NSString* Label=[(GDataXMLElement *) [prop attributeForName:@"Label"] stringValue];
                        BOOL Display=[[(GDataXMLElement *) [prop attributeForName:@"Display"] stringValue]boolValue];
                        BOOL QuickAction=[[(GDataXMLElement *) [prop attributeForName:@"QuickAction"] stringValue]boolValue];
                        NSString* LookupId=[(GDataXMLElement *) [prop attributeForName:@"LookupId"] stringValue];
                        
                        ToolbarItem* item=[[ToolbarItem alloc]initWithName:Name Label:Label Display:Display Custom:NO popup:NO backhome:NO ];
                        [item setLookupId:LookupId];
                        if (Display) {
                            [toolbarItems setValue:item forKey:[NSString stringWithFormat:@"%d",key]];
                            if(QuickAction)
                            {
                                CAction* Qact = [[CAction alloc] initWithLabel:Label action:Name popup:NO backhome:NO Custom:NO];
                                [Qact setLookupId:LookupId];
                                if(prop.children.count<=0)
                                    [QuickActions addObject:Qact];
                            }
                        }
                        NSArray *Subitems=prop.children;
                        if(Subitems.count>0){
                            for(GDataXMLElement *item in Subitems)
                            {   NSArray *toolbarItem=item .children;
                                
                                for(GDataXMLElement *item1 in toolbarItem)
                                {
                                    if([item1.name isEqualToString:@"ToolbarItem"]){
                                        NSString* Namee=[(GDataXMLElement *) [item1 attributeForName:@"Name"] stringValue];
                                        NSString* Labell=[(GDataXMLElement *) [item1 attributeForName:@"Label"] stringValue];
                                        BOOL Displayy=[[(GDataXMLElement *) [item1 attributeForName:@"Display"] stringValue]boolValue];
                                        BOOL QuickAction=[[(GDataXMLElement *) [item1 attributeForName:@"QuickAction"] stringValue]boolValue];
                                        NSString* LookupId=[(GDataXMLElement *) [item1 attributeForName:@"LookupId"] stringValue];
                                        
                                        if (Displayy){
                                            
                                            if(![Name isEqualToString:@"More"]){
                                                CAction* menu = [[CAction alloc] initWithLabel:Labell action:Namee popup:NO backhome:NO Custom:NO];
                                                [menu setLookupId:LookupId];
                                                if(QuickAction)
                                                {
                                                    
                                                    [QuickActions addObject:menu];
                                                }
                                                if([Name isEqualToString:@"Annotations"]){
                                                    [AnnotationsList addObject:menu];
                                                }
                                                else if ([Name isEqualToString:@"Attachments"])
                                                    [AttachmentsList addObject:menu];
                                                else if ([Name isEqualToString:@"Signature"])
                                                    [signActions addObject:menu];
                                                
                                            }
                                            else{
                                                BOOL popup=[[(GDataXMLElement *) [item1 attributeForName:@"ShowPopup"] stringValue]boolValue];
                                                BOOL returnHome=[[(GDataXMLElement *) [item1 attributeForName:@"ReturnHome"] stringValue]boolValue];
                                                CAction* menu = [[CAction alloc] initWithLabel:Labell action:Namee popup:popup backhome:returnHome Custom:NO];
                                                [menu setLookupId:LookupId];
                                                if(QuickAction)
                                                {
                                                    [QuickActions addObject:menu];
                                                }
                                                [toolbarActions addObject:menu];
                                            }
                                        }
                                        
                                    }
                                    
                                    if([item1.name isEqualToString:@"CustomToolbarItem"])
                                    {
                                        NSString* Namee=[(GDataXMLElement *) [item1 attributeForName:@"Name"] stringValue];
                                        NSString* Labell=[(GDataXMLElement *) [item1 attributeForName:@"Label"] stringValue];
                                        BOOL Displayy=[[(GDataXMLElement *) [item1 attributeForName:@"Display"] stringValue]boolValue];
                                        BOOL QuickActionn=[[(GDataXMLElement *) [item1 attributeForName:@"QuickAction"] stringValue]boolValue];
                                        BOOL popup=[[(GDataXMLElement *) [item1 attributeForName:@"ShowPopup"] stringValue]boolValue];
                                        BOOL returnHome=[[(GDataXMLElement *) [item1 attributeForName:@"ReturnHome"] stringValue]boolValue];
                                        NSString* LookupId=[(GDataXMLElement *) [item1 attributeForName:@"LookupId"] stringValue];
                                        
                                        if (Displayy){
                                            CAction* menu = [[CAction alloc] initWithLabel:Labell action:Namee popup:popup backhome:returnHome Custom:YES];
                                            [menu setLookupId:LookupId];
                                            if(QuickActionn)
                                            {
                                                [QuickActions addObject:menu];
                                            }
                                            if([Name isEqualToString:@"Annotations"]){
                                                [AnnotationsList addObject:menu];
                                            }
                                            else if ([Name isEqualToString:@"Attachments"])
                                                [AttachmentsList addObject:menu];
                                            else if ([Name isEqualToString:@"Signature"])
                                                [signActions addObject:menu];
                                            else
                                                if([Name isEqualToString:@"More"])
                                                    [toolbarActions addObject:menu];
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
            
        }
        
        
        
        CCorrespondence  *newCorrespondence = [[CCorrespondence alloc] initWithId:Id Priority:Priority New:New SHOWLOCK:SHOWLOCK];
        [newCorrespondence setStatus:Status];
        [newCorrespondence setTransferId:transferId];
        [newCorrespondence setSystemProperties:systemPropertiesList];
        [newCorrespondence setProperties:propertiesList];
        [newCorrespondence setToolbar:toolbarItems];
        [newCorrespondence setActions:toolbarActions];
        [newCorrespondence setSignActions:signActions];
        [newCorrespondence setThumnailUrl:thumbnailUrl];
        [newCorrespondence setAttachmentsListMenu:AttachmentsList];
        [newCorrespondence setAnnotationsList:AnnotationsList];
        [newCorrespondence setCustomItemsList:CustomItemsList];
        [newCorrespondence setQuickActions:QuickActions];
        [Allcorrespondences addObject:newCorrespondence];
        
    }
    
    return Allcorrespondences;
}

@end
