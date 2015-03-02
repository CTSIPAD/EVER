//
//  HeaderView.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "HeaderView.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "SomeNetworkOperation.h"
#import "LoginViewController.h"
#import "FileManager.h"
#import "OfflineAction.h"
#import "BuiltInActions.h"
#import "CParser.h"
#import "SearchResultViewController.h"
#import "OfflineResult.h"
#import "UserDetailsViewController.h"
#import "SVProgressHUD.h"
#import "containerView.h"
#import "ReportViewController.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)
@interface HeaderView ()

@end

@implementation HeaderView
{
    AppDelegate *mainDelegate;
    NSOperationQueue *queue;
    SearchResultViewController *searchView;
    BOOL sync;
    NSMutableArray *iconArray;
    BOOL ACTIVE;
    UIBarButtonItem *itemStatus;
    
    UIButton *syncButton;
    UIButton *DownloadButton;
    UIView *indicatorView;
    BOOL changeStatus;
    NSString* changeStatusTo;
    BOOL downloadNOW;
    BOOL GOoffline;
    BOOL enadlebtnDownload;
    BOOL enableSyncButton;
    int iconArrayCount;
    CGFloat iconViewWidth;
    CGFloat iconViewOrigine;
    CGRect seperatorViewFrame;
    UIButton *teststop;
    UIImageView *userIcon;
    UIInterfaceOrientation *orientation;
    int origineX;
    int nameLableWidth;
    int barWidth;
    int arabicBarWidth;
    int nameLableX;
    UILabel* DateTimeLabel;
    UIImageView* imageview;
    UIImage* clockImage;
}

-(id)init
{
    
    enableSyncButton=YES; // set it to false when download start
    enadlebtnDownload=YES; // set it to false when start sync
    GOoffline=NO; // set it to true after press download to go offline
    
    
    
    mainDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate ];
    searchView=[[SearchResultViewController alloc] init];
    
    
   
    
    
    // indicator view
    indicatorView=[[UIView alloc] init];
    indicatorView.backgroundColor=[UIColor colorWithRed:12/255.0f green:93/255.0f blue:174/255.0f alpha:1.0];
    UIActivityIndicatorView *indicator=mainDelegate.activityIndicatorObject;
    [indicatorView addSubview:indicator];
    //
    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
    
    // logo image
    UIImage *logoImage=[UIImage imageWithData:mainDelegate.logo];
     mainDelegate.logoView.image=logoImage;
    
    if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            mainDelegate.logoView.frame=CGRectMake([UIScreen mainScreen].bounds.size.height-logoImage.size.width-20, 10, logoImage.size.width, logoImage.size.height);
        }
        else
        {
            if(UIInterfaceOrientationIsPortrait(orient))
                mainDelegate.logoView.frame=CGRectMake([UIScreen mainScreen].bounds.size.height-logoImage.size.width-20, 10, logoImage.size.width, logoImage.size.height);
            else
                mainDelegate.logoView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-logoImage.size.width-20, 10,logoImage.size.width, logoImage.size.height);
        }
        origineX=10;
    }
    else
    {
        mainDelegate.logoView.frame=CGRectMake(10, 10, logoImage.size.width, logoImage.size.height);
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            origineX=60;
        }else{
            
            origineX=340;
        }
    
    }
// initialize as landscape
        nameLableWidth=100;
        barWidth=140;

    
    mainDelegate.barView=[self createBarView];
    clockImage=[UIImage imageNamed:@"clock.png"];
     DateTimeLabel=[[UILabel alloc]initWithFrame:CGRectMake(mainDelegate.barView.frame.origin.x+mainDelegate.barView.frame.size.width-235, mainDelegate.barView.frame.origin.y+mainDelegate.barView.frame.size.height, 235, 40)];
    imageview=[[UIImageView alloc]initWithFrame:CGRectMake(DateTimeLabel.frame.origin.x-clockImage.size.width, DateTimeLabel.frame.origin.y+(DateTimeLabel.frame.size.height/2)-clockImage.size.height/2, clockImage.size.width, clockImage.size.height)];
    imageview.image=clockImage;
    DateTimeLabel.textColor=mainDelegate.SearchLabelsColor;
    DateTimeLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    DateTimeLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview: mainDelegate.logoView];
    [self.view addSubview: mainDelegate.barView];
    [self.view addSubview: imageview];
    [self.view addSubview: DateTimeLabel];
    
    
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self SyncActions];
    [self updateTime];
}

-(void)updateTime
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE dd MMM | hh:mm:ss "];
    NSString* CurrentDT=[formatter stringFromDate:[NSDate date]];
    DateTimeLabel.text=CurrentDT;
    [self performSelector:@selector(updateTime) withObject:self afterDelay:1.0];
}

-(UIView*) createBarView
{
    
    UIView *barView=[[UIView alloc] init];
    
    // fill Array
    iconArray=[[NSMutableArray alloc] init];
    
    // setting button
    UIButton *settingButton=[[UIButton alloc] init];
    UIImage *settingImage=[UIImage imageNamed:@"settings.png"];
    [settingButton setBackgroundImage:settingImage forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(OpenSettingsPage) forControlEvents:UIControlEventTouchUpInside];
    [iconArray addObject:settingButton];
    //
    // setting button
    UIButton *ReportsButton=[[UIButton alloc] init];
    UIImage *ReportsImage=[UIImage imageNamed:@"R2.png"];
    [ReportsButton setBackgroundImage:ReportsImage forState:UIControlStateNormal];
    [ReportsButton addTarget:self action:@selector(ShowReports) forControlEvents:UIControlEventTouchUpInside];
    [iconArray addObject:ReportsButton];
    //
    
    // user icon
    userIcon=[[UIImageView alloc] init];
    UIImage *userimage=[UIImage imageNamed:@"UserIcon.png"];
    userIcon.image=userimage;
    
    // userButton
    self.usernameButton=[[UIButton alloc] init];
    self.usernameButton.tag=1;
    NSString *welcomeString=NSLocalizedString(@"welcome",@"");
    NSString *usernameString=[NSString stringWithFormat:@"%@ %@ %@",welcomeString,mainDelegate.user.firstName,mainDelegate.user.lastName];
    
    [self.usernameButton setTitle:usernameString forState:UIControlStateNormal];
    [self.usernameButton addTarget:self action:@selector(dropdown) forControlEvents:UIControlEventTouchUpInside];
    self.usernameButton.titleLabel.textAlignment=NSTextAlignmentCenter;
    self.statusButton=[[UIButton alloc] init];
    UIImage *onlineImage=[UIImage imageNamed:@"Online.png"];
    UIImage *offlineImage=[UIImage imageNamed:@"Offline.png"];
    //
    
    // logout button
    UIButton *logoutButton=[[UIButton alloc] init];
    UIImage *logoutImage=[UIImage imageNamed:@"Logout.png"];
    [logoutButton setBackgroundImage:logoutImage forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    //
    ////
    
    // check
    if (mainDelegate.isOfflineMode || GOoffline ) {
        // offline mode
        [self.statusButton setImage:offlineImage forState:UIControlStateNormal];
        [self.statusButton addTarget:self action:@selector(ChangeStatusToOnline) forControlEvents:UIControlEventTouchUpInside];
        
    }
    else
    {
        // online mode
        [self.statusButton setImage:onlineImage forState:UIControlStateNormal];
        [self.statusButton addTarget:self action:@selector(ChangeStatusToOffline) forControlEvents:UIControlEventTouchUpInside];
        
        if (([[CParser LoadOfflineActions]count]+[[CParser LoadBuiltInActions]count])>0 && enableSyncButton) {
            // add sync button some thing is happen offline
            
            // sync button
            syncButton=[[UIButton alloc] init];
            UIImage *syncImage=[UIImage imageNamed:@"sync.png"];
            [syncButton setImage:syncImage forState:UIControlStateNormal];
            [syncButton addTarget:self action:@selector(performSync) forControlEvents:UIControlEventTouchUpInside];
            [iconArray addObject:syncButton];
            //
        }
        
        // Download Button
        DownloadButton=[[UIButton alloc] init];
        
        UIImage *DownloadImage=[UIImage imageNamed:@"downloadAll.png"];
        [DownloadButton setBackgroundImage:DownloadImage forState:UIControlStateNormal];
        [DownloadButton addTarget:self action:@selector(AskForDownload) forControlEvents:UIControlEventTouchUpInside];
        [iconArray addObject:DownloadButton];
        //
        
    }
    //
    
    
    // add logout and status buttons
    [iconArray addObject:self.statusButton]; // add status button
    UIButton *nButton=[[UIButton alloc] init];
    [nButton setTitle:@"Y" forState:UIControlStateNormal];
    [nButton setBackgroundColor:[UIColor purpleColor]];
    [iconArray addObject:logoutButton];
    //
    
    
    iconArrayCount=iconArray.count;
    
    if (iconArrayCount>3) {
        
        if (![mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            iconViewWidth=320+(50*(iconArrayCount-2));

                // english landscape
                iconViewOrigine=[UIScreen mainScreen].bounds.size.width-(170+(iconArrayCount-3)*40)-70;

            
        }
        else
        {

                //arabic landscape
                iconViewWidth=430+(50*(iconArrayCount-2));
                iconViewOrigine=[UIScreen mainScreen].bounds.size.width-(170+(iconArrayCount-3)*40)-70;

            
        }
        
    }
    else if (iconArrayCount==3)
    {
        
        if (![mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            iconViewWidth=380;
                // english landscape
                iconViewOrigine=([UIScreen mainScreen].bounds.size.width-170)-70;

        }
        else
        {
            
            if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                //arabic landscape
                iconViewWidth=480;
                iconViewOrigine=[UIScreen mainScreen].bounds.origin.x+30;
            }

            
        }
        
    }
    if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
        // arabic landscape
        barView.frame=CGRectMake([UIScreen mainScreen].bounds.origin.x+30-origineX, 0, iconViewWidth+25-arabicBarWidth, 45);
        userIcon.frame=CGRectMake(barView.frame.size.width-20, 8, userimage.size.width,userimage.size.height-4);
        self.usernameButton.frame=CGRectMake(barView.frame.size.width-(userIcon.frame.size.width+5)-225-nameLableWidth, 8, 220+nameLableWidth, 20);
    }
    else
    {
        // english landscape
        userIcon.frame=CGRectMake(10, 8, userimage.size.width,userimage.size.height-4);
        [barView addSubview:userIcon];
        
        self.usernameButton.frame=CGRectMake(userIcon.frame.size.width+15, 8, 200+nameLableWidth, 20);
        barView.frame=CGRectMake(iconViewOrigine-35, 0, iconViewWidth+barWidth, 45);
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation])) {
            
            // english landscape
            self.usernameButton.frame=CGRectMake(userIcon.frame.size.width+15, 8, 200+nameLableWidth, 20);
            barView.frame=CGRectMake(iconViewOrigine-5-origineX, 0, iconViewWidth+barWidth, 45);
            
        }
        
    }
     [barView addSubview:userIcon];
    [barView addSubview:self.usernameButton];

    // fill icon view
    UIButton *button=[[UIButton alloc] init];
    if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
        seperatorViewFrame=CGRectMake(self.usernameButton.frame.origin.x-10, 0, 15, 40);
    }
    else
    {
        seperatorViewFrame=CGRectMake(self.usernameButton.frame.origin.x+self.usernameButton.frame.size.width+5, 0, 10, 40);
    }
    for (int i=0; i<iconArray.count; i++) {
        
        UIImageView *seperatorView=[[UIImageView alloc] init];
        UIImage *seperatorImage=[UIImage imageNamed:@"seperatorimg.png"];
        seperatorView.image=seperatorImage;
        seperatorView.frame=seperatorViewFrame;
        [barView addSubview:seperatorView];
        
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            button=[iconArray objectAtIndex:i];
            button.frame=CGRectMake(seperatorView.frame.origin.x-35, 4, 35, 35);
            [barView addSubview:button];
            seperatorViewFrame=CGRectMake(button.frame.origin.x-15, 0, 15, 40);
        }
        else
        {
            button=[iconArray objectAtIndex:i];
            
            button.frame=CGRectMake(seperatorView.frame.origin.x+seperatorView.frame.size.width+5, 4, 35, 35);
            [barView addSubview:button];
            seperatorViewFrame=CGRectMake(button.frame.origin.x+button.frame.size.width+5, 0, 10, 40);
        }
        
    }
    barView.backgroundColor=mainDelegate.cellColor;
    return barView;
    
    
}


-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration

{
    
    if (![mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]) {


        if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation])){
            // english rotate to landscape mode
            
            nameLableWidth=100;
            origineX=160;
            barWidth=80;
        }

        
    }
    [mainDelegate.barView removeFromSuperview];
    mainDelegate.barView= [self createBarView];
    [self.view addSubview:mainDelegate.barView];
    
    if (mainDelegate.Downloading) {
        indicatorView.frame=CGRectMake(0, 0, DownloadButton.frame.size.width, DownloadButton.frame.size.height);
        [mainDelegate RunIndicator:DownloadButton];
    }
    else if (mainDelegate.Sync)
    {
        indicatorView.frame=CGRectMake(0, 0, syncButton.frame.size.width, syncButton.frame.size.height);
        [mainDelegate RunIndicator:syncButton];
    }
}


-(void) didMoveToParentViewController:(UIViewController *)parent
{
    
    self.view.frame=CGRectMake(0, 0, parent.view.frame.size.width,400);
    self.view.backgroundColor=[UIColor whiteColor];
}

-(void)OpenSettingsPage{
    UINavigationController *navController=[mainDelegate.splitViewController.viewControllers objectAtIndex:1];
    [navController setNavigationBarHidden:YES animated:YES];
    UIStoryboard *    storyboard=[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    SettingsViewController *SettingsView=[[SettingsViewController alloc] init];
    SettingsView= [storyboard instantiateViewControllerWithIdentifier:@"Settings"];
    
    [navController pushViewController:SettingsView animated:YES];
}
-(void)ShowReports{
    UINavigationController *navController=[mainDelegate.splitViewController.viewControllers objectAtIndex:1];
    [navController setNavigationBarHidden:YES animated:YES];
    ReportViewController *ReportsPage=[[ReportViewController alloc] init];
    [navController pushViewController:ReportsPage animated:YES];
}
-(void)download{

    
    mainDelegate.SyncActions=[[NSMutableArray alloc]init];
    
    indicatorView.frame=CGRectMake(0, 0, DownloadButton.frame.size.width, DownloadButton.frame.size.height);

    [mainDelegate RunIndicator:DownloadButton];
    mainDelegate.Downloading=YES;
    syncButton.enabled=NO;
    
    NSString* url;
    NSString* showthumb;
    if (mainDelegate.ShowThumbnail)
        showthumb=@"true";
    else
        showthumb=@"false";
    if(mainDelegate.SupportsServlets)
        url=[NSString stringWithFormat:@"http://%@?action=DownloadCoreData&token=%@&showThumbnails=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,showthumb,mainDelegate.IpadLanguage.lowercaseString];
    else
        url=[NSString stringWithFormat:@"http://%@/DownloadCoreData?token=%@&showThumbnails=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,showthumb,mainDelegate.IpadLanguage.lowercaseString];
    queue = [[NSOperationQueue alloc] init] ;
    [queue setMaxConcurrentOperationCount:3];
    
    SomeNetworkOperation *op = [[SomeNetworkOperation alloc] init];
    op.delegate = self;
    op.Action=@"Download";
    op.requestToLoad =  [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:mainDelegate.Request_timeOut];;
    [queue addOperation:op];
    
    
    
}

// method called when logout button clicked
-(void)logout{
    //changeStatus=NO; // set it to no to jump from testing it in clickedbuttonatindex
    NSString* message;
    message=NSLocalizedString(@"root.disconnectdialog",@"Do you really want to disconnect ?");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"root.disconnect",@"Sign out")                                       message:message
                                                   delegate:self
                               cancelButtonTitle:NSLocalizedString(@"root.disconnect.NO",@"Stay Connected" )
               otherButtonTitles:NSLocalizedString(@"root.disconnect.YES",@"Sign Out" ),nil];
    [alert show];

}



-(void)ChangeStatusToOnline{
    changeStatus=YES;
    changeStatusTo=@"Online";
    NSString* message;
    message=NSLocalizedString(@"online.verification",@"Are You Sure You want to go online?");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"root.Online",@"Go Online")
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Alert.NO",@"NO" )
                                          otherButtonTitles:NSLocalizedString( @"Alert.YES",@"YES"),nil];
    [alert show];
    
    
}
-(void)ChangeStatusToOffline{
    changeStatus=YES;
    changeStatusTo=@"Offline";
    NSString* message;
    message=NSLocalizedString(@"offline.verification",@"Are You Sure You want to go offline?");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"root.Offline",@"Go Offline")
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Alert.NO",@"NO" )
                                          otherButtonTitles:NSLocalizedString(@"Alert.YES",@"YES" ),nil];
    [alert show];
    
    
    
}


-(void)AskForDownload{
    downloadNOW=YES;
    NSString* message;
    message=NSLocalizedString(@"download.confirmation",@"This will download all the files to your device. When done, the application will go offline. Are you sure you want to continue?");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert.Download", @"Download")
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel" )
                                          otherButtonTitles:NSLocalizedString(@"Confirm",@"Confirm" ),nil];
    [alert show];
}



- (void)didFinishLoad:(NSMutableData *)info{
    // NSLog(@"info:%@",info);
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *validationResult=[CParser ValidateWithData:info];
    if (mainDelegate==nil) mainDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(![validationResult isEqualToString:@"OK"]){
        
        if([validationResult isEqualToString:@"Cannot access to the server"]){
            
            if([mainDelegate.SyncActions count]>0 ){
                // we must check if count<0 then do this else
                // enable btnsync and disable download
                if ( !syncButton.isEnabled) {
                    // syncbutton is disable
                    OfflineResult *OR=mainDelegate.SyncActions[0];
                    [self ShowMessage:OR.Result];
                }
                else{
                    // enable sync button and set maindelegate.sync to no
                    // enable download button
                    [mainDelegate.activityIndicatorObject stopAnimating];
                    syncButton.enabled=YES;
                    //itemSync.customView=btnSync;
                    mainDelegate.Sync=NO;
                    DownloadButton.enabled=true;
                    //itemdownload.enabled=true;
                    [self ShowMessage:validationResult];

                }
                
            }else{
                [self ShowMessage:validationResult];
                
            }
            
            
        }
        else{
            [self ShowMessage:validationResult];
        }
        [mainDelegate.activityIndicatorObject stopAnimating];

        syncButton.enabled=true;
        DownloadButton.enabled=true;
        [mainDelegate stopIndicator];
        
        
    }else{
        
        if(mainDelegate.Sync){
            [self ShowMessage:NSLocalizedString(@"Alert.syncSuccess",@"Synchronization Completed Successfully.")];
            [mainDelegate.activityIndicatorObject stopAnimating];
            [mainDelegate stopIndicator];
            enableSyncButton=false;
            mainDelegate.Sync=NO;
            [CParser DeleteOfflineActions:@"OfflineActions"];
            [CParser DeleteOfflineActions:@"BuiltInActions"];
            DownloadButton.enabled=true;
			[self deleteCachedFiles];
            [self refreshBarView];
            
        }
        else{
            if(mainDelegate.downloadSuccess){
                NSString* message;
                // set gooffline to cause gooffline function after click ok
                GOoffline=YES;
                message=NSLocalizedString(@"Alert.downloadSuccess",@"Download Completed Successfully.");
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",@"Alert")
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"OK",@"OK")
                                                      otherButtonTitles: nil];
                [alert show];
                
                
            }else{
                [self ShowMessage:NSLocalizedString(@"Alert.downloadFailure",@"Failed To Download Data.")];
                
            }
            
            [mainDelegate.activityIndicatorObject stopAnimating];
            [mainDelegate stopIndicator];
            syncButton.enabled=true;
            
        }
    }
    
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(GOoffline){
        GOoffline=NO;
        [self.statusButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"Offline.png"]]forState:UIControlStateNormal];
        [self.statusButton removeTarget:self action:@selector(ChangeStatusToOffline) forControlEvents:UIControlEventTouchUpInside];
        [self.statusButton addTarget:self action:@selector(ChangeStatusToOnline) forControlEvents:UIControlEventTouchUpInside];
        
        
        NSUserDefaults *defaults;
        
        
        defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"YES" forKey:@"offline_mode"];
        [defaults synchronize];
        mainDelegate.isOfflineMode = [[[NSUserDefaults standardUserDefaults] stringForKey:@"offline_mode"] boolValue];
        mainDelegate.NbOfCorrToLoad=0;
        mainDelegate.InboxTotalCorr=0;
        mainDelegate.inboxForArchiveSelected=0;
        mainDelegate.searchModule=nil;
        mainDelegate.selectedInbox=0;

        [self RefreshSerachResult];
        //[self refreshBarView];
        return;
    }
    
    if (buttonIndex == 0)
    {
        
        if(sync==YES){
            //sync
            sync=NO;
            
            [self performSync];
            
        }
        else{
            downloadNOW=NO;
        }
        
    }
    else if (buttonIndex == 1)
    {
        if(downloadNOW){
            downloadNOW=NO;
            [self download];
        }
        else
            if(changeStatus){
                changeStatus=NO;
                if([changeStatusTo isEqualToString:@"Online"]){
                    [self.statusButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"Online.png"]]forState:UIControlStateNormal];
                    [self.statusButton removeTarget:self action:@selector(ChangeStatusToOnline) forControlEvents:UIControlEventTouchUpInside];
                    [self.statusButton addTarget:self action:@selector(ChangeStatusToOffline) forControlEvents:UIControlEventTouchUpInside];
                    NSUserDefaults *defaults;
                    defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:@"NO" forKey:@"offline_mode"];
                    [defaults synchronize];
                   // [self deleteCachedFiles];
                    mainDelegate.isOfflineMode = [[[NSUserDefaults standardUserDefaults] stringForKey:@"offline_mode"] boolValue];
                    mainDelegate.NbOfCorrToLoad=0;
                    mainDelegate.InboxTotalCorr=0;
                    mainDelegate.inboxForArchiveSelected=0;
                    mainDelegate.searchModule=nil;
                    mainDelegate.selectedInbox=0;
                    [self RefreshSerachResult];
                    
                    
                    
                }
                else{
                    
                    [self.statusButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"Offline.png"]]forState:UIControlStateNormal];
                    [self.statusButton removeTarget:self action:@selector(ChangeStatusToOffline) forControlEvents:UIControlEventTouchUpInside];
                    [self.statusButton addTarget:self action:@selector(ChangeStatusToOnline) forControlEvents:UIControlEventTouchUpInside];
                    
                    NSUserDefaults *defaults;
                    defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:@"YES" forKey:@"offline_mode"];
                    [defaults synchronize];
                    
                    
                    mainDelegate.isOfflineMode = [[[NSUserDefaults standardUserDefaults] stringForKey:@"offline_mode"] boolValue];
                    mainDelegate.NbOfCorrToLoad=0;
                    mainDelegate.InboxTotalCorr=0;
                    mainDelegate.inboxForArchiveSelected=0;
                    mainDelegate.searchModule=nil;
                    mainDelegate.selectedInbox=0;
                    [self RefreshSerachResult];
                }
            }
            else
                if(sync==YES){
                    //Discard
                    [CParser DeleteOfflineActions:@"OfflineActions"];
                    [CParser DeleteOfflineActions:@"BuiltInActions"];
                    sync=NO;
                    [self refreshBarView];
                    
                }
                else{
                    mainDelegate.searchModule=nil;
                    mainDelegate.user=nil;
                    mainDelegate.NbOfCorrToLoad=0;
                    mainDelegate.InboxTotalCorr=0;
                    mainDelegate.inboxForArchiveSelected=0;
                    //            if(!mainDelegate.isOfflineMode)
                    //                [self deleteCachedFiles];
                    // self.navigationItem.rightBarButtonItem.enabled = NO;
                    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
                    delegate.user=nil;
                    delegate.searchModule=nil;
                    delegate.selectedInbox=0;
                    UIStoryboard *    storyboard=[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
                    LoginViewController *loginView=[[LoginViewController alloc]init];
                    loginView= [storyboard instantiateViewControllerWithIdentifier:@"LOGIN"];
                    
                    self.view.window.rootViewController=loginView;
                    
                }
    }
    else{
        sync=NO;
        
    }

    
    
}


-(void)SyncActions{
    if(!mainDelegate.isOfflineMode&&!mainDelegate.Downloading && ([CParser EntitySize:@"OfflineActions"]>0||[CParser EntitySize:@"BuiltInActions"]>0)){
        sync=YES;
        NSString* message;
        message=NSLocalizedString(@"Alert.SyncMsg",@"Actions made in offline mode detected");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert.SyncTitle",@"Synchronization")
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Alert.SyncButton",@"Sync" )
                                              otherButtonTitles:NSLocalizedString(@"Alert.DiscardButton",@"Discard Actions" ),NSLocalizedString(@"Alert.NotNowButton",@"Not Now" ),nil];
        [alert show];
        
    }
}

-(void)deleteCachedFiles{
    
    @try{
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSError *error = nil;
        for (NSString *file in [fm contentsOfDirectoryAtPath:cachesDirectory error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", cachesDirectory, file] error:&error];
            if (!success || error) {
                NSLog(@"%@",error);
            }
        }
        for (NSString *file in [fm contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, file] error:&error];
            if (!success || error) {
                NSLog(@"%@",error);
            }
        }
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"NorecordsViewController" function:@"deleteCachedFiles" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)ShowMessage:(NSString*)message{
    
    NSString *msg = message;
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Alert",@"Alert")
                          message: msg
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK",@"OK")
                          otherButtonTitles: nil];
 
    [alert show];
}



-(void)performSync{
    mainDelegate.CounterSync=0;
    mainDelegate.Sync=YES;
    DownloadButton.enabled=FALSE;
    [mainDelegate.activityIndicatorObject startAnimating];
    [mainDelegate RunIndicator:syncButton];
    NSMutableArray * offlineActions=[CParser LoadOfflineActions];
    NSMutableArray* builtinActions=[CParser LoadBuiltInActions];
    mainDelegate.CountOfflineActions=[offlineActions count]+[builtinActions count];
    queue = [[NSOperationQueue alloc] init] ;
    [queue setMaxConcurrentOperationCount:3];
    mainDelegate.SyncActions=[[NSMutableArray alloc]init];
    [mainDelegate.SyncActions removeAllObjects];
    
    for(OfflineAction* action in offlineActions){
        NSURL *url = [NSURL URLWithString:[action.Url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        SomeNetworkOperation *op = [[SomeNetworkOperation alloc] init];
        op.delegate = self;
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
        op.requestToLoad = request;
        op.Action=action.Action;
        
        [queue addOperation:op];
    }
    //ReaderViewController* methodCall=[[ReaderViewController alloc]init];
    //    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Sync",@"Synchronizing ...") maskType:SVProgressHUDMaskTypeBlack];
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    //        for(OfflineAction* action in offlineActions){
    //            NSURL *xmlUrl = [NSURL URLWithString:[action.Url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //            NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
    //            NSString *validationResultAction=[CParser ValidateWithData:xmlData];
    //
    //            if(![validationResultAction isEqualToString:@"OK"])
    //            {
    //                [self ShowMessage:validationResultAction];
    //            }
    //            else {
    //            }
    //        }
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    for(BuiltInActions* act in builtinActions){
        if([act.Action isEqualToString:@"CustomCustom"]){
            NSString* urlString;

            // setting up the URL to post to
            if(mainDelegate.SupportsServlets)
                urlString = [NSString stringWithFormat:@"http://%@",mainDelegate.serverUrl];
            else
                urlString = [NSString stringWithFormat:@"http://%@/SaveAnnotations",mainDelegate.serverUrl];
            
            // setting up the request object now
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:urlString]];
            [request setHTTPMethod:@"POST"];
            
            
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
            [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            NSMutableData *body = [NSMutableData data];
            
            // action parameter
            if(mainDelegate.SupportsServlets){
                // action parameter
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"action\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"SaveAnnotations" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            
            
            
            // file
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Disposition: form-data; name=\"annotations\"; filename=\".xml\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[NSData dataWithData:act.xml]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            // text parameter
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"correspondenceId\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[act.Id dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            // close form
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            // set request body
            [request setHTTPBody:body];
            [request setTimeoutInterval:mainDelegate.Request_timeOut];
            SomeNetworkOperation *op = [[SomeNetworkOperation alloc] init];
            op.delegate = self;
            
            op.requestToLoad = request;
            op.Action=act.Action;
            
            [queue addOperation:op];
        }
        else{
            NSString* urlString;
            
            
            if(mainDelegate.SupportsServlets)
                urlString = [NSString stringWithFormat:@"http://%@",mainDelegate.serverUrl];
            else
                urlString = [NSString stringWithFormat:@"http://%@/UpdateDocument",mainDelegate.serverUrl];
            
            // setting up the request object now
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:urlString]];
            [request setHTTPMethod:@"POST"];
            
            
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
            [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            NSMutableData *body = [NSMutableData data];
            if(mainDelegate.SupportsServlets){
                // action parameter
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"action\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"UpdateDocument" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                
            }
            
            // file
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Disposition: form-data; name=\"userfile\"; filename=\".xml\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[NSData dataWithData:act.xml]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            // text parameter
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"correspondenceId\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[act.Id dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            // close form
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            // set request body
            [request setHTTPBody:body];
            [request setTimeoutInterval:mainDelegate.Request_timeOut];
            SomeNetworkOperation *op = [[SomeNetworkOperation alloc] init];
            op.delegate = self;
            op.Action=act.Action;
            op.requestToLoad = request;
            
            [queue addOperation:op];
            //                            NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            //                            dispatch_async(dispatch_get_main_queue(), ^{
            //                                //[SVProgressHUD dismiss];
            //                                counter++;
            //
            //                                NSString *validationResult=[CParser ValidateWithData:returnData];
            //                                if (mainDelegate==nil) mainDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
            //                                if(!mainDelegate.isOfflineMode){
            //                                    if(![validationResult isEqualToString:@"OK"]){
            //
            //                                        if([validationResult isEqualToString:@"Cannot access to the server"]){
            //                                            [self ShowMessage:validationResult];
            //                                        }
            //                                        else{
            //                                            [self ShowMessage:validationResult];
            //                                        }
            //                                    }else{
            //                                        if(counter==[builtinActions count]){
            //                                            [SVProgressHUD dismiss];
            //                                            [self ShowMessage:NSLocalizedString(@"Alert.syncSuccess",@"Synchronization Completed Successfully.")];
            //
            //                                        }
            //                                    }
            //                                }
            //
            //
            //                            });
            //
            //                        });
        }
        // [methodCall UploadAnnotations:act.Id];
    }
    //                dispatch_async(dispatch_get_main_queue(), ^{
    //                    if(counter==[builtinActions count]){
    //                        [SVProgressHUD dismiss];
    //                        [self ShowMessage:NSLocalizedString(@"Alert.syncSuccess",@"Synchronization Completed Successfully.")];
    //
    //                    }
    //                    [CParser DeleteOfflineActions:@"OfflineActions"];
    //                    [CParser DeleteOfflineActions:@"BuiltInActions"];
    //
    //
    //                });
    //            });
    //        });
    //    });
    
    
}


-(void)dropdown{
    
    if(mainDelegate.user.UserDetails.count>0){
        UserDetailsViewController *UserDetails=[[UserDetailsViewController alloc]initWithStyle:UITableViewStylePlain];
        self.notePopController = [[UIPopoverController alloc] initWithContentViewController:UserDetails];
        if(mainDelegate.user.UserDetails.count>6)
            
            self.notePopController.popoverContentSize = CGSizeMake(250, 50*6);
        else
            self.notePopController.popoverContentSize = CGSizeMake(400, 50*mainDelegate.user.UserDetails.count);
        
        [self.notePopController presentPopoverFromRect:self.usernameButton.frame inView:mainDelegate.barView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
        UserDetails.UserDetail=mainDelegate.user.UserDetails;
        UserDetails.delegate=self;
        
    }
    
}


-(void)SetDepartment:(int)departmentId{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loading ...") maskType:SVProgressHUDMaskTypeBlack];
    
    
    @try{
        
        NSString* params;
        NSString* url;
        if(mainDelegate.SupportsServlets){
            params=[NSString stringWithFormat:@"action=setUserDepartment&token=%@&departmentId=%d", mainDelegate.user.token,departmentId];
            url = [NSString stringWithFormat:@"http://%@?%@",mainDelegate.serverUrl,params];
            
        }
        else{
            params=[NSString stringWithFormat:@"setUserDepartment?token=%@&departmentId=%d", mainDelegate.user.token,departmentId];
            url = [NSString stringWithFormat:@"http://%@/%@",mainDelegate.serverUrl,params];
            
        }
        if(!mainDelegate.isOfflineMode){
            // NSURL *xmlUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            //NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
            NSData *xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            NSString *validationResultAction=[CParser ValidateWithData:xmlData];
            
            if(![validationResultAction isEqualToString:@"OK"])
            {
                [SVProgressHUD dismiss];
                
                [self ShowMessage:validationResultAction];
                
            }else {
                [CParser LoadDepartmentChanges:xmlData];
                [SVProgressHUD dismiss];
                [self.searchResult.correspondenceList removeAllObjects];
                mainDelegate.InboxTotalCorr=0;
                mainDelegate.menuSelectedItem=0;
                mainDelegate.splitViewController=nil;

                [self RefreshSerachResult];
            }
        }else{
            
            [SVProgressHUD dismiss];
            
            
        }
    }
    @catch (NSException *ex) {
        [SVProgressHUD dismiss];
        
        [FileManager appendToLogView:@"userDeatis" function:@"executeAction" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    
}


-(void)dismissPopUp:(UITableViewController*)viewcontroller{
    [self.notePopController dismissPopoverAnimated:NO];
    
}

-(void) RefreshSerachResult
{
    UIStoryboard *    storyboard=[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    mainDelegate.splitViewController= [storyboard instantiateViewControllerWithIdentifier:@"SplitViewController"];
    UINavigationController* navigationController = [self.splitViewController.viewControllers lastObject];
    self.splitViewController.delegate = (id)navigationController.topViewController;
    self.splitViewController.view.backgroundColor = [UIColor grayColor];
    containerView *container=[[containerView alloc] init];
    container.splitView=mainDelegate.splitViewController;
    self.view.window.rootViewController=container;
    
}

-(void) refreshBarView
{
    
        
            [mainDelegate.barView removeFromSuperview];
            mainDelegate.barView= [self createBarView];
           [mainDelegate.barView setNeedsDisplay];
            [self.view addSubview:mainDelegate.barView];
        enableSyncButton=true;
    DateTimeLabel.frame=CGRectMake(mainDelegate.barView.frame.origin.x+mainDelegate.barView.frame.size.width-235, mainDelegate.barView.frame.origin.y+mainDelegate.barView.frame.size.height, 235, 40);
    imageview.frame=CGRectMake(DateTimeLabel.frame.origin.x-clockImage.size.width, DateTimeLabel.frame.origin.y+(DateTimeLabel.frame.size.height/2)-clockImage.size.height/2, clockImage.size.width, clockImage.size.height);

}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
