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
#import "VerticalBarChartViewController.h"
#import "HorizontalBarChartViewController.h"
#import "OverdueBarChartViewController.h"

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
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavbar:)];
    [self.view addGestureRecognizer:tapGesture];
    
    
}
-(void) showHideNavbar:(id) sender
{
    // write code to show/hide nav bar here
    // check if the Navigation Bar is shown
    if (self.navigationController.navigationBar.hidden == NO)
    {
        // hide the Navigation Bar
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    // if Navigation Bar is already hidden
    else if (self.navigationController.navigationBar.hidden == YES)
    {
        // Show the Navigation Bar
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
-(void) createViewButtons
{
    [super viewDidLoad];
    [SVProgressHUD dismiss];
    
    self.navigationItem.hidesBackButton=NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = YES;
    //    self.navigationController.hidesBarsOnTap = true;
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
    
    
    UIImage *PieImage=[UIImage imageNamed:@"categorie.png"];
    int x=(Width+20-(2*PieImage.size.width))/3;
    int y=((Height-720)/3);
    int x2=2*x+PieImage.size.width;
    int y2=2*y+PieImage.size.height-40;
    UIButton *firstBtn=[[UIButton alloc] initWithFrame:CGRectMake(x,y, PieImage.size.width, PieImage.size.height)];

    [firstBtn addTarget:self action:@selector(ShowPie) forControlEvents:UIControlEventTouchUpInside];
    [firstBtn setBackgroundImage:PieImage forState:UIControlStateNormal];
 
    [self addSubviewWithZoomInAnimation:firstBtn duration:0.5 delay:0.3 option:UIViewAnimationOptionAllowUserInteraction withParentView:self.view FromPoint:CGPointMake(firstBtn.frame.origin.x+firstBtn.frame.size.width/2, firstBtn.frame.origin.y+firstBtn.frame.size.height/2) originX:firstBtn.frame.origin.x originY:firstBtn.frame.origin.y];
    
    
    UIButton *secondBtn=[[UIButton alloc] initWithFrame:CGRectMake(x2, y,PieImage.size.width, PieImage.size.height)];
    [secondBtn setBackgroundImage:[UIImage imageNamed:@"structure.png"] forState:UIControlStateNormal];
    [secondBtn addTarget:self action:@selector(ShowBar) forControlEvents:UIControlEventTouchUpInside];
    [self addSubviewWithZoomInAnimation:secondBtn duration:0.5 delay:0.5 option:UIViewAnimationOptionAllowUserInteraction withParentView:self.view FromPoint:CGPointMake(secondBtn.frame.origin.x+secondBtn.frame.size.width/2, secondBtn.frame.origin.y+secondBtn.frame.size.height/2) originX:secondBtn.frame.origin.x originY:secondBtn.frame.origin.y];
   
    
    UIButton *firstButton=[[UIButton alloc] initWithFrame:CGRectMake(x,y2, PieImage.size.width,PieImage.size.height)];
    [firstButton addTarget:self action:@selector(ShowReport) forControlEvents:UIControlEventTouchUpInside];
    [firstButton setBackgroundImage:[UIImage imageNamed:@"months.png"] forState:UIControlStateNormal];
    
    [self addSubviewWithZoomInAnimation:firstButton duration:0.5 delay:0.8 option:UIViewAnimationOptionAllowUserInteraction withParentView:self.view FromPoint:CGPointMake(firstButton.frame.origin.x+firstButton.frame.size.width/2, firstButton.frame.origin.y+firstButton.frame.size.height/2) originX:firstButton.frame.origin.x originY:firstButton.frame.origin.y];
    

    
    UIButton *secondButton=[[UIButton alloc] initWithFrame:CGRectMake(x2, y2,PieImage.size.width, PieImage.size.height)];
    
    [secondButton setBackgroundImage:[UIImage imageNamed:@"documents.png"] forState:UIControlStateNormal];
    [secondButton addTarget:self action:@selector(FilterReport) forControlEvents:UIControlEventTouchUpInside];
    [self addSubviewWithZoomInAnimation:secondButton duration:0.5 delay:1.0 option:UIViewAnimationOptionAllowUserInteraction withParentView:self.view FromPoint:CGPointMake(secondButton.frame.origin.x+secondButton.frame.size.width/2, secondButton.frame.origin.y+secondButton.frame.size.height/2) originX:secondButton.frame.origin.x originY:secondButton.frame.origin.y];
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
    UINavigationController *navController=[mainDelegate.splitViewController.viewControllers objectAtIndex:1];
    [navController setNavigationBarHidden:YES animated:YES];
    VerticalBarChartViewController *ReportsPage=[[VerticalBarChartViewController alloc] init];
    [navController pushViewController:ReportsPage animated:YES];
    
}
-(void)ShowReport
{
    UINavigationController *navController=[mainDelegate.splitViewController.viewControllers objectAtIndex:1];
    [navController setNavigationBarHidden:YES animated:YES];
    HorizontalBarChartViewController *ReportsPage=[[HorizontalBarChartViewController alloc] init];
    [navController pushViewController:ReportsPage animated:YES];


}
- (void)openDocument:(NSString*)urL
{
    
}
#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    
}
-(void) addSubviewWithZoomInAnimation:(UIView*)view duration:(float)secs delay:(float)del
option:(UIViewAnimationOptions)option withParentView:(UIView*)ParentView FromPoint:(CGPoint)sourcePoint
originX:(CGFloat)x originY:(CGFloat)y
{
    [self.view addSubview:view];
    view.center=sourcePoint;
    
    CGAffineTransform trans= CGAffineTransformScale(view.transform,0.01,0.01);
    view.transform=trans;
    
    [ParentView addSubview:view];
    [ParentView bringSubviewToFront:view];
    
    [UIView animateWithDuration:secs delay:del options:option
                     animations:^{
                         view.transform=CGAffineTransformScale(view.transform,100.0,100.0);
                         view.frame=CGRectMake(x,y,view.frame.size.width,view.frame.size.height);
                     }
                     completion:nil];
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
    UINavigationController *navController=[mainDelegate.splitViewController.viewControllers objectAtIndex:1];
    [navController setNavigationBarHidden:YES animated:YES];
    OverdueBarChartViewController *ReportsPage=[[OverdueBarChartViewController alloc] init];
    [navController pushViewController:ReportsPage animated:YES];
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
