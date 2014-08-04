//
//  ViewController.h
//  CTSTest
//
//  Created by DNA on 12/11/13.
//  Copyright (c) 2013 LBI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UISplitViewControllerDelegate,UITextFieldDelegate,NSURLConnectionDataDelegate>
{
    
    UIAlertView *alertLicense;
    BOOL recordResults;
    NSMutableData *conWebData;
}
@property (nonatomic,retain) UIActivityIndicatorView *activityIndicatorObject;
@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
- (IBAction)Login:(id)sender;

@end
