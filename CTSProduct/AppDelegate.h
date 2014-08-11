//
//  AppDelegate.h
//  CTSProduct
//
//  Created by DNA on 6/21/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFDocument.h"
#import "CUser.h"
#import "CSearch.h"
#import "SplitViewController.h"
#import "SearchResultViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSString* IpadLanguage;
@property(nonatomic,assign)BOOL isSharepoint;
@property(nonatomic,assign)BOOL isOfflineMode;
@property(nonatomic,assign)BOOL Downloading;
@property (strong, nonatomic) CSearch *searchModule;
@property (assign, nonatomic) NSInteger selectedInbox;
@property (assign, nonatomic) NSInteger InboxTotalCorr;
@property (assign, nonatomic) NSInteger origin;
@property (strong, nonatomic) CUser *user;
@property(nonatomic,assign)NSInteger menuSelectedItem;
@property(nonatomic,assign)BOOL highlightNow;
@property(nonatomic,assign)BOOL SearchActive;
@property (strong,nonatomic)NSString* docUrl;
@property (strong,nonatomic)NSString* SiteId;
@property (strong,nonatomic)NSString* WebId;
@property (strong,nonatomic)NSString* FileId;
@property (strong,nonatomic)NSString* AttachmentId;
@property (strong,nonatomic)NSString* FileUrl;
@property (strong,nonatomic)NSString *serverUrl;
@property (assign,nonatomic) NSString* FolderName;
@property(nonatomic,assign)BOOL isAnnotated;
@property(nonatomic,assign)BOOL isAnnotationSaved;
@property(nonatomic,assign)BOOL isBasketSelected;
@property (assign, nonatomic) NSInteger attachmentSelected;
@property (assign, nonatomic) NSInteger searchSelected;
@property(nonatomic,assign)BOOL isSigned;
@property (assign, nonatomic)NSInteger inboxForArchiveSelected;
@property (strong, nonatomic)SplitViewController *splitViewController;
@property (nonatomic, retain) NSData *logo;
@property (nonatomic, retain) SearchResultViewController *searchResultViewController;
@property (nonatomic, retain)UIActivityIndicatorView *activityIndicatorObject;
@property (nonatomic, assign) BOOL ShowThumbnail;
@property (nonatomic, assign) BOOL SupportsServlets;
@property (nonatomic, assign) NSString* SignMode;
@property (nonatomic, assign) NSString* AnnotationsMode;
@property (nonatomic, assign) NSString* Signaction;
@property (assign,nonatomic) NSInteger NbOfCorrToLoad;
@property (assign,nonatomic) NSInteger SettingsCorrNb;
@property (retain,nonatomic) NSMutableArray* Highlights;
@property (retain,nonatomic) NSMutableArray* Notes;
@property (retain,nonatomic) NSMutableArray* IncomingHighlights;
@property (retain,nonatomic) NSMutableArray* IncomingNotes;
@property (retain,nonatomic) NSMutableArray* folderNames;
@property (strong,nonatomic)NSString* attachmentType;
@property (strong,nonatomic)NSString* SectionSelected;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
