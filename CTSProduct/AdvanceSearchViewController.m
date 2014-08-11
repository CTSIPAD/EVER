//
//  AdvancedSearchViewController.m
//  CTSTest
//
//  Created by DNA on 1/26/14.
//  Copyright (c) 2014 LBI. All rights reserved.
//

#import "AdvanceSearchViewController.h"
#import "CSearch.h"
#import "CSearchCriteria.h"
#import "CSearchType.h"
#import "SimpleSearchViewController.h"
#import "AdvanceSearchTableViewCell.h"
#import "SearchResultViewController.h"
#import "CParser.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "FileManager.h"
#import "NSData+Base64.h"

@interface AdvanceSearchViewController ()

@end

@implementation AdvanceSearchViewController
{
    AppDelegate* appDelegate;
     NSInteger selectedType;
    UISegmentedControl *segmentedControl;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
     
    }
    return self;
}

//-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
//    return NO;
//}

-(void)deleteCachedFiles{
    
    @try{
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        // TEMPORARY PDF PATH
        // Get the Caches directory
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSError *error = nil;
        for (NSString *file in [fm contentsOfDirectoryAtPath:cachesDirectory error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", cachesDirectory, file] error:&error];
            if (!success || error) {
                // it failed.
                NSLog(@"%@",error);
            }
        }
        for (NSString *file in [fm contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, file] error:&error];
            if (!success || error) {
                // it failed.
                NSLog(@"%@",error);
            }
        }
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"MainMenuViewController" function:@"deleteCachedFiles" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    [self.view setBackgroundColor:[UIColor colorWithRed:88.0f/255.0f green:96.0f/255.0f blue:104.0f/255.0f alpha:1.0]];
    [self.view setBackgroundColor:[UIColor colorWithRed:29.0f / 255.0f green:29.0f / 255.0f blue:29.0f / 255.0f alpha:1.0]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    if(appDelegate.searchModule.searchTypes.count>0)
        selectedType=((CSearchType*)appDelegate.searchModule.searchTypes[0]).typeId;
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton=YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return appDelegate.searchModule.criterias.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(appDelegate.searchModule.criterias.count == indexPath.section)
    {
      return  appDelegate.searchModule.searchTypes.count*55 +60;//40 for search button
    }
    

    return 80;
}

-(CGFloat)  tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//	if(section==appDelegate.searchModule.criterias.count)
//	return appDelegate.searchModule.searchTypes.count*55;
//    
    return 1;
	
}

-(CGFloat)  tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0)
	return 50;
    
    return 1;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    if(section==0){
        
        //view.frame=CGRectMake((self.view.frame.size.width-500)/2, 0, 500, 120);
        
        UIButton *btnSimpleSearch=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-180-20, 75, 180, 30)];
        CGFloat red = 0.0f / 255.0f;
        CGFloat green = 155.0f / 255.0f;
        CGFloat blue = 213.0f / 255.0f;
        btnSimpleSearch.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        btnSimpleSearch.layer.cornerRadius=6;
        btnSimpleSearch.clipsToBounds=YES;
        [btnSimpleSearch setTitle:NSLocalizedString(@"Search.SimpleSearch", @"Simple Search") forState:UIControlStateNormal] ;
            [btnSimpleSearch setImage:[UIImage imageNamed:@"littlesearch.png"] forState:UIControlStateNormal];
            [btnSimpleSearch setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 80)];
            [btnSimpleSearch setTitleEdgeInsets:UIEdgeInsetsMake(5,5, 5,0)];
        
        [btnSimpleSearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnSimpleSearch.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        [btnSimpleSearch addTarget:self action:@selector(simpleSearchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        //[view addSubview:btnSimpleSearch];
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.text =NSLocalizedString(@"Search.AdvancedSearch", @"Advanced Search");
        label.frame = CGRectMake((self.view.frame.size.width-450)/2, 0, 450, 40);
        label.backgroundColor = [UIColor clearColor];
        label.font =[UIFont fontWithName:@"Helvetica-Bold" size:24.0f];
        label.textAlignment=NSTextAlignmentCenter;
        
        [view addSubview:label];
        
       
    }
    return view;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    if(section==appDelegate.searchModule.criterias.count){
       
       }

    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"searchCell";
    CSearchCriteria* criteria=nil;
    if(indexPath.section < appDelegate.searchModule.criterias.count){
    criteria=appDelegate.searchModule.criterias[indexPath.section];
    }
    AdvanceSearchTableViewCell *cell=(AdvanceSearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
    cell = [[AdvanceSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;

    
    
    // Configure the cell...
     if(indexPath.section ==appDelegate.searchModule.criterias.count){
         
         [cell.txtCriteria removeFromSuperview];
         cell.backgroundColor=[UIColor clearColor];
         int buttonPositionY=5;
         
          NSMutableArray *itemArray = [NSMutableArray arrayWithObjects:nil];
         
         
         for(int i=0;i<appDelegate.searchModule.searchTypes.count;i++){
             CSearchType* searchType= [appDelegate.searchModule.searchTypes objectAtIndex:i];
            
             UIButton* btnCustom=[[UIButton alloc]initWithFrame:CGRectMake(0, buttonPositionY, 300, 50)];
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
             btnCustom.layer.cornerRadius=10;
             btnCustom.clipsToBounds=YES;
             btnCustom.tag=searchType.typeId;
             
             
            [itemArray addObject:[NSString stringWithFormat:@"%@",searchType.label]];
             
             
             
             [btnCustom setTitle:searchType.label forState:UIControlStateNormal] ;
             if(![searchType.icon isEqualToString:@""]){
                 UIImageView *imageView=[[UIImageView alloc ]initWithFrame:CGRectMake(10, 7, 37, 37)];
                 imageView.backgroundColor=[UIColor clearColor];
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
             
             buttonPositionY=buttonPositionY+55;
        }
         UIButton* btnSearch=[[UIButton alloc]initWithFrame:CGRectMake(445-150, buttonPositionY-80, 150, 30)];
         CGFloat red = 0.0f / 255.0f;
         CGFloat green = 155.0f / 255.0f;
         CGFloat blue = 213.0f / 255.0f;
         btnSearch.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
         btnSearch.layer.cornerRadius=10;
         btnSearch.clipsToBounds=YES;
         [btnSearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
         [btnSearch setTitle:NSLocalizedString(@"Search",@"Search") forState:UIControlStateNormal];
         btnSearch.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
         [btnSearch addTarget:self action:@selector(searchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
         [cell addSubview:btnSearch];

         segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
         NSDictionary *highlightedattributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:17],NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil];
         [segmentedControl setTitleTextAttributes:highlightedattributes forState:UIControlStateNormal];
         [segmentedControl setTitleTextAttributes:highlightedattributes forState:UIControlStateSelected];
         segmentedControl.frame = CGRectMake((self.view.frame.size.width-300)/3, (appDelegate.searchModule.criterias.count+1)*80, 300, 70);
         segmentedControl.tintColor = [UIColor colorWithRed:0.0f / 255.0f green:155.0f / 255.0f blue:213.0f / 255.0f alpha:1.0];
         [segmentedControl setSelectedSegmentIndex:0];
         [segmentedControl addTarget:self action:@selector(segmentedControlIndexChanged) forControlEvents:UIControlEventValueChanged];
         [self.view addSubview:segmentedControl];
         
         //end jis uisegment
         
         
         
     }else{ [cell updateCellwithCriteria:criteria];
         cell.txtCriteria.returnKeyType = UIReturnKeySearch;
         
         cell.txtCriteria.delegate=self;
     }
    return cell;
}

-(void)searchButtonClicked{
    [self performSelectorOnMainThread:@selector(increaseProgress) withObject:nil waitUntilDone:YES];
    [self performSelectorInBackground:@selector(performSearch) withObject:nil ];
 
    
    

}

-(void)performSearch{
    @try{
        
        appDelegate.SearchActive=YES;
        NSString* showthumb;
        if (appDelegate.ShowThumbnail)
            showthumb=@"true";
        else
            showthumb=@"false";
        //iterate throught cells
        NSMutableArray *cells = [[NSMutableArray alloc] init];
        @try{
            NSLog(@"%d",[self.tableView numberOfSections]);
            //NSLog(@"%@",self.tableView );
        //    NSArray *cellss = [self.tableView visibleCells];
           // int i=0;
            for (UIView *view in self.tableView.subviews) {
                for (AdvanceSearchTableViewCell *cell in view.subviews) {
                    //do
                    if(cell.class!=UIButton.class && cell.class!=UILabel.class && cell.class!=UISegmentedControl.class)
                            [cells addObject:cell];

                }
            }
//            for(UITableViewCell*cell in cellss){
//                if(i!=[cellss count])
//                    [cells addObject:cell];
//                i++;
//            }
//        
        }@catch(NSException *ex){
            NSLog(@"%@",ex);
        }
        NSString* queryString=@"";
        for (AdvanceSearchTableViewCell *cell in cells)
        {
            @try {
                UITextField *textField = [cell txtCriteria];
                // UILabel *lblTitle=[cell lbltitle];
                NSString *value=@"";
                if([cell.criteria.type.lowercaseString isEqualToString:@"list"]){
                    if(cell.txtCriteria.tag !=0)
                        value=[NSString stringWithFormat:@"%d",cell.txtCriteria.tag];
                }else value=textField.text;
                if(cell.criteria.id!=nil)
                    queryString=[NSString stringWithFormat:@"%@%@:%@;#",queryString,cell.criteria.id,value ];
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception);
            }
            @finally {
                
            }
            
        }
        
        queryString=[queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString* url;
        if(appDelegate.SupportsServlets)
            url = [NSString stringWithFormat:@"http://%@",appDelegate.serverUrl];
        else
            url = [NSString stringWithFormat:@"http://%@/SearchCorrespondences",appDelegate.serverUrl];
        
        // setting up the request object now
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        
        // action parameter
        if(appDelegate.SupportsServlets){
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"action\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"SearchCorrespondences" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }

        // token parameter
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"token\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[appDelegate.user.token dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        // criteria parameter
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"criteria\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
//        // typeid parameter
//        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"typeId\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"%d", selectedType] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        // showthumbnail parameter
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"showThumbnails\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[showthumb dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        // index parameter
//        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"index\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"%d",  appDelegate.NbOfCorrToLoad] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        
//        // pageSize parameter
//        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"pageSize\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"%d", appDelegate.SettingsCorrNb] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        // close form
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // set request body
        [request setHTTPBody:body];
        
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
       // NSURL *xmlUrl = [NSURL URLWithString:url];
       // NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
        NSString *validationResultUser=[CParser ValidateWithData:returnData];
        
        if(![validationResultUser isEqualToString:@"OK"])
        {
            [self ShowMessage:validationResultUser];
            
        }
        else {
            appDelegate.searchModule.correspondenceList = [CParser loadSearchCorrespondencesWithData:returnData];
            
            if(appDelegate.searchModule.correspondenceList.count>0){
                 [self performSelectorOnMainThread:@selector(showResult) withObject:nil waitUntilDone:NO];
            }
            else{
                [self ShowMessage:NSLocalizedString(@"Alert.NoResult",@"No Result Found.")];
            }
            
        }
        
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"AdvanceSearchViewController" function:@"searchButtonClicked" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    @finally {
        appDelegate.SearchActive=NO;
        [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
    }
    
}

-(void)showResult{
    SearchResultViewController *searchResultViewController = [[SearchResultViewController alloc]initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:searchResultViewController animated:YES];
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
    [self searchButtonClicked];
    //[textField resignFirstResponder];
    return YES;
}


-(void)segmentedControlIndexChanged
{
    for(int i=0;i<appDelegate.searchModule.searchTypes.count;i++){
        if(((CSearchType*)appDelegate.searchModule.searchTypes[i]).typeId==segmentedControl.selectedSegmentIndex + 1){
            selectedType=((CSearchType*)appDelegate.searchModule.searchTypes[i]).typeId;
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
    for(int i=0;i<appDelegate.searchModule.searchTypes.count;i++){
     
        if(((CSearchType*)appDelegate.searchModule.searchTypes[i]).typeId==btn.tag){
//            CGFloat red = 53.0f / 255.0f;
//            CGFloat green = 53.0f / 255.0f;
//            CGFloat blue = 53.0f / 255.0f;
            
            CGFloat red = 0.0f / 255.0f;
            CGFloat green = 155.0f / 255.0f;
            CGFloat blue = 213.0f / 255.0f;
            btn.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
            selectedType=((CSearchType*)appDelegate.searchModule.searchTypes[i]).typeId;
        }
        else {
            UIButton *button = (UIButton *)[self.view viewWithTag:i+1];
//            CGFloat red = 33.0f / 255.0f;
//            CGFloat green = 33.0f / 255.0f;
//            CGFloat blue = 33.0f / 255.0f;
            CGFloat red = 53.0f / 255.0f;
            CGFloat green = 53.0f / 255.0f;
            CGFloat blue = 53.0f / 255.0f;
            button.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        }
    }

}

-(void)simpleSearchButtonClicked{
    SimpleSearchViewController *simpleViewController = [[SimpleSearchViewController alloc]init];
    UINavigationController *navController=[appDelegate.splitViewController.viewControllers objectAtIndex:1];                            [navController setNavigationBarHidden:YES animated:NO];
    [navController pushViewController:simpleViewController animated:YES];
}
@end
