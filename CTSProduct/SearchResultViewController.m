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
@interface SearchResultViewController ()
@end

@implementation SearchResultViewController{
    AppDelegate *mainDelegate ;
    BOOL sync;
}
@synthesize toolbar=_toolbar;
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
    
    sync=NO;
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.attachmentSelected =0;
    mainDelegate.NbOfCorrToLoad=mainDelegate.SettingsCorrNb;

    _toolbar = [[UIToolbar alloc] init];
    _toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width+90, 45);
    CGFloat red = 88.0f / 255.0f;
    CGFloat green = 96.0f / 255.0f;
    CGFloat blue = 104.0f / 255.0f;
    _toolbar.layer.borderWidth = 2;
    _toolbar.layer.borderColor = [[UIColor colorWithRed:red green:green blue:blue alpha:1.0]CGColor];
    
    _toolbar.barTintColor = [UIColor blackColor];
//    UILabel *userlabel =[[UILabel alloc] initWithFrame:CGRectMake(100, 20, 100, 44)];
//    userlabel.text = [NSString stringWithFormat:@"%@ %@",mainDelegate.user.firstName,mainDelegate.user.lastName];
//    userlabel.frame = CGRectMake(10, 0, 335, 60);
//    userlabel.textColor = [UIColor whiteColor];
//    userlabel.shadowColor = [UIColor colorWithRed:0.0f / 255.0f green:155.0f / 255.0f blue:213.0f / 255.0f alpha:1.0];
//    userlabel.font =[UIFont fontWithName:@"Helvetica" size:20.0f];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 0, _toolbar.frame.size.width-250, 60);

    [btn addTarget:self action:@selector(dropdown) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:[NSString stringWithFormat:@"%@ %@",mainDelegate.user.firstName,mainDelegate.user.lastName] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    btn.titleLabel.shadowColor= [UIColor colorWithRed:0.0f / 255.0f green:155.0f / 255.0f blue:213.0f / 255.0f alpha:1.0];
    btn.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:20.0f];
    btn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];

    
   // UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  //  separator.width = 190;
    UIButton *btnSettings;
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
        btnSettings=[[UIButton alloc]initWithFrame:CGRectMake(47, 62, 37, 37)];
    else
        btnSettings=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-157, 42, 37, 37)];
    [btnSettings setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"settings.png"]]forState:UIControlStateNormal];
    [btnSettings addTarget:self action:@selector(OpenSettingsPage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemsettings = [[UIBarButtonItem alloc] initWithCustomView:btnSettings];

    
    UIButton *btnLogout;
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
        btnLogout=[[UIButton alloc]initWithFrame:CGRectMake(10, 62, 37, 37)];
    else
        btnLogout=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-120, 62, 37, 37)];
    [btnLogout setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"Logout.png"]]forState:UIControlStateNormal];
    [btnLogout addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemlogout = [[UIBarButtonItem alloc] initWithCustomView:btnLogout];
    
    
    UIButton *btndownload;
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
        btndownload=[[UIButton alloc]initWithFrame:CGRectMake(10, 62, 37, 50)];
    else
        btndownload=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-120, 62, 37, 50)];
    [btndownload setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"save.png"]]forState:UIControlStateNormal];
    [btndownload addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemdownload = [[UIBarButtonItem alloc] initWithCustomView:btndownload];
    
  
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
        _toolbar.items = [NSArray arrayWithObjects:itemlogout,itemsettings,itemdownload,item, nil];
    else
        _toolbar.items = [NSArray arrayWithObjects:item,itemdownload,itemsettings,itemlogout, nil];

    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar addSubview:_toolbar];
    self.tableView.backgroundColor = [UIColor colorWithRed:29.0f / 255.0f green:29.0f / 255.0f blue:29.0f / 255.0f alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithRed:45.0f/255.0f green:45.0f/255.0f blue:45.0f/255.0f alpha:1.0];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"searchResultCell"];
    [self.tableView setContentInset:UIEdgeInsetsMake(0,0,0,0)];

    self.searchResult=mainDelegate.searchModule;
    self.navigationItem.leftBarButtonItem=nil;
    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden=YES;
    [self SyncActions];
    
    
    NSMutableArray* REmenuitems=[[NSMutableArray alloc]init];
    for(UserDetail * obj in mainDelegate.user.UserDetails){
        REMenuItem *Item = [[REMenuItem alloc] initWithTitle:obj.title
                                                        subtitle:obj.detail
                                                           image:[UIImage imageNamed:@"Icon_Home"]
                                                highlightedImage:nil
                                                          action:^(REMenuItem *item) {
                                                              NSLog(@"Item: %@", item);
                                                          }];
        [REmenuitems addObject:Item];
    }
   
    
    self.menu = [[REMenu alloc] initWithItems:REmenuitems];
    if (!REUIKitIsFlatMode()) {
        self.menu.cornerRadius = 4;
        self.menu.shadowRadius = 4;
        self.menu.shadowColor = [UIColor blackColor];
        self.menu.shadowOffset = CGSizeMake(0, 1);
        self.menu.shadowOpacity = 1;
    }
    
    self.menu.separatorOffset = CGSizeMake(15.0, 0.0);
    self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:200/255.0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
    
    
    [self.menu setClosePreparationBlock:^{
        NSLog(@"Menu will close");
    }];
    
    [self.menu setCloseCompletionHandler:^{
        NSLog(@"Menu did close");
    }];

    
    
    
}

-(void)dropdown{
    if (self.menu.isOpen)
        return [self.menu close];
     UINavigationController *navController=[mainDelegate.splitViewController.viewControllers objectAtIndex:1];
    [self.menu showFromNavigationController:navController];
}

-(void)download{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Downloading",@"Downloading ...") maskType:SVProgressHUDMaskTypeBlack];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      
    NSString* url;
    if(mainDelegate.SupportsServlets)
        url=[NSString stringWithFormat:@"http://%@?action=DownloadAll",mainDelegate.serverUrl];
    else
        url=[NSString stringWithFormat:@"http://%@/DownloadAll",mainDelegate.serverUrl];
    
    NSURL *xmlUrl = [NSURL URLWithString:url];
    NSData * menuXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
    [CParser Download:menuXmlData];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
        });
    });
    
    
    

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)OpenSettingsPage{
    UINavigationController *navController=[mainDelegate.splitViewController.viewControllers objectAtIndex:1];
    [navController setNavigationBarHidden:YES animated:YES];
    UIStoryboard *    storyboard=[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    SettingsViewController *SettingsView=[[SettingsViewController alloc] init];
    SettingsView= [storyboard instantiateViewControllerWithIdentifier:@"Settings"];

    [navController pushViewController:SettingsView animated:YES];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(mainDelegate.SearchActive==NO){
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
    if(indexPath.row == mainDelegate.NbOfCorrToLoad)
        return 50;
    return 125;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    TableResultCell *cell ;
    if (indexPath.row != mainDelegate.NbOfCorrToLoad || mainDelegate.SearchActive ){
        
        cell = [[TableResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        CCorrespondence *correspondence=self.searchResult.correspondenceList[indexPath.row];
        for (id key in correspondence.systemProperties) {
            
            NSDictionary *subDictionary = [correspondence.systemProperties objectForKey:key];
            NSArray *keys=[subDictionary allKeys];
            NSString *value = [subDictionary objectForKey:[keys objectAtIndex:0]];
            if([[keys objectAtIndex:0] isEqualToString:@"Sender"])
            {
                cell.label2.text=[NSString stringWithFormat:@"%@: %@",[keys objectAtIndex:0],value];
                
            }else if([[keys objectAtIndex:0] isEqualToString:@"Subject"])
            {
                cell.label1.text=[NSString stringWithFormat:@"%@: %@",[keys objectAtIndex:0],value];
            }else if([[keys objectAtIndex:0] isEqualToString:@"Reference Number"])
            {
                cell.label3.text=[NSString stringWithFormat:@"%@: %@",[keys objectAtIndex:0],value];
            }
            else if([[keys objectAtIndex:0] isEqualToString:@"Date"])
            {
                cell.label4.text=[NSString stringWithFormat:@"%@: %@",[keys objectAtIndex:0],value];
            }
        }
        
        UIImage *image;
        
        if(![correspondence.ThumnailUrl isEqualToString:@""]){
            image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:correspondence.ThumnailUrl]]];
            if(image==nil)
                image =[UIImage imageNamed:@"file.png"];

        }
        else{
            image =[UIImage imageNamed:@"file.png"];
        }
        
        [cell.imageView setImage:image];
        
        
        if(indexPath.row % 2 ==0){
            CGFloat red = 53.0f / 255.0f;
            CGFloat green = 53.0f / 255.0f;
            CGFloat blue = 53.0f / 255.0f;
            
            cell.backgroundColor =[UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        }

            if(correspondence.ShowLocked){
                [cell showLockButton:@"cts_Lock.png" tag:indexPath.row lock:correspondence.ShowLocked priority:correspondence.Priority new:correspondence.New];
            }
            else{
                [cell showLockButton:@"cts_Unlock.png" tag:indexPath.row lock:correspondence.ShowLocked priority:correspondence.Priority new:correspondence.New];
            }
            [cell.LockButton addTarget:self action:@selector(performAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell showNew:correspondence.ShowLocked priority:correspondence.Priority new:correspondence.New];
            [cell showPriority:correspondence.Priority];

        
    }
    else{
        if(indexPath.row == mainDelegate.NbOfCorrToLoad) {
            if (cell == nil) {
                cell = [[TableResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            [cell loadmore];
            cell.backgroundColor =[UIColor whiteColor];
            
            
        }
    }
    
    return cell;
}

-(void)performAction:(id)sender{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    
    CCorrespondence *correspondence=self.searchResult.correspondenceList[indexPath.row];
    
    NSString* searchUrl;
    if(mainDelegate.SupportsServlets)
        searchUrl = [NSString stringWithFormat:@"http://%@?action=IsLockedCorrespondence&token=%@&transferId=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.TransferId];
    else
        searchUrl = [NSString stringWithFormat:@"http://%@/IsLockedCorrespondence?token=%@&transferId=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.TransferId];
    NSMutableDictionary* LockResult=[CParser IsLockedCorrespondence:searchUrl];
    NSString* lockedby=[LockResult objectForKey:@"lockedby"];
    BOOL IsLocked=[[LockResult objectForKey:@"IsLocked"]boolValue];
    
    if([lockedby isEqualToString:[NSString stringWithFormat:@"%@ %@",mainDelegate.user.firstName,mainDelegate.user.lastName]] || !IsLocked){
        
        if(correspondence.ShowLocked){
            if([correspondence performCorrespondenceAction:@"UnlockCorrespondence"]){
                correspondence.ShowLocked=NO;
                [sender setImage:[UIImage imageNamed:@"cts_Unlock.png"] forState:UIControlStateNormal];
            }
        }else{
            if([correspondence performCorrespondenceAction:@"LockCorrespondence"]){
                correspondence.ShowLocked=YES;
                mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
              //  correspondence.LockedBy = [NSString stringWithFormat:@"%@ %@",mainDelegate.user.firstName,mainDelegate.user.lastName];
                [sender setImage:[UIImage imageNamed:@"cts_Lock.png"] forState:UIControlStateNormal];
            }
            
        }
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tasktable.locked",@"Task is locked")
                                                        message:[NSString stringWithFormat:@"%@ %@",lockedby,NSLocalizedString(@"tasktable.locked.dialog",@"has locked the task.")]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
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
    [mainDelegate.Highlights removeAllObjects];
    [mainDelegate.Notes removeAllObjects];
    if(indexPath.row != mainDelegate.NbOfCorrToLoad) {
        
        mainDelegate.searchSelected = indexPath.row;
        CCorrespondence *correspondence=self.searchResult.correspondenceList[indexPath.row];

        if(mainDelegate.isBasketSelected){
            
            // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSString* lockedby;
            NSString* lockedbyUserId;
            BOOL IsLocked;
            if(!mainDelegate.isOfflineMode){
                NSString* searchUrl;
                if(mainDelegate.SupportsServlets)
                    searchUrl = [NSString stringWithFormat:@"http://%@?action=IsLockedCorrespondence&token=%@&transferId=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.TransferId];
                else
                    searchUrl = [NSString stringWithFormat:@"http://%@/IsLockedCorrespondence?token=%@&transferId=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.TransferId];

                NSMutableDictionary* LockResult=[CParser IsLockedCorrespondence:searchUrl];
                lockedby=[LockResult objectForKey:@"lockedby"];
                IsLocked=[[LockResult objectForKey:@"IsLocked"]boolValue];
                lockedbyUserId=[LockResult objectForKey:@"UserId"];
                correspondence.ShowLocked=IsLocked;
                [tableView reloadData];
            }
            else{
                IsLocked=NO;
            }
            if([lockedbyUserId isEqualToString:mainDelegate.user.userId] || !IsLocked){
                [self performSelectorOnMainThread:@selector(increaseProgress) withObject:@"" waitUntilDone:YES];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    
                    if(correspondence.attachmentsList == nil){
                        NSData *attachmentXmlData;
                        NSMutableArray *attachments;
                        if(!mainDelegate.isOfflineMode){
                            NSString* attachmentUrl;
                            if(mainDelegate.SupportsServlets)
                                attachmentUrl= [NSString stringWithFormat:@"http://%@?action=GetAttachments&token=%@&docId=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.Id];
                            else
                                attachmentUrl= [NSString stringWithFormat:@"http://%@/GetAttachments?token=%@&docId=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.Id];
                        
                        NSURL *xmlUrl = [NSURL URLWithString:attachmentUrl];
                        attachmentXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
                            attachments=[CParser loadSpecifiqueAttachment:attachmentXmlData CorrespondenceId:correspondence.Id];
                        }
                        else{
                            attachments=[CParser LoadAttachments:correspondence.Id];
                        }
                       
                        
                        [correspondence setAttachmentsList:attachments];
                    }
                    
                    
                    if(!mainDelegate.isOfflineMode){

                    if([correspondence performCorrespondenceAction:@"LockCorrespondence"]){
                        correspondence.ShowLocked=YES;
                        //correspondence.LockedBy = [NSString stringWithFormat:@"%@ %@",mainDelegate.user.firstName,mainDelegate.user.lastName];
                    }}
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performSelectorInBackground:@selector(openDocument:) withObject:[NSString stringWithFormat:@"%d",indexPath.row]];
                        
                    });
                });
                
                
            }
            else {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tasktable.locked",@"Task is locked")
                                                                message:[NSString stringWithFormat:@"%@ %@",lockedby,NSLocalizedString(@"tasktable.locked.dialog",@"has locked the task.")]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
        else{
            [self performSelectorOnMainThread:@selector(increaseProgress) withObject:@"" waitUntilDone:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                if(correspondence.attachmentsList.count == 0){
                    
                    NSData *attachmentXmlData;
                    NSMutableArray *attachments;

                    if(!mainDelegate.isOfflineMode){
                        NSString* attachmentUrl;
                        if(mainDelegate.SupportsServlets)
                            attachmentUrl= [NSString stringWithFormat:@"http://%@?action=GetAttachments&token=%@&docId=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.Id];
                        else
                            attachmentUrl= [NSString stringWithFormat:@"http://%@/GetAttachments?token=%@&docId=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.Id];
                        
                        NSURL *xmlUrl = [NSURL URLWithString:attachmentUrl];
                        attachmentXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
                        attachments=[CParser loadSpecifiqueAttachment:attachmentXmlData CorrespondenceId:correspondence.Id];
                    }
                    else{
                        attachments=[CParser LoadAttachments:correspondence.Id];
                    }
                    
                    
                    [correspondence setAttachmentsList:attachments];
                }
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSelectorInBackground:@selector(openDocument:) withObject:[NSString stringWithFormat:@"%d",indexPath.row]];
                    
                    
                });
            });
            
            
        }
    }
    else{
        
        mainDelegate.isBasketSelected = YES;
        [NSThread detachNewThreadSelector:@selector(increaseLoading) toTarget:self withObject:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSMutableDictionary *correspondences;
            if(!mainDelegate.isOfflineMode){
                NSString* correspondenceUrl;
                NSString* showthumb;
                if (mainDelegate.ShowThumbnail)
                    showthumb=@"true";
                else
                    showthumb=@"false";
                if(mainDelegate.SupportsServlets)
                    correspondenceUrl=[NSString stringWithFormat:@"http://%@?action=GetCorrespondences&token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.selectedInbox,mainDelegate.NbOfCorrToLoad,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
                else
                    correspondenceUrl=[NSString stringWithFormat:@"http://%@/GetCorrespondences?token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.selectedInbox,mainDelegate.NbOfCorrToLoad,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
               
                NSURL *xmlUrl = [NSURL URLWithString:correspondenceUrl];
                NSData * menuXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
                correspondences=[CParser loadCorrespondencesWithData:menuXmlData];

            }
            else{
                correspondences=[CParser LoadCorrespondences:mainDelegate.selectedInbox];

            }
            
            
            
           [mainDelegate.searchModule.correspondenceList addObjectsFromArray:[correspondences objectForKey:[NSString stringWithFormat:@"%ld",(long)mainDelegate.selectedInbox]]];
            
            
          //  [((CMenu*)mainDelegate.user.menu[mainDelegate.selectedInbox-1]).correspondenceList addObjectsFromArray:[correspondences objectForKey:[NSString stringWithFormat:@"%d",currentInbox.menuId]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.searchResult=mainDelegate.searchModule;
                mainDelegate.NbOfCorrToLoad=mainDelegate.NbOfCorrToLoad+mainDelegate.SettingsCorrNb;
                [tableView reloadData];
                [NSThread detachNewThreadSelector:@selector(dismiss) toTarget:self withObject:nil];
            });
        });
        
    }
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
-(void)openDocument:(NSString*)documentId{
    @try{
        CCorrespondence *correspondence=self.searchResult.correspondenceList[[documentId integerValue]];
        CAttachment *fileToOpen=correspondence.attachmentsList[0];
        mainDelegate.FolderName = fileToOpen.FolderName;
        NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:correspondence.Id fromSharepoint:mainDelegate.isSharepoint];
        
        // NSString *tempPdfLocation=[CParser loadPdfFile:fileToOpen.url inDirectory:correspondence.Id];
        if ([ReaderDocument isPDF:tempPdfLocation] == NO) // File must exist
        {
            [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Warning")
                                                            message:NSLocalizedString(@"Alert.Extension",@"Document extension not supported.")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK",@"OK")
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
        else{
            ReaderDocument *document=[self OpenPdfReader:tempPdfLocation];
            
            if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
            {
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
        [FileManager appendToLogView:@"SearchResultViewController" function:@"openDocument" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
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
        [FileManager appendToLogView:@"NorecordsViewController" function:@"deleteCachedFiles" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
}

-(void)logout{
    NSString* message;
    message=NSLocalizedString(@"root.disconnectdialog",@"Do you really want to disconnect ?");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"root.disconnect",@"Sign out")
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"root.disconnect.NO",@"Stay Connected" )
                                          otherButtonTitles:NSLocalizedString(@"root.disconnect.YES",@"Sign Out" ),nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if(sync==YES){
            //sync
            sync=NO;
            
            NSMutableArray * offlineActions=[CParser LoadOfflineActions];
            NSMutableArray* builtinActions=[CParser LoadBuiltInActions];
            ReaderViewController* methodCall=[[ReaderViewController alloc]init];
            [self performSelectorOnMainThread:@selector(increaseProgress) withObject:@"" waitUntilDone:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                for(OfflineAction* action in offlineActions){
                    NSURL *xmlUrl = [NSURL URLWithString:action.Url];
                    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
                    NSString *validationResultAction=[CParser ValidateWithData:xmlData];
                    
                    if(![validationResultAction isEqualToString:@"OK"])
                    {
                            [self ShowMessage:validationResultAction];
                    }
                    else {
                    }
                }
                for(BuiltInActions* act in builtinActions){
                    [methodCall uploadXml:act.Id];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [CParser DeleteOfflineActions:@"OfflineActions"];
                    [CParser DeleteOfflineActions:@"BuiltInActions"];

                });
            });

            
        }
        else{
            //cancel clicked ...do your action
        }
        
    }
    else if (buttonIndex == 1)
    {
        if(sync==YES){
            //Discard
            [CParser DeleteOfflineActions:@"OfflineActions"];
            sync=NO;

        }else{
            mainDelegate.searchModule=nil;
            mainDelegate.user=nil;
            mainDelegate.NbOfCorrToLoad=0;
            mainDelegate.InboxTotalCorr=0;
            [self deleteCachedFiles];
            self.navigationItem.rightBarButtonItem.enabled = NO;
            AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
            delegate.user=nil;
            delegate.searchModule=nil;
            delegate.selectedInbox=0;
            UIStoryboard *    storyboard=[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            LoginViewController *loginView=[[LoginViewController alloc]init];
            loginView= [storyboard instantiateViewControllerWithIdentifier:@"LOGIN"];
            [self.navigationController presentViewController:loginView animated:YES completion:nil];
    
        }
    }
}
-(void)SyncActions{
    if(!mainDelegate.isOfflineMode && ([CParser EntitySize:@"OfflineActions"]>0||[CParser EntitySize:@"BuiltInActions"]>0)){
        sync=YES;
        NSString* message;
        message=NSLocalizedString(@"Actions made in offline mode detected!",@"Actions made in offline mode detected");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Synchronization",@"Synchronization")
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Sync",@"Sync" )
                                              otherButtonTitles:NSLocalizedString(@"Discard Actions",@"Discard Actions" ),nil];
        [alert show];
        
    }
}
- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
    UINavigationController *navController=[mainDelegate.splitViewController.viewControllers objectAtIndex:1];
    [navController setNavigationBarHidden:YES animated:YES];
    SearchResultViewController *searchResultViewController = [[SearchResultViewController alloc]initWithStyle:UITableViewStylePlain];
        [navController pushViewController:searchResultViewController animated:YES];
   }



/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

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

@end
