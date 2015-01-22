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
#import "LookUpObject.h"
@interface CommentViewController ()

@end

@implementation CommentViewController{
    CGRect _realBounds;
    ActionTaskController* actionController;
    AppDelegate *mainDelegate;
    BOOL isDirectionDropDownOpened;
    BOOL isTransferToDropDownOpened;
    CRouteLabel* routeLabel;
    LookUpObject* SelectedObj;
}
@synthesize txtNote,isShown,Action;
@synthesize delegate;
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.superview.bounds = _realBounds;
}

- (void)viewDidLoad {
    _realBounds = self.view.bounds;
    [super viewDidLoad];
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
        SelectedObj=[[LookUpObject alloc]init];
        // self.view.alpha = 1;
        self.view.layer.cornerRadius=5;
        self.view.clipsToBounds=YES;
        self.view.layer.borderWidth=1.0;
        self.view.layer.borderColor=[[UIColor grayColor]CGColor];
        // self.view.backgroundColor= [UIColor colorWithRed:29/255.0f green:29/255.0f  blue:29/255.0f  alpha:1.0];
        CGFloat red = 1.0f / 255.0f;
        CGFloat green = 49.0f / 255.0f;
        CGFloat blue = 97.0f / 255.0f;
        self.view.backgroundColor= [UIColor colorWithRed:red green:green  blue:blue  alpha:1.0];
        
        UILabel *Titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width-20, 20)];
        NSString* local;
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
            local=@"المراسلة";
        else
            local=@"Correspondence";
        NSString * nameAct=[NSString stringWithFormat:@"%@ %@",self.Action.label,local];
        
        
        
        Titlelabel.text = nameAct;
        Titlelabel.textAlignment=NSTextAlignmentCenter;
        Titlelabel.backgroundColor = [UIColor clearColor];
        Titlelabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        Titlelabel.textColor=[UIColor whiteColor];
        
        
        
        
        
        
        
        lblTransferTo = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, frame.size.width-20, 20)];
        lblTransferTo.textAlignment=NSTextAlignmentLeft;
        lblTransferTo.text = NSLocalizedString(@"Choose",@"Please Choose");
        lblTransferTo.backgroundColor = [UIColor clearColor];
        lblTransferTo.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        lblTransferTo.textColor=[UIColor whiteColor];
        txtTransferTo=[[UITextField alloc]initWithFrame:CGRectMake(10, 55, frame.size.width-20, 30)];
        txtTransferTo.textAlignment=NSTextAlignmentLeft;
        txtTransferTo.backgroundColor = [UIColor whiteColor];
        ddbtnDestination = [UIButton buttonWithType:UIButtonTypeCustom];
        [ddbtnDestination setImage:[UIImage imageNamed:@"dropdown-button.png"] forState:UIControlStateNormal];
        ddbtnDestination.frame = CGRectMake(frame.size.width-30, 55, 20, 30);
        [txtTransferTo setUserInteractionEnabled:NO];
        [ddbtnDestination addTarget:self action:@selector(ShowDestinations) forControlEvents:UIControlEventTouchUpInside];
        txtTransferTo.rightViewMode = UITextFieldViewModeAlways;
        
        
        
        
        
        
        UILabel *lblNote ;
        if(self.Action.LookupId!=nil){
            lblNote = [[UILabel alloc] initWithFrame:CGRectMake(10, 105, frame.size.width-20, 20)];
            txtNote = [[UITextView alloc] initWithFrame:CGRectMake(10, 150, frame.size.width-20, frame.size.height-245)];
            
        }
        else{
            lblNote = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, frame.size.width-20, 20)];
            txtNote = [[UITextView alloc] initWithFrame:CGRectMake(10, 55, frame.size.width-20, frame.size.height-150)];
        }
        lblNote.text = NSLocalizedString(@"Note",@"Note");
        lblNote.textAlignment=NSTextAlignmentLeft;
        lblNote.backgroundColor = [UIColor clearColor];
        //lblNote.font = [UIFont fontWithName:@"Helvetica" size:16];
        lblNote.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        lblNote.textColor=[UIColor whiteColor];
        
        txtNote.font = [UIFont systemFontOfSize:15];
        txtNote.delegate = self;
        
        txtNote.autocorrectionType = UITextAutocorrectionTypeNo;
        txtNote.keyboardType = UIKeyboardTypeDefault;
        txtNote.returnKeyType = UIReturnKeyDone;
        
        
        NSInteger btnWidth=115;
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        closeButton.frame =CGRectMake(((frame.size.width-(2*btnWidth +50))/2)+btnWidth+50, 310, btnWidth, 35);
        closeButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        [closeButton setTitle:NSLocalizedString(@"Cancel",@"Cancel") forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        saveButton.frame = CGRectMake((frame.size.width-(2*btnWidth +50))/2, 310, btnWidth, 35);
        saveButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        [saveButton setTitle:NSLocalizedString(self.Action.label,@"Save") forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            lblNote.textAlignment=NSTextAlignmentRight;
            txtNote.textAlignment=NSTextAlignmentRight;
            txtTransferTo.textAlignment=NSTextAlignmentRight;
            lblTransferTo.textAlignment=NSTextAlignmentRight;
            ddbtnDestination.frame = CGRectMake(10, 55, 20, 30);
            
            
        }
        
        
        
        [self.view addSubview:Titlelabel];
        [self.view addSubview:lblNote];
        
        [self.view addSubview:txtNote];
        [self.view addSubview:saveButton];
        [self.view addSubview:closeButton];
        if(self.Action.LookupId!=nil){
            [self.view addSubview:txtTransferTo];
            [self.view addSubview:lblTransferTo];
            [self.view addSubview:ddbtnDestination];
        }
        
        
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
    UIAlertView *alertKO;
    if( txtTransferTo.text.length==0 &&self.Action.LookupId!=nil)
    {
        alertKO=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert",@"Alert") message:NSLocalizedString(@"Transfer.Message",@"Please fill all fields.") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok",@"OK") otherButtonTitles: nil];
        [alertKO show];
    }
    else{
        [NSThread detachNewThreadSelector:@selector(increaseLoading) toTarget:self withObject:nil];
        if([ActionName isEqualToString:@"SignAndSend"]){
            [delegate SignAndSendIt:ActionName document:self.document note:[self.txtNote.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        else{
            [delegate executeAction:Action.action note:[self.txtNote.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] movehome:Action.backhome ReasonId:SelectedObj.key];
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
}

#pragma mark delegate methods

-(void)ShowDestinations{
    mainDelegate.origin=0;
    isTransferToDropDownOpened =NO;
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[UITableView class]]){
            [view removeFromSuperview];
            isTransferToDropDownOpened =YES;
        }
        
    }
    if (!isTransferToDropDownOpened) {
        actionController = [[ActionTaskController alloc] initWithStyle:UITableViewStyleGrouped];
        actionController.rectFrame=CGRectMake(10, txtTransferTo.frame.origin.y+txtTransferTo.frame.size.height, self.view.frame.size.width-20,500) ;
        actionController.isDirection=NO;
        actionController.isDestinationSection=NO;
        actionController.delegate = self;
        actionController.Lookup =[mainDelegate.Lookups objectForKey:self.Action.LookupId];
        [self addChildViewController:actionController];
        [self.view addSubview:actionController.view];
        
    }
}
-(void)actionSelectedLookup:(LookUpObject *)destination{
    
    
    txtTransferTo.text=destination.value;
    SelectedObj=destination;
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[UITableView class]]){
            [view removeFromSuperview];
        }
        
    }
}

-(void)increaseLoading{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading", @"Loading...") maskType:SVProgressHUDMaskTypeBlack];
}
-(void)dismiss{
    [SVProgressHUD dismiss];
}
@end

