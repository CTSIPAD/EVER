//
//  AppDelegate.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "AppDelegate.h"
#import "CParser.h"
@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize IpadLanguage=_IpadLanguage;
@synthesize isSharepoint=_isSharepoint;
@synthesize user=_user;
@synthesize menuSelectedItem=_menuSelectedItem;
@synthesize docUrl=_docUrl;
@synthesize SiteId=_SiteId,FileId=_FileId,FileUrl=_FileUrl,WebId=_WebId,serverUrl=_serverUrl,isOfflineMode=_isOfflineMode,FolderName=_FolderName,isAnnotated=_isAnnotated,isAnnotationSaved=_isAnnotationSaved;
@synthesize isSigned=_isSigned,inboxForArchiveSelected=_inboxForArchiveSelected;
@synthesize splitViewController=_splitViewController,logo=_logo;
@synthesize ShowThumbnail=_ShowThumbnail;
@synthesize SignMode=_SignMode;
@synthesize NbOfCorrToLoad,SettingsCorrNb,InboxTotalCorr=_InboxTotalCorr;
@synthesize Signaction=_Signaction;
@synthesize AnnotationsMode=_AnnotationsMode;
@synthesize Highlights =_Highlights,Notes=_Notes,attachmentType=_attachmentType,Char_count;
@synthesize IncomingHighlights =_IncomingHighlights,IncomingNotes=_IncomingNotes;
@synthesize textColor,bgColor,buttonColor,titleColor,cellColor,iconViewColor,CorrespondenceCellColor,SignatureColor,TablebgColor,metaDataCellColor,selectedInboxColor,thumbnailDefined,LoginSliderImages;
@synthesize barView,logoView,logFilePath,viewController;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    /**** Create Log file ****/
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    
//    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* documentsDirectory  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    NSString *fileName =[NSString stringWithFormat:@"%@.log",[self CurrentDateStringFromDate:[NSDate date] withFormat:@"dd-MM-yyyy"]];
    
    logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);

    /**** End Create Log file ****/
    self.ShowSplash=YES;
    self.barView=[[UIView alloc] init];
    self.logoView=[[UIImageView alloc] init];
    self.highlightNow=NO;
    self.Char_count=3;
    self.searchResultViewController = [[SearchResultViewController alloc]initWithStyle:UITableViewStylePlain];
    self.DrawLayerViews=[[NSMutableDictionary alloc]init];
    self.DocumentsPath=[[NSMutableArray alloc]init];
    LoginSliderImages=[[NSMutableArray alloc]init];
    
    self.IpadLanguage=[[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    self.serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
    self.isOfflineMode = [[[NSUserDefaults standardUserDefaults] stringForKey:@"offline_mode"] boolValue];
    self.ShowThumbnail=[[[NSUserDefaults standardUserDefaults] stringForKey:@"thumbnail_mode"]boolValue];
    self.SupportsServlets=[[[NSUserDefaults standardUserDefaults] stringForKey:@"Support_Servlets"]boolValue];
    self.EncryptionEnabled=[[[NSUserDefaults standardUserDefaults] stringForKey:@"enable_encryption"]boolValue];
    self.PinCodeEnabled=[[[NSUserDefaults standardUserDefaults] stringForKey:@"enable_pincode"]boolValue];
    self.enableAction=[[[NSUserDefaults standardUserDefaults] stringForKey:@"enable_actions"] boolValue];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"CorrNbPerPage"]==nil )
        self.SettingsCorrNb =20;
    else{
        self.SettingsCorrNb =[[[NSUserDefaults standardUserDefaults] stringForKey:@"CorrNbPerPage"]intValue];
        
    }
    NSDictionary* defaults = @{@"timeout_preference":@"30",@"sign_mode": @"CustomSign",@"annotations_mode": @"CustomAnnotations",@"charNumber_preference":@"3"};
    self.Request_timeOut = [[[NSUserDefaults standardUserDefaults] stringForKey:@"timeout_preference"]intValue];
    self.Char_count = [[[NSUserDefaults standardUserDefaults] stringForKey:@"charNumber_preference"]intValue];

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    self.SignMode=[[NSUserDefaults standardUserDefaults] objectForKey:@"sign_mode"];
    self.AnnotationsMode=[[NSUserDefaults standardUserDefaults]objectForKey:@"annotations_mode"];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.Highlights=[[NSMutableArray alloc]init];
    self.QuickActionClicked=NO;
    self.Notes=[[NSMutableArray alloc]init];
    
    self.textColor=[UIColor colorWithRed:196.0f/255.0f green:223.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    self.TablebgColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"backGroundImg.png"]];
    self.bgColor=[UIColor colorWithRed:188/255.0f green:213/255.0f blue:217/255.0f alpha:1.0];
    self.buttonColor=[UIColor colorWithRed:27/255.0f green:109/255.0f blue:121/255.0f alpha:1.0];
    self.titleColor=[UIColor colorWithRed:255/255.0f green:254/255.0f blue:255/255.0f alpha:1.0f];
    self.SearchLabelsColor=[UIColor colorWithRed:84/255.0f green:93/255.0f blue:93/255.0f alpha:1.0f];
    self.InboxCellColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellbg.png"]];
    self.InboxCellColor_ar=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellbg_ar.png"]];
    self.cellColor=[UIColor colorWithRed:47/255.0f green:157/255.0f blue:172/255.0f alpha:1.0f];
    self.metaDataCellColor=[UIColor colorWithRed:157/255.0f green:198/255.0f blue:204/255.0f alpha:1.0];
    self.CorrespondenceCellColor=[UIColor colorWithRed:142/255.0f green:194/255.0f blue:200/255.0f alpha:1.0f];
    self.SearchViewColors=[UIColor colorWithRed:141/255.0f green:194/255.0f blue:202/255.0f alpha:1.0f];
    self.selectedInboxColor=[UIColor colorWithRed:201/255.0f green:83/255.0f blue:55/255.0f alpha:1.0];
    self.iconViewColor=[UIColor colorWithRed:118/255.0f green:181/255.0f blue:190/255.0f alpha:1.0];
    self.InboxCellSelectedColor_ar=[UIColor colorWithPatternImage:[UIImage imageNamed:@"SelectedInbox_ar.png"]];
    self.PopUpBgColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"PopUpBg.png"]];
    self.PopUpTextColor=[UIColor colorWithRed:74/255.0f green:140/255.0f blue:146/255.0f alpha:1.0];
    self.InboxCellSelectedColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"SelectedInbox.png"]];
    SignatureColor=[UIColor blackColor];
    thumbnailDefined=NO;
   
    [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"barBg.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:self.textColor];
  
    return YES;
}
-(NSString*)CurrentDateStringFromDate:(NSDate*)dateTimeInLine withFormat:(NSString*)dateFormat
{
    NSDateFormatter* formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:dateFormat];
    NSString* convertedString=[formatter stringFromDate:dateTimeInLine];
    return convertedString;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.IpadLanguage=[[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
    self.isOfflineMode = [[[NSUserDefaults standardUserDefaults] stringForKey:@"offline_mode"] boolValue];
    self.ShowThumbnail=[[[NSUserDefaults standardUserDefaults] stringForKey:@"thumbnail_mode"]boolValue];
    self.SignMode=[[NSUserDefaults standardUserDefaults] stringForKey:@"sign_mode"];
    self.AnnotationsMode=[[NSUserDefaults standardUserDefaults]objectForKey:@"annotations_mode"];
    self.SupportsServlets=[[[NSUserDefaults standardUserDefaults] stringForKey:@"Support_Servlets"]boolValue];
    self.EncryptionEnabled=[[[NSUserDefaults standardUserDefaults] stringForKey:@"enable_encryption"]boolValue];
    self.PinCodeEnabled=[[[NSUserDefaults standardUserDefaults] stringForKey:@"enable_pincode"]boolValue];
    self.Request_timeOut = [[[NSUserDefaults standardUserDefaults] stringForKey:@"timeout_preference"]intValue];
    self.Char_count = [[[NSUserDefaults standardUserDefaults] stringForKey:@"charNumber_preference"]intValue];

    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}




#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CTSProduct" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CTSProduct.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}



#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void) RunIndicator:(UIButton *)button
{
    
    self.indicatorView=[[UIView alloc] init];

    self.indicatorView.frame=CGRectMake(0, 0, button.frame.size.width, button.frame.size.height);
    self.indicatorView.backgroundColor=[UIColor colorWithRed:12/255.0f green:93/255.0f blue:174/255.0f alpha:1.0];
    UIActivityIndicatorView *indicator=self.activityIndicatorObject;
    indicator.frame=CGRectMake(0, 0, button.frame.size.width, button.frame.size.height);
    [self.activityIndicatorObject startAnimating];
    [self.indicatorView addSubview:indicator];
    [button addSubview:self.indicatorView];

    
}

-(void) stopIndicator
{
 [self.activityIndicatorObject stopAnimating];
 [self.indicatorView removeFromSuperview];
        //[mainDelegate.activityIndicatorObject stopAnimating];


}
@end
