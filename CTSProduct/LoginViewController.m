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
    UIImageView *animatedSplashScreen;
    UIImageView *logo;
    UIImageView* Splash;
    UIScrollView *scr;
    UIPageControl *pgCtr;
    
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
  
    if(appDelegate.LoginSliderImages.count==0){
    
     animatedSplashScreen  = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
 [self addSubviewWithZoomInAnimation:animatedSplashScreen duration:0.4 delay:0 option:UIViewAnimationOptionAllowUserInteraction withParentView:self.view FromPoint:CGPointMake(animatedSplashScreen.frame.origin.x+animatedSplashScreen.frame.size.width/2, animatedSplashScreen.frame.origin.y+animatedSplashScreen.frame.size.height/2) originX:animatedSplashScreen.frame.origin.x originY:animatedSplashScreen.frame.origin.y];    animatedSplashScreen.animationImages= [NSArray arrayWithObjects:[UIImage imageNamed:@"splash1.png"],[UIImage imageNamed:@"splash2.png"],[UIImage imageNamed:@"splash4.png"], nil];
    animatedSplashScreen.animationRepeatCount=1;
    animatedSplashScreen.animationDuration=6;
    [animatedSplashScreen startAnimating];

   [self performSelector:@selector(Changelogo) withObject:nil afterDelay:4.1];
        [self performSelector:@selector(AddImage) withObject:nil afterDelay:6];

    logo  =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"splashlogo.png"]];
    
    [self addSubviewWithDropInAnimation:logo duration:0.4 withParentView:self.view FromPoint:CGPointMake(logo.frame.origin.x+self.view.frame.size.width/2, self.view.frame.origin.y+self.view.frame.size.height/2) originX:self.view.frame.origin.x/2 originY:self.view.frame.origin.y/2];

    
    
    dispatch_queue_t imageQueue = dispatch_queue_create("Image Queue",NULL);
    
        dispatch_async(imageQueue, ^{
            
            [CParser fetchPhotos];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(hideSplash:) withObject:animatedSplashScreen afterDelay:6.0];
                [self performSelector:@selector(initLoginView) withObject:nil afterDelay:6.0];
                
            });
            
        }); 
    
    }
    else
    {
        [self initLoginView];
    }
    
}
-(void)AddImage{
    Splash  = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];

    Splash.image=[UIImage imageNamed:@"splash4.png"];
    [logo removeFromSuperview];
    [self.view addSubview:Splash];
    [self.view addSubview:logo];

}
-(void)initLoginView{
    /**** UserName TextView ******/
    
    self.txtUsername.autoresizingMask = UIViewAutoresizingNone;
    //    self.txtUsername.layer.borderWidth=2;
    self.txtUsername.backgroundColor=[UIColor clearColor];
    self.txtUsername.layer.borderColor=[[UIColor clearColor] CGColor];
    //    self.txtUsername.layer.cornerRadius=10;
    //    self.txtUsername.clipsToBounds=YES;
    self.txtUsername.returnKeyType = UIReturnKeyGo;
    self.txtUsername.autocorrectionType=FALSE;
    self.txtUsername.placeholder=@"Username";
    self.txtUsername.text=@"dory";
    self.txtUsername.textColor=[UIColor colorWithRed:48/255.0 green:157/255.0 blue:174/255.0 alpha:1];
    [self.txtUsername setValue:[UIColor colorWithRed:48/255.0 green:157/255.0 blue:174/255.0 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    
    /**** END  UserName TextView ******/
    
    
    /**** Password TextView ******/
    
    self.txtPassword.autoresizingMask = UIViewAutoresizingNone;
    //    self.txtPassword.layer.borderWidth=2;
    self.txtPassword.backgroundColor=[UIColor clearColor];
    self.txtPassword.layer.borderColor=[[UIColor clearColor] CGColor];
    self.txtPassword.placeholder=@"Password";
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
        [self.btnLogin setTitle:@"تسجيل الدخول" forState:UIControlStateNormal];
        self.txtUsername.rightViewMode = UITextFieldViewModeAlways;
        self.txtPassword.rightViewMode = UITextFieldViewModeAlways;
        self.txtUsername.rightView= paddingView;
        self.txtPassword.rightView= paddingView2;
        self.txtUsername.placeholder=@"اسم المستخدم";
        self.txtPassword.placeholder=@"كلمة السر";

        
    }
    else{
        LoginbtnImg=[UIImage imageNamed:@"Login.png"];
        [self.btnLogin setTitle:@"" forState:UIControlStateNormal];
        self.txtUsername.leftViewMode = UITextFieldViewModeAlways;
        self.txtPassword.leftViewMode = UITextFieldViewModeAlways;
        self.txtUsername.leftView= paddingView;
        self.txtPassword.leftView= paddingView2;
        
    }
    [self.btnLogin setBackgroundImage:LoginbtnImg forState:UIControlStateNormal];

//    [self.btnLogin setImage:LoginbtnImg forState:UIControlStateNormal];

    self.txtPassword.text=@"dory";
    
    /**** LOGIN BUTTON ******/
    
    self.btnLogin.autoresizingMask = UIViewAutoresizingNone;
    //    self.btnLogin.backgroundColor=[UIColor colorWithRed:37/255.0f green:96/255.0f blue:172/255.0f alpha:1.0];
    [self.btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnLogin setTitleColor:appDelegate.titleColor forState:UIControlStateHighlighted];
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
    
    scr=[[UIScrollView alloc] initWithFrame:CGRectMake(33, 135,460, 515)];
    scr.tag = 1;
    scr.autoresizingMask=UIViewAutoresizingNone;
    [self.view addSubview:scr];
    [self setupScrollView:scr];
    pgCtr = [[UIPageControl alloc] initWithFrame:CGRectMake(33, scr.frame.size.height+scr.frame.origin.y-36, scr.frame.size.width, 36)];
    [pgCtr setTag:12];
    pgCtr.numberOfPages=appDelegate.LoginSliderImages.count;
    pgCtr.autoresizingMask=UIViewAutoresizingNone;
    //    pgCtr.backgroundColor=appDelegate.selectedInboxColor;
    [self.view addSubview:pgCtr];
}

-(void)Changelogo
{
    logo.image=[UIImage imageNamed:@"splashlogoLight.png"];
    
}
-(void)hideSplash:(id)object
{
    
    
    [logo removeFromSuperview];
    [animatedSplashScreen removeFromSuperview];
    [Splash removeFromSuperview];

//
//    CGContextRef imageContext = UIGraphicsGetCurrentContext();
//    [UIView beginAnimations:nil context:imageContext];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//    [UIView setAnimationDuration:3];
//    [UIView setAnimationDelegate:self];
//    animatedSplashScreen.alpha=0.0;
//    [UIView commitAnimations];
    
}

-(void) addSubviewWithZoomInAnimation:(UIView*)view duration:(float)secs delay:(float)del
                               option:(UIViewAnimationOptions)option withParentView:(UIView*)ParentView FromPoint:(CGPoint)sourcePoint
                              originX:(CGFloat)x originY:(CGFloat)y
{
    [self.view addSubview:view];
    [self.view bringSubviewToFront:view];
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
-(void) addSubviewWithDropInAnimation:(UIView*)view duration:(float)secs withParentView:(UIView*)ParentView FromPoint:(CGPoint)sourcePoint
                              originX:(CGFloat)x originY:(CGFloat)y
{
    [self.view addSubview:view];
    [self.view bringSubviewToFront:view];
    view.center=sourcePoint;
    
    CGAffineTransform trans= CGAffineTransformScale(view.transform,0.01,0.01);
    view.transform=trans;
    
    [ParentView addSubview:view];
    [ParentView bringSubviewToFront:view];
    
    [UIView animateWithDuration:0.6/1.5 delay:1 options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.transform=CGAffineTransformScale(CGAffineTransformIdentity,1.1,1.1);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.4/2
                                          animations:^{
                                              view.transform=CGAffineTransformScale(CGAffineTransformIdentity,0.9,0.9);
                                          }
                                          completion:^(BOOL finished){
                                              [UIView animateWithDuration:0.3/2
                                                               animations:^{
                                                                   view.transform=CGAffineTransformIdentity;
                                                               }];
                                          }];
                     }];
}


- (void)setupScrollView:(UIScrollView*)scrMain {
      for (int i=1; i<=appDelegate.LoginSliderImages.count; i++) {
        UIImage *image = [UIImage imageWithData:[appDelegate.LoginSliderImages objectAtIndex:i-1]];
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake((i-1)*scrMain.frame.size.width, 0, scrMain.frame.size.width, scrMain.frame.size.height)];
        imgV.contentMode=UIViewContentModeScaleToFill;
        [imgV setImage:image];
        imgV.tag=i+1;
        [scrMain addSubview:imgV];
    }
    [scrMain setContentSize:CGSizeMake(scrMain.frame.size.width*appDelegate.LoginSliderImages.count, scrMain.frame.size.height)];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(scrollingTimer) userInfo:nil repeats:YES];
}

- (void)scrollingTimer {
    UIScrollView *scrMain = (UIScrollView*) [self.view viewWithTag:1];
    pgCtr = (UIPageControl*) [self.view viewWithTag:12];
    CGFloat contentOffset = scrMain.contentOffset.x;
    int nextPage = (int)(contentOffset/scrMain.frame.size.width) + 1 ;
    if( nextPage!=appDelegate.LoginSliderImages.count )  {
        [scrMain scrollRectToVisible:CGRectMake(nextPage*scrMain.frame.size.width, 0, scrMain.frame.size.width, scrMain.frame.size.height) animated:YES];
        pgCtr.currentPage=nextPage;
    } else {
        [scrMain scrollRectToVisible:CGRectMake(0, 0, scrMain.frame.size.width, scrMain.frame.size.height) animated:YES];
        pgCtr.currentPage=0;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
        self.txtUsername.frame=CGRectMake(617, 319, 295, 50);
        self.txtPassword.frame=CGRectMake(617, 392, 295, 50);
        if([appDelegate.IpadLanguage isEqualToString:@"en"])
            self.btnLogin.frame=CGRectMake(self.txtUsername.frame.origin.x-55, 490,  LoginbtnImg.size.width, LoginbtnImg.size.height);
        else
            self.btnLogin.frame=CGRectMake(self.txtUsername.frame.size.width+self.txtUsername.frame.origin.x-LoginbtnImg.size.width+22, 490,  LoginbtnImg.size.width, LoginbtnImg.size.height);
        
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
