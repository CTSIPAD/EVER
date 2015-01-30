//
//  NewActionTableViewController.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "SignatureController.h"
#import "MoreTableViewController.h"
#import "CAction.h"
#import "CUser.h"
#import "CMenu.h"
#import "CParser.h"
#import "CFPendingAction.h"
#import "MainMenuViewController.h"
#import "CSearch.h"
#import "ReaderMainToolbar.h"
#import "AppDelegate.h"
#import "CommentViewController.h"
@interface SignatureController ()
@end

@implementation SignatureController{
    
    AppDelegate *mainDelegate;
    AppDelegate *appDelegate;
}
@synthesize document,m_pdfview,m_pdfdoc,correspondenceId;

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
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.tableView.backgroundColor=mainDelegate.cellColor;
    self.tableView.layer.borderColor=[[UIColor whiteColor]CGColor];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.tableView setSeparatorColor:[UIColor whiteColor]];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"actionCell"];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.SignAction.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"actionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 37, 37)];
    
    UILabel *labelTitle= [[UILabel alloc] init];
    if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
        labelTitle.Frame=CGRectMake(25, 5,cell.frame.size.width-80, 40);
        imageView.frame=CGRectMake(cell.frame.size.width-45, 5, 37, 37);
        labelTitle.textAlignment=NSTextAlignmentRight;
    }
    else{
        labelTitle.Frame=CGRectMake(55, 5,cell.frame.size.width-50, 40);
        labelTitle.textAlignment=NSTextAlignmentLeft;
    }
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.backgroundColor = [UIColor clearColor];
    
    CAction *actionProperty=self.SignAction[indexPath.row];
    if([actionProperty.label isEqualToString:@""] || actionProperty.label==nil){
        NSString* string=[NSString stringWithFormat:@"Signature.%@",actionProperty.action];
        labelTitle.text=NSLocalizedString(string, actionProperty.label);
    }
    else
        labelTitle.text=actionProperty.label;
    UIImage *cellImage;
    if(actionProperty.Custom)
        cellImage =  [UIImage imageWithData:[CParser LoadCachedIcons:actionProperty.action]];
    
    else
        cellImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",actionProperty.action]];
    
    [imageView setImage:cellImage];
    [cell addSubview:imageView];
    [cell addSubview:labelTitle];
    cell.backgroundColor=mainDelegate.cellColor;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [_delegate dismissPopUp:self];
    
    CAction *actionProperty=self.SignAction[indexPath.row];
    if(actionProperty.Custom){
        if(actionProperty.popup==NO){
            [_delegate executeAction:actionProperty.action note:@"" movehome:actionProperty.backhome];
            if(actionProperty.backhome)
                [_delegate movehome:self];
            else
                [_delegate dismissPopUp:self];
            
        }
        else{
            [_delegate PopUpCommentDialog:self Action:actionProperty document:nil];
            
        }
    }else{
        if([actionProperty.action isEqualToString:@"Signature"]||[actionProperty.action isEqualToString:@"SignAll"]){
           [_delegate Sign];
        }
        else{
            [m_pdfview setHandsign:YES];
            [_delegate HandSign];
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
@end
