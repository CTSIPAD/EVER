//
//  OverdueBarChartViewController.m
//  CTSIPAD
//
//  Created by Ronald Cortbawi on 3/12/15.
//  Copyright (c) 2015 EVER. All rights reserved.
//

#import "OverdueBarChartViewController.h"
#import "AppDelegate.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)

@interface OverdueBarChartViewController () <UIWebViewDelegate>{
    CGFloat Width;
    CGFloat Height;
    AppDelegate *mainDelegate;
    
}
@property (retain, nonatomic) IBOutlet UIWebView *WebView;
@end

@implementation OverdueBarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationItem.hidesBackButton=NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavbar:)];
    
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
    NSString *htmlPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"D3OverdueBarChart" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:htmlPath usedEncoding:nil error:nil];
    
    [self.WebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[htmlPath stringByDeletingLastPathComponent]]];
    [self.view addGestureRecognizer:tapGesture];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    /*NSString* data=@"[{structure:\"طبابة\", completed:5,draft:6,new:7},{structure:\"مشتريات\", completed:2,draft:3,new:4},{structure:\"ps\", completed:9,draft:1,new:3}]";
     NSString *showDataFunc = [NSString stringWithFormat:@"showData(%@)", data];
     [self.WebView stringByEvaluatingJavaScriptFromString:showDataFunc];*/
    NSString *serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
    NSString *getPieChartDataUrl =[NSString stringWithFormat:@"http://%@/GetOverdueTransfers?token=%@&language=%@",serverUrl,mainDelegate.user.token,mainDelegate.IpadLanguage];
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
        
        NSString *structure =[NSString stringWithFormat:@"{text:\"%@\"}",NSLocalizedString(@"Reports.Structure", @"structure")];
        NSString *count = [NSString stringWithFormat:@"{text:\"%@\"}",NSLocalizedString(@"Reports.Count", @"count")];
        NSString *title =[NSString stringWithFormat:@"{text:\"%@\"}",NSLocalizedString(@"Reports.NumberOfOverdueTransfersByStructure", @"Number of Overdue Transfers by Structure")];
        [self.WebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"showData(%@,%@,%@,%@)",data,structure,count,title]];
        
    }
    
}



@end
