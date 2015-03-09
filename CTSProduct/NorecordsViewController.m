//
//  NorecordsViewController.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "NorecordsViewController.h"
#import "AppDelegate.h"
#import "CUser.h"
#import "PdfThumbScrollView.h"
#import "CFolder.h"
#import "CAttachment.h"
#import "CCorrespondence.h"
#import "CParser.h"
#import "ReaderDocument.h"
#import "ReaderViewController.h"
#import "CMenu.h"
#import "MainMenuViewController.h"
#import "FileManager.h"
#import "SVProgressHUD.h"
#define  SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)

@interface NorecordsViewController ()

@end

@implementation NorecordsViewController{
    AppDelegate *mainDelegate;
    BOOL blinkStatus;
    UILabel *noRecords;
    CGFloat Width;
    CGFloat Height;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)deleteCachedFiles{
    
    @try{
    
        NSFileManager *fm = [NSFileManager defaultManager];
        
        // TEMPORARY PDF PATH
        // Get the Caches directory
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSError *error = nil;
        for (NSString *file in [fm contentsOfDirectoryAtPath:cachesDirectory error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", cachesDirectory, file] error:&error];
            if (!success || error) {
                // it failed.
                NSLog(@"%@",error);
            }
        }
        for (NSString *file in [fm contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, file] error:&error];
            if (!success || error) {
                // it failed.
                NSLog(@"%@",error);
            }
        }
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"NorecordsViewController" function:@"deleteCachedFiles" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBarHidden = YES;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [SVProgressHUD dismiss];
    
    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBarHidden = YES;
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavbar:)];
    [self.view addGestureRecognizer:tapGesture];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
        Width=self.view.frame.size.width;
        Height=self.view.frame.size.height;
    }
    else{
        Width=self.view.frame.size.height;
        Height=self.view.frame.size.width;
    }
        
    noRecords = [[UILabel alloc] initWithFrame:CGRectMake(0, ( (Height-350)/2)-20, Width, 40)];
    noRecords.numberOfLines=0;
    noRecords.lineBreakMode = NSLineBreakByWordWrapping;
    noRecords.font =[UIFont fontWithName:@"Helvetica-Bold" size:25.0f];
    @try {
        if([mainDelegate.IpadLanguage isEqualToString:@"ar"])
            noRecords.text = [[NSString alloc] initWithFormat:@"لا توجد %@ للعرض",((CMenu*)mainDelegate.user.menu[mainDelegate.inboxForArchiveSelected]).name];
        else
	            noRecords.text = [[NSString alloc] initWithFormat:@"No %@ To Display",((CMenu*)mainDelegate.user.menu[mainDelegate.inboxForArchiveSelected]).name];
        
    }
    @catch (NSException *exception) {
        if([mainDelegate.IpadLanguage isEqualToString:@"ar"])
            noRecords.text = [[NSString alloc] initWithFormat:@"No Records To Display"];
        else
            noRecords.text = [[NSString alloc] initWithFormat:@"لا توجد سجلات للعرض"];
        
    }
    
    
    noRecords.textColor = mainDelegate.cellColor;
    noRecords.textAlignment=NSTextAlignmentCenter;
    //[self.view setBackgroundColor:[UIColor colorWithRed:red green:green blue:blue alpha:1.0]];
    CGRect rect=CGRectMake(0, 0, Width, Height-350);
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageNamed:@"backGroundImg.png"] drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    [self.view setBackgroundColor:mainDelegate.TablebgColor];

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
    UIView *viewheader = [[UIView alloc] init];
    UIImage* headImage=[UIImage imageNamed:@"tableheader.png"];
    UIImageView* imgView=[[UIImageView alloc]initWithImage:headImage];
    [viewheader addSubview:imgView];
    [self.view addSubview:viewheader];
    [self.view addSubview:noRecords];
    
    
    
    
    
}
- (void)viewDidAppear:(BOOL)animated{
    
    
}

-(void)blink{
    if(blinkStatus == NO){
        noRecords.textColor = [UIColor colorWithRed:0.0f/255.0f green:155.0f/255.0f blue:213.0f/255.0f alpha:1.0];
        blinkStatus = YES;
    }
    else{
        noRecords.textColor = [UIColor whiteColor];
        blinkStatus = NO;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
