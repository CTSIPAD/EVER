//
//  MainMenuViewController.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
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
    int x;
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
    
    UIColor *color;
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"en"])
        color=mainDelegate.InboxCellColor;
    else
        color=mainDelegate.InboxCellColor_ar;

    
    self.tableView.opaque=NO;

    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    self.tableView.separatorColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"separator.png"]];
mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    menuItemsCount=mainDelegate.user.menu.count;
    if (mainDelegate.isOfflineMode) {
        totalMenuItemsCount=menuItemsCount;
        x=0;
    }
    else
    {
    totalMenuItemsCount=menuItemsCount+1;//search
        x=1;
    }
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.backgroundColor =color;
    
    self.tableView.layer.borderWidth=2;
    self.tableView.layer.borderColor=[color CGColor];
    
    
    
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
    
//    if(menuItemsCount>4)
//        return (764-20)/6;
//    else{
//        if(indexPath.section==0)//logo
//            return (764-20)/6;
//        else  return 764/totalMenuItemsCount;
//    }
    return 120;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    UIImageView *imageView = [[UIImageView alloc] init];
    UILabel *labelText =[[UILabel alloc] initWithFrame:CGRectMake(2, imageView.frame.size.height+imageView.frame.origin.y+10, cell.frame.size.width-100, TITLE_HEIGHT)];
    labelText.textAlignment=  NSTextAlignmentCenter;
    labelText.backgroundColor=[UIColor clearColor];
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
    if (indexPath.row==rowsNumber-x) {
        UIImage *cellImage = [UIImage imageNamed:[NSString stringWithFormat:@"MainSearchimg.png"]];
        imageView.image=cellImage;
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"en"]){

            imageView.frame=CGRectMake(30,60-(cellImage.size.height/2), cellImage.size.width, cellImage.size.height);
        }
        else{
            imageView.frame=CGRectMake(cell.frame.size.width-cellImage.size.width-120,60-(cellImage.size.height/2), cellImage.size.width, cellImage.size.height);

        }
        labelText.text=NSLocalizedString(@"Search",@"Search");
        
        
    }
    else
    {
        NSData * data= [NSData dataWithBase64EncodedString:((CMenu*)mainDelegate.user.menu[indexPath.row]).icon];
        UIImage *cellImage = [UIImage imageWithData:data];
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"en"]){

        imageView.frame=CGRectMake(30,60-(cellImage.size.height/2), cellImage.size.width, cellImage.size.height);
        }else{
            imageView.frame=CGRectMake(cell.frame.size.width-cellImage.size.width-120,60-(cellImage.size.height/2), cellImage.size.width, cellImage.size.height);

        }
        [imageView setImage:cellImage];
        labelText.text=((CMenu*)mainDelegate.user.menu[indexPath.row]).name;
        
    }
    
   

    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"en"]){
        cell.backgroundColor = mainDelegate.InboxCellColor;
         labelText.frame=CGRectMake(90,60-TITLE_HEIGHT/2, cell.frame.size.width-190, TITLE_HEIGHT);
    }
    else{
        cell.backgroundColor = mainDelegate.InboxCellColor_ar;
        labelText.frame=CGRectMake(2,60-TITLE_HEIGHT/2, cell.frame.size.width-190, TITLE_HEIGHT);

    }
    
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:labelText];
     bgColorView.backgroundColor = mainDelegate.selectedInboxColor;
    bgColorView.layer.masksToBounds = YES;
   cell.selectedBackgroundView = bgColorView;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    @try{
        NSLog(@"Info: Entering didSelectRowAtIndexPath method in MainMenuViewController.");
        mainDelegate.SearchClicked=NO;
        UINavigationController *navController=[mainDelegate.splitViewController.viewControllers objectAtIndex:1];
        [navController setNavigationBarHidden:YES animated:YES];
        mainDelegate.inboxForArchiveSelected = indexPath.row;

            /***** search button *****/
           
            if(indexPath.row==totalMenuItemsCount-x){
                NSLog(@"Info: Clicked Search button in grid.");
                mainDelegate.selectedInbox=-1;
                if(mainDelegate.searchModule ==nil){
                    NSString* searchUrl;
                    NSLog(@"Info:preparing URL");

                    if(mainDelegate.SupportsServlets)
                        searchUrl = [NSString stringWithFormat:@"http://%@?action=BuildAdvancedSearch&token=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage];
                    else
                        searchUrl = [NSString stringWithFormat:@"http://%@/BuildAdvancedSearch?token=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage];
                    NSLog(@"Info:URL=%@",searchUrl);
                    NSLog(@"Info:preparing Request");

                    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:searchUrl] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
                    NSLog(@"Info:Calling Request");
                    NSLog(@"Info: Getting search components .");

                    NSData *searchXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                    
                    NSString *validationResult=[CParser ValidateWithData:searchXmlData];
                    if(![validationResult isEqualToString:@"OK"]){
                        NSLog(@"Error: failed to get search components .");
                        NSLog(@"Error:%@",validationResult);
                        [self ShowMessage:validationResult];
                    }
                    else
                    {
                        mainDelegate.searchModule=[CParser loadSearchWithData:searchXmlData];
                    }
                    
                }
                
                SimpleSearchViewController *simpleSearchView=[[SimpleSearchViewController alloc] init];
                [navController pushViewController:simpleSearchView animated:YES];
                
            }
            /*****end search button *****/
            
            else{
                NSLog(@"Info:Inbox Clicked");
                
                mainDelegate.isBasketSelected = YES;
                /// must change
                //int realindex=indexPath.row;
                //NSMutableArray *arayTest=(CMenu*)mainDelegate.user.menu;
              //  CMenu* currentInbox=((CMenu*)mainDelegate.user.menu[indexPath.row]);
                CMenu* currentInbox=((CMenu*)mainDelegate.user.menu[indexPath.row]);
                
                
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
                        NSLog(@"Info:Preparing Request");
                        if(mainDelegate.SupportsServlets)
                            correspondenceUrl = [NSString stringWithFormat:@"http://%@?action=GetCorrespondences&token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,currentInbox.menuId,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
                        else
                            correspondenceUrl = [NSString stringWithFormat:@"http://%@/GetCorrespondences?token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,currentInbox.menuId,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
                        
                    
                        NSLog(@"Info:URl=%@",correspondenceUrl);
                        NSLog(@"Info:Getting Correspondences");

                        // NSURL *xmlUrl = [NSURL URLWithString:correspondenceUrl];
                        // NSData *menuXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
                        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:correspondenceUrl] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];

                        NSData *menuXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                        
                        correspondences=[CParser loadCorrespondencesWithData:menuXmlData];
                    }
                    else{
                        correspondences=[CParser LoadCorrespondences:currentInbox.menuId];
                    }
                    if(correspondences!=nil){
                    
                    if(!mainDelegate.isOfflineMode){
                        
                        if(mainDelegate.searchModule ==nil){
                            
                            
                            NSString* searchUrl;
                            NSLog(@"Info:Preparing Request");

                            if(mainDelegate.SupportsServlets)
                                searchUrl= [NSString stringWithFormat:@"http://%@?action=BuildAdvancedSearch&token=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage];
                            else
                                searchUrl= [NSString stringWithFormat:@"http://%@/BuildAdvancedSearch?token=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage];
                            //   NSURL *xmlUrl = [NSURL URLWithString:searchUrl];
                            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:searchUrl] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
                            // NSData *menuXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                            NSData *searchXmlData;
                            NSLog(@"Info:URl=%@",searchUrl);
                            NSLog(@"Info:Getting search components");
                            if(!mainDelegate.isOfflineMode){
                                //  searchXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
                                searchXmlData =[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                                NSString *validationResult=[CParser ValidateWithData:searchXmlData];
                                if(![validationResult isEqualToString:@"OK"]){
                                    NSLog(@"Error: failed to get search components .");
                                    NSLog(@"Error: %@",validationResult);
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
                    }
                    else{
                        mainDelegate.searchModule=[[CSearch alloc]init];
                    }
                    // mainDelegate.searchModule.correspondenceList = [CParser loadSearchCorrespondencesWithData:menuXmlData];
                    
                    mainDelegate.searchModule.correspondenceList = [correspondences objectForKey:[NSString stringWithFormat:@"%ld",(long)currentInbox.menuId]];
                    
                    
                    // changed
                    NSMutableArray* res= ((CMenu*)mainDelegate.user.menu[indexPath.row]).correspondenceList=[correspondences objectForKey:[NSString stringWithFormat:@"%d",currentInbox.menuId]];
                    
                    
                    
                    if(res.count ==0){
                        canFound=NO;
                        
                        
                        //   [self ShowMessage:[correspondences objectForKey:@"error"]];
                        
                    }
                    else{
                        canFound=YES;
                    }
                }
                    else{
                        NSLog(@"Info:No correspondence found");
                        canFound=NO;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(canFound){
                            // changed
                            mainDelegate.selectedInbox=((CMenu*)mainDelegate.user.menu[indexPath.row]).menuId;
                            SearchResultViewController *searchResultViewController = [[SearchResultViewController alloc]initWithStyle:UITableViewStylePlain];
                            
                            mainDelegate.menuSelectedItem=indexPath.row-1;
                            [navController pushViewController:searchResultViewController animated:YES];
                            mainDelegate.searchResultViewController=searchResultViewController;
                            
                        }
                        else{
                            // changed
                            mainDelegate.selectedInbox=((CMenu*)mainDelegate.user.menu[tableView.indexPathForSelectedRow.row]).menuId;

                            //[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:mainDelegate.selectedInbox inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                            NorecordsViewController *norecordsView=[[NorecordsViewController alloc] init];
                            [navController pushViewController:norecordsView animated:YES];
                            
                        }
                        
                        
                    });
                    
                });
                
                
                
            }
            
            
       //}
    }
    @catch (NSException *ex) {
        NSLog(@"Error: Error occured in MainMenuViewController Class in method didSelectRowAtIndexPAth.\n Exception Name:%@ Exception Reason: %@",[ex name],[ex reason]);
    }
    
}


-(void)settings{
    SignatureViewController *signatureView = [[SignatureViewController alloc] initWithFrame:CGRectMake(310, 100, 400, 500)];
    signatureView.modalPresentationStyle = UIModalPresentationFormSheet;
    signatureView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:signatureView animated:YES completion:nil];
    signatureView.view.superview.frame = CGRectMake(310, 100, 400, 500); //it's important to do this after
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
