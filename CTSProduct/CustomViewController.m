//
//  CustomViewController.m
//  CTSProduct
//
//  Created by DNA on 7/30/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//


//
#import "CustomViewController.h"
#import "CAction.h"
#import "CUser.h"
#import "CMenu.h"
#import "CParser.h"
#import "CFPendingAction.h"
#import "AppDelegate.h"
#import "FileManager.h"
@interface CustomViewController ()

@end

@implementation CustomViewController
{
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
    CGFloat red = 29.0f / 255.0f;
    CGFloat green = 29.0f / 255.0f;
    CGFloat blue = 29.0f / 255.0f;
    self.tableView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    [self.tableView setSeparatorColor:[UIColor whiteColor]];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CustomCell"];
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
    static NSString *CellIdentifier = @"CustomCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 37, 37)];
    
    UILabel *labelTitle= [[UILabel alloc] initWithFrame:CGRectMake(70, 5,cell.frame.size.width-140, 40)];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.backgroundColor = [UIColor clearColor];
    CAction* row=self.actions[indexPath.row];
    labelTitle.text=row.label;
    if(row.Custom){
        UIImage * image =  [UIImage imageWithData:[CParser LoadCachedIcons:row.action]];
        [imageView setImage:image];
    }
    
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        labelTitle.textAlignment=NSTextAlignmentRight;
        imageView.frame=CGRectMake(cell.frame.size.width-45, 5, 37, 37);
    }
    [cell addSubview:imageView];
    [cell addSubview:labelTitle];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [_delegate dismissPopUp:self];
    CAction* row=self.actions[indexPath.row];
        if(row.popup==NO){
            [_delegate executeAction:row.action note:@"" movehome:row.backhome];
            if(row.backhome)
                [_delegate movehome:self];
            else
                [_delegate dismissPopUp:self];
            
        }
        else{
            [_delegate PopUpCommentDialog:self Action:row document:nil];
            
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
