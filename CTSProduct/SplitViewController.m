//
//  SplitViewController.m
//  CTSProduct
//
//  Created by DNA on 6/24/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "SplitViewController.h"
#import "AppDelegate.h"
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
}
-(void)adjustButtons:(UIInterfaceOrientation)orientation{
    UIViewController *masterViewController = [self.viewControllers objectAtIndex:0];
    UIViewController *detailViewController = [self.viewControllers objectAtIndex:1];
    CGRect masterViewFrame = masterViewController.view.frame;
    CGRect detailViewFrame = detailViewController.view.frame;
    
    masterViewFrame.size.width=masterViewFrame.size.width-100;
    detailViewFrame.size.width=detailViewFrame.size.width+100;
    
    if([appDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        
        
        if (detailViewController.view.frame.origin.x > 0.0) {
            
            masterViewFrame.origin.x+= detailViewFrame.size.width;
            masterViewController.view.frame = masterViewFrame;
            
            detailViewFrame.origin.x -= masterViewFrame.size.width+101;
            
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
@end
