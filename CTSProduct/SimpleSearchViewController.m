//
//  SimpleSearchViewController.m
//  CTSTest
//
//  Created by DNA on 1/20/14.
//  Copyright (c) 2014 LBI. All rights reserved.
//

#import "SimpleSearchViewController.h"
#import "CSearch.h"
#import "CSearchType.h"
#import "AdvanceSearchViewController.h"
#import "SearchResultViewController.h"
#import "CParser.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "FileManager.h"
#import "NSData+Base64.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)
@interface SimpleSearchViewController ()

@end

@implementation SimpleSearchViewController
{
    AppDelegate* maindelegate;
    NSInteger selectedType;
    UISegmentedControl *segmentedControl;
    NSMutableArray *itemArray;
    AppDelegate *mainDelegate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIInterfaceOrientation orientation= [[UIApplication sharedApplication]statusBarOrientation];
    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBarHidden = YES;
    maindelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.view setBackgroundColor:mainDelegate.bgColor];
     btnAdvanceSearch=[[UIButton alloc]init];
    if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
             btnAdvanceSearch.Frame=CGRectMake(self.view.frame.size.width-232, 30, 220, 50);
        }
        else
        {
            if (UIInterfaceOrientationIsPortrait(orientation) ){
                btnAdvanceSearch.Frame=CGRectMake(self.view.frame.size.width-230, 30, 220, 50);
            }
            else
         btnAdvanceSearch.Frame=CGRectMake(self.view.frame.size.width-490, 30, 220, 50);
    }
    }
    else
    {
         btnAdvanceSearch.Frame=CGRectMake(self.view.frame.origin.x+20, 30, 220, 50);
    }

    CGFloat red = 173.0f / 255.0f;
    CGFloat green = 208.0f / 255.0f;
    CGFloat blue = 238.0f / 255.0f;
    btnAdvanceSearch.backgroundColor=mainDelegate.buttonColor;

    btnAdvanceSearch.clipsToBounds=YES;
    [btnAdvanceSearch setTitle:NSLocalizedString(@"Search.AdvancedSearch", @"Advanced Search") forState:UIControlStateNormal] ;
    [btnAdvanceSearch setImage:[UIImage imageNamed:@"Searchimg.png"] forState:UIControlStateNormal];
    [btnAdvanceSearch setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 80)];
    [btnAdvanceSearch setTitleEdgeInsets:UIEdgeInsetsMake(7, 0, 0, 0)];
    [btnAdvanceSearch setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
    btnAdvanceSearch.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    [btnAdvanceSearch addTarget:self action:@selector(advanceSearchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnAdvanceSearch];
    
    
    lblTitle = [[UILabel alloc] init];
    lblTitle.textColor = [UIColor colorWithRed:1.0f/255.0f green:50.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
    lblTitle.text =NSLocalizedString(@"Search.SearchKeywords", @"Search words");
    if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
        lblTitle.frame = CGRectMake(self.view.frame.size.width-140, btnAdvanceSearch.frame.origin.y+btnAdvanceSearch.frame.size.height+60, 120, 40);
        lblTitle.textAlignment=NSTextAlignmentRight;
    }
    else
    {
    lblTitle.frame = CGRectMake(self.view.frame.origin.x+20, btnAdvanceSearch.frame.origin.y+btnAdvanceSearch.frame.size.height+60, 280, 40);
    }
    lblTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:16.0f];

   
    [self.view addSubview:lblTitle];
    
    txtKeyword=[[UITextField alloc] init];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
       txtKeyword.Frame=CGRectMake(self.view.frame.origin.x+20, lblTitle.frame.origin.y+lblTitle.frame.size.height+10, self.view.frame.size.width-40, 50);
    }else{
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            txtKeyword.Frame=CGRectMake(self.view.frame.origin.x+20, lblTitle.frame.origin.y+lblTitle.frame.size.height+10, self.view.frame.size.width-40, 50);
        }
        else
         txtKeyword.Frame=CGRectMake(self.view.frame.origin.x+20, lblTitle.frame.origin.y+lblTitle.frame.size.height+10, self.view.frame.size.width-300, 50);
        
    }
   
  
    txtKeyword.backgroundColor=mainDelegate.textColor;
    txtKeyword.textColor=[UIColor blackColor];

    txtKeyword.returnKeyType = UIReturnKeySearch;
   
    txtKeyword.delegate=self;
     btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
        txtKeyword.textAlignment=NSTextAlignmentRight;
        UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0,10, 20)];
        txtKeyword.rightView = paddingView1;
        txtKeyword.rightViewMode = UITextFieldViewModeAlways;
        [btnSearch setFrame:CGRectMake(txtKeyword.frame.origin.x, txtKeyword.frame.origin.y, 60, txtKeyword.frame.size.height)];

    }
    else{
        txtKeyword.textAlignment=NSTextAlignmentLeft;
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
        txtKeyword.leftView = paddingView;
        txtKeyword.leftViewMode = UITextFieldViewModeAlways;
        [btnSearch setFrame:CGRectMake(txtKeyword.frame.size.width-30, txtKeyword.frame.origin.y, 60, txtKeyword.frame.size.height)];

    }
   
    
  //  [btnSearch setFrame:CGRectMake(((self.view.frame.size.width-450)/2)+405, 307, 40, 40)];
    [btnSearch setImage:[UIImage imageNamed:@"Searchimg.png"] forState:UIControlStateNormal];
    [btnSearch setBackgroundColor:[UIColor colorWithRed:red green:green blue:blue alpha:1.0]];
    [btnSearch addTarget:self action:@selector(searchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:txtKeyword];
    [self.view addSubview:btnSearch];
    

    
    itemArray = [NSMutableArray arrayWithObjects:nil];
    
    
    for(int i=0;i<maindelegate.searchModule.searchTypes.count;i++){
        CSearchType* searchType= [maindelegate.searchModule.searchTypes objectAtIndex:i];
        
        
        [itemArray addObject:[NSString stringWithFormat:@"%@",searchType.label]];
        
        
        
        
        
        
        if(maindelegate.searchModule.searchTypes.count>0)
            selectedType=((CSearchType*)maindelegate.searchModule.searchTypes[0]).typeId;
    }
    
    //jis uisegment
    
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    NSDictionary *highlightedattributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:17],NSFontAttributeName,mainDelegate.titleColor,NSForegroundColorAttributeName, nil];
    [segmentedControl setTitleTextAttributes:highlightedattributes forState:UIControlStateNormal];
    segmentedControl.frame = CGRectMake((self.view.frame.size.width-110)/3, lblTitle.frame.origin.y+lblTitle.frame.size.height+100, 300, 70);
    segmentedControl.tintColor = [UIColor colorWithRed:0.0f / 255.0f green:155.0f / 255.0f blue:213.0f / 255.0f alpha:1.0];
    [segmentedControl setSelectedSegmentIndex:0];
    [segmentedControl addTarget:self action:@selector(segmentedControlIndexChanged) forControlEvents:UIControlEventValueChanged];
   [self.view addSubview:segmentedControl];
    
}

-(void)segmentedControlIndexChanged
{
    for(int i=0;i<maindelegate.searchModule.searchTypes.count;i++){
        if(((CSearchType*)maindelegate.searchModule.searchTypes[i]).typeId==segmentedControl.selectedSegmentIndex + 1){
            selectedType=((CSearchType*)maindelegate.searchModule.searchTypes[i]).typeId;
        }
    }
    
    
    
    switch (segmentedControl.selectedSegmentIndex)
    {
            
        case 0:
            NSLog(@"Search Inbox");
            break;
        case 1:
            NSLog(@"Search Archive");
            break;
        default:
            break;
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (!SYSTEM_VERSION_LESS_THAN(@"8.0") && [mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
             btnAdvanceSearch.Frame=CGRectMake(self.view.frame.size.width-265, 30, 220, 50);
    }
        else
        {
         btnAdvanceSearch.Frame=CGRectMake(self.view.frame.size.width-265, 30, 220, 50);
        }
    }
    
}
-(void)advanceSearchButtonClicked{
    [txtKeyword resignFirstResponder];
    UINavigationController *navController=[maindelegate.splitViewController.viewControllers objectAtIndex:1];                            [navController setNavigationBarHidden:YES animated:NO];
    AdvanceSearchViewController *advanceViewController = [[AdvanceSearchViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [navController pushViewController:advanceViewController animated:YES];
}

- (void)searchButtonTapped:(UIButton *)button
{
    
    if(![txtKeyword.text isEqualToString:@""]){
        [self performSelectorOnMainThread:@selector(increaseProgress) withObject:nil waitUntilDone:YES];
        
        
        [self performSelectorInBackground:@selector(performSearch) withObject:nil];
        
    }
    else{
        [self ShowMessage:NSLocalizedString(@"Alert.TypeKeyword",@"Type a keyword.")];
    }
}

-(void)performSearch{
    
    @try{
        mainDelegate.SearchClicked=YES;
        NSString* showthumb;
        if (mainDelegate.ShowThumbnail)
            showthumb=@"true";
        else
            showthumb=@"false";
        NSString* queryString=[NSString stringWithFormat:@"keyword:%@",[txtKeyword.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        // NSString* url = [NSString stringWithFormat:@"http://%@?action=SearchForCorrespondences&token=%@&criterias=%@&typeId=%d",serverUrl,appDelegate.user.token,queryString,selectedType];
        NSString* url;
        if(mainDelegate.SupportsServlets)
            url = [NSString stringWithFormat:@"http://%@",mainDelegate.serverUrl];
        else
            url = [NSString stringWithFormat:@"http://%@/SearchCorrespondences",mainDelegate.serverUrl];
        
        // setting up the request object now
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        
        // action parameter
        if(mainDelegate.SupportsServlets){
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"action\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"SearchCorrespondences" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        // token parameter
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"token\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[mainDelegate.user.token dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        // criteria parameter
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"criteria\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        // typeID parameter
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"typeId\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%d", selectedType] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        // showthumbnail parameter
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"showThumbnails\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[showthumb dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        // language parameter
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"language\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[mainDelegate.IpadLanguage dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
              // close form
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // set request body
        [request setHTTPBody:body];
        [request setTimeoutInterval:mainDelegate.Request_timeOut];
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
 
        NSString *validationResultUser=[CParser ValidateWithData:returnData];
        if(![validationResultUser isEqualToString:@"OK"])
        {
            
            [self ShowMessage:validationResultUser];
            
        }
        else {
            mainDelegate.searchModule.correspondenceList = [CParser loadSearchCorrespondencesWithData:returnData];
            
            if(mainDelegate.searchModule.correspondenceList.count>0){
                [self performSelectorOnMainThread:@selector(showResult) withObject:nil waitUntilDone:NO];
            }
            else{
                [self ShowMessage:NSLocalizedString(@"Alert.NoResult",@"No Result Found.")];
            }
            
        }
    }
    @catch (NSException *ex) {
        
        [FileManager appendToLogView:@"SimpleSearchViewController" function:@"searchButtonTapped" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    @finally {
        [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
    }
    
}

-(void)showResult{
    UINavigationController *navController=[mainDelegate.splitViewController.viewControllers objectAtIndex:1];
    [navController setNavigationBarHidden:YES animated:YES];
    SearchResultViewController *searchResultViewController = [[SearchResultViewController alloc]initWithStyle:UITableViewStylePlain];
    [navController pushViewController:searchResultViewController animated:YES];
}

-(void)ShowMessage:(NSString*)message{
    
    NSString *msg = message;
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Alert",@"Alert")
                          message: msg
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK",@"OK")
                          otherButtonTitles: nil];
    [alert show];
}
- (void)increaseProgress{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Searching",@"Searching ...") maskType:SVProgressHUDMaskTypeBlack];
    
    
}

- (void)dismiss {
	[SVProgressHUD dismiss];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchButtonTapped:btnSearch];
    //[textField resignFirstResponder];
    return YES;
}


@end
