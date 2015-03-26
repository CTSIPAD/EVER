//
//  ViewController.m
//  D3Tester
//
//  Created by Steven Vandeweghe on 5/24/13.
//  Copyright (c) 2013 Blue Crowbar. All rights reserved.
//

#import "PieViewController.h"
#import "AppDelegate.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)

@interface PieViewController () <UIWebViewDelegate>{
    CGFloat Width;
    CGFloat Height;
    AppDelegate *mainDelegate;
    UIButton *filterWeeklyButton,*filterMonthlyButton,*filterYearlyButton;
    NSString *pieDateRange;
}

@property (retain, nonatomic) IBOutlet UIWebView *WebView;

@end

@implementation PieViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    pieDateRange = @"general";
    self.navigationItem.hidesBackButton=NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavbar:)];
    
    
    UIImage *notClickedWeek=[UIImage imageNamed:@"NotClickedWeek.png"];
    filterWeeklyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filterWeeklyButton setFrame:CGRectMake(self.navigationController.view.frame.size.width/2-140,2.5,70,40)];
    [filterWeeklyButton setTitle:NSLocalizedString(@"Reports.Weekly", @"Weekly") forState:UIControlStateNormal];
    [filterWeeklyButton setBackgroundImage:notClickedWeek forState:UIControlStateNormal];
    [filterWeeklyButton setTitleColor:[self colorWithHexString:@"2f9dac"] forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:filterWeeklyButton];
    [filterWeeklyButton addTarget:self action:@selector(getWeeklyData) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *notClickedMonth=[UIImage imageNamed:@"NotClickedMonth.png"];
    filterMonthlyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filterMonthlyButton setFrame:CGRectMake(self.navigationController.view.frame.size.width/2-70,2.5,70,40)];
    [filterMonthlyButton setTitle:NSLocalizedString(@"Reports.Monthly", @"Monthly") forState:UIControlStateNormal];
    [filterMonthlyButton setBackgroundImage:notClickedMonth forState:UIControlStateNormal];
    [filterMonthlyButton setTitleColor:[self colorWithHexString:@"2f9dac"] forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:filterMonthlyButton];
    [filterMonthlyButton addTarget:self action:@selector(getMonthlyData) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *notClickedYear=[UIImage imageNamed:@"NotClickedYear.png"];
    filterYearlyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filterYearlyButton setFrame:CGRectMake(self.navigationController.view.frame.size.width/2,2.5,70,40)];
    [filterYearlyButton setTitle:NSLocalizedString(@"Reports.Yearly", @"Yearly") forState:UIControlStateNormal];
    [filterYearlyButton setBackgroundImage:notClickedYear forState:UIControlStateNormal];
    [filterYearlyButton setTitleColor:[self colorWithHexString:@"2f9dac"] forState:UIControlStateNormal];
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
    NSString *htmlPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"d3pie" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:htmlPath usedEncoding:nil error:nil];
    
    [self.WebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[htmlPath stringByDeletingLastPathComponent]]];
    [self.view addGestureRecognizer:tapGesture];
    
}

-(void) getWeeklyData{
    [self resetMenuButtonsImages];
    UIImage *clickedWeek=[UIImage imageNamed:@"ClickedWeek.png"];
    [filterWeeklyButton setBackgroundImage:clickedWeek forState:UIControlStateNormal];
    pieDateRange = @"weekly";
    [filterWeeklyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self callWebViewDidFinishLoading];
}

-(void) getMonthlyData{
    [self resetMenuButtonsImages];
    UIImage *clickedMonth=[UIImage imageNamed:@"ClickedMonth.png"];
    [filterMonthlyButton setBackgroundImage:clickedMonth forState:UIControlStateNormal];
    pieDateRange = @"monthly";
    [filterMonthlyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self callWebViewDidFinishLoading];
}

-(void) getYearlyData{
    [self resetMenuButtonsImages];
    UIImage *clickedYear=[UIImage imageNamed:@"ClickedYear.png"];
    [filterYearlyButton setBackgroundImage:clickedYear forState:UIControlStateNormal];
    pieDateRange = @"yearly";
    [filterYearlyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self callWebViewDidFinishLoading];
}

-(void) resetMenuButtonsImages{
    UIImage *notClickedWeek=[UIImage imageNamed:@"NotClickedWeek.png"];
    UIImage *notClickedMonth=[UIImage imageNamed:@"NotClickedMonth.png"];
    UIImage *notClickedYear=[UIImage imageNamed:@"NotClickedYear.png"];
    [filterWeeklyButton setBackgroundImage:notClickedWeek forState:UIControlStateNormal];
    [filterMonthlyButton setBackgroundImage:notClickedMonth forState:UIControlStateNormal];
    [filterYearlyButton setBackgroundImage:notClickedYear forState:UIControlStateNormal];
    [filterWeeklyButton setTitleColor:[self colorWithHexString:@"2f9dac"] forState:UIControlStateNormal];
    [filterMonthlyButton setTitleColor:[self colorWithHexString:@"2f9dac"] forState:UIControlStateNormal];
    [filterYearlyButton setTitleColor:[self colorWithHexString:@"2f9dac"] forState:UIControlStateNormal];
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

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
- (BOOL)shouldAutorotate
{
    return YES;
}

-(void) callWebViewDidFinishLoading{
    NSString *htmlPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"d3pie" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:htmlPath usedEncoding:nil error:nil];
    
    [self.WebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[htmlPath stringByDeletingLastPathComponent]]];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        filterWeeklyButton.hidden = YES;
        filterMonthlyButton.hidden = YES;
        filterYearlyButton.hidden = YES;
        pieDateRange = @"general";
    }
    [super viewWillDisappear:animated];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    /*NSString* data=@"[ {label:\"Incoming Correspondences\", value:62.2,color:\"blue\"},{label:\"Outgoing  Correspondences\", value:18.9, color:\"red\"},{label:\"Internal  Correspondences\", value:18.9,color:\"green\"}]";*/
    
    NSString *serverUrl;
    NSString *getPieChartDataUrl;
    NSString *fromDateString;
    NSString *toDateString;
    NSDate *fromDate;
    NSString *message;
    if([pieDateRange isEqualToString:@"general"]){
        serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
        getPieChartDataUrl =[NSString stringWithFormat:@"http://%@/GetCategoriesCountData?token=%@&language=%@",serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage];
        message = [NSString stringWithFormat:NSLocalizedString(@"Reports.ShowingAllData", @"Showing all data")];
    }else if([pieDateRange isEqualToString:@"weekly"]){
        fromDate =[self getFromDate:@"week"];
        fromDateString = [self castDateToString:fromDate];
        toDateString = [self castDateToString:[NSDate date]];
        
        serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
        getPieChartDataUrl =[NSString stringWithFormat:@"http://%@/GetCategoriesCountData?token=%@&language=%@&fromDate=%@&toDate=%@",serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage,fromDateString,toDateString];
        message = [NSString stringWithFormat:@"%@ %@ %@ %@",[NSString stringWithFormat:NSLocalizedString(@"Reports.ShowingDataFrom", @"*Showing data from")],fromDateString,[NSString stringWithFormat:NSLocalizedString(@"Reports.ToDate", @"to")],toDateString];
        
    }else if([pieDateRange isEqualToString:@"monthly"]){
        fromDate =[self getFromDate:@"month"];
        fromDateString = [self castDateToString:fromDate];
        toDateString = [self castDateToString:[NSDate date]];
        
        serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
        getPieChartDataUrl =[NSString stringWithFormat:@"http://%@/GetCategoriesCountData?token=%@&language=%@&fromDate=%@&toDate=%@",serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage,fromDateString,toDateString];
         message = [NSString stringWithFormat:@"%@ %@ %@ %@",[NSString stringWithFormat:NSLocalizedString(@"Reports.ShowingDataFrom", @"*Showing data from")],fromDateString,[NSString stringWithFormat:NSLocalizedString(@"Reports.ToDate", @"to")],toDateString];
    }else if([pieDateRange isEqualToString:@"yearly"]){
        fromDate =[self getFromDate:@"year"];
        fromDateString = [self castDateToString:fromDate];
        toDateString = [self castDateToString:[NSDate date]];
        
        serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
        getPieChartDataUrl =[NSString stringWithFormat:@"http://%@/GetCategoriesCountData?token=%@&language=%@&fromDate=%@&toDate=%@",serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage,fromDateString,toDateString];
         message = [NSString stringWithFormat:@"%@ %@ %@ %@",[NSString stringWithFormat:NSLocalizedString(@"Reports.ShowingDataFrom", @"*Showing data from")],fromDateString,[NSString stringWithFormat:NSLocalizedString(@"Reports.ToDate", @"to")],toDateString];
    }
    NSURL *url = [NSURL URLWithString:getPieChartDataUrl];
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
        
        NSString* title=[NSString stringWithFormat:@"{text:\"%@\"}",NSLocalizedString(@"Reports.CorrespondencesByCategory", @"Correspondences by Category")];
        NSString *emptyMessage =[NSString stringWithFormat:@"{text:\"%@\"}",NSLocalizedString(@"Reports.EmptyMessage", @"No data to display.")];
        NSString* size=[NSString stringWithFormat:@"{size:%f}",Width-50];
        message =[NSString stringWithFormat:@"{text:\"%@\"}",message];
        [self.WebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"showRing(%@,%@,%@,%@,%@)",size,title,data,message,emptyMessage]];
        
    }
    
}




@end
