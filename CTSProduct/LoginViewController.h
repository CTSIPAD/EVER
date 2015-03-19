//
//  ViewController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
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
-(void)ShowSlider;
@end
