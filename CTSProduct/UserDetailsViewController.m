//
//  UserDetailsViewController.m
//  CTSProduct
//
//  Created by DNA on 8/25/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "UserDetailsViewController.h"
#import "AppDelegate.h"
#import "UserDetail.h"
#import "CParser.h"
#import "SVProgressHUD.h"
#import "FileManager.h"
@interface UserDetailsViewController ()

@end

@implementation UserDetailsViewController{
    AppDelegate *mainDelegate;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.clearsSelectionOnViewWillAppear = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat red = 29.0f / 255.0f;
    CGFloat green = 29.0f / 255.0f;
    CGFloat blue = 29.0f / 255.0f;
    self.tableView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    [self.tableView setSeparatorColor:[UIColor whiteColor]];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UserDetails"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetail* row=self.UserDetail[indexPath.row];
    
    
    UIFont *font = [UIFont systemFontOfSize:17];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:row.detail attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){200, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    size.height = ceilf(size.height);
    size.width  = ceilf(size.width);
    return size.height +30;  //Add a little more padding for big thumbs and the detailText label
    
    
    
    
//    
//    CGSize size = [row.detail sizeWithAttributes:
//                   @{NSFontAttributeName:
//                         [UIFont systemFontOfSize:17.0f]}];
//   
//    
//	return size.height+20;

}
-(CGFloat)  tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.UserDetail.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserDetails";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
   // UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 37, 37)];
    
    //UILabel *labelTitle= [[UILabel alloc] initWithFrame:CGRectMake(70, 5,cell.frame.size.width-140, 40)];
    cell.textLabel.frame=CGRectMake(70, 5,cell.frame.size.width-140, 40);
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    UserDetail* row=self.UserDetail[indexPath.row];
    
    
   //     if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        cell.textLabel.textAlignment=NSTextAlignmentCenter;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text=row.detail;
    [cell.textLabel sizeToFit];

       // imageView.frame=CGRectMake(cell.frame.size.width-45, 5, 37, 37);
  //  }
   //[cell addSubview:imageView];
//    cell.textLabel.text =labelTitle;
    //[cell addSubview:labelTitle];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
//    NSLog(@"%d",indexPath.row);
//    UserDetail* row=self.UserDetail[indexPath.row];
//
//           // [_delegate executeAction:row.action note:@"" movehome:row.backhome];
//    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loading ...") maskType:SVProgressHUDMaskTypeBlack];
//
//    
//        @try{
//            
//            NSString* params;
//            NSString* url;
//            if(mainDelegate.SupportsServlets){
//                params=[NSString stringWithFormat:@"action=setUserDepartment&token=%@&departmentId=%d", mainDelegate.user.token,[row.title intValue]];
//                url = [NSString stringWithFormat:@"http://%@?%@",mainDelegate.serverUrl,params];
//                
//            }
//            else{
//                params=[NSString stringWithFormat:@"ExecuteCustomActions?token=%@&departmentId=%d", mainDelegate.user.token,[row.title intValue]];
//                url = [NSString stringWithFormat:@"http://%@/%@",mainDelegate.serverUrl,params];
//                
//            }
//            if(!mainDelegate.isOfflineMode){
//                NSURL *xmlUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//                NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
//                NSString *validationResultAction=[CParser ValidateWithData:xmlData];
//                
//                if(![validationResultAction isEqualToString:@"OK"])
//                {
//                    [SVProgressHUD dismiss];
//
//                    [self ShowMessage:validationResultAction];
//                    
//                }else {
//                    [SVProgressHUD dismiss];
//
//                    [self ShowMessage:NSLocalizedString(@"Alert.ActionSuccess",@"Action successfuly done.")];
//                    
//                }
//            }else{
//                
//                [SVProgressHUD dismiss];
//                
//                
//            }
//        }
//        @catch (NSException *ex) {
//            [SVProgressHUD dismiss];
//
//            [FileManager appendToLogView:@"userDeatis" function:@"executeAction" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
//        }
    
    [_delegate dismissPopUp:self];
    
    
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

@end
