//
//  ActionsViewController.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "ActionsViewController.h"
#import "CAction.h"
#import "CUser.h"
#import "CMenu.h"
#import "CParser.h"
#import "CFPendingAction.h"
#import "MainMenuViewController.h"
#import "CSearch.h"
#import "ReaderMainToolbar.h"
#import "AppDelegate.h"
#import "FileManager.h"
@interface ActionsViewController ()

@end

@implementation ActionsViewController{
    AppDelegate *mainDelegate;
}
@synthesize document;
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
    //    CGFloat red = 29.0f / 255.0f;
    //    CGFloat green = 29.0f / 255.0f;
    //    CGFloat blue = 29.0f / 255.0f;
    //    self.tableView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    CGFloat red = 1.0f / 255.0f;
    CGFloat green = 49.0f / 255.0f;
    CGFloat blue = 97.0f / 255.0f;
    self.view.backgroundColor= [UIColor colorWithRed:red green:green  blue:blue  alpha:1.0];
    
    [self.tableView setSeparatorColor:[UIColor whiteColor]];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"actionCell"];
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
    return 50;
}
-(CGFloat)  tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.actions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"actionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 37, 37)];
    
    UILabel *labelTitle= [[UILabel alloc] initWithFrame:CGRectMake(70, 5,cell.frame.size.width-140, 40)];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.backgroundColor = [UIColor clearColor];
    
    CAction *actionProperty=self.actions[indexPath.row];
    UIImage *cellImage;
    labelTitle.text=actionProperty.label;
    
    //NSString* imagename=[NSString stringWithFormat:@"%@.png",actionProperty.label];
    cellImage =  [UIImage imageWithData:[CParser LoadCachedIcons:actionProperty.action]];
    
    [imageView setImage:cellImage];
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        labelTitle.textAlignment=NSTextAlignmentRight;
        imageView.frame=CGRectMake(cell.frame.size.width-45, 5, 37, 37);
    }
    [cell addSubview:imageView];
    [cell addSubview:labelTitle];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    CAction *actionProperty=self.actions[indexPath.row];
    [_delegate PopUpCommentDialog:self Action:actionProperty.action document:nil];
    
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
-(void)executeAction:(NSString*)action{
    
    @try{
        
        
        
        NSString* params=[NSString stringWithFormat:@"action=ExecuteCustomActions&token=%@&correspondenceId=%@&docId=%@&actionType=%@", mainDelegate.user.token,self.correspondenceId,self.docId,action];
        NSString *serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_preference"];
        NSString* url = [NSString stringWithFormat:@"http://%@?%@",serverUrl,params];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
        
        // NSURL *xmlUrl = [NSURL URLWithString:url];
        NSData *xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *validationResultAction=[CParser ValidateWithData:xmlData];
        
        if(![validationResultAction isEqualToString:@"OK"])
        {
            [self ShowMessage:validationResultAction];
            
        }else {
            NSString* correspondenceUrl;
            NSString* showthumb;
            if (mainDelegate.ShowThumbnail)
                showthumb=@"true";
            else
                showthumb=@"false";
            if(mainDelegate.SupportsServlets)
                correspondenceUrl=[NSString stringWithFormat:@"http://%@?action=GetCorrespondences&token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",serverUrl,mainDelegate.user.token,mainDelegate.selectedInbox,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
            else
                correspondenceUrl=[NSString stringWithFormat:@"http://%@/GetCorrespondences?token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",serverUrl,mainDelegate.user.token,mainDelegate.selectedInbox,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:correspondenceUrl] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
            NSData *menuXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            //  NSURL *xmlUrl = [NSURL URLWithString:correspondenceUrl];
            //NSData *menuXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
            
            NSMutableDictionary *correspondences=[CParser loadCorrespondencesWithData:menuXmlData];
            
            
            mainDelegate.searchModule.correspondenceList = [correspondences objectForKey:[NSString stringWithFormat:@"%d",mainDelegate.selectedInbox]];
            
            [self ShowMessage:@"Action successfuly done."];
            
            
            
            
            
        }
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ActionsViewController" function:@"executeAction" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    
}







@end
