//
//  AdvanceSearchTableViewCell.m
//  CTSTest
//
//  Created by DNA on 1/27/14.
//  Copyright (c) 2014 LBI. All rights reserved.
//

#import "AdvanceSearchTableViewCell.h"
#import "CSearchCriteria.h"
#import "PMCalendar.h"
#import "DropDownView.h"
#import "AppDelegate.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)
@implementation AdvanceSearchTableViewCell{
    UIButton *button;
    DropDownView* dropDownView;
    CSearchCriteria* criteria;
    AppDelegate* appDelegate;
    ActionTaskController *actionController;
    UIView *calendarView;
    BOOL ShowCalender;
    int mywidth;
}
@synthesize txtCriteria,pmCC,criteria,lbltitle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIInterfaceOrientation orientation=[[UIApplication sharedApplication]statusBarOrientation];
        lbltitle=[[UILabel alloc]init];
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            mywidth=120;
        }else{
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                mywidth=120;
            }
            else
                mywidth=360;
            
        }
        
        UIColor *textColor=[UIColor colorWithRed:195.0/255.0f green:224.0/255.0f blue:242.0/255.0f alpha:1.0f];
        
        self.backgroundColor=[UIColor blackColor];
        if ([appDelegate.IpadLanguage isEqualToString:@"ar"]) {
            if (!SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                lbltitle.Frame=CGRectMake(self.frame.size.width-30, 5, 445, 25);
            }
            else
            {
                
                lbltitle.Frame=CGRectMake(self.frame.size.width-35, 5, 445, 25);
            }
            
            
        }
        else
        {
            if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                lbltitle.Frame=CGRectMake(50, 5, 445, 25);
            }
            else
                lbltitle.Frame=CGRectMake(50, 5, 445, 25);
            
        }
        
        
        lbltitle.textColor=[UIColor colorWithRed:1.0f/255.0f green:50.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
        lbltitle.font=[UIFont fontWithName:@"Helvetica-Bold" size:16.0];
        [self addSubview:lbltitle];
        txtCriteria=[[UITextField alloc]initWithFrame:CGRectMake(20, 30, [UIScreen mainScreen].bounds.size.width-70, 45)];
        txtCriteria.backgroundColor=textColor;
        txtCriteria.textColor=[UIColor blackColor];
        
        if([appDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            txtCriteria.textAlignment=NSTextAlignmentRight;
            lbltitle.textAlignment=NSTextAlignmentRight;
            
        }
        
        
        [self addSubview:txtCriteria];
        
    }
    return self;
}


-(void)updateCellwithCriteria:(CSearchCriteria*)searchCriteria{
    if(searchCriteria !=nil){
        criteria=searchCriteria;
        
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            if([appDelegate.IpadLanguage isEqualToString:@"en"]){
                
                txtCriteria.frame=CGRectMake(50, 30, [UIScreen mainScreen].bounds.size.width-110, 45);
            }
            else{
                txtCriteria.frame=CGRectMake(35, 30, [UIScreen mainScreen].bounds.size.width-70, 45);
                
            }
        }
        else{
            if([appDelegate.IpadLanguage isEqualToString:@"en"])
            {
                txtCriteria.frame=CGRectMake(50, 30, [UIScreen mainScreen].bounds.size.width-mywidth+15, 45);
            }
            else{
                txtCriteria.frame=CGRectMake(35, 30, [UIScreen mainScreen].bounds.size.width-(mywidth-50), 45);
            }
        }
        txtCriteria.enabled=true;
        lbltitle.text=searchCriteria.label;
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(2, 2, 50, 45);
        
        txtCriteria.tag=self.tag;
        if([ criteria.type.lowercaseString isEqualToString:@"date"]){
            if([appDelegate.IpadLanguage isEqualToString:@"en"]){
                txtCriteria.frame=CGRectMake(50, 30, [UIScreen mainScreen].bounds.size.width-mywidth-35, 45);
            }
            else{
                txtCriteria.frame=CGRectMake(35, 30, [UIScreen mainScreen].bounds.size.width-mywidth, 45);
            }
            calendarView=[[UIView alloc] initWithFrame:CGRectMake(txtCriteria.frame.origin.x+txtCriteria.frame.size.width,30, 50, 45)];
            calendarView.backgroundColor=appDelegate.buttonColor;
            [calendarView addSubview:button];
            txtCriteria.enabled=false;
            txtCriteria.clearButtonMode = UITextFieldViewModeWhileEditing;
            [button setImage:[UIImage imageNamed:@"calendar.png"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(ShowCalendar) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:calendarView];
            txtCriteria.rightViewMode = UITextFieldViewModeUnlessEditing;
            
        }
        else if([criteria.type.lowercaseString isEqualToString:@"list"]){
            
            txtCriteria.clearButtonMode = UITextFieldViewModeWhileEditing;
            [button setImage:[UIImage imageNamed:@"dropDownTag.png"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(Showlist) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor=[UIColor colorWithRed:149.0/255.0f green:194.0/255.0f blue:233.0/255.0f alpha:1.0f];
            txtCriteria.enabled=false;
            if([appDelegate.IpadLanguage isEqualToString:@"en"]){
                txtCriteria.frame=CGRectMake(50, 30, [UIScreen mainScreen].bounds.size.width-mywidth-35, 45);
            }
            else{
                txtCriteria.frame=CGRectMake(35, 30, [UIScreen mainScreen].bounds.size.width-mywidth, 45);
            }
            button.frame=CGRectMake(txtCriteria.frame.origin.x+txtCriteria.frame.size.width,30, 50, 45);
            
            [self addSubview:button];
            txtCriteria.rightViewMode = UITextFieldViewModeUnlessEditing;
            
            self.criteria=searchCriteria;
            dropDownView.myDelegate = self;
            
        }
    }
}

-(void)Showlist{
    
    [self resignFirstResponder];
    appDelegate.origin=0;
    opened =NO;
    
    
    for (UIView *view in self.superview.subviews)
    {
        if ([view isMemberOfClass:[UITableView class]]){
            [view removeFromSuperview];
            opened=YES;
            
        }
        
    }
    if (!opened) {
        actionController = [[ActionTaskController alloc] initWithStyle:UITableViewStyleGrouped];
        if ([appDelegate.IpadLanguage isEqualToString:@"ar"]) {
            actionController.rectFrame=CGRectMake(self.frame.origin.x+35, self.frame.origin.y+txtCriteria.frame.origin.y+txtCriteria.frame.size.height, txtCriteria.frame.size.width,500) ;
        }
        else
            actionController.rectFrame=CGRectMake(self.frame.origin.x+48, self.frame.origin.y+txtCriteria.frame.origin.y+txtCriteria.frame.size.height, txtCriteria.frame.size.width,500) ;
        
        actionController.isDirection=NO;
        actionController.isDestinationSection=NO;
        actionController.delegate = self;
        actionController.Lookup =self.criteria.options;
        [self.superview addSubview:actionController.view];
        
    }
}
-(void)actionSelectedLookup:(LookUpObject *)destination{
    
    
    txtCriteria.text=destination.value;
    _listobj=[[LookUpObject alloc]init];
    _listobj=destination;
    for (UIView *view in self.superview.subviews)
    {
        if ([view isMemberOfClass:[UITableView class]]){
            [view removeFromSuperview];
        }
        
    }
}

- (void)setFrame:(CGRect)frame {
    NSInteger i=0;
    if (self.superview){
        i=self.superview.frame.size.width;
        float cellWidth = self.frame.size.width;
        frame.origin.x = (i - cellWidth) / 2;
        frame.size.width = cellWidth;
    }
    
    [super setFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
-(void)ShowCalendar{
    ShowCalender=YES;
    if ([self.pmCC isCalendarVisible])
    {
        [self.pmCC dismissCalendarAnimated:NO];
    }
    
    self.pmCC = [[PMCalendarController alloc] initWithThemeName:@"default"];
    self.pmCC.delegate = self;
    self.pmCC.mondayFirstDayOfWeek = NO;
    //((self.tag+1)*90)
    [self.pmCC presentCalendarFromRect:CGRectMake(calendarView.frame.origin.x,self.frame.origin.y+30 , calendarView.frame.size.width, calendarView.frame.size.height) inView:self.superview.superview permittedArrowDirections:PMCalendarArrowDirectionRight|PMCalendarArrowDirectionLeft animated:YES];
    
    self.pmCC.period = [PMPeriod oneDayPeriodWithDate:[NSDate date]];
    [self calendarController:pmCC didChangePeriod:pmCC.period];
    [self bringSubviewToFront:self.pmCC.view];
    ShowCalender=NO;
}

- (void)calendarController:(PMCalendarController *)calendarController didChangePeriod:(PMPeriod *)newPeriod
{
    //  NSString *currentDate = [[NSDate date] dateStringWithFormat:@"yyyy-MM-dd"];
    NSString *newPeriodDate = [newPeriod.endDate dateStringWithFormat:@"yyyy-MM-dd"];
    txtCriteria.text = [NSString stringWithFormat:@"%@",newPeriodDate];
    if(!ShowCalender)
    {
        
        
        [pmCC dismissCalendarAnimated:YES];
    }
    
}
BOOL opened=NO;
-(void)dropDownCellSelected:(NSInteger)returnIndex{
    opened=NO;
    self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 80);
	NSArray *keys=[criteria.options allKeys];
	txtCriteria.text=[criteria.options valueForKey:[keys objectAtIndex:returnIndex]];
    txtCriteria.tag=returnIndex;
}

-(void)list:(id)sender{
    opened =!opened;
    if(opened)
        self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 300);
    else self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 80);
    [dropDownView openAnimation];
}

@end
