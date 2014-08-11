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

    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBarHidden = NO;
    maindelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
   // [self.view setBackgroundColor:[UIColor colorWithRed:88.0f/255.0f green:96.0f/255.0f blue:104.0f/255.0f alpha:1.0]];
    [self.view setBackgroundColor:[UIColor colorWithRed:29.0f / 255.0f green:29.0f / 255.0f blue:29.0f / 255.0f alpha:1.0]];
    btnAdvanceSearch=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-180-20, 75, 180, 30)];
    CGFloat red = 0.0f / 255.0f;
    CGFloat green = 155.0f / 255.0f;
    CGFloat blue = 213.0f / 255.0f;
    btnAdvanceSearch.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    btnAdvanceSearch.layer.cornerRadius=6;
    btnAdvanceSearch.clipsToBounds=YES;
    [btnAdvanceSearch setTitle:NSLocalizedString(@"Search.AdvancedSearch", @"Advanced Search") forState:UIControlStateNormal] ;
    [btnAdvanceSearch setImage:[UIImage imageNamed:@"littleadvanced.png"] forState:UIControlStateNormal];
    [btnAdvanceSearch setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 80)];
    [btnAdvanceSearch setTitleEdgeInsets:UIEdgeInsetsMake(5,5, 5,0)];
    
    [btnAdvanceSearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnAdvanceSearch.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    [btnAdvanceSearch addTarget:self action:@selector(advanceSearchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnAdvanceSearch];

    
    lblTitle = [[UILabel alloc] init];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.text =NSLocalizedString(@"Search.SearchKeywords", @"Search Keywords");
    
        //lblTitle.frame = CGRectMake((self.view.frame.size.width-450)/2, 150, 450, 40);
    lblTitle.frame = CGRectMake((self.view.frame.size.width-450)/2, 260, 450, 40);
   
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:24.0f];

    if([maindelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        lblTitle.textAlignment=NSTextAlignmentRight;
    }
    [self.view addSubview:lblTitle];
    
//    txtKeyword=[[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width-450)/2, 195, 450, 40)];
   txtKeyword=[[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width-450)/2, 305, 450, 40)];
    txtKeyword.backgroundColor=[UIColor whiteColor];
    txtKeyword.textColor=[UIColor blackColor];
    [txtKeyword.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [txtKeyword.layer setBorderWidth:1.0];
    txtKeyword.returnKeyType = UIReturnKeySearch;
    //The rounded corner part, where you specify your view's corner radius:
    txtKeyword.layer.cornerRadius = 7;
    txtKeyword.clipsToBounds = YES;
    txtKeyword.delegate=self;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    txtKeyword.leftView = paddingView;
    txtKeyword.leftViewMode = UITextFieldViewModeAlways;
    btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
   
//	[btnSearch setFrame:CGRectMake(((self.view.frame.size.width-450)/2)+405, 197, 40, 40)];
    [btnSearch setFrame:CGRectMake(((self.view.frame.size.width-450)/2)+405, 307, 40, 40)];
    [btnSearch setImage:[UIImage imageNamed:@"SearchButton.PNG"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(searchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:txtKeyword];
    [self.view addSubview:btnSearch];
    
    int buttonPositionY=380;

    
    
    
    itemArray = [NSMutableArray arrayWithObjects:nil];
    
    
    for(int i=0;i<maindelegate.searchModule.searchTypes.count;i++){
        CSearchType* searchType= [maindelegate.searchModule.searchTypes objectAtIndex:i];
   UIButton* btnCustom=[[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-300)/3, buttonPositionY+i*60, 300, 50)];
        if(i==0){

            
            CGFloat red = 0.0f / 255.0f;
            CGFloat green = 155.0f / 255.0f;
            CGFloat blue = 213.0f / 255.0f;
            
            
            btnCustom.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    } else{
        
        CGFloat red = 53.0f / 255.0f;
        CGFloat green = 53.0f / 255.0f;
        CGFloat blue = 53.0f / 255.0f;
    btnCustom.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    }
    btnCustom.layer.cornerRadius=6;
    btnCustom.clipsToBounds=YES;
        btnCustom.tag=searchType.typeId;
    
        
        
        [itemArray addObject:[NSString stringWithFormat:@"%@",searchType.label]];
      
        
        
        
    [btnCustom setTitle:searchType.label forState:UIControlStateNormal] ;
        if(![searchType.icon isEqualToString:@""]){
            UIImageView *imageView=[[UIImageView alloc ]initWithFrame:CGRectMake(10, 7, 37, 37)];
            NSData * data= [NSData dataWithBase64EncodedString:searchType.icon];
            UIImage *cellImage = [UIImage imageWithData:data];
            [imageView setImage:cellImage];
           
            [btnCustom addSubview:imageView];
    [btnCustom setTitleEdgeInsets:UIEdgeInsetsMake(10,5, 10,0)];
        }
        else [btnCustom setTitleEdgeInsets:UIEdgeInsetsMake(10,50, 10,0)];
    [btnCustom setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnCustom.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        [btnCustom addTarget:self action:@selector(customButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        //[self.view addSubview:btnCustom];
        
        

        if(maindelegate.searchModule.searchTypes.count>0)
            selectedType=((CSearchType*)maindelegate.searchModule.searchTypes[0]).typeId;
    }
    
    //jis uisegment
    

    segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    NSDictionary *highlightedattributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:17],NSFontAttributeName,[UIColor whiteColor],UITextAttributeTextColor, nil];
    [segmentedControl setTitleTextAttributes:highlightedattributes forState:UIControlStateNormal];
    segmentedControl.frame = CGRectMake((self.view.frame.size.width-110)/3, 400, 300, 70);
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


-(void)customButtonClicked:(UIButton *)btn{
  //  UIButton *btn=(UIButton*)sender;
    for(int i=0;i<maindelegate.searchModule.searchTypes.count;i++){
        NSLog(@"%d",btn.tag);
    if(((CSearchType*)maindelegate.searchModule.searchTypes[i]).typeId==btn.tag){
//    CGFloat red = 53.0f / 255.0f;
//    CGFloat green = 53.0f / 255.0f;
//    CGFloat blue = 53.0f / 255.0f;
        
        CGFloat red = 0.0f / 255.0f;
        CGFloat green = 155.0f / 255.0f;
        CGFloat blue = 213.0f / 255.0f;
    btn.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        selectedType=((CSearchType*)maindelegate.searchModule.searchTypes[i]).typeId;
    }
    else {
        UIButton *button = (UIButton *)[self.view viewWithTag:i+1];
//        CGFloat red = 33.0f / 255.0f;
//        CGFloat green = 33.0f / 255.0f;
//        CGFloat blue = 33.0f / 255.0f;
        
            CGFloat red = 53.0f / 255.0f;
            CGFloat green = 53.0f / 255.0f;
            CGFloat blue = 53.0f / 255.0f;
        button.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    }
    }
}


-(void)advanceSearchButtonClicked{
    UINavigationController *navController=[maindelegate.splitViewController.viewControllers objectAtIndex:1];                            [navController setNavigationBarHidden:YES animated:NO];
    AdvanceSearchViewController *advanceViewController = [[AdvanceSearchViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [navController pushViewController:advanceViewController animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
         mainDelegate.SearchActive=YES;
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
         
//         // index parameter
//         [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//         [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"index\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//         [body appendData:[[NSString stringWithFormat:@"%d",0] dataUsingEncoding:NSUTF8StringEncoding]];
//         [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        
//         // pageSize parameter
//         [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//         [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"pageSize\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//         [body appendData:[[NSString stringWithFormat:@"%d", mainDelegate.SettingsCorrNb] dataUsingEncoding:NSUTF8StringEncoding]];
//         [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
         
         // close form
         [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
         
         // set request body
         [request setHTTPBody:body];
         
         NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        // returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    //NSURL *xmlUrl = [NSURL URLWithString:url];
    //NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
    NSString *validationResultUser=[CParser ValidateWithData:returnData];
    // [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
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
        mainDelegate.SearchActive=NO;
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
