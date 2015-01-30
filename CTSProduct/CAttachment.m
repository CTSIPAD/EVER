//
//  CAttachment.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "CAttachment.h"
#import "AppDelegate.h"
#import "FileManager.h"
@implementation CAttachment{
    NSMutableData *_responseData;
    NSString *tempPdfLocation;
    AppDelegate *mainDelegate;
}
@synthesize tempPdfLocation;
-(id) initWithTitle:(NSString*)title docId:(NSString*)did url:(NSString*)url  location:(NSString*)folderName{
    
    if ((self = [super init])) {
        self.title=title;
        self.docId=did;
        self.url=url;
        self.location=folderName;
    }
    return self;
    
}
-(id) initWithTitle:(NSString*)title docId:(NSString*)did url:(NSString*)url  SiteId:(NSString*)SiteId  FileId:(NSString*)FileId AttachmentId:(NSString*)AttachmentId FileUrl:(NSString *)FileUrl ThubnailUrl:(NSString *)ThubnailUrl isOriginalMail:(NSString*)isOriginalMail FolderName:(NSString*)FolderName{
    
    self.NoteAnnotations=[[NSMutableArray alloc]init];
    self.HighlightAnnotations=[[NSMutableArray alloc]init];
    
    if ((self = [super init])) {
        self.title=title;
        self.docId=did;
        self.url=url;
        self.location=title;
        self.FileId = FileId;
        self.AttachmentId=AttachmentId;
        self.FileUrl = FileUrl;
        self.SiteId = SiteId;
        self.ThubnailUrl = ThubnailUrl;
        self.isOriginalMail=isOriginalMail;
        self.FolderName = FolderName;
    }
    
    
    return self;

}
-(id) initWithTitle:(NSString*)title docId:(NSString*)did url:(NSString*)url  AttachmentId:(NSString*)AttachmentId ThubnailUrl:(NSString *)ThubnailUrl isOriginalMail:(NSString*)isOriginalMail FolderName:(NSString*)FolderName{
    self.NoteAnnotations=[[NSMutableArray alloc]init];
    self.HighlightAnnotations=[[NSMutableArray alloc]init];
    
    if ((self = [super init])) {
        self.title=title;
        self.docId=did;
        self.url=url;
        self.location=title;
        self.AttachmentId=AttachmentId;
        self.ThubnailUrl = ThubnailUrl;
        self.isOriginalMail=isOriginalMail;
        self.FolderName = FolderName;
    }
    
    
    return self;
}
-(id) initWithTitle:(NSString*)title docId:(NSString*)did url:(NSString*)url  location:(NSString*)location SiteId:(NSString*)SiteId WebId:(NSString*)WebId FileId:(NSString*)FileId AttachmentId:(NSString*)AttachmentId FileUrl:(NSString *)FileUrl ThubnailUrl:(NSString*)ThubnailUrl isOriginalMail:(NSString*)isOriginalMail FolderName:(NSString *)FolderName{
    
    self.NoteAnnotations=[[NSMutableArray alloc]init];
    self.HighlightAnnotations=[[NSMutableArray alloc]init];

    if ((self = [super init])) {
        self.title=title;
        self.docId=did;
        self.url=url;
        self.location=location;
        self.FileId = FileId;
        self.AttachmentId=AttachmentId;
        self.WebId = WebId;
        self.FileUrl = FileUrl;
        self.SiteId = SiteId;
        self.ThubnailUrl = ThubnailUrl;
        self.isOriginalMail=isOriginalMail;
        self.FolderName = FolderName;
    }
    
    
    return self;
}

-(NSString *)replaceDocument:(NSString*)dirName
{
    
    @try {
        mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        tempPdfLocation=@"";
        
        NSString*strUrl;
        
        strUrl= [self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//url where the file located
        mainDelegate.docUrl = strUrl;
        mainDelegate.SiteId = self.SiteId;
        mainDelegate.FileId = self.FileId;
        mainDelegate.FileUrl = self.FileUrl;
        mainDelegate.AttachmentId=self.AttachmentId;
        [mainDelegate.IncomingHighlights removeAllObjects];
        [mainDelegate.IncomingNotes removeAllObjects];
        [mainDelegate.IncomingHighlights addObjectsFromArray:self.HighlightAnnotations];
        [mainDelegate.IncomingNotes addObjectsFromArray:self.NoteAnnotations];
        
        
        
        
        NSURL *url=[NSURL URLWithString:strUrl];
        
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];// /Users/dna/Library/Application Support/iPhone Simulator/7.0.3/Applications/9A637052-BDFD-4567-B3AC-6B01DDFD5430/Library/Caches
        
        NSString *path = [cachesDirectory stringByAppendingPathComponent:dirName];//append correspondence number
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
        
        
        NSString* pdfCacheName = [self.url lastPathComponent];//take the name of the file
        
        tempPdfLocation = [path stringByAppendingPathComponent:pdfCacheName];
            NSData *data = [NSData dataWithContentsOfURL:url ];
        if(data.length!=0){
                [data writeToFile:tempPdfLocation atomically:TRUE];
            NSString* dir  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            dir = [dir stringByAppendingString:@"/FoxitSaveAnnotation.pdf"];
            [data writeToFile:dir atomically:TRUE];
        }
            else tempPdfLocation=@"";
        
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"CAttachment" function:@"saveInCacheinDirectory" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    @finally {
        
    }
    return tempPdfLocation;
    
    
	
}

-(NSString *)saveInCacheinDirectory:(NSString*)dirName fromSharepoint:(BOOL)isSharePoint
{
    
    @try {
        NSLog(@"Info: Enter saveInCacheinDirectory Method.");
        mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        tempPdfLocation=@"";
       
        NSString*strUrl;
        
        strUrl= [self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//url where the file located
        mainDelegate.docUrl = strUrl;
        mainDelegate.SiteId = self.SiteId;
        mainDelegate.FileId = self.FileId;
        mainDelegate.FileUrl = self.FileUrl;
        mainDelegate.AttachmentId=self.AttachmentId;
        [mainDelegate.IncomingHighlights removeAllObjects];
        [mainDelegate.IncomingNotes removeAllObjects];
        [mainDelegate.IncomingHighlights addObjectsFromArray:self.HighlightAnnotations];
        [mainDelegate.IncomingNotes addObjectsFromArray:self.NoteAnnotations];
        NSLog(@"Info: Attachment URl=%@",strUrl);

        
        
        NSURL *url=[NSURL URLWithString:strUrl];

        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];// /Users/dna/Library/Application Support/iPhone Simulator/7.0.3/Applications/9A637052-BDFD-4567-B3AC-6B01DDFD5430/Library/Caches
        
        NSString *path = [cachesDirectory stringByAppendingPathComponent:dirName];//append correspondence number
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
        
        
        NSString* pdfCacheName = [self.url lastPathComponent];//take the name of the file
        
        tempPdfLocation = [path stringByAppendingPathComponent:pdfCacheName];//compute the full path for the file
         BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:tempPdfLocation];//check if file is already exists
         if(!fileExists){//write file to cache if not exist
        
            NSData *data = [NSData dataWithContentsOfURL:url ];
            if(data.length!=0)
                [data writeToFile:tempPdfLocation atomically:TRUE];
            else tempPdfLocation=@"";
         }
    }
    @catch (NSException *ex) {
        NSLog(@"Error: Error occured in CAttachment Class in method saveInCacheinDirectory.\n Exception Name:%@ Exception Reason: %@",[ex name],[ex reason]);
    }
    @finally {
        
    }
    return tempPdfLocation;
    
    
	
}
-(void)saveinDirectory:(NSString*)dirName strUrl:(NSString*)strUrl
{
    
    @try {
        mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        tempPdfLocation=@"";
        

        mainDelegate.AttachmentId=self.AttachmentId;

        
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];// /Users/dna/Library/Application Support/iPhone Simulator/7.0.3/Applications/9A637052-BDFD-4567-B3AC-6B01DDFD5430/Library/Caches
        
        NSString *path = [cachesDirectory stringByAppendingPathComponent:dirName];//append correspondence number
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
        
        
        NSString* pdfCacheName = [self.url lastPathComponent];//take the name of the file
        
        tempPdfLocation = [path stringByAppendingPathComponent:pdfCacheName];//compute the full path for the (!fileExists){//write file to cache if not exist
            [[NSFileManager defaultManager] removeItemAtPath:tempPdfLocation error:nil];
            NSData *data = [NSData dataWithContentsOfFile:strUrl ];
        
            if(data.length!=0)
                [data writeToFile:tempPdfLocation atomically:TRUE];
            else tempPdfLocation=@"";
        
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"CAttachment" function:@"saveInCacheinDirectory" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    @finally {
        
    }
    
    
	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    NSFileHandle *hFile = [NSFileHandle fileHandleForWritingAtPath:tempPdfLocation];
    if (!hFile)
    {   //nope->create that file!
        [[NSFileManager defaultManager] createFileAtPath:tempPdfLocation contents:nil attributes:nil];
        //try to open it again...
        hFile = [NSFileHandle fileHandleForWritingAtPath:tempPdfLocation];
    }
    //did we finally get an accessable file?
    if (!hFile)
    {   //nope->bomb out!
        NSLog(@"could not write to file %@", tempPdfLocation);
        return;
    }
    //we never know - hence we better catch possible exceptions!
    @try
    {
        //seek to the end of the file
        [hFile seekToEndOfFile];
        //finally write our data to it
        [hFile writeData:data];
        
    }
    @catch (NSException * e)
    {
        NSLog(@"exception when writing to file %@", tempPdfLocation);
        // result = NO;
    }
    [hFile closeFile];
    [_responseData appendData:data];
    
    // [data writeToFile:tempPdfLocation atomically:TRUE];
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
   
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}



@end
