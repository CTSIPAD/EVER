//
//	ReaderMainPagebar.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//
#import "GDataXMLNode.h"
#import "ReaderMainPagebar.h"
#import "ReaderThumbCache.h"
#import "ReaderDocument.h"
#import"CUser.h"
#import"CCorrespondence.h"
#import"CAttachment.h"
#import"CFolder.h"
#import"CMenu.h"
#import "AppDelegate.h"
#import "NSData+Base64.h"
#import "CParser.h"
#import "CSearch.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)
@implementation ReaderMainPagebar
{
	ReaderDocument *document;
    
	ReaderTrackControl *trackControl;
    
	NSMutableDictionary *miniThumbViews;
    
	ReaderPagebarThumb *pageThumbView;
    
	UILabel *pageNumberLabel;
    
	UIView *pageNumberView;
    
	NSTimer *enableTimer;
	NSTimer *trackTimer;
    AppDelegate* mainDelegate;
    UIView*  thumbView;
    UIScrollView* scrollViewmainPagebar;
}

#pragma mark Constants

#define THUMB_SMALL_GAP 0
//#define THUMB_SMALL_WIDTH 22
//#define THUMB_SMALL_HEIGHT 28
//
//#define THUMB_LARGE_WIDTH 32
//#define THUMB_LARGE_HEIGHT 42
#define THUMB_SMALL_WIDTH 114
#define THUMB_SMALL_HEIGHT 134

#define THUMB_LARGE_WIDTH 114
#define THUMB_LARGE_HEIGHT 134

#define PAGE_NUMBER_WIDTH 96.0f
#define PAGE_NUMBER_HEIGHT 30.0f
#define PAGE_NUMBER_SPACE 20.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark ReaderMainPagebar class methods

+ (Class)layerClass
{
	return [CAGradientLayer class];
}

#pragma mark ReaderMainPagebar instance methods

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame Document:nil CorrespondenceId:0 MenuId:0 AttachmentId:0];
}

- (void)updatePageNumberText:(NSInteger)page
{
	
    CCorrespondence *correspondence;
    if(self.menuId!=100){
        correspondence= ((CMenu*)self.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
    }else{
        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    }
    thumbnailrarray = [[NSMutableArray alloc] init];
    
    if (correspondence.attachmentsList.count>0)
    {
        for(CAttachment* doc in correspondence.attachmentsList)
        {
            if([doc.FolderName isEqualToString:mainDelegate.FolderName]){
                [thumbnailrarray addObject:doc];
            }
            
            
        }
    }
    
    NSInteger pages=thumbnailrarray.count;
    
    NSString *format = NSLocalizedString(@"%d of %d", @"format"); // Format
    if(page>thumbnailrarray.count)
        page=1;
    NSString *number = [NSString stringWithFormat:format, page, pages]; // Text
    
    pageNumberLabel.text = number; // Update the page number label text
    
    pageNumberLabel.tag = page; // Update the last page number tag
    
	
}

- (id)initWithFrame:(CGRect)frame Document:(ReaderDocument *)object CorrespondenceId:(NSInteger)correspondenceId MenuId:(NSInteger)menuId AttachmentId:(NSInteger)attachmentId
{
	//assert(object != nil); // Must have a valid ReaderDocument
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if ((self = [super initWithFrame:frame]))
	{
        self.correspondenceId=correspondenceId;
        self.menuId=menuId;
        self.attachmentId=attachmentId;
		self.autoresizesSubviews = YES;
		self.userInteractionEnabled = YES;
		self.contentMode = UIViewContentModeRedraw;
		//self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        self.backgroundColor=mainDelegate.cellColor;
        
        

		CGRect shadowRect = self.bounds; shadowRect.size.height = 10.0f; shadowRect.origin.y -= shadowRect.size.height;
        
		ReaderPagebarShadow *shadowView = [[ReaderPagebarShadow alloc] initWithFrame:shadowRect];
        
		[self addSubview:shadowView]; // Add the shadow to the view
        
        
        
        
		CGFloat numberY = (0.0f - (PAGE_NUMBER_HEIGHT + PAGE_NUMBER_SPACE));
		CGFloat numberX = ((self.bounds.size.width - PAGE_NUMBER_WIDTH) / 2.0f);
		CGRect numberRect = CGRectMake(numberX, numberY, PAGE_NUMBER_WIDTH, PAGE_NUMBER_HEIGHT);
        
		pageNumberView = [[UIView alloc] initWithFrame:numberRect]; // Page numbers view
		pageNumberView.autoresizesSubviews = NO;
		pageNumberView.userInteractionEnabled = NO;
		pageNumberView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		pageNumberView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        
		pageNumberView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		pageNumberView.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.6f].CGColor;
		pageNumberView.layer.shadowPath = [UIBezierPath bezierPathWithRect:pageNumberView.bounds].CGPath;
		pageNumberView.layer.shadowRadius = 2.0f; pageNumberView.layer.shadowOpacity = 1.0f;
        
		CGRect textRect = CGRectInset(pageNumberView.bounds, 4.0f, 2.0f); // Inset the text a bit
        
		pageNumberLabel = [[UILabel alloc] initWithFrame:textRect]; // Page numbers label
        
		pageNumberLabel.autoresizesSubviews = NO;
		pageNumberLabel.autoresizingMask = UIViewAutoresizingNone;
		pageNumberLabel.textAlignment = NSTextAlignmentCenter;
		pageNumberLabel.backgroundColor = [UIColor clearColor];
		pageNumberLabel.textColor = [UIColor whiteColor];
		pageNumberLabel.font = [UIFont systemFontOfSize:16.0f];
		pageNumberLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		pageNumberLabel.shadowColor = [UIColor blackColor];
		pageNumberLabel.adjustsFontSizeToFitWidth = YES;
        
		[pageNumberView addSubview:pageNumberLabel]; // Add label view
        
		[self addSubview:pageNumberView]; // Add page numbers display view
        
        scrollViewmainPagebar = [[UIScrollView alloc] init];
        scrollViewmainPagebar.frame=CGRectMake(0, 55, 130, self.frame.size.height);
            
        
       
        scrollViewmainPagebar.backgroundColor = [UIColor clearColor];
        scrollViewmainPagebar.showsVerticalScrollIndicator = YES;
        scrollViewmainPagebar.showsHorizontalScrollIndicator = YES;
        
        

        
        mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.user =  mainDelegate.user ;
        
        [self updatePageNumberText:attachmentId+1];
		miniThumbViews = [NSMutableDictionary new]; // Small thumbs
	}
    
	return self;
}

- (void)removeFromSuperview
{
	[trackTimer invalidate]; [enableTimer invalidate];
    
	[super removeFromSuperview];
}

- (void)layoutSubviews
{

    CCorrespondence *correspondence;
    if(self.menuId!=100){
        correspondence= ((CMenu*)self.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
    }else{
        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    }
    
    thumbnailrarray = [[NSMutableArray alloc] init];
    
    
    if (correspondence.attachmentsList.count>0)
    {
        for(CAttachment* doc in correspondence.attachmentsList)
        {
            if([doc.FolderName isEqualToString:mainDelegate.FolderName]){
                [thumbnailrarray addObject:doc];
            }
            
            
        }
    }
    
  
    [self fillThumbView];
}

-(void) fillThumbView
{
    for(UIView* view in scrollViewmainPagebar.subviews){
        [view removeFromSuperview];
    }

    scrollViewmainPagebar.frame=CGRectMake(0, 55, 130, self.frame.size.height);

    UIButton *button;
    UILabel *titleLable;
    UIImage *image;
    NSData *imagedata;
    NSString* urlString;
    NSURL *url;
    
    
    UIButton *gobackFolder=[[UIButton alloc]initWithFrame:CGRectMake(40, 0, 50, 50)];
    [gobackFolder setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"GoBack.png"]]forState:UIControlStateNormal];
    [gobackFolder addTarget:self action:@selector(closePagebar) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:gobackFolder];
    
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    float size=(thumbnailrarray.count*image.size.width)+((thumbnailrarray.count-1)*40);
    CGSize ScreenSize = self.bounds.size;
    int EndSpace;
    for (int i=0; i<=thumbnailrarray.count-1; i++) {
      
        urlString=((CAttachment*)[thumbnailrarray objectAtIndex:i]).ThubnailUrl;
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            EndSpace=(i/8)%8;
        }
        else{
            EndSpace=(i/6)%6;
        }
        
        int padding=thumbnailrarray.count>=6?450:0;
        float origin=(ScreenSize.width-padding-size);
        if(origin<=0) origin=254;
        if(mainDelegate.ShowThumbnail && ![urlString isEqualToString:@""])
        {
            
            url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            imagedata = [[NSData alloc] initWithContentsOfURL:url];
            image = [UIImage imageWithData:imagedata];

            button=[[UIButton alloc]initWithFrame:CGRectMake(30, i*133, 70, 85)];

            titleLable=[[UILabel alloc]initWithFrame:CGRectMake(5,i*133+55 , 120, 100)];
        }
        else
        {
            image =[UIImage imageNamed:@"thumbnail1.png"];
            button=[[UIButton alloc]initWithFrame:CGRectMake(30, i*133,image.size.width, image.size.height)];
            titleLable=[[UILabel alloc]initWithFrame:CGRectMake(30, i*133+image.size.height-20, image.size.width+10, 100)];
        }
        
        
        [button addTarget:self action:@selector(openAttachment:) forControlEvents:UIControlEventTouchUpInside];
        button.tag=i;
       
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [titleLable setText:((CAttachment*)[thumbnailrarray objectAtIndex:i]).title];
        
        titleLable.lineBreakMode = NSLineBreakByWordWrapping;
        titleLable.numberOfLines = 2;
        
        titleLable.textAlignment=NSTextAlignmentCenter;
        titleLable.backgroundColor = [UIColor clearColor];
        titleLable.font = [UIFont fontWithName:@"Helvetica" size:17];
        titleLable.textColor=[UIColor whiteColor];
        [scrollViewmainPagebar addSubview:button];
        [scrollViewmainPagebar addSubview:titleLable];
    }
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
         scrollViewmainPagebar.contentSize = CGSizeMake(75, thumbnailrarray.count*160);
    }
    else
    scrollViewmainPagebar.contentSize = CGSizeMake(75, thumbnailrarray.count*140);

    [self addSubview:scrollViewmainPagebar];
    
}
-(void)adjustToolbar:(UIInterfaceOrientation)tointerfaceOrientation
{
    if (!SYSTEM_VERSION_LESS_THAN(@"8.0")) {
 
    if (UIInterfaceOrientationIsPortrait(tointerfaceOrientation)) {
        self.frame=CGRectMake(0, 0, 130, [UIScreen mainScreen].bounds.size.width);
    }
   scrollViewmainPagebar.contentSize = CGSizeMake(75, thumbnailrarray.count*160);
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(tointerfaceOrientation))
          scrollViewmainPagebar.contentSize = CGSizeMake(75, thumbnailrarray.count*160);
        else
            scrollViewmainPagebar.contentSize = CGSizeMake(75, thumbnailrarray.count*140);
            
  
    }
}
-(void)closePagebar{
    [delegate closePagebar];
}
-(void) openAttachment:(UIButton*)button
{
//    if(self.attachmentId!=button.tag){

        self.attachmentId=button.tag;
        NSInteger page = self.attachmentId+1;
        [self updatePageNumberText:page];
        
        CCorrespondence *correspondence;
        if(self.menuId!=100){
            correspondence= ((CMenu*)self.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
        }else{
            correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
        }
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loading ...") maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        thumbnailrarray = [[NSMutableArray alloc] init];
        
        NSMutableArray* indexes=[[NSMutableArray alloc]init];
        if (correspondence.attachmentsList.count>0)
        {
            int index=0;
            for(CAttachment* doc in correspondence.attachmentsList)
            {
                if([doc.FolderName isEqualToString:mainDelegate.FolderName]){
                    [thumbnailrarray addObject:doc];
                    [indexes addObject:[NSString stringWithFormat:@"%d",index]];
                }
                index++;
                
            }
        }
        
        CAttachment *fileToOpen=thumbnailrarray[self.attachmentId];
        
        
        
        if(fileToOpen.url!=nil){
    
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:correspondence.Id fromSharepoint:mainDelegate.isSharepoint];
                
                ReaderDocument *newDocument=nil;
                if (![tempPdfLocation isEqualToString:@""]&&[ReaderDocument isPDF:tempPdfLocation] == YES) // File must exist
                {
                    newDocument=[self OpenPdfReader:tempPdfLocation];
                    
                    
                
                // NSString *tempPdfLocation=[CParser loadPdfFile:fileToOpen.url inDirectory:correspondence.Id];
                NSString* indexx=[indexes objectAtIndex:self.attachmentId];
                [delegate setAttachmentIdInToolbar:indexx.intValue];
                if(indexx.intValue==correspondence.attachmentsList.count-1){
                    [delegate disableNext];
                    if(correspondence.attachmentsList.count>1)
                        [delegate enablePrev];
                }
                else
                    if(indexx.intValue==0){
                        [delegate disablePrev];
                        if(correspondence.attachmentsList.count>1)
                            [delegate enableNext];
                    }
                    else{
                        [delegate enableNext];
                        [delegate enablePrev];
                    }
                
                
                
                [delegate pagebar:self gotoPage:1 document:newDocument fileId:self.attachmentId]; // Go to document page
                
                }
                else{
                    
                    [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:NSLocalizedString(@"ErrorInURL",@"") waitUntilDone:YES];
                }
                
                //[self startEnableTimer]; // Start track control enable timer
                [SVProgressHUD dismiss];
                
            });
        }else{
            [SVProgressHUD dismiss];

            [self performSelectorOnMainThread:@selector(ShowMessage:) withObject:NSLocalizedString(@"AttachmentProblem",@"") waitUntilDone:YES];
        }
    });
    
        
        
        
//    }
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

//- (void)updatePagebarViews
//{
//	NSInteger page = self.attachmentId+1; // #
//
//	[self updatePageNumberText:page]; // Update page number text
//
//	[self updatePageThumbView:page]; // Update page thumb view
//}
//
//- (void)updatePagebar
//{
//	if (self.hidden == NO) // Only if visible
//	{
//		[self updatePagebarViews]; // Update views
//	}
//}

//- (void)hidePagebar
//{
//	if (self.hidden == NO) // Only if visible
//	{
//
//        [thumbnailrarray removeAllObjects];
//		[UIView animateWithDuration:0.25 delay:0.0
//                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
//                         animations:^(void)
//         {
//             self.alpha = 0.0f;
//         }
//                         completion:^(BOOL finished)
//         {
//             self.hidden = YES;
//         }
//         ];
//	}
//}
//
//- (void)showPagebar
//{
//	if (self.hidden == YES) // Only if hidden
//	{
//
//		[self updatePagebarViews]; // Update views first
//
//		[UIView animateWithDuration:0.25 delay:0.0
//                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
//                         animations:^(void)
//         {
//             self.hidden = NO;
//             self.alpha = 1.0f;
//         }
//                         completion:NULL
//         ];
//	}
//}

#pragma mark ReaderTrackControl action methods

//- (void)trackTimerFired:(NSTimer *)timer
//{
//	[trackTimer invalidate]; trackTimer = nil; // Cleanup timer
//
//	if (trackControl.tag != self.attachmentId) // Only if different
//	{
//		//[delegate pagebar:self gotoPage:trackControl.tag]; // Go to document page
//	}
//}
//
//- (void)enableTimerFired:(NSTimer *)timer
//{
//	[enableTimer invalidate]; enableTimer = nil; // Cleanup timer
//
//	trackControl.userInteractionEnabled = YES; // Enable track control interaction
//}
//
//- (void)restartTrackTimer
//{
//	if (trackTimer != nil) { [trackTimer invalidate]; trackTimer = nil; } // Invalidate and release previous timer
//
//	trackTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(trackTimerFired:) userInfo:nil repeats:NO];
//}
//
//- (void)startEnableTimer
//{
//	if (enableTimer != nil) { [enableTimer invalidate]; enableTimer = nil; } // Invalidate and release previous timer
//
//	enableTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(enableTimerFired:) userInfo:nil repeats:NO];
//}
//
//- (NSInteger)trackViewPageNumber:(ReaderTrackControl *)trackView
//{
//	CGFloat controlWidth = trackView.bounds.size.width; // View width
//    CCorrespondence *correspondence;
//    if(self.menuId!=100){
//        correspondence= ((CMenu*)self.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
//    }else{
//        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
//    }
//
//    NSInteger pages=thumbnailrarray.count;
//
//	CGFloat stride = (controlWidth / pages);
//
//	NSInteger page = (trackView.value / stride); // Integer page number
//
//    mainDelegate.attachmentSelected = page;
//
//	return (page + 1); // + 1
//}
//
//- (void)trackViewTouchDown:(ReaderTrackControl *)trackView
//{
//	NSInteger page = [self trackViewPageNumber:trackView]; // Page
//
//	if (page != self.attachmentId+1) // Only if different
//	{
//        self.attachmentId=page-1;
//		[self updatePageNumberText:page]; // Update page number text
//
//		[self updatePageThumbView:page]; // Update page thumb view
//
//		[self restartTrackTimer]; // Start the track timer
//
//	}
//
//	trackView.tag = page; // Start page tracking
//}
//
//- (void)trackViewValueChanged:(ReaderTrackControl *)trackView
//{
//	NSInteger page = [self trackViewPageNumber:trackView]; // Page
//
//	if (page != trackView.tag) // Only if the page number has changed
//	{
//		[self updatePageNumberText:page]; // Update page number text
//
//		[self updatePageThumbView:page]; // Update page thumb view
//
//		trackView.tag = page; // Update the page tracking tag
//
//		[self restartTrackTimer]; // Restart the track timer
//	}
//}

//- (void)trackViewTouchUp:(ReaderTrackControl *)trackView
//{
//	[trackTimer invalidate]; trackTimer = nil; // Cleanup
//
//	if (trackView.tag != self.attachmentId) // Only if different
//	{
//		trackView.userInteractionEnabled = NO; // Disable track control interaction
//
//        CCorrespondence *correspondence;
//        if(self.menuId!=100){
//            correspondence= ((CMenu*)self.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
//        }else{
//            correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
//        }
//
//        thumbnailrarray = [[NSMutableArray alloc] init];
//
//        NSMutableArray* indexes=[[NSMutableArray alloc]init];
//        if (correspondence.attachmentsList.count>0)
//        {
//            int index=0;
//            for(CAttachment* doc in correspondence.attachmentsList)
//            {
//                if([doc.FolderName isEqualToString:mainDelegate.FolderName]){
//                    [thumbnailrarray addObject:doc];
//                    [indexes addObject:[NSString stringWithFormat:@"%d",index]];
//                }
//                index++;
//
//            }
//        }
//
//        CAttachment *fileToOpen=thumbnailrarray[self.attachmentId];
//
//
//
//
//        [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loading ...") maskType:SVProgressHUDMaskTypeBlack];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//
//
//
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:correspondence.Id fromSharepoint:mainDelegate.isSharepoint];
//
//                ReaderDocument *newDocument=nil;
//                if ([ReaderDocument isPDF:tempPdfLocation] == YES) // File must exist
//                {
//                    newDocument=[self OpenPdfReader:tempPdfLocation];
//
//
//                }
//                // NSString *tempPdfLocation=[CParser loadPdfFile:fileToOpen.url inDirectory:correspondence.Id];
//                NSString* indexx=[indexes objectAtIndex:self.attachmentId];
//                [delegate setAttachmentIdInToolbar:indexx.intValue];
//                if(indexx.intValue==correspondence.attachmentsList.count-1){
//                    [delegate disableNext];
//                    if(correspondence.attachmentsList.count>1)
//                        [delegate enablePrev];
//                }
//                else
//                    if(indexx.intValue==0){
//                        [delegate disablePrev];
//                        if(correspondence.attachmentsList.count>1)
//                            [delegate enableNext];
//                    }
//                    else{
//                        [delegate enableNext];
//                        [delegate enablePrev];
//                    }
//
//
//
//                [delegate pagebar:self gotoPage:1 document:newDocument fileId:self.attachmentId]; // Go to document page
//
//
//
//                [self startEnableTimer]; // Start track control enable timer
//                [SVProgressHUD dismiss];
//
//            });});
//
//	}
//
//	trackView.tag = 0; // Reset page tracking
//
//}

//- (void)trackViewTouchUp:(UIButton *)trackView
//{
//	[trackTimer invalidate]; trackTimer = nil; // Cleanup
//    int aid=self.attachmentId;
//    int taggg=trackView.tag;
//	if (trackView.tag != self.attachmentId) // Only if different
//	{
//		//trackView.userInteractionEnabled =YES; // Disable track control interaction
//
//        CCorrespondence *correspondence;
//        if(self.menuId!=100){
//            correspondence= ((CMenu*)self.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
//        }else{
//            correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
//        }
//
//        thumbnailrarray = [[NSMutableArray alloc] init];
//
//        NSMutableArray* indexes=[[NSMutableArray alloc]init];
//        if (correspondence.attachmentsList.count>0)
//        {
//            int index=0;
//            for(CAttachment* doc in correspondence.attachmentsList)
//            {
//                if([doc.FolderName isEqualToString:mainDelegate.FolderName]){
//                    [thumbnailrarray addObject:doc];
//                    [indexes addObject:[NSString stringWithFormat:@"%d",index]];
//                }
//                index++;
//
//            }
//        }
//
//        CAttachment *fileToOpen=thumbnailrarray[self.attachmentId];
//
//
//
//
//        [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loading ...") maskType:SVProgressHUDMaskTypeBlack];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//
//
//
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:correspondence.Id fromSharepoint:mainDelegate.isSharepoint];
//
//                ReaderDocument *newDocument=nil;
//                if ([ReaderDocument isPDF:tempPdfLocation] == YES) // File must exist
//                {
//                    newDocument=[self OpenPdfReader:tempPdfLocation];
//
//
//                }
//                // NSString *tempPdfLocation=[CParser loadPdfFile:fileToOpen.url inDirectory:correspondence.Id];
//                NSString* indexx=[indexes objectAtIndex:self.attachmentId];
//                [delegate setAttachmentIdInToolbar:indexx.intValue];
//                if(indexx.intValue==correspondence.attachmentsList.count-1){
//                    [delegate disableNext];
//                    if(correspondence.attachmentsList.count>1)
//                        [delegate enablePrev];
//                }
//                else
//                    if(indexx.intValue==0){
//                        [delegate disablePrev];
//                        if(correspondence.attachmentsList.count>1)
//                            [delegate enableNext];
//                    }
//                    else{
//                        [delegate enableNext];
//                        [delegate enablePrev];
//                    }
//
//
//
//                [delegate pagebar:self gotoPage:1 document:newDocument fileId:self.attachmentId]; // Go to document page
//
//
//
//                //[self startEnableTimer]; // Start track control enable timer
//                [SVProgressHUD dismiss];
//
//            });});
//
//	}
//
//	trackView.tag = 0; // Reset page tracking
//
//}
-(ReaderDocument*) OpenPdfReader:(NSString *) pdfPath{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    NSString *filePath = pdfPath;// [pdfs lastObject];
    assert(filePath != nil); // Path to last PDF file
    
    ReaderDocument *newDocument = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
    return newDocument;
}


@end

#pragma mark -

//
//	ReaderTrackControl class implementation
//

//@implementation ReaderTrackControl
//{
//	CGFloat _value;
//}
//
//#pragma mark Properties
//
//@synthesize value = _value;
//
//#pragma mark ReaderTrackControl instance methods
//
//- (id)initWithFrame:(CGRect)frame
//{
//	if ((self = [super initWithFrame:frame]))
//	{
//		self.autoresizesSubviews = NO;
//		self.userInteractionEnabled = YES;
//		self.contentMode = UIViewContentModeRedraw;
//		self.autoresizingMask = UIViewAutoresizingNone;
//		self.backgroundColor = [UIColor clearColor];
//	}
//
//	return self;
//}
//
//- (CGFloat)limitValue:(CGFloat)valueX
//{
//	CGFloat minX = self.bounds.origin.x; // 0.0f;
//	CGFloat maxX = (self.bounds.size.width - 1.0f);
//
//	if (valueX < minX) valueX = minX; // Minimum X
//	if (valueX > maxX) valueX = maxX; // Maximum X
//
//	return valueX;
//}
//
//#pragma mark UIControl subclass methods
//
//- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//	CGPoint point = [touch locationInView:self]; // Touch point
//
//	_value = [self limitValue:point.x]; // Limit control value
//
//	return YES;
//}
//
//- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//	if (self.touchInside == YES) // Only if inside the control
//	{
//		CGPoint point = [touch locationInView:touch.view]; // Touch point
//
//		CGFloat x = [self limitValue:point.x]; // Potential new control value
//
//		if (x != _value) // Only if the new value has changed since the last time
//		{
//			_value = x; [self sendActionsForControlEvents:UIControlEventValueChanged];
//		}
//	}
//
//	return YES;
//}
//
//- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//	CGPoint point = [touch locationInView:self]; // Touch point
//
//	_value = [self limitValue:point.x]; // Limit control value
//}
//
//@end
//
//#pragma mark -
//
//
//	ReaderPagebarThumb class implementation
//

@implementation ReaderPagebarThumb

#pragma mark ReaderPagebarThumb instance methods

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame small:NO];
}

- (id)initWithFrame:(CGRect)frame small:(BOOL)small
{
	if ((self = [super initWithFrame:frame])) // Superclass init
	{
		//CGFloat value = (small ? 0.6f : 0.7f); // Size based alpha value
        
		//UIColor *background = [UIColor colorWithWhite:0.8f alpha:value];
        
		self.backgroundColor = [UIColor clearColor];
        imageView.backgroundColor =[UIColor clearColor];
        
        
		//imageView.layer.borderColor = [UIColor colorWithWhite:0.4f alpha:0.6f].CGColor;
        
		//imageView.layer.borderWidth = 1.0f; // Give the thumb image view a border
	}
    
	return self;
}

@end

#pragma mark -

//
//	ReaderPagebarShadow class implementation
//

@implementation ReaderPagebarShadow

#pragma mark ReaderPagebarShadow class methods

+ (Class)layerClass
{
	return [CAGradientLayer class];
}

#pragma mark ReaderPagebarShadow instance methods

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = NO;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];
        
		CAGradientLayer *layer = (CAGradientLayer *)self.layer;
		UIColor *blackColor = [UIColor colorWithWhite:0.42f alpha:1.0f];
		UIColor *clearColor = [UIColor colorWithWhite:0.42f alpha:0.0f];
        //        UIColor *blackColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
        //		UIColor *clearColor = [UIColor colorWithWhite:0.1f alpha:0.8f];
		layer.colors = [NSArray arrayWithObjects:(id)clearColor.CGColor, (id)blackColor.CGColor, nil];
	}
    
	return self;
}

@end
