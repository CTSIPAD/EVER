//
//  SyncViewController.m
//  CTSProduct
//
//  Created by DNA on 8/13/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "SyncViewController.h"
#import "OfflineResult.h"
#import "AppDelegate.h"
@interface SyncViewController ()

@end

@implementation SyncViewController{
    AppDelegate *mainDelegate;
    
}

@synthesize Results;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        closeButton.frame =CGRectMake(10, 370, frame.size.width-10, 35);
        closeButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        [closeButton setTitle:NSLocalizedString(@"Cancel",@"Cancel") forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.view addSubview:closeButton];
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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.Results=mainDelegate.SyncActions;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.Results.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    CGFloat red = 29.0f / 255.0f;
    CGFloat green = 29.0f / 255.0f;
    CGFloat blue = 29.0f / 255.0f;
    cell.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 37, 37)];
    
    UILabel *labelTitle= [[UILabel alloc] initWithFrame:CGRectMake(70, 5,cell.frame.size.width-140, 40)];
    UILabel *Reason= [[UILabel alloc] initWithFrame:CGRectMake(70, 50,cell.frame.size.width-140, 40)];
    
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.backgroundColor = [UIColor clearColor];
    Reason.textColor = [UIColor redColor];
    Reason.backgroundColor = [UIColor clearColor];
    OfflineResult *row=self.Results[indexPath.row];
    //cell.textLabel.text=row.Name;
    labelTitle.font=[UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    labelTitle.font = [UIFont boldSystemFontOfSize:18];
	labelTitle.numberOfLines = ceilf([[NSString stringWithFormat:@"%@",row.Name] sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(300, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height/20.0);
    labelTitle.text=row.Name;
    
    if([row.Result isEqualToString:@""]){
        
        [imageView setImage:[UIImage imageNamed:@"success.jpg"]];
        imageView.backgroundColor = [UIColor clearColor];
    }
    else{
        [imageView setImage:[UIImage imageNamed:@"failure.jpg"]];
        imageView.backgroundColor = [UIColor clearColor];
        labelTitle.numberOfLines = ceilf([[NSString stringWithFormat:@"%@",row.Result] sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(300, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height/20.0);
        Reason.text=row.Result;
        
    }
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        labelTitle.textAlignment=NSTextAlignmentRight;
        Reason.textAlignment=NSTextAlignmentRight;
        imageView.frame=CGRectMake(cell.frame.size.width-45, 5, 37, 37);
    }
    [cell addSubview:imageView];
    [cell addSubview:labelTitle];
    [cell addSubview:Reason];
    
    return cell;
    
}
- (void)hide
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
