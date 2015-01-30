//
//  SplitViewController.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "SplitViewController.h"
#import "AppDelegate.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)
@interface SplitViewController (){
    AppDelegate *appDelegate;
    
}

@end

@implementation SplitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidLayoutSubviews
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self adjustButtons:orientation];
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [UIView setAnimationsEnabled:NO];
    [appDelegate.searchResultViewController.tableView reloadData];
}
-(void)adjustButtons:(UIInterfaceOrientation)orientation{
    UIViewController *masterViewController = [self.viewControllers objectAtIndex:0];
    UIViewController *detailViewController = [self.viewControllers objectAtIndex:1];
    CGRect masterViewFrame = masterViewController.view.frame;
    CGRect detailViewFrame = detailViewController.view.frame;
    
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        if ([appDelegate.IpadLanguage isEqualToString:@"ar"]) {
            masterViewFrame.size.width=masterViewFrame.size.width-100;
        }
        else{
            masterViewFrame.size.width=masterViewFrame.size.width-100;
            detailViewFrame.size.width=detailViewFrame.size.width+100;
        }
    }else{
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            masterViewFrame.size.width=masterViewFrame.size.width-90;
            detailViewFrame.size.width=detailViewFrame.size.width+20;
        }
        else
        {
            masterViewFrame.size.width=masterViewFrame.size.width-90;
            detailViewFrame.size.width=detailViewFrame.size.width+100;
        }
    }
    
    if([appDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        
        
        if (detailViewController.view.frame.origin.x > 0.0) {
            if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                
                masterViewFrame.origin.x= detailViewFrame.size.width+100;
                masterViewController.view.frame = masterViewFrame;
                detailViewFrame.origin.x -= masterViewFrame.size.width+100;
                detailViewFrame.size.width+=100;
                
            }
            else
            {
                masterViewFrame.origin.x+= detailViewFrame.size.width;
                masterViewController.view.frame = masterViewFrame;
                
                detailViewFrame.origin.x -= masterViewFrame.size.width+90;
            }
            
            
        }
        else{
            
            masterViewController.view.frame = masterViewFrame;
            
        }
        detailViewController.view.frame = detailViewFrame;
        
    }
    else{
        
        
        if (detailViewController.view.frame.origin.x > 0.0) {
            detailViewFrame.origin.x = masterViewFrame.size.width;
        }
        masterViewController.view.frame = masterViewFrame;
        detailViewController.view.frame = detailViewFrame;
        
    }
    [masterViewController.view setNeedsLayout];
    [detailViewController.view setNeedsLayout];
}

// new
-(void) willMoveToParentViewController:(UIViewController *)parent
{
}
// new
-(void) didMoveToParentViewController:(UIViewController *)parent
{
    
    self.view.frame=CGRectMake(0,100, parent.view.frame.size.width, parent.view.frame.size.height-100);
}

@end
