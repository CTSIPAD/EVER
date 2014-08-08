//
//  TransferViewController.m
//  CTSTest
//
//  Created by DNA on 1/14/14.
//  Copyright (c) 2014 LBI. All rights reserved.
//

#import "TransferViewController.h"
#import "ActionTaskController.h"
#import "AppDelegate.h"
#import "CUser.h"
#import "PMCalendar.h"
#import "CRouteLabel.h"
#import "CDestination.h"
#import "SVProgressHUD.h"
@interface TransferViewController (){
    UILabel *lblTransferTo;
    UIButton *ddbtnDestination;
    int origin;
}

@end

@implementation TransferViewController{
     CGRect _realBounds;
    ActionTaskController* actionController;

    BOOL isDirectionDropDownOpened;
    BOOL isTransferToDropDownOpened;
    UIButton *ddbtnDueDate ;
    CDestination* dest;
    CRouteLabel* routeLabel;
    UILabel *lblDirection;
    UIButton *ddbtnDirection;
    UILabel *lblDueDate;
    UILabel *lblNote;
    UIButton *saveButton;
    UIButton *closeButton;
    NSInteger btnWidth;
    AppDelegate *mainDelegate;
    UILabel *Titlelabel;
    UILabel *Section;
    UIButton *ddbtnDestinationSection;
}
@synthesize txtDirection,txtDueDate,txtNote,txtTransferTo,isShown,txtTransferToSection;
@synthesize pmCC;
@synthesize delegate;
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.superview.bounds = _realBounds;
}

- (void)viewDidLoad { _realBounds = self.view.bounds; [super viewDidLoad]; }

- (id)initWithFrame:(CGRect)frame
{
    if (self) {
        mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        originalFrame = frame;
        // self.view.alpha = 1;
        self.view.layer.cornerRadius=5;
        self.view.clipsToBounds=YES;
        self.view.layer.borderWidth=1.0;
        self.view.layer.borderColor=[[UIColor grayColor]CGColor];
        self.view.backgroundColor= [UIColor colorWithRed:29/255.0f green:29/255.0f  blue:29/255.0f  alpha:1.0];


        Titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width-20, 20)];
        Titlelabel.text = NSLocalizedString(@"Transfer.TransferCorrespondence",@"Transfer Correspondence");
        Titlelabel.backgroundColor = [UIColor clearColor];
        Titlelabel.textAlignment=NSTextAlignmentCenter;
        Titlelabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        Titlelabel.textColor=[UIColor whiteColor];
        
        Section= [[UILabel alloc] initWithFrame:CGRectMake(10, 45, frame.size.width-20, 20)];
        Section.textAlignment=NSTextAlignmentLeft;
        Section.text = NSLocalizedString(@"Transfer.TransferTo",@"Transfer To");
        Section.textAlignment=NSTextAlignmentLeft;
        Section.backgroundColor = [UIColor clearColor];
        Section.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        Section.textColor=[UIColor whiteColor];
        
        
        lblTransferTo = [[UILabel alloc] initWithFrame:CGRectMake(10, 105, frame.size.width-20, 20)];
        lblTransferTo.textAlignment=NSTextAlignmentLeft;
        lblTransferTo.text = NSLocalizedString(@"Transfer.TransferTo",@"Transfer To");
        lblTransferTo.backgroundColor = [UIColor clearColor];
        lblTransferTo.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        lblTransferTo.textColor=[UIColor whiteColor];
        txtTransferTo=[[UITextField alloc]initWithFrame:CGRectMake(10, 130, frame.size.width-20, 30)];
        txtTransferTo.textAlignment=NSTextAlignmentLeft;
        txtTransferTo.backgroundColor = [UIColor whiteColor];
        ddbtnDestination = [UIButton buttonWithType:UIButtonTypeCustom];
        [ddbtnDestination setImage:[UIImage imageNamed:@"dropdown-button.png"] forState:UIControlStateNormal];
        ddbtnDestination.frame = CGRectMake(frame.size.width-30, 130, 20, 30);
        [txtTransferTo setUserInteractionEnabled:NO];
        [ddbtnDestination addTarget:self action:@selector(ShowDestinations) forControlEvents:UIControlEventTouchUpInside];
        txtTransferTo.rightViewMode = UITextFieldViewModeAlways;
        
        
        txtTransferToSection=[[UITextField alloc]initWithFrame:CGRectMake(10, 70, frame.size.width-20, 30)];
        txtTransferToSection.textAlignment=NSTextAlignmentLeft;
        txtTransferToSection.backgroundColor = [UIColor whiteColor];
        ddbtnDestinationSection = [UIButton buttonWithType:UIButtonTypeCustom];
        [ddbtnDestinationSection setImage:[UIImage imageNamed:@"dropdown-button.png"] forState:UIControlStateNormal];
        ddbtnDestinationSection.frame = CGRectMake(frame.size.width-30, 70, 20, 30);
        [txtTransferToSection setUserInteractionEnabled:NO];
        [ddbtnDestinationSection addTarget:self action:@selector(ShowDestinationsSections) forControlEvents:UIControlEventTouchUpInside];
        txtTransferToSection.rightViewMode = UITextFieldViewModeAlways;
        
        
        
        lblDirection = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, frame.size.width/2-20, 20)];
        lblDirection.textAlignment=NSTextAlignmentLeft;
        lblDirection.text = NSLocalizedString(@"Transfer.Purpose",@"Purpose");
        lblDirection.textAlignment=NSTextAlignmentLeft;
        lblDirection.backgroundColor = [UIColor clearColor];
        lblDirection.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        lblDirection.textColor=[UIColor whiteColor];
        
        txtDirection=[[UITextField alloc]initWithFrame:CGRectMake(10, 145, frame.size.width/2-20, 30)];
        txtDirection.textAlignment=NSTextAlignmentLeft;
        txtDirection.backgroundColor = [UIColor whiteColor];
        [txtDirection setUserInteractionEnabled:NO];
        txtDirection.rightViewMode = UITextFieldViewModeAlways;

        ddbtnDirection = [UIButton buttonWithType:UIButtonTypeCustom];
        [ddbtnDirection setImage:[UIImage imageNamed:@"dropdown-button.png"] forState:UIControlStateNormal];
        ddbtnDirection.frame = CGRectMake(frame.size.width/2 - 20, 145, 20, 30);
        [ddbtnDirection addTarget:self action:@selector(ShowDirections) forControlEvents:UIControlEventTouchUpInside];
        
        
        lblDueDate = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2+10, 120, frame.size.width/2-20, 20)];
        lblDueDate.textAlignment=NSTextAlignmentLeft;
        lblDueDate.text = NSLocalizedString(@"Transfer.DueDate",@"DueDate");
        lblDueDate.textAlignment=NSTextAlignmentLeft;
        lblDueDate.backgroundColor = [UIColor clearColor];
        lblDueDate.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        lblDueDate.textColor=[UIColor whiteColor];
        
        txtDueDate=[[UITextField alloc]initWithFrame:CGRectMake(frame.size.width/2+10, 145, frame.size.width/2-20, 30)];
        txtDueDate.textAlignment=NSTextAlignmentLeft;
        txtDueDate.backgroundColor = [UIColor whiteColor];
        ddbtnDueDate = [UIButton buttonWithType:UIButtonTypeCustom];
        [ddbtnDueDate setImage:[UIImage imageNamed:@"dropdown-button.png"] forState:UIControlStateNormal];
        ddbtnDueDate.frame = CGRectMake(frame.size.width-30, 145, 20, 30);
        [ddbtnDueDate addTarget:self action:@selector(ShowCalendar:) forControlEvents:UIControlEventTouchUpInside];
       
        
        lblNote = [[UILabel alloc] initWithFrame:CGRectMake(10, 235, frame.size.width-20, 20)];
        lblNote.text = NSLocalizedString(@"Transfer.Note",@"Note");
        lblNote.textAlignment=NSTextAlignmentLeft;
        lblNote.backgroundColor = [UIColor clearColor];
        lblNote.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        lblNote.textColor=[UIColor whiteColor];
        
        txtNote = [[UITextView alloc] initWithFrame:CGRectMake(10, 260, frame.size.width-20, 100)];
        txtNote.font = [UIFont systemFontOfSize:15];
        txtNote.delegate = self;
        
        txtNote.autocorrectionType = UITextAutocorrectionTypeNo;
        txtNote.keyboardType = UIKeyboardTypeDefault;
        txtNote.returnKeyType = UIReturnKeyDone;
        
        
        btnWidth=115;
        
        closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        closeButton.frame =CGRectMake(((frame.size.width-(2*btnWidth +50))/2)+btnWidth+50, 370, btnWidth, 35);
         closeButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        [closeButton setTitle:NSLocalizedString(@"Cancel",@"Cancel") forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
       
        
        saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        saveButton.frame = CGRectMake((frame.size.width-(2*btnWidth +50))/2, 370, btnWidth, 35);
         saveButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        [saveButton setTitle:NSLocalizedString(@"Save",@"Save") forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
       
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            ddbtnDueDate.frame = CGRectMake(frame.size.width/2, 145, 20, 30);
            ddbtnDestinationSection.frame = CGRectMake(10, 70, 20, 30);
            ddbtnDirection.frame = CGRectMake(10, 145, 20, 30);
            ddbtnDestination.frame = CGRectMake(10, 130, 20, 30);

            txtNote.textAlignment=NSTextAlignmentRight;lblNote.textAlignment=NSTextAlignmentRight;
            txtDueDate.textAlignment=NSTextAlignmentRight;
            lblDueDate.textAlignment=NSTextAlignmentRight;
            txtDirection.textAlignment=NSTextAlignmentRight;
            lblDirection.textAlignment=NSTextAlignmentRight;
            txtTransferToSection.textAlignment=NSTextAlignmentRight;
            txtTransferTo.textAlignment=NSTextAlignmentRight;
            lblTransferTo.textAlignment=NSTextAlignmentRight;
            Section.textAlignment=NSTextAlignmentRight;
        }
        

       
        
        [self.view addSubview:Titlelabel];
        
        [self.view addSubview:lblDirection];
        [self.view addSubview:lblDueDate];
        [self.view addSubview:lblNote];
        
        [self.view addSubview:Section];
        [self.view addSubview:txtTransferToSection];
        [self.view addSubview:ddbtnDestinationSection];
        
       
        
         [self.view addSubview:txtDirection];
        [self.view addSubview:ddbtnDirection];
        
         [self.view addSubview:txtDueDate];
        [self.view addSubview:txtNote];
         [self.view addSubview:ddbtnDueDate];
        [self.view addSubview:saveButton];
        [self.view addSubview:closeButton];

       
        
    }
    return self;
}
-(void)ShowDestinationsSections{
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
        CUser* userTemp =  mainDelegate.user;
        actionController = [[ActionTaskController alloc] initWithStyle:UITableViewStyleGrouped];
        actionController.rectFrame=CGRectMake(10, 100, self.view.frame.size.width-20,150) ;
        actionController.isDirection=NO;
        actionController.isDestinationSection=YES;
        actionController.delegate = self;
        actionController.actions =[NSMutableArray  arrayWithArray:[userTemp.destinations allKeys]];
        [self addChildViewController:actionController];
        [self.view addSubview:actionController.view];
        
        
    }
}

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
        CUser* userTemp =  mainDelegate.user;
        actionController = [[ActionTaskController alloc] initWithStyle:UITableViewStyleGrouped];
        actionController.rectFrame=CGRectMake(10, 160, self.view.frame.size.width-20,150) ;
        actionController.isDirection=NO;
        actionController.isDestinationSection=NO;
        actionController.delegate = self;
        actionController.actions =[NSMutableArray  arrayWithArray:[userTemp.destinations objectForKey:mainDelegate.SectionSelected]];
        [self addChildViewController:actionController];
        [self.view addSubview:actionController.view];
        
    }
}

-(void)ShowDirections{
    mainDelegate.origin=50-origin;
    isDirectionDropDownOpened=NO;
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[UITableView class]]){
            [view removeFromSuperview];
            isDirectionDropDownOpened=YES;
        }
        
    }
    if (!isDirectionDropDownOpened) {
        //jen dropdown
        CUser* userTemp =  mainDelegate.user;
        actionController = [[ActionTaskController alloc] initWithStyle:UITableViewStyleGrouped];
        actionController.rectFrame=CGRectMake(10, 225, self.view.frame.size.width/2-20,150) ;
        actionController.isDirection=YES;
        actionController.delegate = self;
        actionController.actions =[NSMutableArray  arrayWithArray:userTemp.routeLabels];
        [self addChildViewController:actionController];
        [self.view addSubview:actionController.view];
       
    }
   
}

-(IBAction)ShowCalendar:(id)sender{
    mainDelegate.origin=50;
    if ([self.pmCC isCalendarVisible])
    {
        [self.pmCC dismissCalendarAnimated:NO];
    }
    
    BOOL isPopover = YES;
    
     self.pmCC = [[PMCalendarController alloc] initWithThemeName:@"default"];
    self.pmCC.delegate = self;
    self.pmCC.mondayFirstDayOfWeek = NO;
    [self.pmCC presentCalendarFromView:ddbtnDueDate
              permittedArrowDirections:PMCalendarArrowDirectionUp
                             isPopover:isPopover
                              animated:YES];

self.pmCC.period = [PMPeriod oneDayPeriodWithDate:[NSDate date]];
[self calendarController:pmCC didChangePeriod:pmCC.period];
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
    //    NSLog(@"hide");
    //    isShown = NO;
    //    [UIView beginAnimations:@"hideAlert" context:nil];
    //    [UIView setAnimationDelegate:self];
    //    self.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
    //    self.view.alpha = 0;
    //    [UIView commitAnimations];
    
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
    if(txtDirection.text.length==0 || txtTransferTo.text.length==0 || txtDueDate.text.length==0)
    {
        alertKO=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert",@"Alert") message:NSLocalizedString(@"Transfer.Message",@"Please fill all fields.") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok",@"OK") otherButtonTitles: nil];
        [alertKO show];
    }
    else{
        [NSThread detachNewThreadSelector:@selector(increaseLoading) toTarget:self withObject:nil];
        [delegate destinationSelected:dest withRouteLabel:routeLabel routeNote:txtNote.text withDueDate:txtDueDate.text viewController:self ] ;
        [NSThread detachNewThreadSelector:@selector(dismiss) toTarget:self withObject:nil];
    }
}

#pragma mark delegate methods

-(void)actionSelectedDirection:(CRouteLabel*)route{
    
   
        txtDirection.text=route.name;
    routeLabel=route;

    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[UITableView class]]){
            [view removeFromSuperview];
        }
        
    }
}
-(void)actionSelectedDestination:(CDestination *)destination{
    
    
    txtTransferTo.text=destination.name;
    
    dest=destination;
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[UITableView class]]){
            [view removeFromSuperview];
        }
        
    }
}

-(void)actionSelectedDestinationSection:(NSString *)section{
    

    txtTransferToSection.text=section;
    mainDelegate.SectionSelected=section;
    [lblTransferTo removeFromSuperview];
    [txtTransferTo removeFromSuperview];
    [ddbtnDestination removeFromSuperview];
    lblTransferTo.text=[NSString stringWithFormat:@"Select %@",section];
    lblDirection.frame =CGRectMake(10, 170, originalFrame.size.width/2-20, 20);
    txtDirection.frame=CGRectMake(10, 195, originalFrame.size.width/2-20, 30);
    ddbtnDirection.frame = CGRectMake(originalFrame.size.width/2 - 20, 195, 20, 30);
    lblDueDate.frame = CGRectMake(originalFrame.size.width/2+10, 170, originalFrame.size.width/2-20, 20);
    txtDueDate.frame=CGRectMake(originalFrame.size.width/2+10, 195, originalFrame.size.width/2-20, 30);
    ddbtnDueDate.frame = CGRectMake(originalFrame.size.width-30, 195, 20, 30);
    lblNote.frame = CGRectMake(10, 235, originalFrame.size.width-20, 20);
    txtNote.frame = CGRectMake(10, 260, originalFrame.size.width-20, 100);
    closeButton.frame =CGRectMake(((originalFrame.size.width-(2*btnWidth +50))/2)+btnWidth+50, 420, btnWidth, 35);
    saveButton.frame = CGRectMake((originalFrame.size.width-(2*btnWidth +50))/2, 420, btnWidth, 35);
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        ddbtnDueDate.frame = CGRectMake(originalFrame.size.width/2, 195, 20, 30);
        ddbtnDirection.frame = CGRectMake(10, 195, 20, 30);
    }
    origin=50;
    [self.view addSubview:lblTransferTo];
    [self.view addSubview:txtTransferTo];
    [self.view addSubview:ddbtnDestination];
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[UITableView class]]){
            [view removeFromSuperview];
        }
        
    }
}
- (void)calendarController:(PMCalendarController *)calendarController didChangePeriod:(PMPeriod *)newPeriod
{
    NSString *currentDate = [[NSDate date] dateStringWithFormat:@"yyyy-MM-dd"];
    NSString *newPeriodDate = [newPeriod.endDate dateStringWithFormat:@"yyyy-MM-dd"];
    if(![newPeriodDate isEqualToString:currentDate])
    {
        txtDueDate.text = [NSString stringWithFormat:@"%@",newPeriodDate];
        
        [pmCC dismissCalendarAnimated:YES];
    }
    
}
-(void)increaseLoading{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading", @"Loading...") maskType:SVProgressHUDMaskTypeBlack];
}
-(void)dismiss{
    [SVProgressHUD dismiss];
}

@end
