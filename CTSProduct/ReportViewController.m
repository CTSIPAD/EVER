//
//  ViewController.m
//  IconsView
//
//  Created by ---- on 10/9/14.
//  Copyright (c) 2014 ever-me. All rights reserved.
//

#import "ReportViewController.h"
#import "AppDelegate.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "PieViewController.h"
#define  SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)

@interface ReportViewController (){
    AppDelegate* mainDelegate;
    CGFloat Width;
    CGFloat Height;
   
}

@end

@implementation ReportViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createViewButtons];
}

-(void) createViewButtons
{
    [super viewDidLoad];
    [SVProgressHUD dismiss];
    
    self.navigationItem.hidesBackButton=NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.hidesBarsOnTap = true;
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
        Width=self.view.frame.size.width;
        Height=self.view.frame.size.height;
    }
    else{
        Width=self.view.frame.size.height;
        Height=self.view.frame.size.width;
    }
    CGRect rect=CGRectMake(0, 0, Width, Height-350);
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageNamed:@"backGroundImg.png"] drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];

    UIView *viewheader = [[UIView alloc] init];
    UIImage* headImage=[UIImage imageNamed:@"tableheader.png"];
    UIImageView* imgView=[[UIImageView alloc]initWithImage:headImage];
    [viewheader addSubview:imgView];
    [self.view addSubview:viewheader];
    
    
    UIButton *firstBtn=[[UIButton alloc] initWithFrame:CGRectMake(Width/6,((Height-720)/3), 220, 160)];
    UIImage *PieImage=[UIImage imageNamed:@"Charts-By-Categorie.png"];
    
    [firstBtn setTitle:@"Charts By Category" forState:UIControlStateNormal];
    [firstBtn setTitleColor:mainDelegate.SearchLabelsColor forState:UIControlStateNormal];
    [firstBtn addTarget:self action:@selector(ShowPie) forControlEvents:UIControlEventTouchUpInside];
    [firstBtn setBackgroundImage:PieImage forState:UIControlStateNormal];
    [firstBtn setTitleEdgeInsets:UIEdgeInsetsMake(firstBtn.frame.size.height+50, 0, 0, 0)];
    firstBtn.titleLabel.textAlignment=NSTextAlignmentCenter;

    UIView* PieView=[[UIView alloc]initWithFrame:CGRectMake(-10+Width/6, ((Height-720)/3)-10, 240, 180)];
    PieView.layer.cornerRadius=15;
    PieView.clipsToBounds=YES;
    PieView.layer.borderWidth=0.5;
    PieView.layer.borderColor=mainDelegate.SearchLabelsColor.CGColor;
    PieView.backgroundColor=mainDelegate.cellColor;
    
    [self.view addSubview:PieView];
    [self.view addSubview:firstBtn];
    
    int x=firstBtn.frame.origin.x;
    int y=firstBtn.frame.origin.y;
    int width=firstBtn.frame.size.width;
    int height=firstBtn.frame.size.height;
    
    UIButton *secondBtn=[[UIButton alloc] initWithFrame:CGRectMake(x+width+100, y, width,height)];
    UIImage *BarImage=[UIImage imageNamed:@"Charts-By-Structures.png"];
    
    [secondBtn setBackgroundImage:BarImage forState:UIControlStateNormal];
    [secondBtn setTitleEdgeInsets:UIEdgeInsetsMake(secondBtn.frame.size.height+50, 0, 0, 0)];
    [secondBtn addTarget:self action:@selector(ShowBar) forControlEvents:UIControlEventTouchUpInside];
    secondBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [secondBtn setTitle:@"Charts By Structures" forState:UIControlStateNormal];
    [secondBtn setTitleColor:mainDelegate.SearchLabelsColor forState:UIControlStateNormal];
    UIView* BarView=[[UIView alloc]initWithFrame:CGRectMake(x+width+90, y-10, width+20,height+20)];
    BarView.backgroundColor=mainDelegate.cellColor;
    BarView.layer.cornerRadius=15;
    BarView.clipsToBounds=YES;
    BarView.layer.borderWidth=0.5;
    PieView.layer.borderColor=mainDelegate.SearchLabelsColor.CGColor;
    [self.view addSubview:BarView];
    [self.view addSubview:secondBtn];
    
    UIButton *firstButton=[[UIButton alloc] initWithFrame:CGRectMake(Width/6,(2*firstBtn.frame.origin.y)+firstBtn.frame.size.height+10, 220, 160)];
    UIImage *Collapseimage=[UIImage imageNamed:@"Charts-By-Months.png"];
    
    [firstButton setTitle:@"Charts By Months" forState:UIControlStateNormal];
    [firstButton setTitleColor:mainDelegate.SearchLabelsColor forState:UIControlStateNormal];
    [firstButton addTarget:self action:@selector(ShowReport) forControlEvents:UIControlEventTouchUpInside];
    [firstButton setBackgroundImage:Collapseimage forState:UIControlStateNormal];
    [firstButton setTitleEdgeInsets:UIEdgeInsetsMake(firstButton.frame.size.height+50, 0, 0, 0)];
    firstButton.titleLabel.textAlignment=NSTextAlignmentCenter;
    
    UIView* view=[[UIView alloc]initWithFrame:CGRectMake(-10+Width/6,(2*firstBtn.frame.origin.y)+firstBtn.frame.size.height, 240, 180)];
    view.layer.cornerRadius=15;
    view.clipsToBounds=YES;
    view.layer.borderWidth=0.5;
    view.layer.borderColor=mainDelegate.SearchLabelsColor.CGColor;
    view.backgroundColor=mainDelegate.cellColor;
    
    [self.view addSubview:view];
    [self.view addSubview:firstButton];
    
     x=firstButton.frame.origin.x;
     y=firstButton.frame.origin.y;
     width=firstButton.frame.size.width;
     height=firstButton.frame.size.height;
    
    UIButton *secondButton=[[UIButton alloc] initWithFrame:CGRectMake(x+width+100, y, width,height)];
    UIImage *calendarImage=[UIImage imageNamed:@"Overdue-Documents.png"];
    
    [secondButton setBackgroundImage:calendarImage forState:UIControlStateNormal];
    [secondButton setTitleEdgeInsets:UIEdgeInsetsMake(secondButton.frame.size.height+50, 0, 0, 0)];
    [secondButton addTarget:self action:@selector(FilterReport) forControlEvents:UIControlEventTouchUpInside];
    secondButton.titleLabel.textAlignment=NSTextAlignmentCenter;
    [secondButton setTitle:@"Overdue Documents" forState:UIControlStateNormal];
    [secondButton setTitleColor:mainDelegate.SearchLabelsColor forState:UIControlStateNormal];
    UIView* view1=[[UIView alloc]initWithFrame:CGRectMake(x+width+90, y-10, width+20,height+20)];
    view1.backgroundColor=mainDelegate.cellColor;
    view1.layer.cornerRadius=15;
    view1.clipsToBounds=YES;
    view1.layer.borderWidth=0.5;
    view.layer.borderColor=mainDelegate.SearchLabelsColor.CGColor;
    [self.view addSubview:view1];
    [self.view addSubview:secondButton];

}
-(void)ShowPie
{
    
    UINavigationController *navController=[mainDelegate.splitViewController.viewControllers objectAtIndex:1];
    [navController setNavigationBarHidden:YES animated:YES];
    PieViewController *ReportsPage=[[PieViewController alloc] init];
    [navController pushViewController:ReportsPage animated:YES];
}
-(void)ShowBar
{
    
    
}
-(void)ShowReport
{
    

}
- (void)openDocument:(NSString*)urL
{
    
	}
#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{

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
- (void)increaseProgress{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loading ...") maskType:SVProgressHUDMaskTypeBlack];
    
    
}
- (void)dismiss {
	[SVProgressHUD dismiss];
}
-(void) FilterReport
{
}
-(void)ShowFilteredReport:(NSString*)fromDate DueDate:(NSString*)duedate viewController:(UIViewController*)viewcontroller
{
  }
-(void) FilterReportByDate:(NSString*)fromdate ToDate:(NSString*)todate
{
    NSLog(@"fourth Button Clicked ");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
