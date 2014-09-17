//
//  NewActionTableViewController.m
//  CTSIpad
//
//  Created by DNA on 6/11/14.
//  Copyright (c) 2014 LBI. All rights reserved.
//

#import "SignatureController.h"
#import "MoreTableViewController.h"
#import "CAction.h"
#import "CUser.h"
#import "CMenu.h"
#import "CParser.h"
#import "CFPendingAction.h"
#import "MainMenuViewController.h"
#import "CSearch.h"
#import "ReaderMainToolbar.h"
#import "AppDelegate.h"
#import "CommentViewController.h"
@interface SignatureController ()
@end

@implementation SignatureController{
    
    AppDelegate *mainDelegate;
    AppDelegate *appDelegate;
}
@synthesize document,m_pdfview,m_pdfdoc,correspondenceId;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat red = 1.0f / 255.0f;
    CGFloat green = 49.0f / 255.0f;
    CGFloat blue = 97.0f / 255.0f;
    self.tableView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.SignAction.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"actionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    UILabel *labelTitle= [[UILabel alloc] initWithFrame:CGRectMake(70, 5,cell.frame.size.width-140, 40)];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.backgroundColor = [UIColor clearColor];
    
    CAction *actionProperty=self.SignAction[indexPath.row];
    if([actionProperty.label isEqualToString:@""] || actionProperty.label==nil){
        NSString* string=[NSString stringWithFormat:@"Signature.%@",actionProperty.action];
        labelTitle.text=NSLocalizedString(string, actionProperty.label);
    }
    else
        labelTitle.text=actionProperty.label;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 37, 37)];
    UIImage *cellImage;
    if(actionProperty.Custom)
        cellImage =  [UIImage imageWithData:[CParser LoadCachedIcons:actionProperty.action]];
    
    else
        cellImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",actionProperty.action]];
    
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
    [_delegate dismissPopUp:self];
    
    CAction *actionProperty=self.SignAction[indexPath.row];
    if(actionProperty.Custom){
        if(actionProperty.popup==NO){
            [_delegate executeAction:actionProperty.action note:@"" movehome:actionProperty.backhome];
            if(actionProperty.backhome)
                [_delegate movehome:self];
            else
                [_delegate dismissPopUp:self];
            
        }
        else{
            [_delegate PopUpCommentDialog:self Action:actionProperty document:nil];
            
        }
    }else{
        if([actionProperty.action isEqualToString:@"Sign"]||[actionProperty.action isEqualToString:@"SignAll"]){
           
            [self ActionExecute:actionProperty.action document:document];
        }
        else if([actionProperty.action isEqualToString:@"FreeSign"]||[actionProperty.action isEqualToString:@"FreeSignAll"]){
            [self SignWithLocation:actionProperty.action document:document];
            
        }
        else{
            [m_pdfview setHandsign:YES];

            [_delegate HandSign];
        }
    }
    //  [_delegate PopUpCommentDialog:self];
}
-(void)SignWithLocation:(NSString*)action document:(ReaderDocument *)document{
    
    
    if([mainDelegate.SignMode isEqualToString:@"CustomSign"]){
        mainDelegate.Signaction =@"";
        m_pdfview.delegate = _delegate;
        [m_pdfview setBtnHighlight:NO];
        [m_pdfview setBtnNote:NO];
        [m_pdfview setBtnSign:YES];
        if([action isEqualToString:@"FreeSignAll"]){
            [m_pdfview setFreeSignAll:YES];
            [m_pdfview setDocumentPagesNb:[self.document.pageCount intValue]];
        }else{
            [m_pdfview setFreeSignAll:NO];
            [m_pdfview setDocumentPagesNb:[m_pdfview GetPageIndex]+1];
            
            
        }
        UIAlertView *alertOk=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Info",@"Info") message:NSLocalizedString(@"Alert.Sign",@"Click on pdf document to sign") delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
        [alertOk show];
    }
    else{
        //jis sign
        mainDelegate.Signaction =action;
        [_delegate openmanagesignature];
    }
    
    
    
}
-(void)ActionExecute:(NSString*)action document:(ReaderDocument *)document{
    if([mainDelegate.SignMode isEqualToString:@"CustomSign"]){
        mainDelegate.Signaction =@"";
        mainDelegate.isAnnotated=YES;
        mainDelegate.FileUrl = [mainDelegate.FileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        int index;
        if([action isEqualToString:@"Sign"]){
            index=[m_pdfview GetPageIndex]+1;
            
        }
        else if([action isEqualToString:@"SignAll"]){
            index=[self.document.pageCount intValue];
            
        }
        NSString* searchUrl = [NSString stringWithFormat:@"http://%@?action=SignIt&loginName=%@&pdfFilePath=%@&pageNumber=%d&SiteId=%@&FileId=%@&FileUrl=%@",mainDelegate.serverUrl,mainDelegate.user.loginName,mainDelegate.docUrl,self.document.pageCount.intValue,mainDelegate.SiteId,mainDelegate.FileId,mainDelegate.FileUrl];
        if(!mainDelegate.isOfflineMode){
            // NSURL *xmlUrl = [NSURL URLWithString:searchUrl];
            // NSData *XmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[searchUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
            NSData *XmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            CParser *p=[[CParser alloc] init];
            [p john:XmlData];
            
            
            [_delegate showDocument:nil];
            
            
            CGPoint ptLeftTop;
            
            ptLeftTop.x = 279;
            ptLeftTop.y = 360;
            
            
            [m_pdfdoc extractText:ptLeftTop];
            [m_pdfview setNeedsDisplay];
            
            
            NSString *validationResultAction=[CParser ValidateWithData:XmlData];
            
            if(![validationResultAction isEqualToString:@"OK"])
            {
                
                [self ShowMessage:validationResultAction];
                
            }else {
                
                [self ShowMessage:@"Action successfuly done."];
                
            }
        }else{
            [CParser cacheOfflineActions:self.correspondenceId url:searchUrl action:@"Sign"];
        }
        
    }
    
    else{
        //jis sign
        mainDelegate.Signaction =action;
        CGPoint ptLeftTop;
        ptLeftTop.x=445;
        ptLeftTop.y=34;
        
        CGPoint ptRightBottom;
        ptRightBottom.x=445;
        ptRightBottom.y=34;
        
        [_delegate tappedSaveSignatureWithWidth:@"100" withHeight:@"100" withRed:0 withGreen:0 withBlue:0];
        
        
        [m_pdfdoc AddStampAnnot:ptLeftTop secondPoint:ptRightBottom previousPoint:ptLeftTop];
        [m_pdfview setBtnSign:NO];
        
    }
    
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
