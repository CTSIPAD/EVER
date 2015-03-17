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
    
    filterWeeklyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filterWeeklyButton setFrame:CGRectMake(self.navigationController.view.frame.size.width/2-140,-15,70,59)];
    [filterWeeklyButton setTitle:@"Weekly" forState:UIControlStateNormal];
    [filterWeeklyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    filterWeeklyButton.backgroundColor =mainDelegate.InboxCellSelectedColor;
    [self.navigationController.navigationBar addSubview:filterWeeklyButton];
    [filterWeeklyButton addTarget:self action:@selector(getWeeklyData) forControlEvents:UIControlEventTouchUpInside];
    
    filterMonthlyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filterMonthlyButton setFrame:CGRectMake(self.navigationController.view.frame.size.width/2-70,-15,70,59)];
    [filterMonthlyButton setTitle:@"monthly" forState:UIControlStateNormal];
    [filterMonthlyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    filterMonthlyButton.backgroundColor =mainDelegate.InboxCellSelectedColor;
    [self.navigationController.navigationBar addSubview:filterMonthlyButton];
    [filterMonthlyButton addTarget:self action:@selector(getMonthlyData) forControlEvents:UIControlEventTouchUpInside];
    
    filterYearlyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filterYearlyButton setFrame:CGRectMake(self.navigationController.view.frame.size.width/2,-15,70,59)];
    [filterYearlyButton setTitle:@"Yearly" forState:UIControlStateNormal];
    [filterYearlyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    filterYearlyButton.backgroundColor =mainDelegate.InboxCellSelectedColor;
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
    pieDateRange = @"weekly";
    [self callWebViewDidFinishLoading];
}

-(void) getMonthlyData{
    pieDateRange = @"monthly";
    [self callWebViewDidFinishLoading];
}

-(void) getYearlyData{
    pieDateRange = @"yearly";
    [self callWebViewDidFinishLoading];
}

-(NSString*) castDateToString:(NSDate*)date{
    NSString *retVal ;
    NSDateFormatter *formatter;
    
    formatter = [[NSDateFormatter alloc] init];
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

-(void)ClearWebViewContent{
    [self.WebView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
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
    if([pieDateRange isEqualToString:@"general"]){
        serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
        getPieChartDataUrl =[NSString stringWithFormat:@"http://%@/GetCategoriesCountData?token=%@&language=%@",serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage];
    }else if([pieDateRange isEqualToString:@"weekly"]){
        NSDate *fromDate =[self getFromDate:@"week"];
        NSString *fromDateString = [self castDateToString:fromDate];
        NSString *toDateString = [self castDateToString:[NSDate date]];
        
        serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
        getPieChartDataUrl =[NSString stringWithFormat:@"http://%@/GetCategoriesCountData?token=%@&language=%@&fromDate=%@&toDate=%@",serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage,fromDateString,toDateString];
    }else if([pieDateRange isEqualToString:@"monthly"]){
        NSDate *fromDate =[self getFromDate:@"month"];
        NSString *fromDateString = [self castDateToString:fromDate];
        NSString *toDateString = [self castDateToString:[NSDate date]];
        
        serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
        getPieChartDataUrl =[NSString stringWithFormat:@"http://%@/GetCategoriesCountData?token=%@&language=%@&fromDate=%@&toDate=%@",serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage,fromDateString,toDateString];
        
    }else if([pieDateRange isEqualToString:@"yearly"]){
        NSDate *fromDate =[self getFromDate:@"year"];
        NSString *fromDateString = [self castDateToString:fromDate];
        NSString *toDateString = [self castDateToString:[NSDate date]];
        
        serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
        getPieChartDataUrl =[NSString stringWithFormat:@"http://%@/GetCategoriesCountData?token=%@&language=%@&fromDate=%@&toDate=%@",serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage,fromDateString,toDateString];
        
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
        NSString* title=@"{text:\"Correspondences by Category\"}";
        NSString* size=[NSString stringWithFormat:@"{size:%f}",Width-50];
        [self.WebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"showRing(%@,%@,%@)",size,title,data]];
        
    }
    
}




@end
