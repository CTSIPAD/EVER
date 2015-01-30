//
//  CParser.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSearch.h"
#import "CUser.h"
#import "CAttachment.h"
@interface CParser : NSObject
+(void)ClearCache;
+(NSString*)ValidateWithData:(NSData*)xmlData;
+ (CUser *)loadUserWithData:(NSString*) url ;
+(NSMutableDictionary *)loadCorrespondencesWithData:(NSData*)xmlData;
+(NSMutableDictionary*)LoadCorrespondences:(int)InboxId;
+(NSString*)loadPdfFile:(NSString*)fileUrl inDirectory:(NSString*)dirName;
+(NSInteger)GetNoteIdWithData:(NSData*) xmlData;
+(CSearch *)loadSearchWithData:(NSData*)xmlData;
+(NSMutableArray*)loadSearchCorrespondencesWithData:(NSData*)xmlData;
+(NSMutableArray*)loadSpecifiqueAttachment:(NSData*)xmlData CorrespondenceId:(NSString*)Id;
-(void)john:(NSData *)xmlData;
+(NSData*)LoadCachedIcons:(NSString*)key;
+(void)cacheIcon:(NSString*)key value:(NSData*)value;
+(void)cacheXml:(NSString*)Id xml:(NSData*)xml nb:(NSString*)nb name:(NSString*)name;
+(NSData*)LoadXML:(NSString*)Id nb:(NSString*)nb name:(NSString*)name;
+(void)cacheOfflineActions:(NSString*)Id url:(NSString*)url action:(NSString*)action;
+(NSMutableArray*)LoadOfflineActions;
+(int)EntitySize:(NSString*)name;
+(void)DeleteOfflineActions:(NSString*)name;
+(NSMutableArray*)LoadBuiltInActions;
+(void)cacheBuiltInActions:(NSString*)Id action:(NSString*)action xml:(NSData*)xml;
+(BOOL)LoadLogin:(NSString*)username password:(NSString*)password;
+(void)cacheLogin:(NSString*)username password:(NSString*)password;
+(NSMutableArray*)LoadAttachments:(NSString*)CorrespondenceId;
+ (NSMutableDictionary*)IsLockedCorrespondence:(NSString *)url;
+(void)GetFolderAttachment:(NSString*)url Id:(int)Id;
+(void)DeleteCorrespondence:(NSString*)CorrespondenceId inboxId:(NSString*)InboxId;
+(void)Download:(NSData*)xmlData;
+(void)LoadDepartmentChanges:(NSData *) xmlData;
+(NSMutableArray*)loadRecipients:(NSString*) url section:(NSString*)section ;
+(CAttachment*)LoadNewAttachmentResults:(NSData *)xmlData docId:(NSString*)docid;
+(void)ShowMessage:(NSString*)message;
+(CGFloat)pixelToPoints:(CGFloat)px;
@end
