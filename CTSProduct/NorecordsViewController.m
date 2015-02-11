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
@interface NorecordsViewController ()

@end

@implementation NorecordsViewController{
    AppDelegate *mainDelegate;
    BOOL blinkStatus;
    UILabel *noRecords;
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



- (void)viewDidLoad
{
    [super viewDidLoad];
    [SVProgressHUD dismiss];

    //jis toolbar
    
    //    CGFloat red = 88.0f / 255.0f;
    //    CGFloat green = 96.0f / 255.0f;
    //    CGFloat blue = 104.0f / 255.0f;
    
    CGFloat red = 173.0f / 255.0f;
    CGFloat green = 208.0f / 255.0f;
    CGFloat blue = 238.0f / 255.0f;
    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBarHidden = YES;
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    noRecords = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-350, self.view.frame.size.height/3, self.view.frame.size.width/2, 40)];
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
    
    
    noRecords.shadowColor = [UIColor colorWithRed:0.0f / 255.0f green:155.0f / 255.0f blue:213.0f / 255.0f alpha:1.0];
    noRecords.shadowOffset = CGSizeMake(0.0, 1.0);
    noRecords.textColor = [UIColor whiteColor];
    noRecords.textAlignment=NSTextAlignmentCenter;
    //[self.view setBackgroundColor:[UIColor colorWithRed:red green:green blue:blue alpha:1.0]];
    [self.view setBackgroundColor:[UIColor colorWithRed:red green:green blue:blue alpha:1.0]];
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
