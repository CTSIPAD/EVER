//
//  MainMenuViewController.m
//  CTSTest
//
//  Created by DNA on 12/11/13.
//  Copyright (c) 2013 LBI. All rights reserved.
//
#import "mach/mach.h"
#import "MainMenuViewController.h"
#import "AppDelegate.h"
#import "CUser.h"
#import "CMenu.h"
#import "CSearch.h"
#import "CParser.h"
#import "SignatureViewController.h"
#import "SimpleSearchViewController.h"
#import "GDataXMLNode.h"
#import "SignatureViewController.h"
#import "NorecordsViewController.h"
#import "SearchResultViewController.h"
#import "NSData+Base64.h"
#import "FileManager.h"
#import "SVProgressHUD.h"
#import "REMenu.h"
@interface MainMenuViewController ()
{
    AppDelegate* mainDelegate;
    NSInteger menuItemsCount;
    NSInteger totalMenuItemsCount;
    BOOL canFound;
    
}
@end

@implementation MainMenuViewController

#pragma mark Constants
#define ICON_HEIGHT 68
#define ICON_WIDTH 68
#define TITLE_HEIGHT 30



- (void)viewDidLoad
{
    [super viewDidLoad];
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.navigationController setNavigationBarHidden:TRUE];
    
    CGFloat redsep = 88.0f / 255.0f;
    CGFloat greensep = 96.0f / 255.0f;
    CGFloat bluesep = 104.0f / 255.0f;
    self.tableView.opaque=NO;
    
    [self.tableView setSeparatorColor:[UIColor colorWithRed:redsep green:greensep blue:bluesep alpha:1.0]];
    self.tableView.backgroundColor =[UIColor colorWithRed:redsep green:greensep blue:bluesep alpha:1.0];
    
    
    
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    menuItemsCount=mainDelegate.user.menu.count;
    totalMenuItemsCount=menuItemsCount+2;//logo+search
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    //self.tableView.backgroundColor = [UIColor blackColor];
    
    self.tableView.layer.borderWidth=2;
    self.tableView.layer.borderColor=[[UIColor colorWithRed:redsep green:greensep blue:bluesep alpha:1.0]CGColor];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    if(mainDelegate.inboxForArchiveSelected!=0)
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:mainDelegate.inboxForArchiveSelected inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return totalMenuItemsCount;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(menuItemsCount>4)
        return (764-20)/6;
    else{
        if(indexPath.section==0)//logo
            return (764-20)/6;
        else  return 764/totalMenuItemsCount;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((cell.frame.size.width-ICON_WIDTH)/2, (cell.frame.size.height-ICON_HEIGHT-30)/2, ICON_WIDTH, ICON_HEIGHT) ];
    UILabel *labelText =[[UILabel alloc] initWithFrame:CGRectMake(10, imageView.frame.size.height+imageView.frame.origin.y+5, cell.frame.size.width-20, TITLE_HEIGHT)];
    labelText.textAlignment=  NSTextAlignmentCenter;
    labelText.textColor=[UIColor whiteColor];
    labelText.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    labelText.layer.shadowOpacity = 0.6;
    labelText.layer.shadowRadius = 2.0;
    labelText.layer.shadowColor = [UIColor blackColor].CGColor;
    labelText.layer.shadowOffset = CGSizeMake(4.0, 2.0);
    labelText.lineBreakMode = NSLineBreakByWordWrapping;
    labelText.numberOfLines = 0;
    UIView *bgColorView = [[UIView alloc] init];
    
    
    NSInteger rowsNumber=totalMenuItemsCount;
    if(indexPath.row==0){//logo
        
        CGFloat redview = 88.0f / 255.0f;
        CGFloat greenview = 96.0f / 255.0f;
        CGFloat blueview = 104.0f / 255.0f;
        UIView *bl = [[UIView alloc] initWithFrame:CGRectMake(5, 5, self.tableView.frame.size.width-10, 114)];
        UIImage *Logo = [UIImage imageWithData:mainDelegate.logo];
        bl.backgroundColor = [UIColor colorWithRed:redview green:greenview blue:blueview alpha:1.0];
        bl.layer.contents = (id)Logo.CGImage;
        cell.backgroundColor = [UIColor blackColor];
        [cell.contentView addSubview:bl];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        
        
    }
    else
        if(indexPath.row==rowsNumber-1){//search
            imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"cts_Search.png"]];
            labelText.text=NSLocalizedString(@"Search",@"Search");
            CGFloat red = 88.0f / 255.0f;
            CGFloat green = 96.0f / 255.0f;
            CGFloat blue = 104.0f / 255.0f;
            cell.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
            
        }
        else {
            CGFloat red = 88.0f / 255.0f;
            CGFloat green = 96.0f / 255.0f;
            CGFloat blue = 104.0f / 255.0f;
            cell.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
            if(indexPath.row == 3){
                NSData * data= [NSData dataWithBase64EncodedString:((CMenu*)mainDelegate.user.menu[indexPath.row-1]).icon];
                UIImage *cellImage = [UIImage imageWithData:data];
                [imageView setImage:cellImage];
                //imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"cts_Inbound.png"]];
            }
            else
                if(indexPath.row==2){
                    NSData * data= [NSData dataWithBase64EncodedString:((CMenu*)mainDelegate.user.menu[indexPath.row-1]).icon];
                    UIImage *cellImage = [UIImage imageWithData:data];
                    [imageView setImage:cellImage];
                    
                }
                else{
                    
                    NSData * data= [NSData dataWithBase64EncodedString:((CMenu*)mainDelegate.user.menu[indexPath.row-1]).icon];
                    UIImage *cellImage = [UIImage imageWithData:data];
                    [imageView setImage:cellImage];
                    
                }
            labelText.text=((CMenu*)mainDelegate.user.menu[indexPath.row-1]).name;
            
            
        }
    
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:labelText];
    bgColorView.backgroundColor = [UIColor colorWithRed:0.0f / 255.0f green:155.0f / 255.0f blue:213.0f / 255.0f alpha:1.0];//blue
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    @try{
        
        UINavigationController *navController=[mainDelegate.splitViewController.viewControllers objectAtIndex:1];
        [navController setNavigationBarHidden:YES animated:YES];
        
        if(indexPath.row!=0){
            /***** search button *****/
            if(indexPath.row==totalMenuItemsCount-1){
                mainDelegate.selectedInbox=4;
                if(mainDelegate.searchModule ==nil){
                    NSString* searchUrl;
                    if(mainDelegate.SupportsServlets)
                        searchUrl = [NSString stringWithFormat:@"http://%@?action=BuildAdvancedSearch&token=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage];
                    else
                        searchUrl = [NSString stringWithFormat:@"http://%@/BuildAdvancedSearch?token=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage];
                    NSURL *xmlUrl = [NSURL URLWithString:searchUrl];
                    NSData *searchXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
                    
                    NSString *validationResult=[CParser ValidateWithData:searchXmlData];
                    if(![validationResult isEqualToString:@"OK"]){
                        [self ShowMessage:validationResult];
                    }
                    else{
                        
                        
                        mainDelegate.searchModule=[CParser loadSearchWithData:searchXmlData];
                    }
                    
                }
                
                SimpleSearchViewController *simpleSearchView=[[SimpleSearchViewController alloc] init];
                [navController pushViewController:simpleSearchView animated:YES];
                
            }
            /*****end search button *****/
            
            else{
                
                
                mainDelegate.isBasketSelected = YES;
                CMenu* currentInbox=((CMenu*)mainDelegate.user.menu[indexPath.row-1]);
                
                mainDelegate.inboxForArchiveSelected = indexPath.row-1;
                
                //                if(mainDelegate.isOfflineMode){
                //                    canFound=NO;
                //                    [self ShowMessage:NSLocalizedString(@"Alert.NoTask",@"No Tasks Found")];
                //
                //                }
                //                else{
                //[NSThread detachNewThreadSelector:@selector(increaseLoading) toTarget:self withObject:nil];
                [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loading ...") maskType:SVProgressHUDMaskTypeBlack];
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
                            correspondenceUrl = [NSString stringWithFormat:@"http://%@?action=GetCorrespondences&token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,currentInbox.menuId,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
                        else
                            correspondenceUrl = [NSString stringWithFormat:@"http://%@/GetCorrespondences?token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,currentInbox.menuId,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
                        NSURL *xmlUrl = [NSURL URLWithString:correspondenceUrl];
                        NSData *menuXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
                        correspondences=[CParser loadCorrespondencesWithData:menuXmlData];
                    }
                    else{
                        correspondences=[CParser LoadCorrespondences:currentInbox.menuId];
                    }
                    
                    
                    if(!mainDelegate.isOfflineMode){
                        
                        if(mainDelegate.searchModule ==nil){
                            
                            
                            NSString* searchUrl;
                            if(mainDelegate.SupportsServlets)
                                searchUrl= [NSString stringWithFormat:@"http://%@?action=BuildAdvancedSearch&token=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage];
                            else
                                searchUrl= [NSString stringWithFormat:@"http://%@/BuildAdvancedSearch?token=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage];
                            NSURL *xmlUrl = [NSURL URLWithString:searchUrl];
                            NSData *searchXmlData;
                            if(!mainDelegate.isOfflineMode){
                                searchXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
                                
                                NSString *validationResult=[CParser ValidateWithData:searchXmlData];
                                if(![validationResult isEqualToString:@"OK"]){
                                    [self ShowMessage:validationResult];
                                }
                                else{
                                    
                                    [CParser cacheXml:@"Search" xml:searchXmlData nb:@"0" name:@""];
                                    mainDelegate.searchModule=[CParser loadSearchWithData:searchXmlData];
                                }
                            }else{
                                searchXmlData=[CParser LoadXML:@"Search" nb:@"0" name:@""];
                                mainDelegate.searchModule=[CParser loadSearchWithData:searchXmlData];
                                
                            }
                        }
                    }else{
                        mainDelegate.searchModule=[[CSearch alloc]init];
                    }
                    // mainDelegate.searchModule.correspondenceList = [CParser loadSearchCorrespondencesWithData:menuXmlData];
                    
                    mainDelegate.searchModule.correspondenceList = [correspondences objectForKey:[NSString stringWithFormat:@"%ld",(long)currentInbox.menuId]];
                    
                    
                    
                    ((CMenu*)mainDelegate.user.menu[indexPath.row-1]).correspondenceList=[correspondences objectForKey:[NSString stringWithFormat:@"%d",currentInbox.menuId]];
                    
                    
                    
                    if(((CMenu*)mainDelegate.user.menu[indexPath.row-1]).correspondenceList.count ==0){
                        canFound=NO;
                        NorecordsViewController *norecordsView=[[NorecordsViewController alloc] init];
                        [navController pushViewController:norecordsView animated:YES];
                        mainDelegate.selectedInbox=((CMenu*)mainDelegate.user.menu[tableView.indexPathForSelectedRow.row-1]).menuId;
                        
                        //   [self ShowMessage:[correspondences objectForKey:@"error"]];
                        
                    }
                    else{
                        canFound=YES;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(canFound){
                            mainDelegate.selectedInbox=((CMenu*)mainDelegate.user.menu[indexPath.row-1]).menuId;
                            SearchResultViewController *searchResultViewController = [[SearchResultViewController alloc]initWithStyle:UITableViewStylePlain];
                            
                            mainDelegate.menuSelectedItem=indexPath.row-1;
                            [navController pushViewController:searchResultViewController animated:YES];
                            
                        }
                        else{
                            
                            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:mainDelegate.selectedInbox inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                            
                            return;
                        }
                        
                        
                    });
                    
                });
                
                
                
            }
            
            
        }
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"MainMenuViewController" function:@"didSelectRowAtIndexPath" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    
}

-(void)performSync{
    [self performSelectorOnMainThread:@selector(increaseProgress) withObject:@"" waitUntilDone:YES];
    [self performSelectorInBackground:@selector(synchronization) withObject:nil];
}

-(void)synchronization
{
    
    @try {
        
        if ([mainDelegate.user processPendingActions]) {
            
            //upload signature document
            // [self uploadSignatureXml];
            
            //upload pending documents
            //  [self uploadPendingXml];
            
            
            //reload baskets if no pendings left
            NSString *inboxIds=@"";
            for(CMenu *menu in mainDelegate.user.menu){
                inboxIds=[NSString stringWithFormat:@"%@%d,",inboxIds,menu.menuId];
            }
            NSString* homeUrl;
            NSString* showthumb;
            if (mainDelegate.ShowThumbnail)
                showthumb=@"true";
            else
                showthumb=@"false";
            if(mainDelegate.SupportsServlets)
                homeUrl = [NSString stringWithFormat:@"http://%@?action=GetCorrespondences&token=%@&inboxId=%@&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,inboxIds,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
            else
                homeUrl = [NSString stringWithFormat:@"http://%@/GetCorrespondences?token=%@&inboxId=%@&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,inboxIds,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
            
            NSURL *xmlUrl = [NSURL URLWithString:homeUrl];
            NSData *homeXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
            
            
            NSMutableDictionary *correspondences=[CParser loadCorrespondencesWithData:homeXmlData];
            for (CMenu* menu in mainDelegate.user.menu)
            {
                menu.correspondenceList=[correspondences objectForKey:[NSString stringWithFormat:@"%d",menu.menuId]];
                
            }
            mainDelegate.selectedInbox=((CMenu*)mainDelegate.user.menu[0]).menuId;
            
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:mainDelegate.selectedInbox inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            
            [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:mainDelegate.selectedInbox inSection:0]] ;
            [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
        }
        else {
            [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
            [self ShowMessage:NSLocalizedString(@"Alert.Connection",@"Connection not found")];
        }
        
        
        
        
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"MainMenuViewController" function:@"synchronization" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    
    
}
-(void)settings{
    SignatureViewController *signatureView = [[SignatureViewController alloc] initWithFrame:CGRectMake(310, 100, 400, 500)];
    signatureView.modalPresentationStyle = UIModalPresentationFormSheet;
    signatureView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:signatureView animated:YES completion:nil];
    signatureView.view.superview.frame = CGRectMake(310, 100, 400, 500); //it's important to do this after presentModalViewController
    // noteView.view.superview.center = self.view.center;
    // transferView.delegate=self;
}



-(void)ShowMessage:(NSString*)message{
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Alert",@"Alert")
                          message: message
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK",@"OK")
                          otherButtonTitles: nil];
    [alert show];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
	return YES;
}

- (void)increaseProgress{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Sync",@"Synchronizing ...") maskType:SVProgressHUDMaskTypeBlack];
}
- (void)increaseLoading{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loading ...") maskType:SVProgressHUDMaskTypeBlack];
}

- (void)dismiss {
	[SVProgressHUD dismiss];
}

@end
