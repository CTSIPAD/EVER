//
//  TransferViewController.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "TransferViewController.h"
#import "ActionTaskController.h"
#import "AppDelegate.h"
#import "CUser.h"
#import "PMCalendar.h"
#import "CRouteLabel.h"
#import "CDestination.h"
#import "SVProgressHUD.h"
#import "CParser.h"
@interface TransferViewController (){
    UILabel *lblTransferTo;
    UIButton *ddbtnDestination;
    int origin;
    NSString* laseSection;
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
    LookUpObject* sect;
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
    BOOL ShowCalender;
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
        self.view.layer.cornerRadius=5;
        self.view.clipsToBounds=YES;
        self.view.layer.borderWidth=1.0;
        self.view.layer.borderColor=[[UIColor grayColor]CGColor];
        

        self.view.backgroundColor=mainDelegate.buttonColor;
        
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
        [ddbtnDestination setImage:[UIImage imageNamed:@"dropDownTag.png"] forState:UIControlStateNormal];
        ddbtnDestination.frame=CGRectMake(frame.size.width-50, 70, 40, 30);
        [txtTransferTo addTarget:self action:@selector(textFieldDidChange:)
                                        forControlEvents:UIControlEventEditingChanged];
        [ddbtnDestination addTarget:self action:@selector(ShowDestinations) forControlEvents:UIControlEventTouchUpInside];
        txtTransferTo.rightViewMode = UITextFieldViewModeAlways;
        
        
        txtTransferToSection=[[UITextField alloc]initWithFrame:CGRectMake(10, 70, frame.size.width-20, 30)];
        txtTransferToSection.textAlignment=NSTextAlignmentLeft;
        txtTransferToSection.backgroundColor=mainDelegate.SearchViewColors;
        ddbtnDestinationSection = [UIButton buttonWithType:UIButtonTypeCustom];
        [ddbtnDestinationSection setImage:[UIImage imageNamed:@"dropDownTag.png"] forState:UIControlStateNormal];
        ddbtnDestinationSection.frame = CGRectMake(frame.size.width-50, 70, 40, 30);
        ddbtnDestinationSection.backgroundColor=mainDelegate.buttonColor;
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
       // txtDirection.backgroundColor = [UIColor whiteColor];
        txtDirection.backgroundColor=mainDelegate.SearchViewColors;
        [txtDirection setUserInteractionEnabled:NO];
        txtDirection.rightViewMode = UITextFieldViewModeAlways;
        
        ddbtnDirection = [UIButton buttonWithType:UIButtonTypeCustom];
        [ddbtnDirection setImage:[UIImage imageNamed:@"dropDownTag.png"] forState:UIControlStateNormal];
        ddbtnDirection.frame = CGRectMake(frame.size.width/2 - 50, 145, 40, 30);
        ddbtnDirection.backgroundColor=mainDelegate.buttonColor;
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
        txtDueDate.enabled=NO;
        txtDueDate.backgroundColor=mainDelegate.SearchViewColors;
        
        ddbtnDueDate = [UIButton buttonWithType:UIButtonTypeCustom];
        [ddbtnDueDate setImage:[UIImage imageNamed:@"calendar.png"] forState:UIControlStateNormal];
        ddbtnDueDate.frame = CGRectMake(frame.size.width-45, 145, 40, 30);
        ddbtnDueDate.backgroundColor=mainDelegate.buttonColor;
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
        txtNote.backgroundColor=mainDelegate.SearchViewColors;
        txtNote.autocorrectionType = UITextAutocorrectionTypeNo;
        txtNote.keyboardType = UIKeyboardTypeDefault;
        txtNote.returnKeyType = UIReturnKeyDone;
        
        
        btnWidth=115;
        
        closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
             closeButton.frame = CGRectMake((frame.size.width-(2*btnWidth +50))/2, 370, btnWidth, 35);
        }
        else
        closeButton.frame =CGRectMake(((frame.size.width-(2*btnWidth +50))/2)+btnWidth+50, 370, btnWidth, 35);
        closeButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        [closeButton setTitle:NSLocalizedString(@"Cancel",@"Cancel") forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
       // [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
        closeButton.backgroundColor=mainDelegate.selectedInboxColor;
        
        saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            saveButton.frame =CGRectMake(((frame.size.width-(2*btnWidth +50))/2)+btnWidth+50, 370, btnWidth, 35);
        }
        else
        saveButton.frame = CGRectMake((frame.size.width-(2*btnWidth +50))/2, 370, btnWidth, 35);
        saveButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        [saveButton setTitle:NSLocalizedString(@"Transfer",@"Transfer") forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        //[saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [saveButton setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
        saveButton.backgroundColor=mainDelegate.selectedInboxColor;
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            // arabic frame
            ddbtnDueDate.frame = CGRectMake(frame.size.width/2, 145, 40, 30);
            ddbtnDestinationSection.frame = CGRectMake(10, 70, 40, 30);
            ddbtnDirection.frame = CGRectMake(10, 145, 40, 30);
            ddbtnDestination.frame = CGRectMake(10, 130, 40, 30);
            
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
-(void)textFieldDidChange:(UITextField *)textField{
    
if(textField.text.length>=mainDelegate.Char_count){
    mainDelegate.origin=0;
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[UITableView class]]){
            [view removeFromSuperview];
        }
        
    }
    
      
        NSString* url;
        
        if(!mainDelegate.SupportsServlets)
            url = [NSString stringWithFormat:@"http://%@/FindRecipient?typeId=%@&criteria=%@&token=%@&language=%@",mainDelegate.serverUrl,sect.key,textField.text,mainDelegate.user.token,mainDelegate.IpadLanguage];
        else
            url = [NSString stringWithFormat:@"http://%@?action=FindRecipient&typeId=%@&criteria=%@&token=%@&language=%@",mainDelegate.serverUrl,sect.key,textField.text,mainDelegate.user.token,mainDelegate.IpadLanguage];
        CUser* userTemp =  mainDelegate.user;
    
   // [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loading ...") maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
          NSMutableArray* dic=[CParser loadRecipients:url section:sect.key];
        dispatch_async(dispatch_get_main_queue(), ^{
            [ userTemp.destinations setObject:dic forKey:sect.key];
            if(dic.count>0){
                CUser* userTemp =  mainDelegate.user;
                actionController = [[ActionTaskController alloc] initWithStyle:UITableViewStyleGrouped];
                actionController.rectFrame=CGRectMake(10, 160, self.view.frame.size.width-20,150) ;
                actionController.isDirection=NO;
                actionController.isDestinationSection=NO;
                actionController.delegate = self;
                actionController.actions =[NSMutableArray  arrayWithArray:[userTemp.destinations objectForKey:sect.key]];
                [self addChildViewController:actionController];
                [self.view addSubview:actionController.view];
                
            }
           // [SVProgressHUD dismiss];
        });
        
    });

  
    

    }
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
         if(userTemp.Sections.count>0){
        actionController = [[ActionTaskController alloc] initWithStyle:UITableViewStyleGrouped];
        actionController.rectFrame=CGRectMake(10, 100, self.view.frame.size.width-19,150) ;
        actionController.isDirection=NO;
        actionController.isDestinationSection=YES;
        actionController.delegate = self;
        actionController.actions =userTemp.Sections;
        [self addChildViewController:actionController];
        [self.view addSubview:actionController.view];
         }
        
    }
}

-(void)ShowDestinations{
    CUser* userTemp =  mainDelegate.user;
    if(((NSMutableArray*)[userTemp.destinations objectForKey:sect.key]).count>0){
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
        if(userTemp.destinations.count>0){
        actionController = [[ActionTaskController alloc] initWithStyle:UITableViewStyleGrouped];
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            actionController.rectFrame=CGRectMake(10, 160, self.view.frame.size.width-20,150) ;
        }
        else
        actionController.rectFrame=CGRectMake(10, 160, self.view.frame.size.width-15,150) ;
        actionController.isDirection=NO;
        actionController.isDestinationSection=NO;
        actionController.delegate = self;
        actionController.actions =[NSMutableArray  arrayWithArray:[userTemp.destinations objectForKey:sect.key]];
        [self addChildViewController:actionController];
        [self.view addSubview:actionController.view];
        }
    }
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
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            actionController.rectFrame=CGRectMake(10, 225, self.view.frame.size.width/2-20,150) ;
        }
        else
        actionController.rectFrame=CGRectMake(10, 225, self.view.frame.size.width/2-15,150) ;
        actionController.isDirection=YES;
        actionController.delegate = self;
        actionController.actions =[NSMutableArray  arrayWithArray:userTemp.routeLabels];
        [self addChildViewController:actionController];
        [self.view addSubview:actionController.view];
        
    }
    
}

-(IBAction)ShowCalendar:(id)sender{
    ShowCalender=YES;
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
    ShowCalender=NO;

}

- (void)show
{

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
        alertKO=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert",@"Alert") message:NSLocalizedString(@"Transfer.Message",@"Please fill all fields.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
        [alertKO show];
    }
    else{
        [NSThread detachNewThreadSelector:@selector(increaseLoading) toTarget:self withObject:nil];
        [delegate destinationSelected:dest withRouteLabel:routeLabel routeNote:txtNote.text withDueDate:txtDueDate.text viewController:self ] ;
        if(mainDelegate.QuickActionClicked)
            mainDelegate.QuickActionClicked=false;
        
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

-(void)actionSelectedDestinationSection:(LookUpObject *)section{
    if (![section.value isEqualToString:laseSection] && ![laseSection isEqualToString:@""]) {
        txtTransferTo.text=@"";
    }

    txtTransferToSection.text=section.value;
    laseSection=section.value;
    sect=section;
    [lblTransferTo removeFromSuperview];
    [txtTransferTo removeFromSuperview];
    [ddbtnDestination removeFromSuperview];
    NSString *selectString=NSLocalizedString(@"select", @"selected section");
    lblTransferTo.text=[NSString stringWithFormat:@"%@ %@",selectString,section.value];
    txtTransferTo.backgroundColor=mainDelegate.SearchViewColors;
    if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
        ddbtnDestinationSection.frame = CGRectMake(10, 70, 40, 30);
    }
    else
    {
        ddbtnDestination.frame= CGRectMake(originalFrame.size.width-40,  130, 35, 30);
    }
    ddbtnDestination.backgroundColor=mainDelegate.buttonColor;
    lblDirection.frame =CGRectMake(10, 170, originalFrame.size.width/2-20, 20);
    txtDirection.frame=CGRectMake(10, 195, originalFrame.size.width/2-20, 30);
    txtDirection.backgroundColor=mainDelegate.SearchViewColors;
    ddbtnDirection.frame = CGRectMake(originalFrame.size.width/2 - 45, 195, 40, 30);
    ddbtnDirection.backgroundColor=mainDelegate.buttonColor;
    lblDueDate.frame = CGRectMake(originalFrame.size.width/2+20, 170, originalFrame.size.width/2-25, 20);
    txtDueDate.frame=CGRectMake(originalFrame.size.width/2+20, 195, originalFrame.size.width/2-30, 30);
    txtDueDate.backgroundColor=mainDelegate.SearchViewColors;
    ddbtnDueDate.frame = CGRectMake(originalFrame.size.width-40, 195, 35, 30);
    ddbtnDueDate.backgroundColor=mainDelegate.buttonColor;
    lblNote.frame = CGRectMake(10, 235, originalFrame.size.width-20, 20);
    txtNote.frame = CGRectMake(10, 260, originalFrame.size.width-20, 100);
   
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        saveButton.frame =CGRectMake(((originalFrame.size.width-(2*btnWidth +50))/2)+btnWidth+50, 420, btnWidth, 35);
        closeButton.frame = CGRectMake((originalFrame.size.width-(2*btnWidth +50))/2, 420, btnWidth, 35);
        ddbtnDueDate.frame = CGRectMake(originalFrame.size.width/2, 195, 35, 30);
        ddbtnDirection.frame = CGRectMake(10, 195, 35, 30);
    }
    else
    {
        closeButton.frame =CGRectMake(((originalFrame.size.width-(2*btnWidth +50))/2)+btnWidth+50, 420, btnWidth, 35);
        saveButton.frame = CGRectMake((originalFrame.size.width-(2*btnWidth +50))/2, 420, btnWidth, 35);
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
    NSString *newPeriodDate = [newPeriod.endDate dateStringWithFormat:@"yyyy-MM-dd"];
    txtDueDate.text = [NSString stringWithFormat:@"%@",newPeriodDate];
    if(!ShowCalender)
    {
        
        
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
