//
//  CAttachment.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAttachment : NSObject<NSURLConnectionDelegate>

@property (nonatomic, retain) NSString* location;
@property (nonatomic, retain) NSString* docId;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* thumbnailBase64;
@property (nonatomic, retain) NSMutableArray* annotations;
@property (nonatomic, retain) NSString *tempPdfLocation;


@property (nonatomic,retain) NSString* SiteId;
@property (nonatomic,retain) NSString* WebId;
@property (nonatomic,retain) NSString* FileId;
@property (nonatomic,retain) NSString* AttachmentId;
@property (nonatomic,retain) NSString* FileUrl;
@property (nonatomic,retain) NSString* ThubnailUrl;
@property (nonatomic,retain) NSString* isOriginalMail;
@property (nonatomic,retain) NSString* FolderName;
@property (nonatomic,retain) NSString* FolderId;
@property (nonatomic,retain) NSString* Status;

@property (retain,nonatomic) NSMutableArray* HighlightAnnotations;
@property (retain,nonatomic) NSMutableArray* NoteAnnotations;


-(id) initWithTitle:(NSString*)title docId:(NSString*)did url:(NSString*)url location:(NSString*)folderName;

-(id) initWithTitle:(NSString*)title docId:(NSString*)did url:(NSString*)url  SiteId:(NSString*)SiteId  FileId:(NSString*)FileId AttachmentId:(NSString*)AttachmentId FileUrl:(NSString *)FileUrl ThubnailUrl:(NSString *)ThubnailUrl isOriginalMail:(NSString*)isOriginalMail FolderName:(NSString*)FolderName;
-(id) initWithTitle:(NSString*)title docId:(NSString*)did url:(NSString*)url  AttachmentId:(NSString*)AttachmentId ThubnailUrl:(NSString *)ThubnailUrl isOriginalMail:(NSString*)isOriginalMail FolderName:(NSString*)FolderName;
-(NSString *)saveInCacheinDirectory:(NSString*)dirName fromSharepoint:(BOOL)isSharePoint;
-(void)saveinDirectory:(NSString*)dirName strUrl:(NSString*)strUrl;
-(NSString *)replaceDocument:(NSString*)dirName;
@end
