//
//  AcceptWithCommentViewController.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
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
    NSInteger btnWidth;
    NSInteger btnHeight;
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
        
        self.view.backgroundColor=mainDelegate.PopUpBgColor;
        UILabel *Titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, frame.size.width-100, 20)];
        NSString * nameAct=[NSString stringWithFormat:@"%@",self.Action.label];
        Titlelabel.text = nameAct;
        Titlelabel.textAlignment=NSTextAlignmentLeft;
        Titlelabel.backgroundColor = [UIColor clearColor];
        Titlelabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        Titlelabel.textColor=mainDelegate.selectedInboxColor;

        UILabel *lblNote = [[UILabel alloc] initWithFrame:CGRectMake(50, 110, frame.size.width-100, 20)];

        lblNote.text = NSLocalizedString(@"Note",@"Note");
        lblNote.textAlignment=NSTextAlignmentLeft;
        lblNote.backgroundColor = [UIColor clearColor];
        lblNote.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        lblNote.textColor=mainDelegate.PopUpTextColor;

        txtNote = [[UITextView alloc] initWithFrame:CGRectMake(50, 160, frame.size.width-100, frame.size.height-300)];
            
        txtNote.font = [UIFont systemFontOfSize:15];
        txtNote.delegate = self;
        txtNote.backgroundColor=mainDelegate.SearchViewColors;
        txtNote.autocorrectionType = UITextAutocorrectionTypeNo;
        txtNote.keyboardType = UIKeyboardTypeDefault;
        txtNote.returnKeyType = UIReturnKeyDone;
        txtNote.layer.cornerRadius=5;
        txtNote.clipsToBounds=YES;
        txtNote.layer.borderWidth=1.0;
        txtNote.layer.borderColor=mainDelegate.PopUpTextColor.CGColor;
        
        UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        UIImage *closeButtonImage;
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            closeButtonImage=[UIImage imageNamed:@"PopUpCancelBtn_ar.png"];
            btnWidth=closeButtonImage.size.width;
            btnHeight=closeButtonImage.size.height;
            closeButton.frame = CGRectMake(50, txtNote.frame.origin.y+txtNote.frame.size.height+40, btnWidth, btnHeight);
        }else{
            closeButtonImage=[UIImage imageNamed:@"PopUpCancelBtn_en.png"];
            btnWidth=closeButtonImage.size.width;
            btnHeight=closeButtonImage.size.height;
            closeButton.frame = CGRectMake((frame.size.width-50)-btnWidth, txtNote.frame.origin.y+txtNote.frame.size.height+40, btnWidth, btnHeight);
            [closeButton setTitleEdgeInsets: UIEdgeInsetsMake(0,20,0,0)];
        }
        [closeButton setBackgroundImage:closeButtonImage forState:UIControlStateNormal];
        closeButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:17];
        [closeButton setTitle:NSLocalizedString(@"Cancel",@"Cancel") forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
        
        
        
        
        
        UIButton* saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        UIImage *SaveButtonImage;
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            SaveButtonImage=[UIImage imageNamed:@"PopUpbtn.png"];
            btnWidth=SaveButtonImage.size.width;
            btnHeight=SaveButtonImage.size.height;
            saveButton.frame = CGRectMake(btnWidth+60, txtNote.frame.origin.y+txtNote.frame.size.height+40, btnWidth, btnHeight);
        }else{
            SaveButtonImage=[UIImage imageNamed:@"PopUpbtn.png"];
            btnWidth=SaveButtonImage.size.width;
            btnHeight=SaveButtonImage.size.height;
            saveButton.frame = CGRectMake((frame.size.width-60)-(2*btnWidth), txtNote.frame.origin.y+txtNote.frame.size.height+40, btnWidth, btnHeight);
            
        }
        [saveButton setBackgroundImage:SaveButtonImage forState:UIControlStateNormal];
        
        saveButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:14];
        [saveButton setTitle:NSLocalizedString(self.Action.label,@"Save") forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        [saveButton setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
        
             if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            lblNote.textAlignment=NSTextAlignmentRight;
            txtNote.textAlignment=NSTextAlignmentRight;
            Titlelabel.textAlignment=NSTextAlignmentRight;

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

