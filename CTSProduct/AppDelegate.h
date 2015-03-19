//
//  AppDelegate.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFDocument.h"
#import "CUser.h"
#import "CSearch.h"
#import "SplitViewController.h"
#import "SearchResultViewController.h"
#import "containerView.h"
#import "LoginViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UIImageView *splashView;

}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginViewController *viewController;
@property (strong,nonatomic) UIView *indicatorView;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSString* IpadLanguage;
@property (nonatomic,assign) NSInteger attachementsCount;
@property(nonatomic,assign)BOOL isSharepoint;
@property(nonatomic,assign)BOOL isOfflineMode;
@property(nonatomic,assign)BOOL Downloading;
@property(nonatomic,assign)BOOL Sync;
@property(nonatomic,assign)BOOL EmptyDoc;
@property (strong, nonatomic) CSearch *searchModule;
@property (assign, nonatomic) NSInteger selectedInbox;
@property (assign, nonatomic) NSInteger InboxTotalCorr;
@property (assign, nonatomic) NSInteger origin;
@property (strong, nonatomic) CUser *user;
@property(nonatomic,assign)NSInteger menuSelectedItem;
@property(nonatomic,assign)NSInteger CountOfflineActions;
@property(nonatomic,assign)NSInteger CounterSync;
@property(nonatomic,assign)BOOL highlightNow;
@property(nonatomic,assign)BOOL EncryptionEnabled;
@property(nonatomic,assign)BOOL PinCodeEnabled;
@property (strong,nonatomic)NSString* docUrl;
@property (strong,nonatomic)NSString* SiteId;
@property (strong,nonatomic)NSString* WebId;
@property (strong,nonatomic)NSString* FileId;
@property (strong,nonatomic)NSString* AttachmentId;
@property (strong,nonatomic)NSString* FileUrl;
@property (strong,nonatomic)NSString *serverUrl;
@property (strong,nonatomic)NSString *logFilePath;
@property (assign,nonatomic) NSString* FolderName;
@property (assign,nonatomic) NSString* FolderId;
@property(nonatomic,assign)BOOL isAnnotated;
@property(nonatomic,assign)BOOL isAnnotationSaved;
@property(nonatomic,assign)BOOL isBasketSelected;
@property (assign, nonatomic) NSInteger attachmentSelected;
@property (assign, nonatomic) NSInteger searchSelected;
@property (assign, nonatomic) NSInteger Request_timeOut;
@property(nonatomic,assign)BOOL isSigned;
@property(nonatomic,assign)BOOL SearchClicked;

@property(nonatomic,assign)int QuickActionIndex;
@property (assign, nonatomic)NSInteger inboxForArchiveSelected;
@property (assign, nonatomic)NSInteger Char_count;
@property (strong, nonatomic)SplitViewController *splitViewController;
@property (nonatomic, retain) NSData *logo;
@property (nonatomic, retain) SearchResultViewController *searchResultViewController;
@property (nonatomic, retain) HeaderView *HeaderViewController;
@property (strong,nonatomic) UIView *barView;
@property (strong,nonatomic) UIImageView *logoView;
@property (nonatomic, retain)UIActivityIndicatorView *activityIndicatorObject;
@property (nonatomic, assign) BOOL ShowThumbnail;
@property (nonatomic, assign) BOOL SupportsServlets;
@property (nonatomic, assign) BOOL QuickActionClicked;
@property (nonatomic, assign) NSString* SignMode;
@property (nonatomic, assign) NSString* AnnotationsMode;
@property (nonatomic, assign) NSString* Signaction;
@property (assign,nonatomic) NSInteger NbOfCorrToLoad;
@property (assign,nonatomic) NSInteger SettingsCorrNb;
@property (retain,nonatomic) NSMutableArray* SyncActions;
@property (retain,nonatomic) NSMutableArray* Highlights;
@property (retain,nonatomic) NSMutableArray* Notes;
@property (retain,nonatomic) NSMutableArray* IncomingHighlights;
@property (retain,nonatomic) NSMutableArray* IncomingNotes;
@property (retain,nonatomic) NSMutableArray* folderNames;
@property (retain,nonatomic) NSMutableArray* DocumentsPath;
@property (retain,nonatomic) NSMutableArray* LoginSliderImages;
@property (retain,nonatomic) NSMutableDictionary* Lookups;
@property (strong,nonatomic)NSString* attachmentType;
@property (retain,nonatomic) NSMutableDictionary* DrawLayerViews;
@property(nonatomic,assign)BOOL downloadSuccess;
@property(nonatomic,assign)BOOL IsInside;
@property(nonatomic,assign) BOOL enableAction;
@property(nonatomic,strong) UIColor *textColor;
@property(nonatomic,strong) UIColor *bgColor;
@property (nonatomic,strong) UIColor *buttonColor;
@property(nonatomic,strong) UIColor *titleColor;
@property(nonatomic,strong) UIColor *cellColor;
@property(nonatomic,strong) UIColor *metaDataCellColor;
@property(nonatomic,strong) UIColor *TablebgColor;
@property(nonatomic,strong) UIColor *CorrespondenceCellColor;
@property(nonatomic,strong) UIColor *selectedInboxColor;
@property(nonatomic,strong) UIColor *iconViewColor;
@property(nonatomic,strong) UIColor *SearchViewColors;
@property(nonatomic,strong) UIColor *SearchLabelsColor;
@property(nonatomic,strong) UIColor *InboxCellColor;
@property(nonatomic,strong) UIColor *InboxCellColor_ar;
@property(nonatomic,strong) UIColor *InboxCellSelectedColor_ar;
@property(nonatomic,strong) UIColor *InboxCellSelectedColor;
@property(nonatomic,strong) UIColor *PopUpBgColor;
@property(nonatomic,strong) UIColor *PopUpTextColor;
@property(nonatomic,strong) UIColor *SignatureColor;



@property(nonatomic,assign) BOOL thumbnailDefined;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void) RunIndicator:(UIButton*)button;
-(void) stopIndicator;
@end
