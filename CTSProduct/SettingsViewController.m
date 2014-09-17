


#import "SettingsViewController.h"
#import "SignatureViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "FileManager.h"
#import "CParser.h"
@interface SettingsViewController (){
    AppDelegate* mainDelegate;
    NSUserDefaults *defaults;
}

@end

@implementation SettingsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.btnSave.autoresizingMask = UIViewAutoresizingNone;
    self.btnSave.backgroundColor=[UIColor colorWithRed:37/255.0f green:96/255.0f blue:172/255.0f alpha:1.0];
    [self.btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    CGFloat red = 0.0f / 255.0f;
    CGFloat green = 155.0f / 255.0f;
    CGFloat blue = 213.0f / 255.0f;
    [self.btnSave setTitleColor:[UIColor colorWithRed:red green:green blue:blue alpha:1.0] forState:UIControlStateHighlighted];
    self.btnSave.layer.borderColor=[[UIColor grayColor] CGColor];
    self.btnSave.layer.cornerRadius=10;
    [self.btnSave.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:24]];
    
    defaults = [NSUserDefaults standardUserDefaults];
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CGFloat red1 = 173.0f / 255.0f;
    CGFloat green1 = 208.0f / 255.0f;
    CGFloat blue1 = 238.0f / 255.0f;
    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBarHidden = NO;
    self.tableView.backgroundColor = [UIColor colorWithRed:red1 green:green1 blue:blue1 alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithRed:45.0f/255.0f green:45.0f/255.0f blue:45.0f/255.0f alpha:1.0];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"searchResultCell"];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(0,0,0,0)];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"CorrNbPerPage"]!=nil )
        self.NbOfCorrespondences.text =[[NSUserDefaults standardUserDefaults] stringForKey:@"CorrNbPerPage"];
    else
        self.NbOfCorrespondences.text=[NSString stringWithFormat:@"%d",mainDelegate.SettingsCorrNb];
    
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class],nil] setTextColor:[UIColor whiteColor]];
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class],nil] setTextAlignment:NSTextAlignmentRight];
    
}

-(void)deleteCachedFiles{
    
    @try{
        
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
    
    switch (section)
    {
        case 0:{
            SignatureViewController *signatureView = [[SignatureViewController alloc] initWithFrame:CGRectMake(310, 100, 400, 500)];
            signatureView.modalPresentationStyle = UIModalPresentationFormSheet;
            signatureView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:signatureView animated:YES completion:nil];
            signatureView.view.superview.frame = CGRectMake(310, 100, 400, 500);
        }
            break;
            
        case 1:
            [CParser ClearCache];
            [defaults setObject:@"" forKey:@"iconsCache"];
            [defaults synchronize];
            [self logMeOut];
            /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Wrong username or password please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];*/
            break;
        default:
            break;
    }
    
}

- (IBAction)save:(id)sender {
    [self.NbOfCorrespondences resignFirstResponder];//Dismiss the keyboard.
    mainDelegate.SettingsCorrNb =[self.NbOfCorrespondences.text intValue];
    [defaults setObject:self.NbOfCorrespondences.text forKey:@"CorrNbPerPage"];
    [defaults synchronize];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Message",@"Message") message:NSLocalizedString(@"Alert.SaveSuccess",@"Saved Successfully") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}
@end
