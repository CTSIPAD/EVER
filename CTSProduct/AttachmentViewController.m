//
//  UploadViewController.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "AttachmentViewController.h"
#import "CAction.h"
#import "CUser.h"
#import "CMenu.h"
#import "CParser.h"
#import "CFPendingAction.h"
#import "AppDelegate.h"
#import "FileManager.h"
#import "SVProgressHUD.h"
@interface AttachmentViewController ()

@end

@implementation AttachmentViewController{
    AppDelegate *mainDelegate;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.clearsSelectionOnViewWillAppear = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.tableView.backgroundColor=mainDelegate.cellColor;
    self.tableView.layer.borderColor=[[UIColor whiteColor]CGColor];
    [self.tableView setSeparatorColor:[UIColor whiteColor]];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AttachmentsCell"];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(CGFloat)  tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.actions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AttachmentsCell";

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.frame=self.view.frame;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 37, 37)];
    
    UILabel *labelTitle= [[UILabel alloc] init];
    if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
        labelTitle.Frame=CGRectMake(20, 5,cell.frame.size.width-80, 40);
        imageView.frame=CGRectMake(cell.frame.size.width-45, 5, 37, 37);
        labelTitle.textAlignment=NSTextAlignmentRight;
    }
    else{
          labelTitle.Frame=CGRectMake(60, 5,cell.frame.size.width-50, 40);
          labelTitle.textAlignment=NSTextAlignmentLeft;
    }
        labelTitle.textColor = [UIColor whiteColor];
    CAction* row=self.actions[indexPath.row];
    if([row.label isEqualToString:@""]|| row.label==nil)
        labelTitle.text=NSLocalizedString(row.action,row.action);
    else
        labelTitle.text=row.label;
    if(row.Custom){
        UIImage * image =  [UIImage imageWithData:[CParser LoadCachedIcons:row.action]];
        [imageView setImage:image];
    }
    else{
        [imageView setImage:[UIImage imageNamed:row.action]];
    }
   
    [cell addSubview:imageView];
    [cell addSubview:labelTitle];
    cell.backgroundColor=mainDelegate.cellColor;
    if([row.action isEqualToString:@"AddNew"]&& [[self.NewBtnStatus lowercaseString] isEqualToString:@"readonly"]){
        cell.userInteractionEnabled=false;
    }
    else
        cell.userInteractionEnabled=true;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    if(mainDelegate.QuickActionClicked){
        [self.notePopController dismissPopoverAnimated:NO];
        
        
        CAction* row=self.actions[indexPath.row];
        if(row.Custom){
            if(row.popup==NO){
                [NSThread detachNewThreadSelector:@selector(increaseLoading) toTarget:self withObject:nil];
                
                [_delegate executeAction:row.action note:@"" movehome:row.backhome];
                [_delegate movehome:self];
                
                [NSThread detachNewThreadSelector:@selector(dismiss) toTarget:self withObject:nil];
                mainDelegate.QuickActionClicked=false;
                
            }
            else{
                [_delegate PopUpCommentDialog:self Action:row document:nil];
                
            }
            
        }
        else{
            if([row.action isEqualToString:@"Transfer"]){
                [_delegate PopUpTransferDialog];
            }
            else{
                if([row.action isEqualToString:@"AddNew"]){
                    if(!mainDelegate.isOfflineMode)
                        [_delegate ShowUploadAttachmentDialog:self.index];
                    else
                        [self ShowMessage:NSLocalizedString(@"Upload_attachment", @"connect to upload")];
                }
                mainDelegate.QuickActionClicked=false;
                
            }
        }
        
    }
    else{
        [_delegate dismissPopUp:self];
        
        CAction* row=self.actions[indexPath.row];
        if(row.Custom){
            if(row.popup==NO){
                [_delegate executeAction:row.action note:@"" movehome:row.backhome];
                if(row.backhome)
                    [_delegate movehome:self];
                else
                    [_delegate dismissPopUp:self];
                
            }
            else{
                [_delegate PopUpCommentDialog:self Action:row document:nil];
                
            }    }
        else{
            if([row.action isEqualToString:@"ShowAttachments"]){
                [_delegate ShowHidePageBar];
            }
            else{
                if([row.action isEqualToString:@"AddNew"])
                {
                    if(!mainDelegate.isOfflineMode)
                        [_delegate ShowUploadAttachmentDialog];
                    else
                        [self ShowMessage:NSLocalizedString(@"Upload_attachment", @"connect to upload")];
                }
            }
        }
    }
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
-(void)increaseLoading{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading", @"Loading...") maskType:SVProgressHUDMaskTypeBlack];
}
-(void)dismiss{
    [SVProgressHUD dismiss];
}

@end
