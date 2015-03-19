//
//  VerticalBarChartViewController.m
//  CTSIPAD
//
//  Created by Ronald Cortbawi on 3/9/15.
//  Copyright (c) 2015 EVER. All rights reserved.
//

#import "VerticalBarChartViewController.h"
#import "AppDelegate.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)

@interface VerticalBarChartViewController  () <UIWebViewDelegate>{
    CGFloat Width;
    CGFloat Height;
    AppDelegate *mainDelegate;
    UIButton *filterWeeklyButton,*filterMonthlyButton,*filterYearlyButton;
    NSString *verticalBarDateRange;
}
@property (retain, nonatomic) IBOutlet UIWebView *WebView;
@end

@implementation VerticalBarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    verticalBarDateRange = @"general";
    self.navigationItem.hidesBackButton=NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavbar:)];
    
    UIImage *notClickedWeek=[UIImage imageNamed:@"NotClickedWeek.png"];
    filterWeeklyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filterWeeklyButton setFrame:CGRectMake(self.navigationController.view.frame.size.width/2-140,2.5,70,40)];
    [filterWeeklyButton setTitle:NSLocalizedString(@"Reports.Weekly", @"Weekly") forState:UIControlStateNormal];
    [filterWeeklyButton setBackgroundImage:notClickedWeek forState:UIControlStateNormal];
    [filterWeeklyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:filterWeeklyButton];
    [filterWeeklyButton addTarget:self action:@selector(getWeeklyData) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *notClickedMonth=[UIImage imageNamed:@"NotClickedMonth.png"];
    filterMonthlyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filterMonthlyButton setFrame:CGRectMake(self.navigationController.view.frame.size.width/2-70,2.5,70,40)];
    [filterMonthlyButton setTitle:NSLocalizedString(@"Reports.Monthly", @"Monthly") forState:UIControlStateNormal];
    [filterMonthlyButton setBackgroundImage:notClickedMonth forState:UIControlStateNormal];
    [filterMonthlyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:filterMonthlyButton];
    [filterMonthlyButton addTarget:self action:@selector(getMonthlyData) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *notClickedYear=[UIImage imageNamed:@"NotClickedYear.png"];
    filterYearlyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filterYearlyButton setFrame:CGRectMake(self.navigationController.view.frame.size.width/2,2.5,70,40)];
    [filterYearlyButton setTitle:NSLocalizedString(@"Reports.Yearly", @"Yearly") forState:UIControlStateNormal];
    [filterYearlyButton setBackgroundImage:notClickedYear forState:UIControlStateNormal];
    [filterYearlyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:filterYearlyButton];
    [filterYearlyButton addTarget:self action:@selector(getYearlyData) forControlEvents:UIControlEventTouchUpInside];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
        Width=self.view.frame.size.width;
        Height=self.view.frame.size.height;
    }
    else{
        Width=self.view.frame.size.height;
        Height=self.view.frame.size.width;
    }
    CGRect rect=CGRectMake(0, 0, Width, Height);
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageNamed:@"backGroundImg.png"] drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
    
    UIView *viewheader = [[UIView alloc] init];
    UIImage* headImage=[UIImage imageNamed:@"tableheader.png"];
    UIImageView* imgView=[[UIImageView alloc]initWithImage:headImage];
    [viewheader addSubview:imgView];
    [self.view addSubview:viewheader];
    
    self.WebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 45, Height-100, Width-100)];
    self.WebView.delegate=self;
    [self.view addSubview:self.WebView];
    self.WebView.backgroundColor=[UIColor colorWithPatternImage:image];
    NSString *htmlPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"D3VerticalBarChart" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:htmlPath usedEncoding:nil error:nil];
    
    [self.WebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[htmlPath stringByDeletingLastPathComponent]]];
    [self.view addGestureRecognizer:tapGesture];
    
    
}

-(void) getWeeklyData{
    [self resetMenuButtonsImages];
    UIImage *clickedWeek=[UIImage imageNamed:@"ClickedWeek.png"];
    [filterWeeklyButton setBackgroundImage:clickedWeek forState:UIControlStateNormal];
    verticalBarDateRange = @"weekly";
    [self callWebViewDidFinishLoading];
}

-(void) getMonthlyData{
    [self resetMenuButtonsImages];
    UIImage *clickedMonth=[UIImage imageNamed:@"ClickedMonth.png"];
    [filterMonthlyButton setBackgroundImage:clickedMonth forState:UIControlStateNormal];
    verticalBarDateRange = @"monthly";
    [self callWebViewDidFinishLoading];
}

-(void) getYearlyData{
    [self resetMenuButtonsImages];
    UIImage *clickedYear=[UIImage imageNamed:@"ClickedYear.png"];
    [filterYearlyButton setBackgroundImage:clickedYear forState:UIControlStateNormal];
    verticalBarDateRange = @"yearly";
    [self callWebViewDidFinishLoading];
}

-(void) resetMenuButtonsImages{
    UIImage *notClickedWeek=[UIImage imageNamed:@"NotClickedWeek.png"];
    UIImage *notClickedMonth=[UIImage imageNamed:@"NotClickedMonth.png"];
    UIImage *notClickedYear=[UIImage imageNamed:@"NotClickedYear.png"];
    [filterWeeklyButton setBackgroundImage:notClickedWeek forState:UIControlStateNormal];
    [filterMonthlyButton setBackgroundImage:notClickedMonth forState:UIControlStateNormal];
    [filterYearlyButton setBackgroundImage:notClickedYear forState:UIControlStateNormal];
}

-(NSString*) castDateToString:(NSDate*)date{
    NSString *retVal ;
    NSDateFormatter *formatter;
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:usLocale];
    [formatter setDateFormat:@"MM-dd-yyyy"];
    
    retVal = [formatter stringFromDate:date];
    return retVal;
}

-(NSDate*) getFromDate:(NSString*)status{
    NSDate *retVal;
    NSDate *now = [NSDate date];  // now
    NSDate *today;
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit // beginning of this day
                                    startDate:&today // save it here
                                     interval:NULL
                                      forDate:now];
    
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    
    if([status  isEqualToString: @"week"])
    {
        comp.day = -7;
        NSDate * oneWeekBefore = [[NSCalendar currentCalendar] dateByAddingComponents:comp
                                                                               toDate:today
                                                                              options:0];
        retVal = oneWeekBefore;
    }else if([status isEqualToString:@"month"]){
        comp.day = -30;
        NSDate * oneMonthBefore = [[NSCalendar currentCalendar] dateByAddingComponents:comp
                                                                                toDate:today
                                                                               options:0];
        retVal = oneMonthBefore;
    }else{
        comp.day = -365;
        NSDate * oneYearBefore = [[NSCalendar currentCalendar] dateByAddingComponents:comp
                                                                               toDate:today
                                                                              options:0];
        retVal = oneYearBefore;
    }
    
    return retVal;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void) showHideNavbar:(id) sender
{
    // write code to show/hide nav bar here
    // check if the Navigation Bar is shown
    if (self.navigationController.navigationBar.hidden == NO)
    {
        // hide the Navigation Bar
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    // if Navigation Bar is already hidden
    else if (self.navigationController.navigationBar.hidden == YES)
    {
        // Show the Navigation Bar
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}
- (BOOL)shouldAutorotate
{
    return YES;
}

-(void) callWebViewDidFinishLoading{
    NSString *htmlPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"D3VerticalBarChart" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:htmlPath usedEncoding:nil error:nil];
    
    [self.WebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[htmlPath stringByDeletingLastPathComponent]]];
}


-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        filterWeeklyButton.hidden = YES;
        filterMonthlyButton.hidden = YES;
        filterYearlyButton.hidden = YES;
        verticalBarDateRange = @"general";
    }
    [super viewWillDisappear:animated];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    /*NSString* data=@"[{structure:\"طبابة\", completed:5,draft:6,new:7},{structure:\"مشتريات\", completed:2,draft:3,new:4},{structure:\"ps\", completed:9,draft:1,new:3}]";
     NSString *showDataFunc = [NSString stringWithFormat:@"showData(%@)", data];
     [self.WebView stringByEvaluatingJavaScriptFromString:showDataFunc];*/
    
    NSString *serverUrl;
    NSString *getVerticalChartDataUrl;
    NSDate *fromDate;
    NSString *fromDateString;
    NSString *toDateString;
    NSString *message;
    if([verticalBarDateRange isEqualToString:@"general"]){
        serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
        getVerticalChartDataUrl =[NSString stringWithFormat:@"http://%@/GetCorrespondenceStructureCountData?token=%@&language=%@",serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage];
        message = [NSString stringWithFormat:NSLocalizedString(@"Reports.ShowingAllData", @"Showing all data")];
    }else if([verticalBarDateRange isEqualToString:@"weekly"]){
        fromDate =[self getFromDate:@"week"];
        fromDateString = [self castDateToString:fromDate];
        toDateString = [self castDateToString:[NSDate date]];
        
        serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
        getVerticalChartDataUrl =[NSString stringWithFormat:@"http://%@/GetCorrespondenceStructureCountData?token=%@&language=%@&fromDate=%@&toDate=%@",serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage,fromDateString,toDateString];
             message = [NSString stringWithFormat:@"%@ %@ %@ %@",[NSString stringWithFormat:NSLocalizedString(@"Reports.ShowingDataFrom", @"*Showing data from")],fromDateString,[NSString stringWithFormat:NSLocalizedString(@"Reports.ToDate", @"to")],toDateString];
    }else if([verticalBarDateRange isEqualToString:@"monthly"]){
        fromDate =[self getFromDate:@"month"];
        fromDateString = [self castDateToString:fromDate];
        toDateString = [self castDateToString:[NSDate date]];
        
        serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
        getVerticalChartDataUrl =[NSString stringWithFormat:@"http://%@/GetCorrespondenceStructureCountData?token=%@&language=%@&fromDate=%@&toDate=%@",serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage,fromDateString,toDateString];
             message = [NSString stringWithFormat:@"%@ %@ %@ %@",[NSString stringWithFormat:NSLocalizedString(@"Reports.ShowingDataFrom", @"*Showing data from")],fromDateString,[NSString stringWithFormat:NSLocalizedString(@"Reports.ToDate", @"to")],toDateString];
    }else if([verticalBarDateRange isEqualToString:@"yearly"]){
        fromDate =[self getFromDate:@"year"];
        fromDateString = [self castDateToString:fromDate];
        toDateString = [self castDateToString:[NSDate date]];
        
        serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
        getVerticalChartDataUrl =[NSString stringWithFormat:@"http://%@/GetCorrespondenceStructureCountData?token=%@&language=%@&fromDate=%@&toDate=%@",serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage,fromDateString,toDateString];
         message = [NSString stringWithFormat:@"%@ %@ %@ %@",[NSString stringWithFormat:NSLocalizedString(@"Reports.ShowingDataFrom", @"*Showing data from")],fromDateString,[NSString stringWithFormat:NSLocalizedString(@"Reports.ToDate", @"to")],toDateString];    }
    NSURL *url = [NSURL URLWithString:getVerticalChartDataUrl];
    NSMutableURLRequest* request=[[NSMutableURLRequest alloc]initWithURL:url];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:request
                                                  returningResponse:&response
                                                              error:&error];
    
    NSString *data = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPResponse statusCode];
    
    if([[NSString stringWithFormat: @"%ld", (long)statusCode]  isEqual: @"200"]){
         message =[NSString stringWithFormat:@"{text:\"%@\"}",message];
        NSString *structure =[NSString stringWithFormat:@"{text:\"%@\"}",NSLocalizedString(@"Reports.Structure", @"structure")];
        NSString *count = [NSString stringWithFormat:@"{text:\"%@\"}",NSLocalizedString(@"Reports.Count", @"count")];
        NSString *title = [NSString stringWithFormat:@"{text:\"%@\"}",NSLocalizedString(@"Reports.CorrespondencesCountbyStatus", @"Correspondences Count by Status")];
        [self.WebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"showData(%@,%@,%@,%@,%@)",data,message,structure,count,title]];
        
    }
    
}


@end
