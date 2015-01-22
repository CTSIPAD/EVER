//
//  AcceptWithCommentViewController.m
//  CTSIpad
//
//  Created by DNA on 6/12/14.
//  Copyright (c) 2014 LBI. All rights reserved.
//

#import "CommentViewController.h"
#import "ActionTaskController.h"
#import "AppDelegate.h"
#import "CUser.h"
#import "PMCalendar.h"
#import "CRouteLabel.h"
#import "CDestination.h"
#import "SVProgressHUD.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)
@interface CommentViewController ()

@end

@implementation CommentViewController{
    CGRect _realBounds;
    ActionTaskController* actionController;
    AppDelegate *mainDelegate;
    BOOL isDirectionDropDownOpened;
    BOOL isTransferToDropDownOpened;
    CRouteLabel* routeLabel;
}
@synthesize txtNote,isShown,Action;
@synthesize delegate;
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.superview.bounds = _realBounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _realBounds=self.view.bounds;
}
- (id)initWithActionName:(CGRect)frame Action:(CAction *)action {
    
    self.Action =action;
    self = [self initWithFrame:frame];
    
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    if (self) {
        originalFrame = frame;
        mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        // self.view.alpha = 1;
        self.view.layer.cornerRadius=5;
        self.view.clipsToBounds=YES;
        self.view.layer.borderWidth=1.0;
        self.view.layer.borderColor=[[UIColor grayColor]CGColor];
        self.view.backgroundColor=mainDelegate.bgBlueColor;
        UILabel *Titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width-20, 20)];

        NSString * nameAct=[NSString stringWithFormat:@"%@",self.Action.label];
        
        
        Titlelabel.text = nameAct;
        Titlelabel.textAlignment=NSTextAlignmentCenter;
        Titlelabel.backgroundColor = [UIColor clearColor];
        Titlelabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        Titlelabel.textColor=[UIColor whiteColor];

        UILabel *lblNote = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, frame.size.width-40, 20)];

        lblNote.text = NSLocalizedString(@"Note",@"Note");
        lblNote.textAlignment=NSTextAlignmentLeft;
        lblNote.backgroundColor = [UIColor clearColor];
        lblNote.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        lblNote.textColor=[UIColor whiteColor];

        txtNote = [[UITextView alloc] init];
        if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
            txtNote.frame= CGRectMake(10, 55, frame.size.width-50, frame.size.height-150);
            else
            txtNote.frame= CGRectMake(10, 55, frame.size.width-35, frame.size.height-150);
        txtNote.font = [UIFont systemFontOfSize:15];
        txtNote.delegate = self;
        txtNote.backgroundColor=mainDelegate.textColor;
        txtNote.autocorrectionType = UITextAutocorrectionTypeNo;
        txtNote.keyboardType = UIKeyboardTypeDefault;
        txtNote.returnKeyType = UIReturnKeyDone;
        
        
        NSInteger btnWidth=115;
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            closeButton.frame = CGRectMake((frame.size.width-(2*btnWidth +50))/2, 310, btnWidth, 35);
        }
        else
        closeButton.frame =CGRectMake(((frame.size.width-(2*btnWidth +50))/2)+btnWidth+50, 310, btnWidth, 35);
        closeButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        [closeButton setTitle:NSLocalizedString(@"Cancel",@"Cancel") forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        //[closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
        closeButton.backgroundColor=mainDelegate.buttonColor;
        
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            saveButton.frame =CGRectMake(((frame.size.width-(2*btnWidth +50))/2)+btnWidth+50, 310, btnWidth, 35);
        }
        else
        saveButton.frame = CGRectMake((frame.size.width-(2*btnWidth +50))/2, 310, btnWidth, 35);
        saveButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        [saveButton setTitle:NSLocalizedString(self.Action.label,@"Save") forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        //[saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [saveButton setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
        saveButton.backgroundColor=mainDelegate.buttonColor;
        
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            lblNote.textAlignment=NSTextAlignmentRight;
            txtNote.textAlignment=NSTextAlignmentRight;
        }
        
        
        
        
        [self.view addSubview:Titlelabel];
        [self.view addSubview:lblNote];
        
        [self.view addSubview:txtNote];
        [self.view addSubview:saveButton];
        [self.view addSubview:closeButton];
        
        
        
    }
    return self;
}



- (void)show
{
    // NSLog(@"show");
    
    isShown = YES;
    self.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.view.alpha = 0;
    [UIView beginAnimations:@"showAlert" context:nil];
    [UIView setAnimationDelegate:self];
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 12, 1, 1, 1.0);
    self.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
    self.view.alpha = 1;
    [UIView commitAnimations];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self hide];
        
        //cancel clicked ...do your action
    }
    else if (buttonIndex == 1)
    {
        //[alertView textFieldAtIndex:0].text
        
    }
}
-(void)clear{
    txtNote.text=@"";
}
- (void)hide
{
    //  [delegate ActionMoveHome:self];//Use to move home
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (BOOL)disablesAutomaticKeyboardDismissal { return NO; }

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}




-(void)save{
    
    [NSThread detachNewThreadSelector:@selector(increaseLoading) toTarget:self withObject:nil];
    if([ActionName isEqualToString:@"SignAndSend"]){
        [delegate SignAndSendIt:ActionName document:self.document note:[self.txtNote.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    else{
        [delegate executeAction:Action.action note:[self.txtNote.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] movehome:Action.backhome];
    }
    [NSThread detachNewThreadSelector:@selector(dismiss) toTarget:self withObject:nil];
    
    [self dismissViewControllerAnimated:YES  completion:^{
            if(Action.backhome){
                if(mainDelegate.QuickActionClicked){
                    mainDelegate.QuickActionClicked=false;
                    
                    [delegate dismissUpload:self];
                    [delegate ActionMoveHome:self];
                    
                }
                else
                    [delegate ActionMoveHome:self];
            }
    }];
    
    
}


-(void)increaseLoading{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading", @"Loading...") maskType:SVProgressHUDMaskTypeBlack];
}
-(void)dismiss{
    [SVProgressHUD dismiss];
}
@end

