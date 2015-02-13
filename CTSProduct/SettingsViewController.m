//
//SettingsViewController.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//


#import "SettingsViewController.h"
#import "SignatureViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "FileManager.h"
#import "CParser.h"
#import "SVProgressHUD.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)
@interface SettingsViewController (){
    AppDelegate* mainDelegate;
    NSUserDefaults *defaults;
}

@end

@implementation SettingsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
        mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.btnSave.autoresizingMask = UIViewAutoresizingNone;

    self.btnSave.backgroundColor=mainDelegate.buttonColor;
    [self.btnSave setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
    
    self.NbOfCorrespondences.backgroundColor=mainDelegate.textColor;
    self.NbOfCorrespondences.textColor=mainDelegate.titleColor;
    self.NbOfCorrespondences.borderStyle=UITextBorderStyleNone;
    self.NbOfCorrespondences.keyboardType=UIKeyboardTypeNumberPad;
    [self.btnSave.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:24]];
    
    defaults = [NSUserDefaults standardUserDefaults];

    
    CGFloat red1 = 173.0f / 255.0f;
    CGFloat green1 = 208.0f / 255.0f;
    CGFloat blue1 = 238.0f / 255.0f;
    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBarHidden = YES;
    self.tableView.backgroundColor = [UIColor colorWithRed:red1 green:green1 blue:blue1 alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithRed:45.0f/255.0f green:45.0f/255.0f blue:45.0f/255.0f alpha:1.0];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"searchResultCell"];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(0,0,0,0)];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"CorrNbPerPage"]!=nil )
        self.NbOfCorrespondences.text =[[NSUserDefaults standardUserDefaults] stringForKey:@"CorrNbPerPage"];
    else
        self.NbOfCorrespondences.text=[NSString stringWithFormat:@"%d",mainDelegate.SettingsCorrNb];

    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class],nil] setTextColor:mainDelegate.titleColor];
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class],nil] setTextAlignment:NSTextAlignmentRight];
    if (mainDelegate.isOfflineMode) {
        self.btnSave.enabled=false;
        self.NbOfCorrespondences.enabled=false;
    }
    
}

-(void)deleteCachedFiles{
    
    @try{
        
        
        defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"NO" forKey:@"offline_mode"];
        [defaults synchronize];
        mainDelegate.isOfflineMode = [[[NSUserDefaults standardUserDefaults] stringForKey:@"offline_mode"] boolValue];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSError *error = nil;
        for (NSString *file in [fm contentsOfDirectoryAtPath:cachesDirectory error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", cachesDirectory, file] error:&error];
            if (!success || error) {
                NSLog(@"%@",error);
            }
        }
        for (NSString *file in [fm contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, file] error:&error];
            if (!success || error) {
                NSLog(@"%@",error);
            }
        }
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"NorecordsViewController" function:@"deleteCachedFiles" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
}

-(void)logMeOut{
    [self deleteCachedFiles];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.user=nil;
    delegate.searchModule=nil;
    delegate.selectedInbox=0;
    UIStoryboard *    storyboard=[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    LoginViewController *loginView=[[LoginViewController alloc]init];
    loginView= [storyboard instantiateViewControllerWithIdentifier:@"LOGIN"];
    [self.navigationController presentViewController:loginView animated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger section = [indexPath section];
    if (section==2 && mainDelegate.isOfflineMode) {
        [tableView cellForRowAtIndexPath:indexPath].selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    switch (section)
    {
        case 0:{

            if (!mainDelegate.isOfflineMode) {
                int myHeight;
                if (mainDelegate.PinCodeEnabled)
                    myHeight=500;
                else
                    myHeight=400;

            SignatureViewController *signatureView = [[SignatureViewController alloc] initWithFrame:CGRectMake(310, 100, 400, 500)];
            signatureView.modalPresentationStyle = UIModalPresentationFormSheet;
            signatureView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:signatureView animated:YES completion:nil];
              
            if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
                signatureView.view.superview.frame = CGRectMake(310, 100, 400, myHeight);
            else
                signatureView.preferredContentSize=CGSizeMake(400, myHeight);
            }
        
            else
            {
                [self ShowMessage:NSLocalizedString(@"Alert.EditSignature", @"go online before edit signature")];
            }
        }
            break;
            
        case 1:
            [CParser ClearCache];
            [defaults setObject:@"" forKey:@"iconsCache"];
            [defaults synchronize];
            [self logMeOut];
          
            break;
        case 2:
            if (!mainDelegate.isOfflineMode) {
                
                NSData *imageData= [NSData dataWithContentsOfFile:mainDelegate.logFilePath] ;

                [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Uploading ...") maskType:SVProgressHUDMaskTypeBlack];
                @try{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        
                        NSString* urlString;
                        if(mainDelegate.SupportsServlets)
                            urlString = [NSString stringWithFormat:@"http://%@",mainDelegate.serverUrl];
                        else
                            urlString = [NSString stringWithFormat:@"http://%@/SendLogs",mainDelegate.serverUrl];
                        
                        
                        // setting up the request object now
                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                        [request setURL:[NSURL URLWithString:urlString]];
                        [request setHTTPMethod:@"POST"];
                        
                        
                        NSString *boundary = @"---------------------------14737809831466499882746641449";
                        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
                        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
                        
                        NSMutableData *body = [NSMutableData data];
                        if(mainDelegate.SupportsServlets){
                            // action parameter
                            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"action\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData:[@"SendLogs" dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                            
                            
                        }
                        // file
                        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\".txt\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[NSData dataWithData:imageData]];
                        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                        

                        // close form
                        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                        
                        // set request body
                        [request setHTTPBody:body];
                        [request setTimeoutInterval:mainDelegate.Request_timeOut];
                        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                            NSString *validationResult=[CParser ValidateWithData:returnData];
                            if (mainDelegate==nil) mainDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
                                if(![validationResult isEqualToString:@"OK"]){
                                        [self ShowMessage:validationResult];
                                }else{
                                    
                                    [self ShowMessage:NSLocalizedString(@"Alert.Success", @"Saved Successfully")];
                            }
                            
                        });
                        
                    });
                }
                @catch (NSException *ex) {
                    [FileManager appendToLogView:@"ReaderViewController" function:@"uploadXml" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
                }

            }
            
            else
            {
              //  [self ShowMessage:NSLocalizedString(@"Alert.EditSignature", @"go online before edit signature")];
            }

            break;
        default:
            break;
    }
    
}

-(void)ShowMessage:(NSString*)message{
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Alert",@"Alert")
                          message: message
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK",@"OK")
                          otherButtonTitles: nil];
    [alert show];
}

- (IBAction)save:(id)sender {
    [self.NbOfCorrespondences resignFirstResponder];//Dismiss the keyboard.
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [self.NbOfCorrespondences.text stringByTrimmingCharactersInSet:ws];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    BOOL isDecimal = [nf numberFromString:trimmed] != nil;
    if(isDecimal &&trimmed.intValue>0){
        
    if(![trimmed isEqualToString:@""] && trimmed!=nil){
            
        
    mainDelegate.SettingsCorrNb =[self.NbOfCorrespondences.text intValue];
    [defaults setObject:self.NbOfCorrespondences.text forKey:@"CorrNbPerPage"];
    [defaults synchronize];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Message",@"Message") message:NSLocalizedString(@"Alert.SaveSuccess",@"Saved Successfully") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"ok") otherButtonTitles:nil];
    [alert show];
     

    }else{
        UIAlertView *alertKO;
        alertKO=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Fields Missing",@"Fields Missing") message:NSLocalizedString(@"Fill Fields",@"Please fill fileName field.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
        [alertKO show];
    }
    }else{
        self.NbOfCorrespondences.text=@"";
        UIAlertView *alertKO;
        alertKO=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert",@"Alert") message:NSLocalizedString(@"ValideNumber",@"please inset a valid number.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
        [alertKO show];
    }
}

@end
