//
//  ViewController.m
//  D3Tester
//
//  Created by Steven Vandeweghe on 5/24/13.
//  Copyright (c) 2013 Blue Crowbar. All rights reserved.
//

#import "PieViewController.h"

@interface PieViewController () <UIWebViewDelegate>

@property (retain, nonatomic) IBOutlet UIWebView *WebView;

@end

@implementation PieViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.hidesBarsOnTap = true;
//    if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
//        Width=self.view.frame.size.width;
//        Height=self.view.frame.size.height;
//    }
//    else{
//        Width=self.view.frame.size.height;
//        Height=self.view.frame.size.width;
//    }
    CGRect rect=self.view.frame;
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

    
    self.WebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height-100)];
    self.WebView.delegate=self;
    [self.view addSubview:self.WebView];
    self.WebView.backgroundColor=[UIColor colorWithPatternImage:image];
	NSString *htmlPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"D3Ring" ofType:@"html"];
	NSString *html = [NSString stringWithContentsOfFile:htmlPath usedEncoding:nil error:nil];
	[self.WebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[htmlPath stringByDeletingLastPathComponent]]];
}


- (BOOL)shouldAutorotate
{
	return YES;
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString* data=@"[ {label:\"Incoming\", value:29,color:\"#3366CC\"},{label:\"Outgoing\", value:23, color:\"#DC3912\"},{label:\"Internal\", value:90,color:\"#FF9900\"},{label:\"Drafts\", value:50, color:\"#109618\"}]";
//    NSString* data=@"[{\"country\":\"Namibia\",\"rate\":37.6},{\"country\":\"Macedonia, FYR\",\"rate\":32.0},{\"country\":\"Armenia\",\"rate\":28.6},{\"country\":\"Bosnia and Herzegovina\",\"rate\":27.2}]";
    [self.WebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"showRing(%@)",data]];
}

@end
