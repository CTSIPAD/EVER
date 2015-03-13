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
    
       [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"metadataCell"];
    
    self.tableView.separatorColor=[UIColor clearColor];

    
}

-(void)viewWillAppear:(BOOL)animated{
    UIImage* bgColor;

    UIInterfaceOrientation orientation=[[ UIApplication sharedApplication]statusBarOrientation];
    
    if (  UIInterfaceOrientationIsPortrait(orientation)) {
        
        bgColor=[UIImage imageNamed:@"metadataBg_Portraite.png"];
    }
    else
        
        bgColor=[UIImage imageNamed:@"metadataBg1.png"];
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:bgColor]];

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
    
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return properties.count;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)mycell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(properties.count!=indexPath.row+1){
    UIImage*image=[UIImage imageNamed:@"metadataSeparator.png"];
    UIView * additionalSeparator = [[UIView alloc] initWithFrame:CGRectMake(8,mycell.frame.size.height-image.size.height,mycell.frame.size.width-16,image.size.height)];
    additionalSeparator.backgroundColor = [UIColor colorWithPatternImage:image];
    [mycell addSubview:additionalSeparator];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key=[NSString stringWithFormat:@"%d",indexPath.row];
    NSDictionary *subDictionary = [properties objectForKey:key];
    NSArray *keys=[subDictionary allKeys];
    NSDictionary *subSubDictionary=[subDictionary objectForKey:[keys objectAtIndex:0]];
    NSArray *subkeys=[subSubDictionary allKeys];
    NSString* Labeltext= [subSubDictionary objectForKey:[subkeys objectAtIndex:0]];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:Labeltext attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){200, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size.height+100;

    
}


-(void)hide{
    [ReaderViewController closeMetadata];
}






- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"metadataCell";
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.backgroundColor=[UIColor clearColor];
    
    
    NSString *key=[NSString stringWithFormat:@"%d",indexPath.row];
    NSDictionary *subDictionary = [properties objectForKey:key];
    
    NSArray *keys=[subDictionary allKeys];
    cell.textLabel.numberOfLines=0;
    NSDictionary *subSubDictionary=[subDictionary objectForKey:[keys objectAtIndex:0]];
    NSArray *subkeys=[subSubDictionary allKeys];
    
    
//    UIImage *cellImage=[UIImage imageNamed:@"SubjectIcon.png"];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 20, cellImage.size.width, cellImage.size.height)];
//    
//    [imageView setImage:cellImage];
   
    
    UILabel *lblTitle=[[UILabel alloc]initWithFrame:CGRectMake(20, 20, cell.frame.size.width-180, 30)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    lblTitle.text=[subkeys objectAtIndex:0];
    lblTitle.textAlignment=NSTextAlignmentLeft;

    
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        lblTitle.textAlignment=NSTextAlignmentRight;
        lblTitle.frame=CGRectMake(15, 20, cell.frame.size.width-180, 30);
//        imageView.frame=CGRectMake(lblTitle.frame.origin.x+lblTitle.frame.size.width+5, 15,cellImage.size.width, cellImage.size.height);
        
    }
    CGSize textSize = [[subSubDictionary objectForKey:[subkeys objectAtIndex:0]] sizeWithFont: [UIFont fontWithName:@"Helvetica" size:14]
                         constrainedToSize:CGSizeMake(cell.frame.size.width-180, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
    
    
    
    
    UILabel *lbldetail=[[UILabel alloc]initWithFrame:CGRectMake(lblTitle.frame.origin.x, 55, cell.frame.size.width-180, textSize.height)];
    [lbldetail setBackgroundColor:[UIColor clearColor]];
    lbldetail.textColor=[UIColor colorWithRed:196/255.0f green:208/255.0f blue:208/255.0f alpha:1.0f];
    lbldetail.font = [UIFont fontWithName:@"Helvetica" size:14];
    lbldetail.textAlignment=NSTextAlignmentLeft;

    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        lbldetail.frame=CGRectMake(15, 55, cell.frame.size.width-180, textSize.height);
        lbldetail.textAlignment=NSTextAlignmentRight;
    }
    lbldetail.text=[subSubDictionary objectForKey:[subkeys objectAtIndex:0]];
    lbldetail.lineBreakMode = NSLineBreakByWordWrapping;
    lbldetail.numberOfLines=0;
    
   

   

    [cell addSubview:lblTitle];
    [cell addSubview:lbldetail];
//    [cell addSubview:imageView];
//    [lbldetail sizeToFit];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [ReaderViewController closeMetadata];
    
}


@end
