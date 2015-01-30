//
//  containerView.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "containerView.h"
#import "HeaderView.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "SomeNetworkOperation.h"
#import "LoginViewController.h"
#import "FileManager.h"
#import "OfflineAction.h"
#import "BuiltInActions.h"
#import "CParser.h"


// yasser
@interface containerView ()

@end

@implementation containerView
{

    AppDelegate *mainDelegate;
    NSOperationQueue *queue;
    SearchResultViewController *searchView;
    BOOL sync;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        mainDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
        [self getchild];
    }
    return self;
}


-(void) getchild
{
    self.header =[[HeaderView alloc] init];
    [self addChildViewController:self.header];
    [self.header didMoveToParentViewController:self];
    [self.view addSubview:self.header.view];
    
    
    
    self.splitView=mainDelegate.splitViewController;
    [self addChildViewController:self.splitView];
    [self.splitView didMoveToParentViewController:self];
    [self.view addSubview:self.splitView.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(NSUInteger)supportedInterfaceOrientations{
    return  UIInterfaceOrientationMaskLandscape;
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
