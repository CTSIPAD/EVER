//
//  loaderView.m
//  CTSProductLastVersion
//
//  Created by ---- on 10/29/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

// yasser
#import "loaderView.h"
#import "SplitViewController.h"
#import "TableResultCell.h"

@interface loaderView ()

@end

@implementation loaderView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *lablle=[[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-30,50, 200, 30)];
        lablle.text=@"Tap here to load";
        lablle.textColor=[UIColor blackColor];
        self.view.backgroundColor=[UIColor greenColor];
        [self.view addSubview:lablle];
        
        UIButton *loadButton=[[UIButton alloc] initWithFrame:CGRectMake(10, 20, 50, 30)];
        [loadButton setTitle:@"load" forState:UIControlStateNormal];
        [loadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [loadButton addTarget:self action:@selector(loadmore) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loadButton];
    }
    return self;
}

-(void) loadmore
{
TableResultCell *tableResult=[[TableResultCell alloc] init];
    [tableResult loadmore];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"");
}
-(void) willMoveToParentViewController:(UIViewController *)parent
{
}
-(void) didMoveToParentViewController:(UIViewController *)parent
{
    //SplitViewController *splitView=[[SplitViewController alloc] init];
    // UIViewController *masterViewController = [splitView.viewControllers objectAtIndex:0];
     //UIViewController *detailViewController = [splitView.viewControllers objectAtIndex:1];
     self.view.frame=CGRectMake(220, 650, parent.view.frame.size.width, 380);
    //self.view.frame=CGRectMake(0,parent.view.frame.size.height-100, parent.view.frame.size.width, 50);
   // self.view.frame=CGRectMake(masterViewController.view.frame.size.width, detailViewController.view.frame.size.height-250, parent.view.frame.size.width, 300);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
