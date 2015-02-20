//
//  MetadataViewController.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "MetadataViewController.h"
#import "CCorrespondence.h"
#import "ReaderViewController.h"
#import "AppDelegate.h"
@interface MetadataViewController ()

@end

@implementation MetadataViewController{
    NSMutableDictionary* properties;
    AppDelegate *mainDelegate;
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
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.tableView setUserInteractionEnabled:NO];
    [self.tableView setBackgroundColor:mainDelegate.metaDataCellColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"metadataCell"];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    properties = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *subDictionary;
    
    for (int j=0;j< self.currentCorrespondence.properties.count;j++) {
        NSMutableDictionary *mainDictionary=[[NSMutableDictionary alloc] init];
        NSString *s1=[NSString stringWithFormat:@"%d",j];
        subDictionary = [self.currentCorrespondence.properties objectForKey:s1];
        NSString *s=[NSString stringWithFormat:@"%d",j];
        [mainDictionary setObject:subDictionary forKey:s];
        [properties setObject:mainDictionary forKey:s];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return properties.count ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key=[NSString stringWithFormat:@"%d",indexPath.section];
    NSDictionary *subDictionary = [properties objectForKey:key];
    NSArray *keys=[subDictionary allKeys];
    NSDictionary *subSubDictionary=[subDictionary objectForKey:[keys objectAtIndex:0]];
    NSArray *subkeys=[subSubDictionary allKeys];
    NSString* Labeltext= [subSubDictionary objectForKey:[subkeys objectAtIndex:0]];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:Labeltext attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){200, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size.height+50;

    
}

-(CGFloat)  tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	
	return 1;
	
}

-(CGFloat)  tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 50;
}

-(void)hide{
    [ReaderViewController closeMetadata];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];

    view.backgroundColor=mainDelegate.cellColor;
    view.frame=CGRectMake(0, 0, 350, 50);
    
    UILabel *lblTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, 10, cell.frame.size.width-20, 30)];
    [lblTitle setBackgroundColor:mainDelegate.cellColor];
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    NSString *key=[NSString stringWithFormat:@"%d",section];
    NSDictionary *subDictionary = [properties objectForKey:key];
    NSArray *keys=[subDictionary allKeys];
    NSDictionary *subSubDictionary=[subDictionary objectForKey:[keys objectAtIndex:0]];
    lblTitle.text=[[subSubDictionary allKeys] objectAtIndex:0];
    
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
        lblTitle.textAlignment=NSTextAlignmentRight;
    
    [view addSubview:lblTitle];
    
    return view;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"metadataCell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor=mainDelegate.metaDataCellColor;
    NSString *key=[NSString stringWithFormat:@"%d",indexPath.section];
    NSDictionary *subDictionary = [properties objectForKey:key];
    
    NSArray *keys=[subDictionary allKeys];
    cell.textLabel.numberOfLines=0;
    NSDictionary *subSubDictionary=[subDictionary objectForKey:[keys objectAtIndex:0]];
    NSArray *subkeys=[subSubDictionary allKeys];
    cell.textLabel.text= [subSubDictionary objectForKey:[subkeys objectAtIndex:0]];
    cell.textLabel.textColor=mainDelegate.SearchLabelsColor;

    cell.textLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:14];
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
        cell.textLabel.textAlignment=NSTextAlignmentRight;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [ReaderViewController closeMetadata];
    
}


@end
