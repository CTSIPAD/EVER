//
//	ReaderMainToolbar.m
//	Reader v2.6.1
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2012 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderConstants.h"
#import "ReaderMainToolbar.h"
#import "ReaderDocument.h"
#import"CUser.h"
#import"CMenu.h"
#import"CCorrespondence.h"
#import"CAttachment.h"
#import"CFolder.h"
#import "AppDelegate.h"
#import "CParser.h"
#import "CSearch.h"
#import "TransferViewController.h"
#import <MessageUI/MessageUI.h>
#import "CFPendingAction.h"
#import "GDataXMLElement-Extras.h"
#import "SVProgressHUD.h"
#import "ToolbarItem.h"

#define ButtonWidth 65
#define seperator 35
#define arabicFont 14
#define lableX 5
@implementation ReaderMainToolbar
{
    NSInteger correspondencesCount;
    NSInteger attachementsCount;
    AppDelegate *mainDelegate;
    NSString* pageName;
    CCorrespondence *correspondence;
    UIButton *CustomButton;
    UIButton *customButton1;
    UIImage* homeimage;
    UIImage* metadataimage;
    UIImage* Hideimage;
    UIImage* Attachementsimage;
    UIImage* Transferimage;
    UIImage* Annotationsimage;
    UIImage* Signatureimage;
    UIImage* Saveimage;
    UIImage* Previousimage;
    UIImage* nextImage;
    UIImage* moreImage;
    UILabel* homeLabel;
    UILabel* metadataLabel;
    UILabel* HideLabel;
    UILabel* AttachementsLabel;
    UILabel* TransferLabel;
    UILabel* AnnotationsLabel;
    UILabel* SignatureLabel;
    UILabel* SaveLabel;
    UILabel* PreviousLabel;
    UILabel* nextLabel;
    UILabel* moreLable;
    BOOL lblTitleHide;
    BOOL enableAction;
    UIInterfaceOrientation CurrentOrientation;
 
}
@synthesize nextButton,previousButton,MoreButton,transferButton,attachmentButton,metadataButton,lockButton,commentsButton,annotationButton,lblTitle,closeButton,ActionsButton,Save;

@synthesize delegate;

#pragma mark ReaderMainToolbar instance methods

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame document:nil CorrespondenceId:0 MenuId:0 AttachmentId:0];
}

- (id)initWithFrame:(CGRect)frame document:(ReaderDocument *)object CorrespondenceId:(NSInteger)correspondenceId MenuId:(NSInteger)menuId AttachmentId:(NSInteger)attachmentId
{
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hidden=true;
	assert(object != nil); // Must have a valid ReaderDocument
	if ((self = [super initWithFrame:frame]))
	{
        
        self.menuId=menuId;
        self.correspondenceId=correspondenceId;
        self.attachmentId=attachmentId;
        self.user=mainDelegate.user;
        
        
        if(menuId!=100){
            correspondence=((CMenu*)self.user.menu[menuId]).correspondenceList[correspondenceId];
            correspondencesCount=((CMenu*)self.user.menu[menuId]).correspondenceList.count;
            //jen PreviousNext
            NSMutableArray* thumbnailrarray = [[NSMutableArray alloc] init];
            
            
            if (correspondence.attachmentsList.count>0)
            {
                for(CAttachment* doc in correspondence.attachmentsList)
                {
                    if([doc.FolderName isEqualToString:mainDelegate.FolderName]){
                        [thumbnailrarray addObject:doc];
                    }
                    
                    
                }
            }
            
            attachementsCount=thumbnailrarray.count;
        }else{
            
            correspondence=mainDelegate.searchModule.correspondenceList[mainDelegate.searchSelected];
            correspondencesCount=mainDelegate.searchModule.correspondenceList.count;
            //jen PreviousNext
            NSMutableArray* thumbnailrarray = [[NSMutableArray alloc] init];
            
            
            if (correspondence.attachmentsList.count>0)
            {
                for(CAttachment* doc in correspondence.attachmentsList)
                {
                    if([doc.FolderName isEqualToString:mainDelegate.FolderName]){
                        [thumbnailrarray addObject:doc];
                    }
                    
                    
                }
            }
            
            //attachementsCount=thumbnailrarray.count;
            attachementsCount=correspondence.attachmentsList.count;
            
        }
        // title,home,next,previous and hide initialize at begining
        homeLabel=[[UILabel alloc]init];
        metadataLabel=[[UILabel alloc]init];
        HideLabel=[[UILabel alloc]init];
        AttachementsLabel=[[UILabel alloc]init];
        TransferLabel=[[UILabel alloc]init];
        AnnotationsLabel=[[UILabel alloc]init];
        SignatureLabel=[[UILabel alloc]init];
        SaveLabel=[[UILabel alloc]init];
        PreviousLabel=[[UILabel alloc]init];
        nextLabel=[[UILabel alloc]init];
        moreLable=[[UILabel alloc]init];
        
        lblTitle=[[UILabel alloc]initWithFrame:CGRectMake(20, 15, self.frame.size.width, 15)];
        lblTitle.font = [UIFont fontWithName:@"Helvetica" size:12];
        lblTitle.textColor=[UIColor colorWithRed:204/255.0f green:233/255.0f blue:247/255.0f alpha:1.0];
        //[self addSubview:lblTitle];
        
        Transferimage=[UIImage imageNamed:@"Transfer.png"];
        Attachementsimage=[UIImage imageNamed:@"AttachementsIcon.png"];
        metadataimage=[UIImage imageNamed:@"metadata.png"];
        Annotationsimage=[UIImage imageNamed:@"Annotations.png"];
        Signatureimage=[UIImage imageNamed:@"Signature.png"];
        Saveimage=[UIImage imageNamed:@"SaveIcon.png"];
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            moreImage=[UIImage imageNamed:@"More-flipped.png"];
        }
        else{
            moreImage=[UIImage imageNamed:@"More.png"];

        }
        homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        homeButton.tag=100;
        homeimage=[UIImage imageNamed:@"homeIcon.png"];
        [homeButton setBackgroundImage:homeimage forState:UIControlStateNormal];
        [homeButton setTitleEdgeInsets:UIEdgeInsetsMake(58, 15, 0,10)];
        
        homeLabel.text=NSLocalizedString(@"Menu.Home",@"Home");
        
        homeLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
        homeLabel.textColor=[UIColor whiteColor];
        homeLabel.numberOfLines = 3;
        homeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [homeButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        [homeButton addTarget:self action:@selector(homeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:homeButton];
        [self addSubview:homeLabel];
        
        
        nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        nextButton.tag=100;
        nextImage=[UIImage imageNamed:@"NextIcon.png"];
        [nextButton setBackgroundImage: nextImage forState:UIControlStateNormal];
        nextLabel.text=NSLocalizedString(@"Menu.Next",@"Next");
        nextLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
        nextLabel.textColor=[UIColor whiteColor];
        nextLabel.numberOfLines = 3;
        nextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            [nextButton addTarget:self action:@selector(previousButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self addSubview:nextButton];
        [self addSubview:nextLabel];

        if(attachmentId==attachementsCount-1){
            nextButton.enabled=FALSE;
        }
        else  nextButton.enabled=TRUE;
        
        previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        previousButton.tag=100;
        Previousimage=[UIImage imageNamed:@"PreviousIcon.png"];

        [previousButton setBackgroundImage: Previousimage forState:UIControlStateNormal];
        PreviousLabel.text=NSLocalizedString(@"Menu.Previous",@"Previous");
        PreviousLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
        PreviousLabel.textColor=[UIColor whiteColor];
        PreviousLabel.numberOfLines = 3;
        PreviousLabel.lineBreakMode = NSLineBreakByWordWrapping;
         [previousButton addTarget:self action:@selector(previousButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
             [previousButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self addSubview:previousButton];
        [self addSubview:PreviousLabel];

        if(attachmentId==0){
            previousButton.enabled=FALSE;
        }
        else  previousButton.enabled=TRUE;
        
        
        
        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.tag=100;
        Hideimage=[UIImage imageNamed:@"HideIcon.png"];
        [closeButton setBackgroundImage:Hideimage forState:UIControlStateNormal];
        HideLabel.text=NSLocalizedString(@"Menu.Hide", @"Hide Menu");
        HideLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
        HideLabel.numberOfLines = 3;
        HideLabel.lineBreakMode = NSLineBreakByWordWrapping;
        HideLabel.textColor=[UIColor whiteColor];
        [closeButton addTarget:self action:@selector(hideToolbar) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        [self addSubview:HideLabel];


    }
    CurrentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    UIDeviceOrientation orient=[[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsPortrait(orient)) {
        CurrentOrientation=UIInterfaceOrientationPortrait;
    }
    [self adjustButtons:CurrentOrientation];
    [self updateToolbar];
    self.backgroundColor=[UIColor colorWithRed:12/255.0f green:93/255.0f blue:174/255.0f alpha:1.0];
    self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 100);
	return self;
}

//portrait/landscape  Mode to set frame for fixed button
-(void)adjustButtons:(UIInterfaceOrientation)orientation{
    CurrentOrientation=orientation;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        // initialize as portrait or rotate to portrait
        
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            int startleft=10;


            homeButton.frame = CGRectMake(768-80, 15, homeimage.size.width,homeimage.size.height);
            previousButton.frame=CGRectMake(startleft, homeButton.frame.origin.y, Previousimage.size.width,Previousimage.size.height);
            nextButton.frame = CGRectMake(startleft+ButtonWidth,homeButton.frame.origin.y, nextImage.size.width,nextImage.size.height);
            closeButton.frame=CGRectMake(startleft+2*ButtonWidth+5, homeButton.frame.origin.y, Hideimage.size.width,Hideimage.size.height);
            lblTitleHide=true;

            
        }
        else{
            int endright=768;
            homeButton.frame = CGRectMake(10, 15,homeimage.size.width,homeimage.size.height);
              closeButton.frame=CGRectMake(endright-2*ButtonWidth-80, homeButton.frame.origin.y, Hideimage.size.width,Hideimage.size.height);
            previousButton.frame=CGRectMake(closeButton.frame.origin.x+closeButton.frame.size.width+20,homeButton.frame.origin.y, Previousimage.size.width,Previousimage.size.height);
            nextButton.frame = CGRectMake(previousButton.frame.origin.x+previousButton.frame.size.width+20,homeButton.frame.origin.y, nextImage.size.width,nextImage.size.height);
             lblTitleHide=true;
        }
    } else{
        //landscape mode
     
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            int startleft=10;
            
            homeButton.frame = CGRectMake(768+167, 15, homeimage.size.width,homeimage.size.height);
            previousButton.frame=CGRectMake(startleft, homeButton.frame.origin.y, Previousimage.size.width,Previousimage.size.height);
            nextButton.frame = CGRectMake(startleft+ButtonWidth,homeButton.frame.origin.y, nextImage.size.width,nextImage.size.height);
            closeButton.frame=CGRectMake(startleft+2*ButtonWidth+5,homeButton.frame.origin.y, Hideimage.size.width,Hideimage.size.height);
           
            lblTitleHide=false;
            
        }
        else{
            int endright=768+182;
             homeButton.frame = CGRectMake(10, 15, homeimage.size.width,homeimage.size.height);
             nextButton.frame = CGRectMake(endright,homeButton.frame.origin.y,nextImage.size.width,nextImage.size.height);
            previousButton.frame=CGRectMake(endright-ButtonWidth,homeButton.frame.origin.y, Previousimage.size.width,Previousimage.size.height);
            closeButton.frame=CGRectMake(endright-2*ButtonWidth-5, homeButton.frame.origin.y, Hideimage.size.width,Hideimage.size.height);
            lblTitleHide=false;
            
            
        }
    }
    if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
        homeLabel.frame=CGRectMake(homeButton.frame.origin.x+3, homeButton.frame.origin.y+homeButton.frame.size.height-5, 60, 60);
        nextLabel.frame=CGRectMake(previousButton.frame.origin.x+3, previousButton.frame.origin.y+previousButton.frame.size.height, 60, 30);
        PreviousLabel.frame=CGRectMake(nextButton.frame.origin.x+7,nextButton.frame.origin.y+nextButton.frame.size.height, 90, 30);
        HideLabel.frame=CGRectMake(closeButton.frame.origin.x+7, closeButton.frame.origin.y+closeButton.frame.size.height, 90, 30);
    }
    else
    {
        homeLabel.frame=CGRectMake(homeButton.frame.origin.x, homeButton.frame.origin.y+homeButton.frame.size.height, 60, 30);
        PreviousLabel.frame=CGRectMake(previousButton.frame.origin.x-lableX, previousButton.frame.origin.y+previousButton.frame.size.height, 60, 30);
        nextLabel.frame=CGRectMake(nextButton.frame.origin.x+6,nextButton.frame.origin.y+nextButton.frame.size.height, 90, 30);
        HideLabel.frame=CGRectMake(closeButton.frame.origin.x+5, closeButton.frame.origin.y+closeButton.frame.size.height, 90, 30);
    
    }

    [self updateToolbar];
    
}



- (void)hideToolbar
{
	if (self.hidden == NO)
	{
 
		[UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             self.hidden = YES;
         }
         ];
	}
}

- (void)showToolbar:(NSString*)status
{
	if (self.hidden == YES)
	{
        
		[UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.hidden = NO;
             self.alpha = 1.0f;
         }
                         completion:NULL
         ];
	}
    [self refreshToolbar:status];
}
-(void)refreshToolbar:(NSString*)state{
    if([[state uppercaseString] isEqualToString:@"READONLY"]){
        for(UIButton* btn in self.subviews){
            if(btn.tag!=100)
                btn.enabled=false;
        }
    }
    else
        if([[state uppercaseString] isEqualToString:@"NOTPDF"]){
            Save.enabled=false;
            SignActionButton.enabled=false;
            annotationButton.enabled=false;
        }
        else{
            for(UIButton* btn in self.subviews){
                if(btn.tag!=100)
                    btn.enabled=true;
            }
        }
}
-(ReaderDocument*) OpenPdfReader:(NSString *) pdfPath{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    NSString *filePath = pdfPath;// [pdfs lastObject];
    assert(filePath != nil); // Path to last PDF file
    
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
    return document;
}


#pragma mark UIButton action methods
- (void)SignAction:(UIButton *)button
{
  
	[delegate tappedInToolbar:self SignActionButton:button];
}


- (void)homeButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self homeButton:button];
}

- (void)ActionsButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self actionsButton:button];
}
- (void)MoreButtonTapped:(UIButton *)button
{
    
	[delegate tappedInToolbar:self MoreButton:button];
}
- (void)CustomButtonTapped:(UIButton *)button
{
    NSString*key=[NSString stringWithFormat:@"%d",button.tag];
    ToolbarItem* item=[correspondence.toolbar objectForKey:key];
    NSMutableArray* CustomItems=[[NSMutableArray alloc]init];
    CustomItems=[correspondence.CustomItemsList objectForKey:item.Name];
    if(CustomItems.count<=0){
        if(!item.popup){
            [delegate executeAction:item.Name note:@"" movehome:item.backhome];
            if(item.backhome)
                [delegate tappedInToolbar:self homeButton:button];
        }
        else
            [delegate tappedInToolbar:self CustomButton:button Item:item ShowItems:NO];
    }
    else{
        [delegate tappedInToolbar:self CustomButton:button Item:item ShowItems:YES];
        
    }
    
}
- (void)SaveButtonTapped:(UIButton *)button
{
    
	[delegate tappedInToolbar:self SaveButton:button];
}
- (void)commentButtonTapped:(UIButton *)button
{
    [delegate tappedInToolbar:self commentButton:button];
}
- (void)metadataButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self metadataButton:button];
}

- (void)attachmentButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self attachmentButton:button];
}

- (void)annotationButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self annotationButton:button];
}
-(void)actionButtonTapped:(UIButton *)button
{
    [delegate tappedInToolbar:self actionButton:button];
}
- (void)transferButtonTapped:(UIButton *)button
{
    [delegate tappedInToolbar:self transferButton:button];
    
}
BOOL lockSelected=NO;
- (void)lockButtonTapped:(UIButton *)button
{
    
    lockSelected=!lockSelected;
    if(lockSelected){
        lockButton.selected=YES;
    }else  lockButton.selected=NO;

}

-(BOOL)performLock:(NSString*)action{
    
    BOOL isPerformed=NO;
    
    NSString* url=[NSString stringWithFormat:@"action=%@&token=%@&correspondenceId=%@",action,mainDelegate.user.token,correspondence.Id];
    NSString* lockUrl = [NSString stringWithFormat:@"http://%@?%@",mainDelegate.serverUrl,url];

    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[lockUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
    NSData *lockXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *validationResult=[CParser ValidateWithData:lockXmlData];
    if(![validationResult isEqualToString:@"OK"]){
        if([validationResult isEqualToString:@"Cannot access to the server"])
        {isPerformed=YES;
            
            //  CFPendingAction*pa = [[CFPendingAction alloc] initWithActionUrl:url];
            // [mainDelegate.user addPendingAction:pa];
        }else
            [delegate tappedInToolbar:self lockButton:nil message:validationResult];
    }
    else isPerformed=YES;
    
    return isPerformed;
}


- (void)nextButtonTapped :(UIButton *)button
{
    CAttachment *fileToOpen;
    self.attachmentId=self.attachmentId+1;
    
    
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    mainDelegate.attachmentType = @"nextprevioustype";
    
    correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    
    
    fileToOpen=correspondence.attachmentsList[self.attachmentId];
    if (fileToOpen.url !=nil || !mainDelegate.isOfflineMode) {
        
    
    [self updateTitleWithLocation:fileToOpen.location withName:fileToOpen.title];
    
    //jis next
    [self performSelectorOnMainThread:@selector(increaseProgress) withObject:@"" waitUntilDone:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        if([fileToOpen.url isEqualToString:@""]||fileToOpen.url==nil){
            
            [mainDelegate.folderNames addObject:fileToOpen.FolderName];
            mainDelegate.FolderName=fileToOpen.FolderName;
            mainDelegate.FolderId=fileToOpen.FolderId;
            int docId = [correspondence.Id intValue];
            NSData *attachmentXmlData;
            if(!mainDelegate.isOfflineMode){
                NSString* attachmentUrl;
                NSString* showthumb;
                if (mainDelegate.ShowThumbnail)
                    showthumb=@"true";
                else
                    showthumb=@"false";
                if(mainDelegate.SupportsServlets)
                    attachmentUrl= [NSString stringWithFormat:@"http://%@?action=GetFolderAttachments&token=%@&docId=%d&folderName=%@&folderId=%@&showThumbnails=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,docId,mainDelegate.FolderName,mainDelegate.FolderId,showthumb,mainDelegate.IpadLanguage];
                else
                    attachmentUrl= [NSString stringWithFormat:@"http://%@/GetFolderAttachments?token=%@&docId=%d&folderName=%@&folderId=%@&showThumbnails=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,docId,mainDelegate.FolderName,mainDelegate.FolderId,showthumb,mainDelegate.IpadLanguage];
                
                [CParser GetFolderAttachment:attachmentUrl Id:self.correspondenceId];
                
            }else{
                attachmentXmlData=[CParser LoadXML:@"Attachment" nb:correspondence.Id name:mainDelegate.FolderName];
                
            }
            
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:fileToOpen.docId fromSharepoint:mainDelegate.isSharepoint];
            ReaderDocument *newdocument=nil;
            if ([ReaderDocument isPDF:tempPdfLocation] == YES) // File must exist
            {
                newdocument=[self OpenPdfReader:tempPdfLocation];
            }
            
            [delegate tappedInToolbar:self nextButton:button documentReader:newdocument correspondenceId:self.correspondenceId attachementId:self.attachmentId];
            
            if(self.attachmentId==attachementsCount-1){
                button.enabled=FALSE;
            }
            else  button.enabled=TRUE;
            
            if(self.attachmentId==0){
                previousButton.enabled=FALSE;
            }
            else  previousButton.enabled=TRUE;
            lockSelected=NO;
            [self updateToolbar];
            [SVProgressHUD dismiss];
            
        });
    });
    
    }
    else
    {
        [CParser ShowMessage:NSLocalizedString(@"AttachmentProblem", @"connect befor open")];
    }
    
    [self refreshToolBar];
    
}


- (void)increaseProgress{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Downloading",@"Downloading ...") maskType:SVProgressHUDMaskTypeBlack];
    
    
}
- (void)previousButtonTapped :(UIButton *)button
{
    //jen PreviousNExt
    CAttachment *fileToOpen;
    //self.correspondenceId=self.correspondenceId-1;
    
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    mainDelegate.attachmentType = @"nextprevioustype";
    
    self.attachmentId=self.attachmentId-1;
    
    correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    fileToOpen=correspondence.attachmentsList[self.attachmentId];
    
    [self updateTitleWithLocation:fileToOpen.location withName:fileToOpen.title];
    NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:fileToOpen.docId fromSharepoint:mainDelegate.isSharepoint];

    ReaderDocument *document=nil;
    if ([ReaderDocument isPDF:tempPdfLocation] == YES) // File must exist
    {
        document=[self OpenPdfReader:tempPdfLocation];
    }
    [delegate tappedInToolbar:self previousButton:button documentReader:document correspondenceId:self.correspondenceId attachementId:self.attachmentId];
 
    if(self.attachmentId==0){
        button.enabled=FALSE;
    }
    else  button.enabled=TRUE;

    if(self.attachmentId==attachementsCount-1){
        nextButton.enabled=FALSE;
    }
    else  nextButton.enabled=TRUE;
    
    lockSelected=NO;
    [self updateToolbar];
}

-(void)refreshToolBar
{
    for(UIView* view in self.subviews){
        if([view isKindOfClass:[UIButton class]]){
            [view removeFromSuperview];
        }
	if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
 
    [self addSubview:homeButton];
    [self addSubview:homeLabel];
    if (UIInterfaceOrientationIsLandscape(CurrentOrientation)){
        [self addSubview:closeButton];
        [self addSubview:HideLabel];
    }
    

    [self addSubview:nextButton];
    [self addSubview:nextLabel];

    [self addSubview:previousButton];
    [self addSubview:PreviousLabel];


}


-(void)updateToolbar{
    NSInteger btnWidth=homeButton.frame.origin.x+homeButton.frame.size.width+seperator;
    NSInteger arabicBtnOrigine=homeButton.frame.origin.x-48-seperator;

    [self refreshToolBar];
    BOOL found=NO;
    int index=0;
    
    while(index<=correspondence.toolbar.count){
        NSString*key=[NSString stringWithFormat:@"%d",index];
        ToolbarItem* item=[correspondence.toolbar objectForKey:key];
        if(!item.Custom){
            if([item.Name isEqualToString:@"MetaData"]&&item.Display){
                metadataButton = [UIButton buttonWithType:UIButtonTypeCustom];
                metadataButton.tag=100;
                if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
                    metadataButton.frame = CGRectMake(arabicBtnOrigine, homeButton.frame.origin.y, metadataimage.size.width,metadataimage.size.height);
                       metadataLabel.font=[UIFont fontWithName:@"Helvetica" size:arabicFont];
                }
                else
                {
                     metadataButton.frame = CGRectMake(btnWidth, homeButton.frame.origin.y, metadataimage.size.width,metadataimage.size.height);
                       metadataLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
                }
               
                [metadataButton setBackgroundImage:metadataimage forState:UIControlStateNormal];
                if (item.Label==nil || [item.Label isEqualToString:@""])
                    metadataLabel.text=NSLocalizedString(@"Menu.Metadata",item.Label);
                else
                    metadataLabel.text=NSLocalizedString(item.Label,item.Label);
                
                metadataLabel.textColor=[UIColor whiteColor];
                metadataLabel.numberOfLines = 3;
                metadataLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [metadataButton addTarget:self action:@selector(metadataButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
                    metadataLabel.frame=CGRectMake(metadataButton.frame.origin.x-lableX-8, metadataButton.frame.origin.y+metadataButton.frame.size.height, 90, 30);
                }
                else
                metadataLabel.frame=CGRectMake(metadataButton.frame.origin.x-lableX-2, metadataButton.frame.origin.y+metadataButton.frame.size.height, 90, 30);

                [self addSubview:metadataButton];
                [self addSubview:metadataLabel];

                btnWidth=btnWidth+metadataButton.frame.size.width+seperator;
                arabicBtnOrigine=arabicBtnOrigine-38-seperator;
                
            }
            if([item.Name isEqualToString:@"Attachments"]&&item.Display){
                attachmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
                if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
                {
                    attachmentButton.frame = CGRectMake(arabicBtnOrigine, homeButton.frame.origin.y, Attachementsimage.size.width,Attachementsimage.size.height);
                        AttachementsLabel.font=[UIFont fontWithName:@"Helvetica" size:arabicFont];
                }
                    else
                    {
                    attachmentButton.frame = CGRectMake(btnWidth+5, homeButton.frame.origin.y, Attachementsimage.size.width,Attachementsimage.size.height);
                             AttachementsLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
                    }
               
                [attachmentButton setBackgroundImage:Attachementsimage forState:UIControlStateNormal];
                if (item.Label==nil || [item.Label isEqualToString:@""])
                    AttachementsLabel.text=NSLocalizedString(@"Menu.Attachments",item.Label);
                else
                    AttachementsLabel.text=NSLocalizedString(item.Label,item.Label);
                AttachementsLabel.numberOfLines = 3;
                AttachementsLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [attachmentButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
                [attachmentButton addTarget:self action:@selector(attachmentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
                     AttachementsLabel.frame=CGRectMake(attachmentButton.frame.origin.x+3, attachmentButton.frame.origin.y+attachmentButton.frame.size.height, 80, 30);
                }
                else
                AttachementsLabel.frame=CGRectMake(attachmentButton.frame.origin.x-lableX-6, attachmentButton.frame.origin.y+attachmentButton.frame.size.height, 80, 30);
                AttachementsLabel.textColor=[UIColor whiteColor];
                [self addSubview:attachmentButton];
                [self addSubview:AttachementsLabel];

                btnWidth=btnWidth+attachmentButton.frame.size.width+seperator;
                arabicBtnOrigine=arabicBtnOrigine-38-seperator;
                
            }

            if([item.Name isEqualToString:@"Transfer"]&&item.Display ){
                
                transferButton = [UIButton buttonWithType:UIButtonTypeCustom];
                if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
                    transferButton.frame = CGRectMake(arabicBtnOrigine, homeButton.frame.origin.y,Transferimage.size.width,Transferimage.size.height);
                    //btnWidth=btnWidth+65;
                                    TransferLabel.font=[UIFont fontWithName:@"Helvetica" size:arabicFont];
                    
                }
                else{
                    transferButton.frame = CGRectMake(btnWidth+10, homeButton.frame.origin.y,Transferimage.size.width,Transferimage.size.height-4);
                  TransferLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
                    
                }
               
                [transferButton setBackgroundImage:Transferimage forState:UIControlStateNormal];
                if (item.Label==nil || [item.Label isEqualToString:@""])
                    TransferLabel.text=NSLocalizedString(@"Menu.Transfer",item.Label) ;
                else
                    TransferLabel.text=NSLocalizedString(item.Label,item.Label);

                TransferLabel.numberOfLines = 3;
                TransferLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [transferButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
                [transferButton addTarget:self action:@selector(transferButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
                     TransferLabel.frame=CGRectMake(transferButton.frame.origin.x+5, transferButton.frame.origin.y+transferButton.frame.size.height-2, 90, 30);
                }
                else
                TransferLabel.frame=CGRectMake(transferButton.frame.origin.x-lableX, transferButton.frame.origin.y+transferButton.frame.size.height, 90, 30);
                TransferLabel.textColor=[UIColor whiteColor];
                [self addSubview:transferButton];
                [self addSubview:TransferLabel];

                btnWidth=btnWidth+transferButton.frame.size.width+seperator;
                arabicBtnOrigine=arabicBtnOrigine-38-seperator;
                
            }
            if([item.Name isEqualToString:@"Annotations"]&&item.Display ){
                
                annotationButton = [UIButton buttonWithType:UIButtonTypeCustom];
                if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
                    annotationButton.frame = CGRectMake(arabicBtnOrigine, homeButton.frame.origin.y, Annotationsimage.size.width,Annotationsimage.size.height);                           AnnotationsLabel.font=[UIFont fontWithName:@"Helvetica" size:arabicFont];
                    
                }
                else{
                    annotationButton.frame = CGRectMake(btnWidth+15, homeButton.frame.origin.y, Annotationsimage.size.width,Annotationsimage.size.height);
                      AnnotationsLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
                    btnWidth=btnWidth+annotationButton.frame.size.width+seperator;
                    
                }
                
                [annotationButton setBackgroundImage: Annotationsimage forState:UIControlStateNormal];
                if (item.Label==nil || [item.Label isEqualToString:@""])
                    AnnotationsLabel.text=NSLocalizedString(@"Menu.Annotations",item.Label);
                else
                    AnnotationsLabel.text=NSLocalizedString(item.Label,item.Label);
              
                AnnotationsLabel.numberOfLines = 3;
                AnnotationsLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [annotationButton addTarget:self action:@selector(annotationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
                    AnnotationsLabel.frame=CGRectMake(annotationButton.frame.origin.x, annotationButton.frame.origin.y+annotationButton.frame.size.height+3, 90, 30);
                }
                else
                AnnotationsLabel.frame=CGRectMake(annotationButton.frame.origin.x-12, annotationButton.frame.origin.y+annotationButton.frame.size.height, 90, 30);
                AnnotationsLabel.textColor=[UIColor whiteColor];
                [self addSubview:annotationButton];
                [self addSubview:AnnotationsLabel];

                arabicBtnOrigine=arabicBtnOrigine-35-seperator;
                
            }
            if([item.Name isEqualToString:@"Signature"]&&item.Display ){
                
                SignActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
                if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
                    SignActionButton.frame = CGRectMake(arabicBtnOrigine, homeButton.frame.origin.y, Signatureimage.size.width,Signatureimage.size.height);
                    btnWidth=btnWidth+85;
                     SignatureLabel.font=[UIFont fontWithName:@"Helvetica" size:arabicFont];
                }
                else{
                    SignActionButton.frame = CGRectMake(btnWidth+15, homeButton.frame.origin.y,Signatureimage.size.width,Signatureimage.size.height-3);
                    btnWidth=btnWidth+SignActionButton.frame.size.width+seperator;
                     SignatureLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
                    
                }
                
                [SignActionButton setBackgroundImage: Signatureimage forState:UIControlStateNormal];
                if (item.Label==nil || [item.Label isEqualToString:@""])
                    SignatureLabel.text=NSLocalizedString(@"Menu.sign",item.Label);
                else
                    SignatureLabel.text=NSLocalizedString(item.Label,item.Label);
                SignatureLabel.numberOfLines = 3;
                SignatureLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [SignActionButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
                [SignActionButton addTarget:self action:@selector(SignAction:) forControlEvents:UIControlEventTouchUpInside];
                if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
                 SignatureLabel.frame=CGRectMake(SignActionButton.frame.origin.x+9, SignActionButton.frame.origin.y+SignActionButton.frame.size.height-2, 90, 30);
                }
                else
                SignatureLabel.frame=CGRectMake(SignActionButton.frame.origin.x-2, SignActionButton.frame.origin.y+SignActionButton.frame.size.height, 90, 30);
                SignatureLabel.textColor=[UIColor whiteColor];
                [self addSubview:SignActionButton];
                [self addSubview:SignatureLabel];

                arabicBtnOrigine=arabicBtnOrigine-38-seperator;
                if(found){
                    Save = [UIButton buttonWithType:UIButtonTypeCustom];
                    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
                    {
                        Save.frame = CGRectMake(arabicBtnOrigine, homeButton.frame.origin.y, Saveimage.size.width,Saveimage.size.height);
                        SaveLabel.font=[UIFont fontWithName:@"Helvetica" size:arabicFont];
                    }
                    else
                    {
                        SaveLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
                        Save.frame = CGRectMake(btnWidth+3, homeButton.frame.origin.y+3, Saveimage.size.width,Saveimage.size.height);
                    }
                    
                    [Save setBackgroundImage: Saveimage forState:UIControlStateNormal];
                    SaveLabel.text=NSLocalizedString(@"Menu.save",@"Save");
                    
                    
                    SaveLabel.numberOfLines = 3;
                    SaveLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    [Save setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
                    [Save addTarget:self action:@selector(SaveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
                        SaveLabel.frame=CGRectMake(Save.frame.origin.x+10, Save.frame.origin.y+Save.frame.size.height+2, 90, 30);
                    }
                    else
                        SaveLabel.frame=CGRectMake(Save.frame.origin.x+3, Save.frame.origin.y+Save.frame.size.height, 90, 30);
                    SaveLabel.textColor=[UIColor whiteColor];
                    [self addSubview:Save];
                    [self addSubview:SaveLabel];
                    btnWidth=btnWidth+Save.frame.size.width+seperator;
                    arabicBtnOrigine=arabicBtnOrigine-38-seperator;
                }
                
            }

            if(([item.Name isEqualToString:@"Signature"]||[item.Name isEqualToString:@"Annotations"])&&item.Display){
                if (!found) {
                    found=YES;
                }
                else
                    found=NO;
               
                
            }
            if([item.Name isEqualToString:@"More"]&&item.Display){
                if(correspondence.actions.count>0 ){
                    MoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    
                    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
                        MoreButton.frame = CGRectMake(arabicBtnOrigine, homeButton.frame.origin.y, moreImage.size.width, moreImage.size.height);
                            moreLable.frame=CGRectMake(MoreButton.frame.origin.x+5, MoreButton.frame.origin.y+MoreButton.frame.size.height+3, 90, 30);
                        moreLable.font=[UIFont fontWithName:@"Helvetica" size:arabicFont];
                        
                    }
                    else{
                        MoreButton.frame = CGRectMake(btnWidth, homeButton.frame.origin.y, moreImage.size.width, moreImage.size.height);
                           moreLable.font=[UIFont fontWithName:@"Helvetica" size:14];
                        [MoreButton setBackgroundImage: [UIImage imageNamed:@"More.png"] forState:UIControlStateNormal];
                        moreLable.frame=CGRectMake(MoreButton.frame.origin.x-lableX, MoreButton.frame.origin.y+MoreButton.frame.size.height+3, 90, 30);
                        
                    }
                    [MoreButton setBackgroundImage: moreImage forState:UIControlStateNormal];
                    if (item.Label==nil || [item.Label isEqualToString:@""])
                        moreLable.text=NSLocalizedString(@"Menu.More",item.Label);

                    else
                         moreLable.text=NSLocalizedString(item.Label,item.Label);

                    

                    moreLable.numberOfLines = 3;
                    moreLable.lineBreakMode = NSLineBreakByWordWrapping;
                    [MoreButton addTarget:self action:@selector(MoreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    moreLable.textColor=[UIColor whiteColor];
                    [self addSubview:moreLable];
                    [self addSubview:MoreButton];
                    btnWidth=btnWidth+MoreButton.frame.size.width+seperator;                   arabicBtnOrigine=arabicBtnOrigine-38-seperator;
                    
                }}
        }
        else{
            
            if(item.Display){
                UIImage * image =  [UIImage imageWithData:[CParser LoadCachedIcons:item.Name]];
                UILabel *customlabel=[[UILabel alloc]init];
                CustomButton = [UIButton buttonWithType:UIButtonTypeCustom];
                if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
                    CustomButton.frame = CGRectMake(arabicBtnOrigine, homeButton.frame.origin.y, image.size.width, image.size.height);
                     customlabel.font=[UIFont fontWithName:@"Helvetica" size:arabicFont];
                    customlabel.frame=CGRectMake(CustomButton.frame.origin.x, CustomButton.frame.origin.y+CustomButton.frame.size.height, image.size.width, 60);
                }
                else
                {
                    CustomButton.frame = CGRectMake(btnWidth, homeButton.frame.origin.y, image.size.width, image.size.height);
                          customlabel.font=[UIFont fontWithName:@"Helvetica" size:14];
                     customlabel.frame=CGRectMake(CustomButton.frame.origin.x-10, CustomButton.frame.origin.y+CustomButton.frame.size.height-10, 60, 60);
                }
               
                   
                [CustomButton setBackgroundImage:image forState:UIControlStateNormal];
                customlabel.text=NSLocalizedString(item.Label,item.Label);
          
                customlabel.numberOfLines = 3;
                customlabel.lineBreakMode = NSLineBreakByWordWrapping;
                [CustomButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
                CustomButton.tag=index;
                [CustomButton addTarget:self action:@selector(CustomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                customlabel.textColor=[UIColor whiteColor];
                [self addSubview:CustomButton];
                [self addSubview:customlabel];

                btnWidth=btnWidth+CustomButton.frame.size.width+seperator;                   arabicBtnOrigine=arabicBtnOrigine-38-seperator;
                
            }
            
        }
        index++;
//        if ([attachment.title rangeOfString:@".pdf"].location != NSNotFound) {
//            found = YES;
//        }
    }
 
}

-(void) updateTitleWithLocation:(NSString*)location withName:(NSString*)name{
    [lblTitle setText:[NSString stringWithFormat:@"LOCATION: %@   TITLE: %@",location,name]];
}
@end
