//
//  ActionsTableViewController.m
//  CTSTest
//
//  Created by DNA on 1/22/14.
//  Copyright (c) 2014 LBI. All rights reserved.
//

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
#import "FileManager.h"
@interface MoreTableViewController ()

@end

@implementation MoreTableViewController{
    AppDelegate *mainDelegate;
}
@synthesize document;
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
    CGFloat red = 29.0f / 255.0f;
    CGFloat green = 29.0f / 255.0f;
    CGFloat blue = 29.0f / 255.0f;
    self.tableView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
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
    static NSString *CellIdentifier = @"actionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 37, 37)];
    
    UILabel *labelTitle= [[UILabel alloc] initWithFrame:CGRectMake(70, 5,cell.frame.size.width-140, 40)];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.backgroundColor = [UIColor clearColor];
    
    CAction *actionProperty=self.actions[indexPath.row];
    UIImage *cellImage;
    labelTitle.text=actionProperty.label;
    labelTitle.numberOfLines=3;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    labelTitle.lineBreakMode = NSLineBreakByWordWrapping;
    
    //NSString* imagename=[NSString stringWithFormat:@"%@.png",actionProperty.label];
    cellImage =  [UIImage imageWithData:[CParser LoadCachedIcons:actionProperty.action]];
    
    [imageView setImage:cellImage];
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        labelTitle.textAlignment=NSTextAlignmentRight;
        imageView.frame=CGRectMake(cell.frame.size.width-45, 5, 37, 37);
    }
    [cell addSubview:imageView];
    [cell addSubview:labelTitle];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    //    CAction *actionProperty=self.actions[indexPath.row];
    //    if([actionProperty.action isEqualToString:@"Archive"]){
    //    [self executeAction:actionProperty.action];
    //        [_delegate movehome:self];
    //    }
    //    else{
    //        [_delegate PopUpCommentDialog:self Action:actionProperty.action document:nil];
    //
    //    }
    @try
    {
    CAction *actionProperty=self.actions[indexPath.row];
    if(actionProperty.popup==NO){
        [_delegate executeAction:actionProperty.action note:@"" movehome:actionProperty.backhome];
            if(actionProperty.backhome){
                
                [_delegate movehome:self];
            }
            else
                [_delegate dismissPopUp:self];
            
        }
        else{
            [_delegate PopUpCommentDialog:self Action:actionProperty document:nil];
            
        }
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception: %@", exception);
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
