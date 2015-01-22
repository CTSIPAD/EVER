//
//  SearchResultViewController.m
//  iBoard
//
//  Created by LBI on 11/14/13.
//  Copyright (c) 2013 LBI. All rights reserved.
//

#import "SearchResultViewController.h"
#import "TableResultCell.h"
#import "ReaderDocument.h"
#import "ReaderViewController.h"
#import "CSearch.h"
#import "CParser.h"
#import "CCorrespondence.h"
#import "CAttachment.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "GDataXMLNode.h"
#import "FileManager.h"
#import "CMenu.h"
#import "SettingsViewController.h"
#import "OfflineAction.h"
#import "BuiltInActions.h"
#import "UserDetail.h"
#import "SomeNetworkOperation.h"
#import "OfflineResult.h"
#import "SyncViewController.h"
#import "UserDetailsViewController.h"
#import "UploadControllerDialog.h"
#import "CommentViewController.h"
#import "HeaderView.h"
#import "containerView.h"
#define  SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)
@interface SearchResultViewController ()
@end

@implementation SearchResultViewController{
    AppDelegate *mainDelegate ;
    int counter;
    NSOperationQueue *queue;
    UIBarButtonItem *itemdownload;
    UIButton *btndownload;
    UIButton *btnSync;
    UIBarButtonItem *item;
    UIBarButtonItem *itemSync;
    UIBarButtonItem *itemlogout;
    UIBarButtonItem *itemsettings;
    UIButton *btn ;
    BOOL ACTIVE;
    UIButton *btnStatus;
    UIBarButtonItem *itemStatus;
    NSString* changeStatusTo;
    int customHeight;
    HeaderView *header;
    BOOL Break;
    BOOL IsLocked;
    UIInterfaceOrientation lastOrientation;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    counter=0;
    ACTIVE=false;
    customHeight=0;
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    mainDelegate.activityIndicatorObject=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    mainDelegate.activityIndicatorObject.center=CGPointMake(517, 420);
    mainDelegate.activityIndicatorObject.transform = CGAffineTransformMakeScale(1.5, 1.5);
    mainDelegate.attachmentSelected =0;
    mainDelegate.NbOfCorrToLoad=mainDelegate.SettingsCorrNb;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.tableView.backgroundColor=mainDelegate.bgColor;
    self.tableView.separatorColor = mainDelegate.bgColor;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"searchResultCell"];
    [self.tableView setContentInset:UIEdgeInsetsMake(0,0,0,0)];
    self.searchResult=mainDelegate.searchModule;
    self.navigationItem.leftBarButtonItem=nil;
    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden=YES;
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.tintColor=[UIColor whiteColor];
    self.searchBar.barTintColor=mainDelegate.cellColor;
    self.searchBar.placeholder=NSLocalizedString(@"Search",@"Search");
    self.searchBar.delegate=self;
    
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText length] == 0) {
        [searchBar performSelector: @selector(resignFirstResponder)
                        withObject: nil
                        afterDelay: 0];
        [searchBar setShowsCancelButton:NO animated:YES];
        
        self.tableView.allowsSelection = YES;
        self.tableView.scrollEnabled = YES;
        mainDelegate.isBasketSelected = YES;
        [NSThread detachNewThreadSelector:@selector(increaseLoading) toTarget:self withObject:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData * menuXmlData;
            
            NSMutableDictionary *correspondences;
            if(!mainDelegate.isOfflineMode){
                NSString* correspondenceUrl;
                NSString* showthumb;
                if (mainDelegate.ShowThumbnail)
                    showthumb=@"true";
                else
                    showthumb=@"false";
                mainDelegate.NbOfCorrToLoad=mainDelegate.SettingsCorrNb;
                if (mainDelegate.selectedInbox==0){
                    mainDelegate.selectedInbox=((CMenu*)mainDelegate.user.menu[0]).menuId;
                    mainDelegate.menuSelectedItem=1;
                    
                }
                if(mainDelegate.SupportsServlets)
                    correspondenceUrl=[NSString stringWithFormat:@"http://%@?action=GetCorrespondences&token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@&SearchCriteria=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.selectedInbox,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb,self.searchBar.text];
                else
                    correspondenceUrl=[NSString stringWithFormat:@"http://%@/GetCorrespondences?token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@&SearchCriteria=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.selectedInbox,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb,self.searchBar.text];
                
                NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[correspondenceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
                menuXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                correspondences=[CParser loadCorrespondencesWithData:menuXmlData];
                
            }
            else{
                correspondences=[CParser LoadCorrespondences:mainDelegate.selectedInbox];
                
            }
            if(mainDelegate.searchModule==nil){
                mainDelegate.searchModule=[[CSearch alloc]init];
                
            }
            if(mainDelegate.searchModule.correspondenceList==nil){
                mainDelegate.searchModule.correspondenceList=[[NSMutableArray alloc]init];
            }
            [mainDelegate.searchModule.correspondenceList removeAllObjects];
            
            [mainDelegate.searchModule.correspondenceList addObjectsFromArray:[correspondences objectForKey:[NSString stringWithFormat:@"%ld",(long)mainDelegate.selectedInbox]]];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!mainDelegate.isOfflineMode){
                    NSString *validationResultAction=[CParser ValidateWithData:menuXmlData];
                    
                    if(![validationResultAction isEqualToString:@"OK"])
                    {
                        [self ShowMessage:validationResultAction];
                    }
                    else {
                        self.searchResult=mainDelegate.searchModule;
                        [self.tableView reloadData];
                        
                    }
                }
                
                [NSThread detachNewThreadSelector:@selector(dismiss) toTarget:self withObject:nil];
            });
        });
        
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
    mainDelegate.isBasketSelected = YES;
    [NSThread detachNewThreadSelector:@selector(increaseLoading) toTarget:self withObject:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData * menuXmlData;
        
        NSMutableDictionary *correspondences;
        if(!mainDelegate.isOfflineMode){
            NSString* correspondenceUrl;
            NSString* showthumb;
            if (mainDelegate.ShowThumbnail)
                showthumb=@"true";
            else
                showthumb=@"false";
            mainDelegate.NbOfCorrToLoad=mainDelegate.SettingsCorrNb;
            if (mainDelegate.selectedInbox==0){
                mainDelegate.selectedInbox=((CMenu*)mainDelegate.user.menu[0]).menuId;
                mainDelegate.menuSelectedItem=1;
                
            }
            if(mainDelegate.SupportsServlets)
                correspondenceUrl=[NSString stringWithFormat:@"http://%@?action=GetCorrespondences&token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@&SearchCriteria=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.selectedInbox,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb,self.searchBar.text];
            else
                correspondenceUrl=[NSString stringWithFormat:@"http://%@/GetCorrespondences?token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@&SearchCriteria=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.selectedInbox,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb,self.searchBar.text];
            
            
            //            NSURL *xmlUrl = [NSURL URLWithString:[correspondenceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            //            menuXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[correspondenceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
            menuXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            correspondences=[CParser loadCorrespondencesWithData:menuXmlData];
            
        }
        else{
            correspondences=[CParser LoadCorrespondences:mainDelegate.selectedInbox];
            
        }
        if(mainDelegate.searchModule==nil){
            mainDelegate.searchModule=[[CSearch alloc]init];
            
        }
        if(mainDelegate.searchModule.correspondenceList==nil){
            mainDelegate.searchModule.correspondenceList=[[NSMutableArray alloc]init];
        }
        [mainDelegate.searchModule.correspondenceList removeAllObjects];
        
        [mainDelegate.searchModule.correspondenceList addObjectsFromArray:[correspondences objectForKey:[NSString stringWithFormat:@"%ld",(long)mainDelegate.selectedInbox]]];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!mainDelegate.isOfflineMode){
                NSString *validationResultAction=[CParser ValidateWithData:menuXmlData];
                
                if(![validationResultAction isEqualToString:@"OK"])
                {
                    [self ShowMessage:validationResultAction];
                }
                else {
                    self.searchResult=mainDelegate.searchModule;
                    [self.tableView reloadData];
                    
                }
            }
            
            [NSThread detachNewThreadSelector:@selector(dismiss) toTarget:self withObject:nil];
        });
    });
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some
    // api that you are using to do the search
    //  NSArray *results = [SomeService doSearch:searchBar.text];
	
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
    
    
    mainDelegate.isBasketSelected = YES;
    [NSThread detachNewThreadSelector:@selector(increaseLoading) toTarget:self withObject:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData * menuXmlData;
        
        NSMutableDictionary *correspondences;
        if(!mainDelegate.isOfflineMode){
            NSString* correspondenceUrl;
            NSString* showthumb;
            if (mainDelegate.ShowThumbnail)
                showthumb=@"true";
            else
                showthumb=@"false";
            mainDelegate.NbOfCorrToLoad=mainDelegate.SettingsCorrNb;
            if (mainDelegate.selectedInbox==0){
                mainDelegate.selectedInbox=((CMenu*)mainDelegate.user.menu[0]).menuId;
                mainDelegate.menuSelectedItem=1;
                
            }
            if(mainDelegate.SupportsServlets)
                correspondenceUrl=[NSString stringWithFormat:@"http://%@?action=GetCorrespondences&token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@&SearchCriteria=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.selectedInbox,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb,self.searchBar.text];
            else
                correspondenceUrl=[NSString stringWithFormat:@"http://%@/GetCorrespondences?token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@&SearchCriteria=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.selectedInbox,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb,self.searchBar.text];
            
            
            //            NSURL *xmlUrl = [NSURL URLWithString:[correspondenceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            //            menuXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[correspondenceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
            menuXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            correspondences=[CParser loadCorrespondencesWithData:menuXmlData];
            
        }
        else{
            correspondences=[CParser LoadCorrespondences:mainDelegate.selectedInbox];
            
        }
        if(mainDelegate.searchModule==nil){
            mainDelegate.searchModule=[[CSearch alloc]init];
            
        }
        if(mainDelegate.searchModule.correspondenceList==nil){
            mainDelegate.searchModule.correspondenceList=[[NSMutableArray alloc]init];
        }
        [mainDelegate.searchModule.correspondenceList removeAllObjects];
        
        [mainDelegate.searchModule.correspondenceList addObjectsFromArray:[correspondences objectForKey:[NSString stringWithFormat:@"%ld",(long)mainDelegate.selectedInbox]]];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!mainDelegate.isOfflineMode){
                NSString *validationResultAction=[CParser ValidateWithData:menuXmlData];
                
                if(![validationResultAction isEqualToString:@"OK"])
                {
                    [self ShowMessage:validationResultAction];
                }
                else {
                    self.searchResult=mainDelegate.searchModule;
                    [self.tableView reloadData];
                    
                }
            }
            
            [NSThread detachNewThreadSelector:@selector(dismiss) toTarget:self withObject:nil];
        });
    });
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (mainDelegate.isOfflineMode) {
        return self.searchResult.correspondenceList.count;
    }
    if(self.searchResult.correspondenceList.count==0)
        return 1;
    if(!mainDelegate.SearchClicked){
        if(mainDelegate.InboxTotalCorr<=mainDelegate.NbOfCorrToLoad){
            if(mainDelegate.InboxTotalCorr>self.searchResult.correspondenceList.count)
                return self.searchResult.correspondenceList.count;
            
            return mainDelegate.InboxTotalCorr;
        }
        
        if(self.searchResult.correspondenceList.count==mainDelegate.InboxTotalCorr && self.searchResult.correspondenceList.count<=mainDelegate.NbOfCorrToLoad)
            return self.searchResult.correspondenceList.count;
        if(self.searchResult==nil || self.searchResult.correspondenceList==nil)
            return 0;
        return mainDelegate.NbOfCorrToLoad+1;
    }
    else{
        return self.searchResult.correspondenceList.count;
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.searchResult.correspondenceList.count==0){
        [self.tableView setBounces:NO];
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation])) {
            customHeight=0;
        }
        else
        {
            customHeight=800;
        }
        
        return self.tableView.frame.size.height+customHeight;
    }
    else{
        if(indexPath.row == mainDelegate.NbOfCorrToLoad && mainDelegate.selectedInbox!=-1&&!mainDelegate.isOfflineMode)
            return 70;
        return 170;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.searchResult.correspondenceList.count==0){
        NSLog(@"Info: number of correspondences is equal to zero.");
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        UIGraphicsBeginImageContext(self.view.frame.size);
        [[UIImage imageNamed:@"detailviewBackground.png"] drawInRect:self.view.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        cell.backgroundColor = [UIColor colorWithPatternImage:image];
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
        self.tableView.tableHeaderView = nil;
        return  cell;
    }
    else{
//        self.tableView.tableHeaderView = self.searchBar;
        self.tableView.tableHeaderView = nil;

        static NSString *CellIdentifier = @"Cell";
        TableResultCell *cell ;
        if (indexPath.row != mainDelegate.NbOfCorrToLoad || mainDelegate.SearchClicked ||  mainDelegate.isOfflineMode){
            cell = [[TableResultCell alloc] init:indexPath.row frame:self.tableView.frame];
            
            cell.delegate=self;
            CCorrespondence *correspondence=self.searchResult.correspondenceList[indexPath.row];
            
            for (id key in correspondence.systemProperties) {
                
                NSDictionary *subDictionary = [correspondence.systemProperties objectForKey:key];
                NSArray *keys=[subDictionary allKeys];
                NSString *value = [subDictionary objectForKey:[keys objectAtIndex:0]];
                if([key isEqualToString:@"2"])
                {
                    cell.label2.text=[NSString stringWithFormat:@"%@: %@",[keys objectAtIndex:0],value];
                    
                }else if([key isEqualToString:@"1"])
                {
                    cell.label1.lineBreakMode = NSLineBreakByWordWrapping;
                    cell.label1.numberOfLines = 0;
                    cell.label1.text=[NSString stringWithFormat:@"%@: %@",[keys objectAtIndex:0],value];
                }else if([key isEqualToString:@"0"])
                {
                    cell.label3.text=[NSString stringWithFormat:@"%@: %@",[keys objectAtIndex:0],value];
                }
                else if([key isEqualToString:@"3"])
                {
                    cell.label4.text=[NSString stringWithFormat:@"%@: %@",[keys objectAtIndex:0],value];
                }
            }
            
            
            
            
            
            
            
            [cell.LockButton addTarget:self action:@selector(performAction:) forControlEvents:UIControlEventTouchUpInside];
            
            
            
            cell.backgroundColor =mainDelegate.bgColor;
            UIView *bgViewColor=[[UIView alloc] init];
            bgViewColor.backgroundColor=[UIColor colorWithRed:47.0f / 255.0f green:129.0f / 255.0f blue:211.0f / 255.0f alpha:1.0];
            cell.selectedBackgroundView=bgViewColor;
            
        }
        else{
            if(indexPath.row == mainDelegate.NbOfCorrToLoad ) {
                if (cell == nil) {
                    cell = [[TableResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    
                }
                [cell loadmore];
                
                cell.backgroundColor =[UIColor colorWithRed:1.0f/255.0f green:49.0f/255.0f blue:97.0f/255.0f alpha:1.0f];
                
                
                
                
            }
        }
     
        return cell;
    }
}
/*************************Quick Actions Methods************************/
-(void)executeAction:(NSString*)action note:(NSString*)Note movehome:(BOOL)movehome{
    ReaderViewController* view=[[ReaderViewController alloc]init];
    view.delegate=self;
    [view executeAction:action note:Note movehome:movehome];
}
-(void)ActionMoveHome:(CommentViewController *)viewcontroller{
    mainDelegate.splitViewController=nil;
    [self RefreshSerachResult];
}
-(void)movehome:(UITableViewController *)viewcontroller{
    
    mainDelegate.splitViewController=nil;
    
    [self RefreshSerachResult];
}
-(void)PopUpCommentDialog:(UITableViewController*)viewcontroller Action:(CAction *)action document:(ReaderDocument*)document1{
    
    CommentViewController *AcceptView = [[CommentViewController alloc] initWithActionName:CGRectMake(0, 200, 450, 370)  Action:action];
    AcceptView.modalPresentationStyle = UIModalPresentationFormSheet;
    AcceptView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:AcceptView animated:YES completion:nil];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
        AcceptView.view.superview.frame = CGRectMake(300, 200, 430, 400);
    else
    AcceptView.preferredContentSize=CGSizeMake(450,370);
   
    AcceptView.delegate=self;
    AcceptView.Action=action;
    AcceptView.document =document1;
    
}
-(void)PopUpTransferDialog{
    TransferViewController *transferView = [[TransferViewController alloc] initWithFrame:CGRectMake(0, 200, 450, 370)];
    transferView.modalPresentationStyle = UIModalPresentationFormSheet;
    transferView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:transferView animated:YES completion:nil];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
        transferView.view.superview.frame = CGRectMake(300, 200, 450, 470);
    else
     transferView.preferredContentSize=CGSizeMake(450,470);
    //transferView.view.superview.frame = CGRectMake(300, 200, 450, 470); //it's important to do this after presentModalViewController
    // noteView.view.superview.center = self.view.center;
    transferView.delegate=self;
    
}
-(void)ShowUploadAttachmentDialog:(int)index{
    CCorrespondence *correspondence;
    
    correspondence=mainDelegate.searchModule.correspondenceList[index];
    
    UploadControllerDialog *uploadDialog = [[UploadControllerDialog alloc] initWithFrame:CGRectMake(300, 200, 400, 400)];
    uploadDialog.modalPresentationStyle = UIModalPresentationFormSheet;
    uploadDialog.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    uploadDialog.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self presentViewController:uploadDialog animated:YES completion:nil];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
         uploadDialog.view.superview.frame = CGRectMake(300, 200, 400, 400);
    else
        uploadDialog.preferredContentSize=CGSizeMake(400,400);
    
    uploadDialog.CorrespondenceId=correspondence.Id;
    uploadDialog.quickActionSelected=YES;
    uploadDialog.delegate=self;
    
}
-(void)dismissUpload:(UIViewController*)viewcontroller{
    if ([self respondsToSelector:@selector(dismissReaderViewController:)] == YES)
	{
        
        [self dismissViewControllerAnimated:YES  completion:^{
             //[delegate dismissReaderViewController:self];
            [self movehome:self];
        }];
    }
    
}


-(void)destinationSelected:(CDestination*)dest withRouteLabel:(CRouteLabel*)routeLabel routeNote:(NSString*)note withDueDate:(NSString*)date viewController:(TransferViewController *)viewcontroller
{
    ReaderViewController* view=[[ReaderViewController alloc]init];
    view.delegate=self;
    view.correspondenceId=mainDelegate.QuickActionIndex;
    [view destinationSelected:dest withRouteLabel:routeLabel routeNote:note withDueDate:date viewController:viewcontroller];
    [self dismissUpload:self];
}
/*************************End Quick Actions Methods************************/
-(void)performAction:(id)sender{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];

    
    CCorrespondence *correspondence=self.searchResult.correspondenceList[indexPath.row];
    
    NSString* searchUrl;
    if(mainDelegate.SupportsServlets)
        searchUrl = [NSString stringWithFormat:@"http://%@?action=IsLockedCorrespondence&token=%@&transferId=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.TransferId,mainDelegate.IpadLanguage];
    else
        searchUrl = [NSString stringWithFormat:@"http://%@/IsLockedCorrespondence?token=%@&transferId=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.TransferId,mainDelegate.IpadLanguage];
    NSMutableDictionary* LockResult=[CParser IsLockedCorrespondence:searchUrl];
    NSString* lockedby=[LockResult objectForKey:@"lockedby"];
    NSString* UserId=[LockResult objectForKey:@"UserId"];
    
    BOOL isLocked=[[LockResult objectForKey:@"IsLocked"]boolValue];
    
    if([UserId isEqualToString:mainDelegate.user.userId] || !isLocked){
        
        if(correspondence.ShowLocked){
            if([correspondence performCorrespondenceAction:@"UnlockCorrespondence"]){
                correspondence.ShowLocked=NO;
                [sender setImage:[UIImage imageNamed:@"cts_Unlock.png"] forState:UIControlStateNormal];
               // [cell hideActions:NO];
            }
        }else{
            if([correspondence performCorrespondenceAction:@"LockCorrespondence"]){
                correspondence.ShowLocked=YES;
                mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                //  correspondence.LockedBy = [NSString stringWithFormat:@"%@ %@",mainDelegate.user.firstName,mainDelegate.user.lastName];
                [sender setImage:[UIImage imageNamed:@"lockimg.png"] forState:UIControlStateNormal];
                //[cell hideActions:YES];
            }
            
        }
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tasktable.locked",@"Task is locked")
                                                        message:[NSString stringWithFormat:@"%@ %@",lockedby,NSLocalizedString(@"tasktable.locked.dialog",@"has locked the task.")]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [SVProgressHUD dismiss];
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Info: Enter didSelectRowAtIndexPath method in class SearchResultViewController.");

    [mainDelegate.Highlights removeAllObjects];
    [mainDelegate.IncomingHighlights removeAllObjects];
    [mainDelegate.IncomingNotes removeAllObjects];
    [mainDelegate.Notes removeAllObjects];
    
    @try {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (self.searchResult.correspondenceList.count==0) {
            
            return;
        }
        
        
        mainDelegate.QuickActionClicked=false;
        [mainDelegate.Highlights removeAllObjects];
        [mainDelegate.Notes removeAllObjects];
        if(indexPath.row != mainDelegate.NbOfCorrToLoad) {
            
            mainDelegate.searchSelected = indexPath.row;
            CCorrespondence *correspondence=self.searchResult.correspondenceList[indexPath.row];
            
//            if(mainDelegate.isBasketSelected){
                [self performSelectorOnMainThread:@selector(increaseProgress) withObject:@"" waitUntilDone:YES];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSString* lockedby;
                    NSString* lockedbyUserId;
                    
                    if(!mainDelegate.isOfflineMode){
                        NSString* searchUrl;
                        NSLog(@"Info:Preparing IsLockedCorrespondence Rquest");
                        if(mainDelegate.SupportsServlets)
                            searchUrl = [NSString stringWithFormat:@"http://%@?action=IsLockedCorrespondence&token=%@&transferId=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.TransferId,mainDelegate.IpadLanguage];
                        else
                            searchUrl = [NSString stringWithFormat:@"http://%@/IsLockedCorrespondence?token=%@&transferId=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.TransferId,mainDelegate.IpadLanguage];
                        NSLog(@"URL:%@",searchUrl);
                        NSMutableDictionary* LockResult=[CParser IsLockedCorrespondence:searchUrl];
                        if(LockResult==nil)
                        {
                            
                            Break=YES;
                            
                        }
                        else
                            Break=NO;
                        if(!Break){
                        lockedby=[LockResult objectForKey:@"lockedby"];
                        IsLocked=[[LockResult objectForKey:@"IsLocked"]boolValue];
                        lockedbyUserId=[LockResult objectForKey:@"UserId"];
                        correspondence.ShowLocked=IsLocked;
                        }
                        // [tableView reloadData];
                    }
                    else
                    {
                        IsLocked=NO;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        if(!Break){
                        if([lockedbyUserId isEqualToString:mainDelegate.user.userId] || !IsLocked){
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                
                                NSData *attachmentXmlData;
                                NSMutableArray *attachments;
                                if(!mainDelegate.isOfflineMode){
                                    NSString* attachmentUrl;
                                    NSLog(@"Info: preparing GetAttachments Request.");
                                    if(mainDelegate.SupportsServlets)
                                        attachmentUrl= [NSString stringWithFormat:@"http://%@?action=GetAttachments&token=%@&docId=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.Id,mainDelegate.IpadLanguage];
                                    else
                                        attachmentUrl= [NSString stringWithFormat:@"http://%@/GetAttachments?token=%@&docId=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.Id,mainDelegate.IpadLanguage];
                                    NSLog(@"URL: %@",attachmentUrl);
                                    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[attachmentUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
                                    attachmentXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                                    attachments=[CParser loadSpecifiqueAttachment:attachmentXmlData CorrespondenceId:correspondence.Id];
                                }
                                else{
                                    attachments=[CParser LoadAttachments:correspondence.Id];
                                }
                                
                                if(attachments.count==0){
                                    [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
                                    Break=YES;
                                    if(mainDelegate.isOfflineMode)
                                        [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:NSLocalizedString(@"AttachmentNotCached",@"") waitUntilDone:YES];
                                }
                                else{
                                    
                                    [correspondence setAttachmentsList:attachments];
                                    
                                    
                                    
                                    if(!mainDelegate.isOfflineMode){
                                        NSLog(@"Info:Locking correspondence");
                                        if([correspondence performCorrespondenceAction:@"LockCorrespondence"]){
                                            correspondence.ShowLocked=YES;
                                            //correspondence.LockedBy = [NSString stringWithFormat:@"%@ %@",mainDelegate.user.firstName,mainDelegate.user.lastName];
                                        }}
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if(!Break){
                                        NSLog(@"Info:Open Attachment.");
                                        [self performSelectorInBackground:@selector(openDocument:) withObject:[NSString stringWithFormat:@"%d",indexPath.row]];
                                    }
                                    Break=NO;
                                    
                                });
                            });
                        }
                        else {
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tasktable.locked",@"Task is locked")
                                                                            message:[NSString stringWithFormat:@"%@ %@",lockedby,NSLocalizedString(@"tasktable.locked.dialog",@"has locked the task.")]
                                                                           delegate:nil
                                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                                  otherButtonTitles:nil];
                            [alert show];
                            [SVProgressHUD dismiss];
                        }
                        }
                        else{
                            [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
                        }
                    });
                });
                
                
                
//            }
//            else{
//                [self performSelectorOnMainThread:@selector(increaseProgress) withObject:@"" waitUntilDone:YES];
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                    
//                    if(correspondence.attachmentsList.count == 0){
//                        
//                        NSData *attachmentXmlData;
//                        NSMutableArray *attachments;
//                        
//                        if(!mainDelegate.isOfflineMode){
//                            NSString* attachmentUrl;
//                            if(mainDelegate.SupportsServlets)
//                                attachmentUrl= [NSString stringWithFormat:@"http://%@?action=GetAttachments&token=%@&docId=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.Id,mainDelegate.IpadLanguage];
//                            else
//                                attachmentUrl= [NSString stringWithFormat:@"http://%@/GetAttachments?token=%@&docId=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.Id,mainDelegate.IpadLanguage];
//                            
//                            //                        NSURL *xmlUrl = [NSURL URLWithString:attachmentUrl];
//                            //                        attachmentXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
//                            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[attachmentUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
//                            attachmentXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//                            attachments=[CParser loadSpecifiqueAttachment:attachmentXmlData CorrespondenceId:correspondence.Id];
//                        }
//                        else{
//                            attachments=[CParser LoadAttachments:correspondence.Id];
//                        }
//                        
//                        
//                        [correspondence setAttachmentsList:attachments];
//                    }
//                    
//                    
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self performSelectorInBackground:@selector(openDocument:) withObject:[NSString stringWithFormat:@"%d",indexPath.row]];
//                        
//                        
//                    });
//                });
//                
//                
//            }
        }
        else{
            NSLog(@"Info: Clicked search button in Grid");
            mainDelegate.isBasketSelected = YES;
            [self performSelectorOnMainThread:@selector(increaseLoading) withObject:@"" waitUntilDone:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData * menuXmlData;
                
                NSMutableDictionary *correspondences;
                if(!mainDelegate.isOfflineMode){
                    NSString* correspondenceUrl;
                    NSString* showthumb;
                    if (mainDelegate.ShowThumbnail)
                        showthumb=@"true";
                    else
                        showthumb=@"false";
                    
                    if (![self.searchBar.text isEqualToString:@""]){
                        ACTIVE=true;
                    }
                    if ([self.searchBar.text isEqualToString:@""]&& ACTIVE){
                        ACTIVE=false;
                        [mainDelegate.searchModule.correspondenceList removeAllObjects];
                        mainDelegate.NbOfCorrToLoad=0;
                    }
                    NSLog(@"Info: preparing GetCorrespondence Request.");
                    if(mainDelegate.SupportsServlets)
                        correspondenceUrl=[NSString stringWithFormat:@"http://%@?action=GetCorrespondences&token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.selectedInbox,mainDelegate.NbOfCorrToLoad,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
                    else
                        correspondenceUrl=[NSString stringWithFormat:@"http://%@/GetCorrespondences?token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.selectedInbox,mainDelegate.NbOfCorrToLoad,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
                    
                    
                    if (![self.searchBar.text isEqualToString:@""]){
                        correspondenceUrl=[NSString stringWithFormat:@"%@&SearchCriteria=%@",correspondenceUrl,self.searchBar.text];
                    }
                    NSLog(@"URL=%@",correspondenceUrl);
                    //  NSURL *xmlUrl = [NSURL URLWithString:[correspondenceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    //  menuXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
                    
                    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[correspondenceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
                    menuXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                    correspondences=[CParser loadCorrespondencesWithData:menuXmlData];
                    
                }
                else{
                    correspondences=[CParser LoadCorrespondences:mainDelegate.selectedInbox];
                    
                }
                
                
                
                [mainDelegate.searchModule.correspondenceList addObjectsFromArray:[correspondences objectForKey:[NSString stringWithFormat:@"%ld",(long)mainDelegate.selectedInbox]]];
                
                
                //  [((CMenu*)mainDelegate.user.menu[mainDelegate.selectedInbox-1]).correspondenceList addObjectsFromArray:[correspondences objectForKey:[NSString stringWithFormat:@"%d",currentInbox.menuId]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!mainDelegate.isOfflineMode){
                        NSString *validationResultAction=[CParser ValidateWithData:menuXmlData];
                        
                        if(![validationResultAction isEqualToString:@"OK"])
                        {
                            NSLog(@"");
                            [self ShowMessage:validationResultAction];
                        }
                        else {
                            self.searchResult=mainDelegate.searchModule;
                            mainDelegate.NbOfCorrToLoad=mainDelegate.NbOfCorrToLoad+mainDelegate.SettingsCorrNb;
                        }
                    }
                    
                    [tableView reloadData];
                    [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];                });
            });
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error:Selection on GRid Error: %@",exception);
    }
    lastOrientation=[[UIApplication sharedApplication]statusBarOrientation];
}

- (void)increaseLoading{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loading ...") maskType:SVProgressHUDMaskTypeBlack];
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
- (void)openVoidDoc:(NSString*)documentId
{
	NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
	NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
	NSString *filePath = [pdfs lastObject]; assert(filePath != nil); // Path to last PDF file
    
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
	if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
	{
        ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document MenuId:100 CorrespondenceId:[documentId integerValue] AttachmentId:0];
        
        readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
        
        readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:readerViewController animated:YES completion:^{
            [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];}];
    }
    
    
}
-(void)openDocument:(NSString*)documentId{
    @try{
        NSLog(@"Info: Enter method openDocument.");
        CCorrespondence *correspondence=self.searchResult.correspondenceList[[documentId integerValue]];
        CAttachment *fileToOpen=correspondence.attachmentsList[0];
        mainDelegate.FolderName = fileToOpen.FolderName;
        mainDelegate.FolderId = fileToOpen.FolderId;

        NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:correspondence.Id fromSharepoint:mainDelegate.isSharepoint];
        NSLog(@"Info:local pdf location: %@",tempPdfLocation);
        if([tempPdfLocation isEqualToString:@""]){
            NSLog(@"Error: empty pdf location.");
            [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:NSLocalizedString(@"UnableToConnect", "unable to connect server") waitUntilDone:NO];
            return;
            
        }
        
        // NSString *tempPdfLocation=[CParser loadPdfFile:fileToOpen.url inDirectory:correspondence.Id];
        if ([ReaderDocument isPDF:tempPdfLocation] == NO) // File must exist
        {
            NSLog(@"Error: document in not pdf.");
            [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Warning")
                                                            message:NSLocalizedString(@"Alert.Extension",@"Document extension not supported.")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK",@"OK")
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
        else{
            NSLog(@"Info:openning document.");
            ReaderDocument *document=[self OpenPdfReader:tempPdfLocation];
            
            if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
            {
                mainDelegate.EmptyDoc=NO;
                ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document MenuId:100 CorrespondenceId:[documentId integerValue] AttachmentId:0];
                
                readerViewController.delegate = self; // Set the ReaderViewController delegate to self
                
                
                readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                
                [self presentViewController:readerViewController animated:YES completion:^{
                    [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
                    
                }];
                
            }
        }
    }
    @catch (NSException *ex) {
        // mainDelegate.EmptyDoc=YES;
        
        // [self openVoidDoc:documentId];
        //        NSLog(@"%d",[ex reason].length);
        //        NSRange prefixRange = [[ex reason] rangeOfString:@"]:"];
        //        NSRange needleRange = NSMakeRange(prefixRange.location+@"]:".length, [ex reason].length-1);
        //        [self ShowMessage:[NSString stringWithFormat:@"unable to open Document,Reason:%@",	[[ex reason] substringWithRange:needleRange]]];
        NSLog(@"Error: Error occured in SearchResultViewController Class in method OpenDocument.\n Exception Name:%@ Exception Reason: %@",[ex name],[ex reason]);
    }
    @finally {
        [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
    }
}

-(ReaderDocument*) OpenPdfReader:(NSString *) pdfPath{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    NSString *filePath = pdfPath;// [pdfs lastObject];
    assert(filePath != nil); // Path to last PDF file
    
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
    return document;
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
        NSLog(@"Error: Error occured in SearchResultViewController Class in method deleteCachedFiles.\n Exception Name:%@ Exception Reason: %@",[ex name],[ex reason]);

    }
}


- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
    self.tableView.tableHeaderView = nil;
    UINavigationController *navController=[mainDelegate.splitViewController.viewControllers objectAtIndex:1];
    [navController setNavigationBarHidden:YES animated:YES];
    SearchResultViewController *searchResultViewController = [[SearchResultViewController alloc]initWithStyle:UITableViewStylePlain];
    mainDelegate.searchResultViewController=searchResultViewController;
    [navController pushViewController:searchResultViewController animated:YES];
    NSFileManager* fileManager=[NSFileManager defaultManager];
    
    [self checkOrientation];
    for(NSString* path in mainDelegate.DocumentsPath){
        if ( [[NSFileManager defaultManager] isReadableFileAtPath:path] ){
            [fileManager removeItemAtPath:path error:nil];
            
            
        }
    }
    [mainDelegate.DocumentsPath removeAllObjects];
    
}

-(void) checkOrientation
{
    UIInterfaceOrientation orientation=[[ UIApplication sharedApplication]statusBarOrientation];
    
    //
    if ( [mainDelegate.IpadLanguage isEqualToString:@"en"] && UIInterfaceOrientationIsPortrait(orientation) && orientation!=lastOrientation) {
        
        mainDelegate.barView.frame=CGRectMake(200, 0, 560, 45);
    }
    
    //
    if ([mainDelegate.IpadLanguage isEqualToString:@"ar"] && UIInterfaceOrientationIsLandscape(orientation)&& orientation!=lastOrientation) {
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            mainDelegate.logoView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width+20, 5, 200, 100);
        }
        else
        {
            mainDelegate.logoView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-220, 5, 200, 100);
        }
    }
    //
    if (UIInterfaceOrientationIsPortrait(orientation) && [mainDelegate.IpadLanguage isEqualToString:@"ar"] && orientation!=lastOrientation) {
        for (UIView *view in mainDelegate.barView.subviews) {
            if ([view isKindOfClass:[UIButton class]] && view.tag==1) {
                view.frame=CGRectMake(233, 8, 265, 20);
            }
            
        }
        mainDelegate.logoView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-200, 5, 200, 100);
        
        [mainDelegate.barView setNeedsLayout];
        mainDelegate.logoView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-200, 5, 200, 100);
    }
    
//    if (UIInterfaceOrientationIsLandscape(orientation) && [mainDelegate.IpadLanguage isEqualToString:@"en"] && orientation!=lastOrientation) {
//        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
//           mainDelegate.barView.frame=CGRectMake(460, 0, 500, 45);
//        }
//        else
//       mainDelegate.barView.frame=CGRectMake(450, 0, 555 , 45);
//    }

}
-(void)dismissPopUp:(UITableViewController*)viewcontroller{
    [self.notePopController dismissPopoverAnimated:NO];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (BOOL)splitViewController: (UISplitViewController*)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    if(UIInterfaceOrientationIsLandscape(orientation))
        return NO;
    else return YES;
}


- (void)increaseProgress{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loading ...") maskType:SVProgressHUDMaskTypeBlack];
    
    
}
- (void)dismiss {
	[SVProgressHUD dismiss];
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

@end
