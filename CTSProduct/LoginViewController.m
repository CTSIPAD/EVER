//
//  ViewController.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "StringEncryption.h"
#import "NSData+Base64.h"
#import "CUser.h"
#import "CMenu.h"
#import "CParser.h"
#import "CCorrespondence.h"
#import "CAttachment.h"
#import "MainMenuViewController.h"
#import "SearchResultViewController.h"
#import "containerView.h"
#define TAG_OK 1
#define TAG_NO 2
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)
@interface LoginViewController (){
    NSUserDefaults *defaults;
    NSString* IconsCached;
    NSString* Password;
    UIImage* LoginbtnImg;
    
}

@end

@implementation LoginViewController
{
    AppDelegate *appDelegate;
    
}
@synthesize activityIndicatorObject,txtUsername,txtPassword,btnLogin;
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    IconsCached = [defaults objectForKey:@"iconsCache"];
    if(![IconsCached isEqualToString:@"YES"]){
        //[CParser ClearCache];
        IconsCached=@"NO";
        [defaults setObject:IconsCached forKey:@"iconsCache"];
        [defaults synchronize];
    }
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.inboxForArchiveSelected=0;
    /**** UserName TextView ******/
    
    self.txtUsername.autoresizingMask = UIViewAutoresizingNone;
//    self.txtUsername.layer.borderWidth=2;
    self.txtUsername.backgroundColor=[UIColor clearColor];
    self.txtUsername.layer.borderColor=[[UIColor clearColor] CGColor];
//    self.txtUsername.layer.cornerRadius=10;
//    self.txtUsername.clipsToBounds=YES;
    self.txtUsername.returnKeyType = UIReturnKeyGo;
    self.txtUsername.autocorrectionType=FALSE;
    self.txtUsername.text=@"";
    self.txtUsername.textColor=[UIColor colorWithRed:48/255.0 green:157/255.0 blue:174/255.0 alpha:1];
    [self.txtUsername setValue:[UIColor colorWithRed:48/255.0 green:157/255.0 blue:174/255.0 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    
    /**** END  UserName TextView ******/
    
    
    /**** Password TextView ******/
    
    self.txtPassword.autoresizingMask = UIViewAutoresizingNone;
//    self.txtPassword.layer.borderWidth=2;
    self.txtPassword.backgroundColor=[UIColor clearColor];
    self.txtPassword.layer.borderColor=[[UIColor clearColor] CGColor];
//    self.txtPassword.layer.cornerRadius=10;
//    self.txtPassword.clipsToBounds=YES;
    self.txtPassword.secureTextEntry=YES;
    self.txtPassword.returnKeyType = UIReturnKeyGo;
    self.txtPassword.textColor=[UIColor colorWithRed:48/255.0 green:157/255.0 blue:174/255.0 alpha:1];
    [self.txtPassword setValue:[UIColor colorWithRed:48/255.0 green:157/255.0 blue:174/255.0 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    /****END Password TextView ******/
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 35)];
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 35)];
    
    if([appDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        LoginbtnImg=[UIImage imageNamed:@"Login_ar.png"];
        self.txtUsername.rightViewMode = UITextFieldViewModeAlways;
        self.txtPassword.rightViewMode = UITextFieldViewModeAlways;
        self.txtUsername.rightView= paddingView;
        self.txtPassword.rightView= paddingView2;
        
    }
    else{
        LoginbtnImg=[UIImage imageNamed:@"Login.png"];
        self.txtUsername.leftViewMode = UITextFieldViewModeAlways;
        self.txtPassword.leftViewMode = UITextFieldViewModeAlways;
        self.txtUsername.leftView= paddingView;
        self.txtPassword.leftView= paddingView2;
        
    }
    self.txtPassword.text=@"";
    
    /**** LOGIN BUTTON ******/
    
    self.btnLogin.autoresizingMask = UIViewAutoresizingNone;
//    self.btnLogin.backgroundColor=[UIColor colorWithRed:37/255.0f green:96/255.0f blue:172/255.0f alpha:1.0];
    [self.btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    CGFloat red = 0.0f / 255.0f;
    CGFloat green = 155.0f / 255.0f;
    CGFloat blue = 213.0f / 255.0f;
    [self.btnLogin setTitleColor:[UIColor colorWithRed:red green:green blue:blue alpha:1.0] forState:UIControlStateHighlighted];
//    self.btnLogin.layer.borderColor=[[UIColor grayColor] CGColor];
//    self.btnLogin.layer.cornerRadius=10;
    if([appDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        self.btnLogin.titleLabel.text=@"تسجيل الدخول";
        [self.btnLogin.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    }
    
    
    
    /**** END LOGIN BUTTON ******/
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self adjustControls:orientation];//set Interface according to ipad orientation
    
    [self getLicense];
    
    
    [self.view addSubview:self.txtUsername];
    
    
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];//Dismiss the keyboard.
    [self connect];
    [self stopIndicator];
    return YES;
}



-(void)startIndicator{
    [activityIndicatorObject startAnimating];
}
-(void)stopIndicator{
    [activityIndicatorObject stopAnimating];
}



- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    [self adjustControls:interfaceOrientation];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [txtPassword resignFirstResponder];
    [txtUsername resignFirstResponder];
	if(interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"loginPortrait.png"]];
        
        
    }
    else if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"loginLandscape.png"]];
        
    }
	
}


-(void)getLicense{
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //cancel clicked ...do your action
        if(alertView.tag==TAG_NO)
        {
            [alertLicense show];
        }
    }
    else if (buttonIndex == 1)
    {
        if(alertView.tag==TAG_OK)
        {
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSDate *dt=[NSDate date];
            int daysToAdd = 30;  // or 60 :-)
            NSDate *endDate = [dt dateByAddingTimeInterval:60*60*24*daysToAdd];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
            
            
            
            NSString *stringFromDate = [formatter stringFromDate:dt];
            NSString *stringEndDate= [formatter stringFromDate:endDate];
            [prefs setObject:stringFromDate forKey:@"trialStartDate"];
            [prefs setObject:stringEndDate forKey:@"trialEndDate"];
            [prefs setObject:@"Trial" forKey:@"Activated"];
            //if ([self checkLicense:licenseKey]) {
            // [prefs setObject:licenseKey forKey:@"LicenseKey"];
            [prefs synchronize];
            
            
            
            [super viewDidLoad];
        }
        else
        {
            [alertLicense show];
        }
        
        
    }
}

-(void)validateKey{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)Login:(id)sender{
    [self.txtPassword resignFirstResponder];
    [self.txtUsername resignFirstResponder];
    [self connect];
}

-(void)connect{
    @try
    {
        NSLog(@"Info: Enter Connect Method.");
        
        [NSThread detachNewThreadSelector:@selector(startIndicator) toTarget:self withObject:nil];
        
        NSString *username = self.txtUsername.text;
        NSString *password = self.txtPassword.text;
        
        //if fields are not empty
        
        if([username isEqual:@""] == FALSE && [password isEqual:@""] == FALSE)
        {
            NSString* encpass;
            NSData *encryptedData;
            if(appDelegate.EncryptionEnabled){
                NSLog(@"Info: Encrypting Password.");
                NSString * _key = @"EverTeamYears202020";
                StringEncryption *crypto = [[StringEncryption alloc] init];
                NSData *_secretData = [password dataUsingEncoding:NSUTF8StringEncoding];
                CCOptions padding = kCCOptionPKCS7Padding;
                encryptedData = [crypto encrypt:_secretData key:[_key dataUsingEncoding:NSUTF8StringEncoding] padding:&padding];
                encpass=[encryptedData base64EncodingWithLineLength:0];
            }
            else{
                encpass=self.txtPassword.text;
            }
            NSString* url;
            NSString* includeIcons;
            if ([[defaults objectForKey:@"iconsCache"] isEqualToString:@"YES"])
                includeIcons=@"false";
            else
                includeIcons=@"true";
            
            if(!appDelegate.SupportsServlets)
                url = [NSString stringWithFormat:@"http://%@/Login?userCode=%@&password=%@&language=%@&includeIcons=%@",appDelegate.serverUrl,username,encpass,appDelegate.IpadLanguage,includeIcons];
            else
                url = [NSString stringWithFormat:@"http://%@?action=Login&userCode=%@&password=%@&language=%@&includeIcons=%@",appDelegate.serverUrl,username,encpass,appDelegate.IpadLanguage,includeIcons];
            if(appDelegate.EncryptionEnabled){
                Password=[encryptedData base64EncodingWithLineLength:0];
            }else{
                Password=self.txtPassword.text;
            }
            
            [self performConnecting:url];
            
        }
        else
        {
            if ([username isEqual:@""])
                [self ShowMessage:NSLocalizedString(@"EmptyUserName", @"Empty username")];
 
            else if ([password isEqual:@""])
            [self ShowMessage:NSLocalizedString(@"EmptyPassword",@"EmptyPassword")];
            [self stopIndicator];
            if(!appDelegate.isOfflineMode){
                [defaults setObject:@"NO" forKey:@"LoginSuccess"];
                [defaults synchronize];
            }
        }
    }
    @catch (NSException *ex) {
        NSLog(@"Error: Error occured in LoginViewController Class in method Connect.\n Exception Name:%@ Exception Reason: %@",[ex name],[ex reason]);
        
    }
    
}

-(void)performConnecting:(NSString *)url{
    @try{
        if(appDelegate.isOfflineMode){
            if([[defaults objectForKey:@"LoginSuccess"] isEqualToString:@"NO"]){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You Must Login in online before!" delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"ok") otherButtonTitles:nil];
                [alert show];
              //  self.txtUsername.text=@"";
               // self.txtPassword.text=@"";
                [self stopIndicator];
                return;
                
            }else
                if([CParser LoadLogin:[self.txtUsername.text lowercaseString] password:Password]<=0){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Wrong username or password please try again" delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"ok") otherButtonTitles:nil];
                    [alert show];
                   // self.txtUsername.text=@"";
                   // self.txtPassword.text=@"";
                    [self stopIndicator];
                    return;
                }
        }
        CUser * user = [CParser loadUserWithData:url];
        if(user==nil){
            [self stopIndicator];
            NSLog(@"Error:loadUserWithData returned null user");
        }
            
        if(![user.ServerMessage isEqualToString:@"OK"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnableToConnect", @"unable to connect server") message:user.ServerMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
            [alert show];
            [defaults synchronize];
          //  self.txtUsername.text=@"";
          //  self.txtPassword.text=@"";
            [self stopIndicator];
            return;
        }
        else{
            NSLog(@"Info:Status OK");
            user.loginName=self.txtUsername.text;
            if(user.menu.count>0)
            {
                NSString *inboxIds=@"";
                if(appDelegate.isOfflineMode)
                {
                    for(CMenu *menu in user.menu)
                    {
                        inboxIds=[NSString stringWithFormat:@"%@%d,",inboxIds,menu.menuId];
                    }
                }
                else
                {
                    inboxIds=[NSString stringWithFormat:@"%d",((CMenu*)user.menu[0]).menuId];
                }
                
                appDelegate.user=user;
           
                if(!appDelegate.isOfflineMode){
                    IconsCached=@"YES";
                    [defaults setObject:IconsCached forKey:@"iconsCache"];
                    [defaults setObject:@"YES" forKey:@"LoginSuccess"];
                    [CParser cacheLogin:[self.txtUsername.text lowercaseString] password:Password];
                }
                appDelegate.menuSelectedItem=0;
                appDelegate.splitViewController=nil;
                UIStoryboard *    storyboard=[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
                appDelegate.splitViewController= [storyboard instantiateViewControllerWithIdentifier:@"SplitViewController"];
                UINavigationController* navigationController = [self.splitViewController.viewControllers lastObject];
                self.splitViewController.delegate = (id)navigationController.topViewController;
                containerView *container=[[containerView alloc] init];
                self.view.window.rootViewController=container;
                
                
            }
            else{
                NSLog(@"Info:Icons not Cached");
                [defaults setObject:@"NO" forKey:@"iconsCache"];
                [defaults synchronize];
                [self connect];
            }
        }
    }
    @catch (NSException *ex) {
        NSLog(@"Error: Error occured in LoginViewController Class in method performConnecting.\n Exception Name:%@ Exception Reason: %@",[ex name],[ex reason]);
    }
    
}


-(void)saveDocInCache:(CAttachment*)firstDoc inDirectory:(NSString*)dirName
{
	[firstDoc saveInCacheinDirectory:dirName fromSharepoint:appDelegate.isSharepoint];
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
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Progress.Connecting",@"Connecting ...") maskType:SVProgressHUDMaskTypeBlack];
}

- (void)dismiss {
	[SVProgressHUD dismiss];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
    
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        //DO Portrait
        
        const int movementDistance = -50; // tweak as needed
        const float movementDuration = 0.3f; // tweak as needed
        
        int movement = (up ? movementDistance : -movementDistance);
        
        [UIView beginAnimations: @"animateTextField" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        [UIView commitAnimations];
    }
    else{
        if (self.interfaceOrientation==UIInterfaceOrientationLandscapeRight){
            const float movementDuration = 0.3f; // tweak as needed
            
            [UIView beginAnimations: @"animateTextField" context: nil];
            [UIView setAnimationBeginsFromCurrentState: YES];
            [UIView setAnimationDuration: movementDuration];
            if(up)
            {
                if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                    self.view.frame = CGRectOffset(self.view.frame,140, 0);
                }
                else
                    self.view.frame = CGRectOffset(self.view.frame,0, -140);
            }
                else
                    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                        self.view.frame = CGRectOffset(self.view.frame,-140, 0);
                    }
            else
                    self.view.frame = CGRectOffset(self.view.frame,0, 140);
            
            [UIView commitAnimations];
        }
        if (self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft){
            const float movementDuration = 0.3f; // tweak as needed
            
            [UIView beginAnimations: @"animateTextField" context: nil];
            [UIView setAnimationBeginsFromCurrentState: YES];
            [UIView setAnimationDuration: movementDuration];
            if(up){
                if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                    self.view.frame = CGRectOffset(self.view.frame, -140, 0);
                }
                else
                    self.view.frame = CGRectOffset(self.view.frame, 0, -140);
            }
            else{
                if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                    self.view.frame = CGRectOffset(self.view.frame, 140, 0);
                }
                else
                    self.view.frame = CGRectOffset(self.view.frame, 0, 140);
            }
            
            [UIView commitAnimations];
        }}
    
    activityIndicatorObject.center=CGPointMake(btnLogin.frame.origin.x+btnLogin.frame.size.width+20,btnLogin.frame.origin.y+20);
    
}

-(void)adjustControls:(UIInterfaceOrientation)interfaceOrientation{
    if(interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"loginPortrait.png"]];
        self.txtUsername.frame=CGRectMake(157, 660, 470, 60);
        self.txtPassword.frame=CGRectMake(157, 741, 470, 60);
        if([appDelegate.IpadLanguage isEqualToString:@"en"])
            self.btnLogin.frame=CGRectMake(95, 850, LoginbtnImg.size.width, LoginbtnImg.size.height);
        else
            self.btnLogin.frame=CGRectMake(self.txtUsername.frame.size.width+self.txtUsername.frame.origin.x-LoginbtnImg.size.width+20, 850,  LoginbtnImg.size.width, LoginbtnImg.size.height);
        
    }
    else if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"loginLandscape.png"]];
        self.txtUsername.frame=CGRectMake(675, 300, 255, 60);
        self.txtPassword.frame=CGRectMake(675, 384, 255, 60);
        if([appDelegate.IpadLanguage isEqualToString:@"en"])
            self.btnLogin.frame=CGRectMake(self.txtUsername.frame.origin.x-47, 490,  LoginbtnImg.size.width, LoginbtnImg.size.height);
        else
            self.btnLogin.frame=CGRectMake(self.txtUsername.frame.size.width+self.txtUsername.frame.origin.x-LoginbtnImg.size.width+20, 490,  LoginbtnImg.size.width, LoginbtnImg.size.height);
        
    }
    activityIndicatorObject=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorObject.color=[UIColor colorWithRed:48/255.0 green:157/255.0 blue:174/255.0 alpha:1];
    activityIndicatorObject.center=CGPointMake(btnLogin.frame.origin.x+btnLogin.frame.size.width+20,btnLogin.frame.origin.y+20);
    activityIndicatorObject.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [self.view addSubview:activityIndicatorObject];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
	return YES;
}

@end
