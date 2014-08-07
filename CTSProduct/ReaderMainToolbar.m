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

@implementation ReaderMainToolbar
{
    NSInteger correspondencesCount;
    NSInteger attachementsCount;
    AppDelegate *mainDelegate;
    NSString* pageName;
    CCorrespondence *correspondence;
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

        
        lblTitle=[[UILabel alloc]initWithFrame:CGRectMake(20, 15, self.frame.size.width, 15)];
        lblTitle.font = [UIFont fontWithName:@"Helvetica" size:12];
        lblTitle.textColor=[UIColor colorWithRed:204/255.0f green:233/255.0f blue:247/255.0f alpha:1.0];
        [self addSubview:lblTitle];

        
        homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [homeButton setBackgroundImage:[UIImage imageNamed:@"HomeIcon.png"] forState:UIControlStateNormal];
        [homeButton setTitleEdgeInsets:UIEdgeInsetsMake(55, 10, 0,10)];
        [homeButton setTitle:NSLocalizedString(@"Menu.Home",@"Home") forState:UIControlStateNormal];
        homeButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
        homeButton.titleLabel.numberOfLines = 3;
        homeButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [homeButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        [homeButton addTarget:self action:@selector(homeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:homeButton];
        
       

        nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextButton setBackgroundImage: [UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
        [nextButton setTitleEdgeInsets:UIEdgeInsetsMake(55, 0, 0,0)];
        [nextButton setTitle:NSLocalizedString(@"Menu.Next",@"Next") forState:UIControlStateNormal];
        nextButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:13];
        nextButton.titleLabel.numberOfLines = 3;
        nextButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [nextButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        [nextButton setTitleColor:[UIColor grayColor]forState:UIControlStateDisabled];
        [nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nextButton];
        
        if(attachmentId==attachementsCount-1){
            nextButton.enabled=FALSE;
        }
        else  nextButton.enabled=TRUE;
      
        previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [previousButton setBackgroundImage: [UIImage imageNamed:@"previous.png"] forState:UIControlStateNormal];
        [previousButton setTitleEdgeInsets:UIEdgeInsetsMake(55, 0, 0,0)];
        [previousButton setTitle:NSLocalizedString(@"Menu.Previous",@"Previous") forState:UIControlStateNormal];
        previousButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:13];
        previousButton.titleLabel.numberOfLines = 3;
        previousButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [previousButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        [previousButton setTitleColor:[UIColor grayColor]forState:UIControlStateDisabled];
        [previousButton addTarget:self action:@selector(previousButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:previousButton];
       
        if(attachmentId==0){
            previousButton.enabled=FALSE;
        }
        else  previousButton.enabled=TRUE;
        

        
        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"Hide.png"] forState:UIControlStateNormal];
        [closeButton setTitle:NSLocalizedString(@"Menu.Hide", @"Hide Menu") forState:UIControlStateNormal];
        [closeButton setTitleEdgeInsets:UIEdgeInsetsMake(55, 0, 0,0)];
        closeButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:13];
        closeButton.titleLabel.numberOfLines = 3;
        closeButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [closeButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor grayColor]forState:UIControlStateDisabled];
        [closeButton addTarget:self action:@selector(hideToolbar) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self adjustButtons:orientation];
    [self updateToolbar];

	return self;
}

-(void)adjustButtons:(UIInterfaceOrientation)orientation{
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            int startleft=10;
            previousButton.frame=CGRectMake(startleft, 30, 65, 90);
            nextButton.frame = CGRectMake(startleft+ButtonWidth,30, 65, 90);
            closeButton.frame=CGRectMake(startleft+2*ButtonWidth+5, 30, 80, 90);
            homeButton.frame = CGRectMake(768-80, 30, 80, 90);

            
        }
        else{
            int endright=768;
            nextButton.frame = CGRectMake(endright-ButtonWidth,30, 65, 90);
            previousButton.frame=CGRectMake(endright-2*ButtonWidth, 30, 65, 90);
            closeButton.frame=CGRectMake(endright-3*ButtonWidth-5, 30, 80, 90);
            homeButton.frame = CGRectMake(10, 30, 80, 90);

        }
    } else{
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            int startleft=10;
            previousButton.frame=CGRectMake(startleft, 30, 65, 90);
            nextButton.frame = CGRectMake(startleft+ButtonWidth,30, 65, 90);
            closeButton.frame=CGRectMake(startleft+2*ButtonWidth+5, 30, 80, 90);
            homeButton.frame = CGRectMake(768+167, 30, 80, 90);

            
        }
        else{
            int endright=768+182;
            nextButton.frame = CGRectMake(endright,30, 65, 90);
            previousButton.frame=CGRectMake(endright-ButtonWidth, 30, 65, 90);
            closeButton.frame=CGRectMake(endright-2*ButtonWidth-5, 30, 80, 90);
            homeButton.frame = CGRectMake(10, 30, 80, 90);

            
        }
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

- (void)showToolbar
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
//    if(correspondence.Locked==NO){
//         if([self performLock:@"LockCorrespondence"])
//         [lockButton setTitle:NSLocalizedString(@"Menu.Unlock",@"unlock") forState:UIControlStateNormal];
//        if(self.menuId !=100)
//        ((CCorrespondence*) ((CMenu*)self.user.menu[self.menuId]).correspondenceList[self.correspondenceId]).Locked=YES;
//    }
//    else{  if([self performLock:@"UnlockCorrespondence"])
//         [lockButton setTitle:NSLocalizedString(@"Menu.Lock",@"lock") forState:UIControlStateNormal];
//        if(self.menuId !=100)
//         ((CCorrespondence*) ((CMenu*)self.user.menu[self.menuId]).correspondenceList[self.correspondenceId]).Locked=NO;
//       
//    }
}

-(BOOL)performLock:(NSString*)action{
    
    BOOL isPerformed=NO;

    NSString* url=[NSString stringWithFormat:@"action=%@&token=%@&correspondenceId=%@",action,mainDelegate.user.token,correspondence.Id];
    NSString* lockUrl = [NSString stringWithFormat:@"http://%@?%@",mainDelegate.serverUrl,url];
    NSURL *xmlUrl = [NSURL URLWithString:lockUrl];
    NSData *lockXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
    
    NSString *validationResult=[CParser ValidateWithData:lockXmlData];
    if(![validationResult isEqualToString:@"OK"]){
        if([validationResult isEqualToString:@"Cannot access to the server"])
        {isPerformed=YES;
            
            CFPendingAction*pa = [[CFPendingAction alloc] initWithActionUrl:url];
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
        //jen PreviousNext
       // NSMutableArray* thumbnailrarray = [[NSMutableArray alloc] init];
        
        
//        if (correspondence.attachmentsList.count>0)
//        {
//            for(CAttachment* doc in correspondence.attachmentsList)
//            {
//                if([doc.FolderName isEqualToString:mainDelegate.FolderName]){
//                    [thumbnailrarray addObject:doc];
//                }
//                
//                
//            }
//        }

   
    fileToOpen=correspondence.attachmentsList[self.attachmentId];
    [self updateTitleWithLocation:fileToOpen.location withName:fileToOpen.title];

    //jis next
    [self performSelectorOnMainThread:@selector(increaseProgress) withObject:@"" waitUntilDone:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

    if([fileToOpen.url isEqualToString:@""]){
       
        [mainDelegate.folderNames addObject:fileToOpen.FolderName];
        
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
                attachmentUrl= [NSString stringWithFormat:@"http://%@?action=GetFolderAttachments&token=%@&docId=%d&folderName=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,docId,mainDelegate.FolderName,showthumb];
            else
                attachmentUrl= [NSString stringWithFormat:@"http://%@/GetFolderAttachments?token=%@&docId=%d&folderName=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,docId,mainDelegate.FolderName,showthumb];
       
            [CParser GetFolderAttachment:attachmentUrl Id:self.correspondenceId];
        
        }else{
            attachmentXmlData=[CParser LoadXML:@"Attachment" nb:correspondence.Id name:mainDelegate.FolderName];

        }
        
        
        }
        
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:fileToOpen.docId fromSharepoint:mainDelegate.isSharepoint];
                //  NSString *tempPdfLocation=[CParser loadPdfFile:fileToOpen.url inDirectory:correspondence.Id];
                ReaderDocument *newdocument=nil;
                if ([ReaderDocument isPDF:tempPdfLocation] == YES) // File must exist
                {
                    newdocument=[self OpenPdfReader:tempPdfLocation];
                }
                
                //jen PreviousNext
                //[delegate tappedInToolbar:self nextButton:button documentReader:newdocument correspondenceId:self.correspondenceId];
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
    
    if(self.menuId!=100){
        correspondence= ((CMenu*)self.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
        //jen
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
        
        fileToOpen=thumbnailrarray[self.attachmentId];
    }else{
        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
        //jen
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
        
        //fileToOpen=thumbnailrarray[self.attachmentId];
    }
    
    fileToOpen=correspondence.attachmentsList[self.attachmentId];
    [self updateTitleWithLocation:fileToOpen.location withName:fileToOpen.title];
    //jen
    // NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:correspondence.Id fromSharepoint:mainDelegate.isSharepoint];
    NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:fileToOpen.docId fromSharepoint:mainDelegate.isSharepoint];
    // NSString *tempPdfLocation=[CParser loadPdfFile:fileToOpen.url inDirectory:correspondence.Id];
    
    ReaderDocument *document=nil;
    if ([ReaderDocument isPDF:tempPdfLocation] == YES) // File must exist
    {
        document=[self OpenPdfReader:tempPdfLocation];
    }
    //jen PreviousNext
	//[delegate tappedInToolbar:self previousButton:button documentReader:document correspondenceId:self.correspondenceId];
    [delegate tappedInToolbar:self previousButton:button documentReader:document correspondenceId:self.correspondenceId attachementId:self.attachmentId];
    //    if(self.correspondenceId==0){
    //        button.enabled=FALSE;
    //
    //    }
    if(self.attachmentId==0){
        button.enabled=FALSE;
    }
    else  button.enabled=TRUE;
    
    //    if(self.correspondenceId==correspondencesCount-1){
    //        nextButton.enabled=FALSE;
    //    }
    if(self.attachmentId==attachementsCount-1){
        nextButton.enabled=FALSE;
    }
    else  nextButton.enabled=TRUE;
    
    lockSelected=NO;
    [self updateToolbar];
}



-(void)updateToolbar{
       NSInteger btnWidth=75;
    [metadataButton removeFromSuperview];
    [attachmentButton removeFromSuperview];
    [transferButton removeFromSuperview];
    [commentsButton removeFromSuperview];
    [annotationButton removeFromSuperview];
    [MoreButton removeFromSuperview];
    [Save removeFromSuperview];
    [ActionsButton removeFromSuperview];
    [SignActionButton removeFromSuperview];
    int index=0;
    while(index<=correspondence.toolbar.count){
        NSString*key=[NSString stringWithFormat:@"%d",index];
        ToolbarItem* item=[correspondence.toolbar objectForKey:key];
        if(!item.Custom){
         if([item.Name isEqualToString:@"MetaData"]&&item.Display){
        metadataButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            metadataButton.frame = CGRectMake(homeButton.frame.origin.x-btnWidth, 30, 80, 90);
        }
        else
            metadataButton.frame = CGRectMake(homeButton.frame.origin.x+btnWidth, 30, 80, 90);
        [metadataButton setBackgroundImage:[UIImage imageNamed:@"metadata.png"] forState:UIControlStateNormal];
        if (item.Label==nil || [item.Label isEqualToString:@""])
            [metadataButton setTitle:NSLocalizedString(@"Menu.Metadata",item.Label) forState:UIControlStateNormal];
        else
            [metadataButton setTitle:NSLocalizedString(item.Label,item.Label) forState:UIControlStateNormal];

        [metadataButton setTitleEdgeInsets:UIEdgeInsetsMake(55, 2, 0,2)];
        
        metadataButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
        metadataButton.titleLabel.numberOfLines = 3;
        metadataButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [metadataButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        [metadataButton addTarget:self action:@selector(metadataButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:metadataButton];
        btnWidth=btnWidth+70;
        
    }
      if([item.Name isEqualToString:@"Attachments"]&&item.Display){
        attachmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
            attachmentButton.frame = CGRectMake(homeButton.frame.origin.x-btnWidth, 30, 80, 90);
        else
        attachmentButton.frame = CGRectMake(homeButton.frame.origin.x+btnWidth, 30, 80, 90);
        
        [attachmentButton setBackgroundImage:[UIImage imageNamed:@"attachments.png"] forState:UIControlStateNormal];
        [attachmentButton setTitleEdgeInsets:UIEdgeInsetsMake(55, 0, 0,0)];
        if (item.Label==nil || [item.Label isEqualToString:@""])
            [attachmentButton setTitle:NSLocalizedString(@"Menu.Attachments",item.Label) forState:UIControlStateNormal];
        else
            [attachmentButton setTitle:NSLocalizedString(item.Label,item.Label) forState:UIControlStateNormal];
        attachmentButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
        attachmentButton.titleLabel.numberOfLines = 3;
        attachmentButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [attachmentButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        [attachmentButton addTarget:self action:@selector(attachmentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:attachmentButton];
        btnWidth=btnWidth+70;

    }
//        if([item.Name isEqualToString:@"Comments"]&&item.Display){
//        commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
//            commentsButton.frame = CGRectMake(homeButton.frame.origin.x-btnWidth, 30, 80, 90);
//            btnWidth=btnWidth+65;
//
//        }
//        else{
//        commentsButton.frame = CGRectMake(homeButton.frame.origin.x+btnWidth, 30, 80, 90);
//            btnWidth=btnWidth+75;
//
//        }
//        
//        [commentsButton setTitleEdgeInsets:UIEdgeInsetsMake(55, 2, 0,2)];
//        [commentsButton setBackgroundImage:[UIImage imageNamed:@"comments.png"] forState:UIControlStateNormal];
//        [commentsButton setTitle:NSLocalizedString(@"Menu.Comments",item.Label) forState:UIControlStateNormal];
//        commentsButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
//        [commentsButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
//        [commentsButton addTarget:self action:@selector(commentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:commentsButton];
//
//        
//    }
        if([item.Name isEqualToString:@"Transfer"]&&item.Display){

        transferButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            transferButton.frame = CGRectMake(homeButton.frame.origin.x-btnWidth, 30, 80, 90);
            btnWidth=btnWidth+65;

        }
        else{
            transferButton.frame = CGRectMake(homeButton.frame.origin.x+btnWidth, 30, 80, 90);
            btnWidth=btnWidth+70;

        }
        [transferButton setBackgroundImage:[UIImage imageNamed:@"transfer.png"] forState:UIControlStateNormal];
        [transferButton setTitleEdgeInsets:UIEdgeInsetsMake(55, 2, 0,2)];
        if (item.Label==nil || [item.Label isEqualToString:@""])
            [transferButton setTitle:NSLocalizedString(@"Menu.Transfer",item.Label) forState:UIControlStateNormal];
        else
            [transferButton setTitle:NSLocalizedString(item.Label,item.Label) forState:UIControlStateNormal];
        transferButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
        transferButton.titleLabel.numberOfLines = 3;
        transferButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [transferButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        [transferButton addTarget:self action:@selector(transferButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:transferButton];

        }
        if([item.Name isEqualToString:@"Annotations"]&&item.Display){

        annotationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            annotationButton.frame = CGRectMake(homeButton.frame.origin.x-btnWidth, 30, 80, 90);
            btnWidth=btnWidth+65;

        }
        else{
            annotationButton.frame = CGRectMake(homeButton.frame.origin.x+btnWidth, 30, 80, 90);
            btnWidth=btnWidth+70;

        }
        [annotationButton setBackgroundImage: [UIImage imageNamed:@"Annotations.png"] forState:UIControlStateNormal];
        [annotationButton setTitleEdgeInsets:UIEdgeInsetsMake(55, 0, 0,0)];
        if (item.Label==nil || [item.Label isEqualToString:@""])
            [annotationButton setTitle:NSLocalizedString(@"Menu.Annotations",item.Label) forState:UIControlStateNormal];
        else
            [annotationButton setTitle:NSLocalizedString(item.Label,item.Label) forState:UIControlStateNormal];
        annotationButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:13];
        annotationButton.titleLabel.numberOfLines = 3;
        annotationButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [annotationButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        [annotationButton setTitleColor:[UIColor grayColor]forState:UIControlStateDisabled];
        [annotationButton addTarget:self action:@selector(annotationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:annotationButton];

    }
        if([item.Name isEqualToString:@"Signature"]&&item.Display){

        SignActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            SignActionButton.frame = CGRectMake(homeButton.frame.origin.x-btnWidth, 30, 60, 70);
            btnWidth=btnWidth+75;

        }
        else{
            SignActionButton.frame = CGRectMake(homeButton.frame.origin.x+15+btnWidth, 30, 60, 70);
            btnWidth=btnWidth+70;

        }
        [SignActionButton setBackgroundImage: [UIImage imageNamed:@"Signature.png"] forState:UIControlStateNormal];
        [SignActionButton setTitleEdgeInsets:UIEdgeInsetsMake(75, 0, 0,0)];
        if (item.Label==nil || [item.Label isEqualToString:@""])
            [SignActionButton setTitle:NSLocalizedString(@"Menu.sign",item.Label) forState:UIControlStateNormal];
        else
            [SignActionButton setTitle:NSLocalizedString(item.Label,item.Label) forState:UIControlStateNormal];
        SignActionButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:13];
        SignActionButton.titleLabel.numberOfLines = 3;
        SignActionButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [SignActionButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        [SignActionButton setTitleColor:[UIColor grayColor]forState:UIControlStateDisabled];
        [SignActionButton addTarget:self action:@selector(SignAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:SignActionButton];

    }
//        if([item.Name isEqualToString:@"Actions"]&&item.Display){
//
//        ActionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
//            ActionsButton.frame = CGRectMake(homeButton.frame.origin.x-btnWidth, 30, 60, 70);
//            btnWidth=btnWidth+75;
//            
//        }
//        else{
//            ActionsButton.frame = CGRectMake(homeButton.frame.origin.x+btnWidth, 30, 60, 70);
//            btnWidth=btnWidth+75;
//            
//        }
//        [ActionsButton setBackgroundImage: [UIImage imageNamed:@"Actions.png"] forState:UIControlStateNormal];
//        [ActionsButton setTitleEdgeInsets:UIEdgeInsetsMake(75, 0, 0,0)];
//        if (item.Label==nil || [item.Label isEqualToString:@""])
//            [ActionsButton setTitle:NSLocalizedString(@"Menu.Actions",item.Label) forState:UIControlStateNormal];
//        else
//            [ActionsButton setTitle:NSLocalizedString(item.Label,item.Label) forState:UIControlStateNormal];
//        ActionsButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:13];
//        ActionsButton.titleLabel.numberOfLines = 3;
//        ActionsButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        [ActionsButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
//        [ActionsButton setTitleColor:[UIColor grayColor]forState:UIControlStateDisabled];
//        [ActionsButton addTarget:self action:@selector(ActionsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:ActionsButton];
//        
//    }
        if([item.Name isEqualToString:@"Signature"]&&item.Display&& [mainDelegate.SignMode isEqualToString:@"BuiltInSign"]){

        Save = [UIButton buttonWithType:UIButtonTypeCustom];
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
            Save.frame = CGRectMake(homeButton.frame.origin.x-btnWidth, 30, 70, 90);
        else
            Save.frame = CGRectMake(homeButton.frame.origin.x+btnWidth, 30, 70, 90);
        [Save setBackgroundImage: [UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
        [Save setTitleEdgeInsets:UIEdgeInsetsMake(55, 0, 0,0)];
         [Save setTitle:NSLocalizedString(@"Menu.save",@"Save") forState:UIControlStateNormal];
    
        Save.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:13];
        Save.titleLabel.numberOfLines = 3;
        Save.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [Save setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        [Save setTitleColor:[UIColor grayColor]forState:UIControlStateDisabled];
        [Save addTarget:self action:@selector(SaveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:Save];
        btnWidth=btnWidth+65;
        
    }
        if([item.Name isEqualToString:@"More"]&&item.Display){
    if(correspondence.actions.count>0 ){
        MoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            MoreButton.frame = CGRectMake(homeButton.frame.origin.x-btnWidth, 30, 80, 100);
            [MoreButton setBackgroundImage: [UIImage imageNamed:@"More-flipped.png"] forState:UIControlStateNormal];

        }
        else{
            MoreButton.frame = CGRectMake(homeButton.frame.origin.x+btnWidth, 30, 80, 100);
            [MoreButton setBackgroundImage: [UIImage imageNamed:@"More.png"] forState:UIControlStateNormal];

        }
        if (item.Label==nil || [item.Label isEqualToString:@""])
            [MoreButton setTitle:NSLocalizedString(@"Menu.More",item.Label) forState:UIControlStateNormal];
        else
            [MoreButton setTitle:NSLocalizedString(item.Label,item.Label) forState:UIControlStateNormal];

        [MoreButton setTitleEdgeInsets:UIEdgeInsetsMake(45, 0, 0,0)];
        MoreButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:13];
        MoreButton.titleLabel.numberOfLines = 3;
        MoreButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [MoreButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        [MoreButton setTitleColor:[UIColor grayColor]forState:UIControlStateDisabled];
        [MoreButton addTarget:self action:@selector(MoreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:MoreButton];
        btnWidth=btnWidth+65;

    }}
        }
        else{
            if(item.Display){
                UIButton *CustomButton = [UIButton buttonWithType:UIButtonTypeCustom];
                if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
                    CustomButton.frame = CGRectMake(homeButton.frame.origin.x-btnWidth, 30, 80, 90);
                }
                else
                    CustomButton.frame = CGRectMake(homeButton.frame.origin.x+btnWidth, 30, 80, 90);
                UIImage * image =  [UIImage imageWithData:[CParser LoadCachedIcons:item.Name]];
                [CustomButton setBackgroundImage:image forState:UIControlStateNormal];
                [CustomButton setTitle:NSLocalizedString(item.Label,item.Label) forState:UIControlStateNormal];
                [CustomButton setTitleEdgeInsets:UIEdgeInsetsMake(55, 2, 0,2)];
                CustomButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
                CustomButton.titleLabel.numberOfLines = 3;
                CustomButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [CustomButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
                CustomButton.tag=index;
                [CustomButton addTarget:self action:@selector(CustomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:CustomButton];
                
                btnWidth=btnWidth+70;
                
            }
            
        }
        index++;
}
}

-(void) updateTitleWithLocation:(NSString*)location withName:(NSString*)name{
    [lblTitle setText:[NSString stringWithFormat:@"LOCATION: %@   TITLE: %@",location,name]];
}
@end
