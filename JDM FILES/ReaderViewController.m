//
//	ReaderViewController.m
//	Reader v2.6.0
//

#import "ReaderConstants.h"
#import "ReaderViewController.h"
#import "ThumbsViewController.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ReaderContentView.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"
#import <MessageUI/MessageUI.h>
#import "CGPDFDocument.h"
#import "NoteAlertView.h"
#import "MetadataViewController.h"
#import "TransferViewController.h"
#import "CMenu.h"
#import "CCorrespondence.h"
#import "CAttachment.h"
#import "CFolder.h"
#import "AppDelegate.h"
#import "CParser.h"
#import "PDFDocument.h"
#import "PDFView.h"
#import "Base64.h"
#import "NSData-AES.h"
#import "NotesViewController.h"
#import "CDestination.h"
#import "ActionsViewController.h"
#import "SearchResultViewController.h"
#import "CRouteLabel.h"
#import "CFPendingAction.h"
#import "AnnotationsController.h"
#import "MoreTableViewController.h"
#import "GDataXMLNode.h"
#import "OfflineAction.h"
#import "CSearch.h"
#import "ManageSignatureViewController.h"
#import "CustomViewController.h"
#import "SignatureController.h"
#import "CommentViewController.h"
#import "CAction.h"
#import "SVProgressHUD.h"
#import "FileManager.h"
#import "note.h"
#import "HighlightClass.h"
#import "AttachmentViewController.h"
#import "UploadControllerDialog.h"
#import "ToolbarItem.h"
//#import "SVProgressHUD.h"

@interface ReaderViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate,
									ReaderMainToolbarDelegate, ReaderMainPagebarDelegate, ReaderContentViewDelegate, ThumbsViewControllerDelegate>
@end

@implementation ReaderViewController
{
	ReaderDocument *document;

    
	UIScrollView *theScrollView;

	ReaderMainToolbar *mainToolbar;

	ReaderMainPagebar *mainPagebar;

	NSMutableDictionary *contentViews;

	UIPrintInteractionController *printInteraction;

	NSInteger currentPage;

	CGSize lastAppearSize;

	NSDate *lastHideTime;

	BOOL isVisible;
    
    float lastContentOffset;
    UIInterfaceOrientation gCurrentOrientation;
    
    CGPDFDocumentRef PDFdocument;
    UISearchBar *searchBar;
    UISearchDisplayController *searchBarVC;
    Boolean Searching;
    UIPopoverController *searchPopVC;
    UITableView *tblSearchResult;
    UIViewController *ObjVC;
    
    NSArray *selections;
	//Scanner *scanner;
    NSString *keyword;
    
    CGPDFPageRef PDFPageRef;
    CGPDFDocumentRef PDFDocRef;
    NSMutableArray *arrSearchPagesIndex;
    int i;
    BOOL OrientationLock;
    AppDelegate *mainDelegate;
    
    BOOL isNoteVisible;
    BOOL isMetadataVisible;
    UIView *metadataContainer;

       NSMutableArray *folderNamesArray;
}

#pragma mark Constants

#define PAGING_VIEWS 3

#define TOOLBAR_HEIGHT 115.0f
#define PAGEBAR_HEIGHT 220.0f

#define TAP_AREA_SIZE 48.0f

#define TAG_DEV 1
#define TAG_SIGN 2
#define TAG_SAVE 3

#pragma mark Properties

@synthesize delegate,keyword,selections,openButton,numberPages,folderPagebar;

#pragma mark Support methods

- (void)updateScrollViewContentSize
{
    
	NSInteger count = [document.pageCount integerValue];

	if (count > PAGING_VIEWS) count = PAGING_VIEWS; // Limit

	CGFloat contentHeight = theScrollView.bounds.size.height;

	CGFloat contentWidth = (theScrollView.bounds.size.width * count);

	theScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateScrollViewContentViews
{
	[self updateScrollViewContentSize]; // Update the content size

	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSet]; // Page set

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(id key, id object, BOOL *stop)
		{
			ReaderContentView *contentView = object; [pageSet addIndex:contentView.tag];
		}
	];

	__block CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;

	__block CGPoint contentOffset = CGPointZero; NSInteger page = [document.pageNumber integerValue];

	[pageSet enumerateIndexesUsingBlock: // Enumerate page number set
		^(NSUInteger number, BOOL *stop)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key

			ReaderContentView *contentView = [contentViews objectForKey:key];

			contentView.frame = viewRect; if (page == number) contentOffset = viewRect.origin;

			viewRect.origin.x += viewRect.size.width; // Next view frame position
		}
	];

	if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
	{
		theScrollView.contentOffset = contentOffset; // Update content offset
	}
}

- (void)updateToolbarBookmarkIcon
{
	//NSInteger page = [document.pageNumber integerValue];

	//BOOL bookmarked = [document.bookmarks containsIndex:page];

	//[mainToolbar setBookmarkState:bookmarked]; // Update
}

- (void)showDocumentPage:(NSInteger)page
{
	if (page != currentPage) // Only if different
	{
		NSInteger minValue; NSInteger maxValue;
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1;

		if ((page < minPage) || (page > maxPage)) return;

		if (maxPage <= PAGING_VIEWS) // Few pages
		{
			minValue = minPage;
			maxValue = maxPage;
		}
		else // Handle more pages
		{
			minValue = (page - 1);
			maxValue = (page + 1);

			if (minValue < minPage)
				{minValue++; maxValue++;}
			else
				if (maxValue > maxPage)
					{minValue--; maxValue--;}
		}

		NSMutableIndexSet *newPageSet = [NSMutableIndexSet new];

		NSMutableDictionary *unusedViews = [contentViews mutableCopy];

		CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;

		for (NSInteger number = minValue; number <= maxValue; number++)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key

			ReaderContentView *contentView = [contentViews objectForKey:key];

			if (contentView == nil) // Create a brand new document content view
			{
				//NSURL *fileURL = document.fileURL; NSString *phrase = document.password; // Document properties

				//contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:number password:phrase];
                m_pdfview = [[PDFView alloc]initWithFrame:viewRect];
                [m_pdfdoc setPDFView:m_pdfview];
                [m_pdfdoc setCurPage:[m_pdfdoc getPDFPage:number]];
                [m_pdfview initPDFDoc:m_pdfdoc];
               
                //Add pdf view to viewcontroller.
               // [self.view addSubview:m_pdfview];

				//[theScrollView addSubview:contentView];
               // [contentViews setObject:contentView forKey:key];

				contentView.message = self; [newPageSet addIndex:number];
			}
			else // Reposition the existing content view
			{
				contentView.frame = viewRect; [contentView zoomReset];

				[unusedViews removeObjectForKey:key];
			}

			viewRect.origin.x += viewRect.size.width;
		}

		[unusedViews enumerateKeysAndObjectsUsingBlock: // Remove unused views
			^(id key, id object, BOOL *stop)
			{
				[contentViews removeObjectForKey:key];

				ReaderContentView *contentView = object;

				[contentView removeFromSuperview];
			}
		];

		unusedViews = nil; // Release unused views

		CGFloat viewWidthX1 = viewRect.size.width;
		CGFloat viewWidthX2 = (viewWidthX1 * 2.0f);

		CGPoint contentOffset = CGPointZero;

		if (maxPage >= PAGING_VIEWS)
		{
			if (page == maxPage)
				contentOffset.x = viewWidthX2;
			else
				if (page != minPage)
					contentOffset.x = viewWidthX1;
		}
		else
			if (page == (PAGING_VIEWS - 1))
				contentOffset.x = viewWidthX1;

		if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
		{
			theScrollView.contentOffset = contentOffset; // Update content offset
		}

		if ([document.pageNumber integerValue] != page) // Only if different
		{
			document.pageNumber = [NSNumber numberWithInteger:page]; // Update page number
		}

		NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid;

		if ([newPageSet containsIndex:page] == YES) // Preview visible page first
		{
			NSNumber *key = [NSNumber numberWithInteger:page]; // # key

			ReaderContentView *targetView = [contentViews objectForKey:key];

			[targetView showPageThumb:fileURL page:page password:phrase guid:guid];

			[newPageSet removeIndex:page]; // Remove visible page from set
		}

		[newPageSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock: // Show previews
			^(NSUInteger number, BOOL *stop)
			{
				NSNumber *key = [NSNumber numberWithInteger:number]; // # key

				ReaderContentView *targetView = [contentViews objectForKey:key];

				[targetView showPageThumb:fileURL page:number password:phrase guid:guid];
			}
		];

		newPageSet = nil; // Release new page set

		[mainPagebar updatePagebar]; // Update the pagebar display

		//[self updateToolbarBookmarkIcon]; // Update bookmark

		currentPage = page; // Track current page number
	}
}

- (void)showDocument:(id)object
{
    @try{
	 // Set content size

	//[self showDocumentPage:[document.pageNumber integerValue]];

	document.lastOpen = [NSDate date]; // Update last opened date

	isVisible = YES; // iOS present modal bodge
    CCorrespondence *correspondence;
    if(self.menuId!=100){
        correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
    }else{
        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    }
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
        
        CAttachment *fileToOpen;
        
        if([mainDelegate.attachmentType isEqualToString:@"nextprevioustype"]){
            fileToOpen=correspondence.attachmentsList[self.attachmentId];
        }
        else{
            fileToOpen=thumbnailrarray[self.attachmentId];
        }
        
    
        mainDelegate.attachmentType =@"";
        
        //CAttachment *fileToOpen;

    
        
    [mainToolbar updateTitleWithLocation:fileToOpen.location withName:fileToOpen.title];
      NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:correspondence.Id fromSharepoint:mainDelegate.isSharepoint];
    //NSString *tempPdfLocation=[CParser loadPdfFile:fileToOpen.url inDirectory:correspondence.Id];
    
    const char* file = [tempPdfLocation UTF8String];
    
	m_pdfdoc = [[PDFDocument alloc] init];
	[m_pdfdoc initPDFSDK];
	if(![m_pdfdoc openPDFDocument: file]){
        [m_pdfview removeFromSuperview];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Warning")
                                                            message:NSLocalizedString(@"Alert.Extension",@"Document extension not supported.")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK",@"OK")
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
       
    }
    else{
        if(![self.view.subviews containsObject:m_pdfview]){
            float factor;
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
                factor=1;
                            m_pdfview = [[PDFView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-self.view.bounds.size.width/factor)/2, 5, self.view.bounds.size.width/factor, self.view.bounds.size.height-5)];
                //jis orientation
                if(isMetadataVisible){
                    [metadataContainer removeFromSuperview];
                    [self.view addSubview:metadataContainer];
                    m_pdfview.frame=CGRectMake (325, 0, self.view.bounds.size.width/1.75, self.view.bounds.size.height-5);
                    metadataContainer.frame=CGRectMake(0, 0, 320, 1019);
                    numberPages.frame = CGRectMake(360, 950, 80, 40);
                    openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 20);               

                }
                //endjis orientation
            } else {
                factor=1.75;
                    m_pdfview = [[PDFView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-self.view.bounds.size.width/factor)/2, 5, self.view.bounds.size.width/factor, self.view.bounds.size.height-5)];
                if(isMetadataVisible){
                    m_pdfview.frame=CGRectMake(320+(self.view.bounds.size.width-(320+m_pdfview.frame.size.width))/2, 0, m_pdfview.frame.size.width, m_pdfview.frame.size.height);
                }
            }

            
            

            

            [m_pdfdoc setPDFView:m_pdfview];
            [m_pdfview initPDFDoc:m_pdfdoc];
            [self.view addSubview:m_pdfview];
            
            [m_pdfview addSubview:openButton];
         [m_pdfview addSubview:numberPages];
            
            [m_pdfview addSubview:folderPagebar];
            
        }
        else{
	[m_pdfdoc setPDFView:m_pdfview];
	[m_pdfview initPDFDoc:m_pdfdoc];
        }
//
//	//Add pdf view to viewcontroller.
       
        [self.view bringSubviewToFront:numberPages];
        [self.view bringSubviewToFront:openButton];
    [self.view bringSubviewToFront:mainToolbar];
    [self.view bringSubviewToFront:mainPagebar];
        [self.view bringSubviewToFront:folderPagebar];
    [self updateScrollViewContentSize];
    }
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"showDocument" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
}

#pragma mark UIViewController methods

- (id)initWithReaderDocument:(ReaderDocument *)object MenuId:(NSInteger)menuId CorrespondenceId:(NSInteger)correspondenceId AttachmentId:(NSInteger)attachmentId
{
	id reader = nil; // ReaderViewController object
   
	if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]]))
	{   self.menuId=menuId;
        self.correspondenceId=correspondenceId;
        self.attachmentId=attachmentId;
        mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		if ((self = [super initWithNibName:nil bundle:nil])) // Designated initializer
		{
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

			[notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillTerminateNotification object:nil];

			[notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillResignActiveNotification object:nil];

			[object updateProperties]; document = object; // Retain the supplied ReaderDocument object for our use

			[ReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory

			reader = self; // Return an initialized ReaderViewController object
		}
	}

	return reader;
}

-(void) openToolbar{
    [self.view bringSubviewToFront:mainToolbar];
    [mainToolbar showToolbar];
}

-(void)openPagebar:(id)sender{
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loading ...") maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        mainDelegate.FolderName =folderarray[[sender tag]];
        
        CCorrespondence *correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
        
        
        if(![mainDelegate.folderNames containsObject:mainDelegate.FolderName]){
            
            [folderNamesArray addObject:mainDelegate.FolderName];
            [mainDelegate.folderNames addObject:mainDelegate.FolderName];
            
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
            
            CGSize size = [UIScreen mainScreen].bounds.size;
            size = CGSizeMake(size.height, size.width);
            CGRect viewRect = CGRectMake( 0,0,size.width, self.view.bounds.size.height);
            
            //CGRect viewRect = CGRectMake( m_pdfview.bounds.origin.x+218,0,size.width, self.view.bounds.size.height);
            
            CGRect pagebarRect = viewRect;
            
            pagebarRect.size.height = PAGEBAR_HEIGHT;
            pagebarRect.origin.y = (viewRect.size.height - PAGEBAR_HEIGHT);
            
            mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect Document:document CorrespondenceId:self.correspondenceId MenuId:self.menuId AttachmentId:self.attachmentId]; // At bottom
            
            
            
            //jis folderpagebar
            UIButton *gobackFolder=[[UIButton alloc]initWithFrame:CGRectMake(2, -20, 50, 50)];
            [gobackFolder setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"GoBack.png"]]forState:UIControlStateNormal];
            [gobackFolder addTarget:self action:@selector(closePagebar) forControlEvents:UIControlEventTouchUpInside];
            [mainPagebar addSubview:gobackFolder];
            [mainPagebar bringSubviewToFront:gobackFolder];
            
            mainPagebar.delegate = self;
            //    CGRect shadowRect = mainPagebar.bounds; shadowRect.size.height = 10.0f; shadowRect.origin.y -= shadowRect.size.height;
            //    
            //    ReaderPagebarShadow *shadowView = [[ReaderPagebarShadow alloc] initWithFrame:shadowRect];
            //    
            //    [mainPagebar addSubview:shadowView];
            [self.view addSubview:mainPagebar];
            mainPagebar.hidden=false;
            
            // [mainPagebar showPagebar];
            folderPagebar.hidden=true;
            [SVProgressHUD dismiss];
        });
    });
    
}

-(void)closePagebar{
    self.attachmentId=0;
    [mainPagebar removeFromSuperview];
     mainPagebar.hidden=true;
   // [m_pdfview removeFromSuperview];

    mainPagebar=nil;
    //[mainPagebar hidePagebar];
    folderPagebar.hidden = false;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
     mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    folderNamesArray = [[NSMutableArray alloc]init];
    mainDelegate.folderNames = [[NSMutableArray alloc]init];
    openButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [openButton setTitle:[NSString stringWithFormat:@"Click to see the Menu"] forState:UIControlStateNormal];
    [openButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    openButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [openButton setTintColor:[UIColor whiteColor]];
    [openButton setBackgroundImage:[UIImage imageNamed:@"clickformenu.jpg"] forState:UIControlStateNormal];
    [openButton addTarget:self action:@selector(openToolbar) forControlEvents:UIControlEventTouchUpInside];
   openButton.imageEdgeInsets = UIEdgeInsetsMake(-50, -50, -50, -50);
   // [self.view addSubview:openButton];
    

	assert(document != nil); // Must have a valid ReaderDocument

	//self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.view.backgroundColor=[UIColor colorWithRed:29/255.0f green:29/255.0f  blue:29/255.0f  alpha:1.0];
	CGRect viewRect = self.view.bounds; // View controller's view bounds

	theScrollView = [[UIScrollView alloc] initWithFrame:viewRect]; // All

	theScrollView.scrollsToTop = NO;
	theScrollView.pagingEnabled = YES;
	theScrollView.delaysContentTouches = NO;
	theScrollView.showsVerticalScrollIndicator = NO;
	theScrollView.showsHorizontalScrollIndicator = NO;
    theScrollView.scrollEnabled=NO;
	theScrollView.contentMode = UIViewContentModeRedraw;
	theScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	theScrollView.backgroundColor = [UIColor clearColor];
	theScrollView.userInteractionEnabled = YES;
	theScrollView.autoresizesSubviews = NO;
	theScrollView.delegate = self;

	//[self.view addSubview:theScrollView];

	CGRect toolbarRect = viewRect;
	toolbarRect.size.height = TOOLBAR_HEIGHT;

	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect document:document CorrespondenceId:self.correspondenceId MenuId:self.menuId AttachmentId:self.attachmentId]; // At top
	mainToolbar.delegate = self;
    mainToolbar.hidden=true;
    
    
    
    
	[self.view addSubview:mainToolbar];
    
    [mainToolbar hideToolbar];
    
    folderPagebar = [[UIView alloc]init];
    
    
    
    folderPagebar.frame = CGRectMake(0, 2*PAGEBAR_HEIGHT+104,585.8, PAGEBAR_HEIGHT);
    
    
    folderPagebar.autoresizesSubviews = YES;
    folderPagebar.userInteractionEnabled = YES;
    folderPagebar.contentMode = UIViewContentModeRedraw;
    folderPagebar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    folderPagebar.backgroundColor = [UIColor colorWithRed:3/255.0f green:3/255.0f  blue:3/255.0f  alpha:0.8];
    
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, folderPagebar.bounds.size.width, folderPagebar.bounds.size.height)];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.showsHorizontalScrollIndicator = YES;
    

    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//     mainDelegate.annot = [[NSMutableArray alloc] init];

    folderarray = [[NSMutableArray alloc] init];
    
    for(CMenu* inbox in mainDelegate.user.menu)
    {
        if (inbox.correspondenceList.count>0)
        {
            for(CCorrespondence* correspondence in inbox.correspondenceList)
            {
                if (correspondence.attachmentsList.count>0)
                {
                    for(CAttachment* doc in correspondence.attachmentsList)
                    {
                        if(![folderarray containsObject:doc.FolderName]){
                            
                            [folderarray addObject:doc.FolderName];
                            
                        }

                    }
                }
            }
        }
    }

    scrollView.contentSize = CGSizeMake(folderPagebar.bounds.size.width * 3, folderPagebar.bounds.size.height);

    for( i=0 ;i<folderarray.count;i++){
        UIButton *btnFolder;
        UILabel* folderlabel;
        
        if(i%4==0){
            btnFolder=[[UIButton alloc]initWithFrame:CGRectMake(26+26+(140*i), 30, 100, 130)];
            
            folderlabel=[[UILabel alloc]initWithFrame:CGRectMake(26+26+(140*i), 100, 100, 100)];
        }
        else{
            btnFolder=[[UIButton alloc]initWithFrame:CGRectMake(26+(140*i), 30, 100, 130)];
            
            folderlabel=[[UILabel alloc]initWithFrame:CGRectMake(26+(140*i), 100, 100, 100)];
        }
        
     

        [btnFolder setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"Folder.png"]]forState:UIControlStateNormal];
        
        folderlabel.text=[folderarray objectAtIndex:i];
        
        folderlabel.lineBreakMode = NSLineBreakByWordWrapping;
        folderlabel.numberOfLines = 2;
        
        folderlabel.textAlignment=NSTextAlignmentCenter;
        folderlabel.backgroundColor = [UIColor clearColor];
        folderlabel.font = [UIFont fontWithName:@"Helvetica" size:17];
        folderlabel.textColor=[UIColor whiteColor];
        //  [btnFolder setTitle:[folderarray objectAtIndex:i] forState:UIControlStateNormal];
        btnFolder.tag =i;
        [btnFolder addTarget:self action:@selector(openPagebar:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:btnFolder];
        [scrollView addSubview:folderlabel];
        
    }
    [folderPagebar addSubview:scrollView];
    

//    UIButton *btnFolder=[[UIButton alloc]initWithFrame:CGRectMake(folderPagebar.frame.size.width/2-50, 0, 70, 70)];
//    [btnFolder setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"Folder.png"]]forState:UIControlStateNormal];
//    [btnFolder addTarget:self action:@selector(openPagebar) forControlEvents:UIControlEventTouchUpInside];
//    [folderPagebar addSubview:btnFolder];
    folderPagebar.hidden=true;
    
    CGRect shadowRect = folderPagebar.bounds; shadowRect.size.height = 10.0f; shadowRect.origin.y -= shadowRect.size.height;
    
    ReaderPagebarShadow *shadowView = [[ReaderPagebarShadow alloc] initWithFrame:shadowRect];
    
    [folderPagebar addSubview:shadowView];
    
//end jis folderpagebar
    

//mounir note
//    
//	mainPagebar.delegate = self;
//
//	[self.view addSubview:mainPagebar];
//    
//    [mainPagebar hidePagebar];

	UILongPressGestureRecognizer *singleTapOne = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	//singleTapOne.numberOfTouchesRequired = 1;
    //singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
   // singleTapOne.cancelsTouchesInView=YES;
	[self.view addGestureRecognizer:singleTapOne];

	UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;
	[self.view addGestureRecognizer:doubleTapOne];
    
    UIPinchGestureRecognizer *twoFingerPinch = [[UIPinchGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(twoFingerPinch:)];
    [self.view addGestureRecognizer:twoFingerPinch];


	UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapTwo.numberOfTouchesRequired = 2; doubleTapTwo.numberOfTapsRequired = 2; doubleTapTwo.delegate = self;
	[self.view addGestureRecognizer:doubleTapTwo];

	[singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail
    
    UISwipeGestureRecognizer *swipeRecognizerLeft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    swipeRecognizerLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRecognizerLeft];
    
    UISwipeGestureRecognizer *swipeLeftRecognizerRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
   swipeLeftRecognizerRight.direction=UISwipeGestureRecognizerDirectionRight;
   [self.view addGestureRecognizer:swipeLeftRecognizerRight];
    
    UISwipeGestureRecognizer *swipeRecognizerUp=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    swipeRecognizerUp.direction=UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeRecognizerUp];
    
    UISwipeGestureRecognizer *swipeRecognizerDown=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    swipeRecognizerDown.direction=UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeRecognizerDown];
  

	contentViews = [NSMutableDictionary new]; lastHideTime = [NSDate date];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
   
    
    
    
    
    numberPages = [UIButton buttonWithType:UIButtonTypeCustom];
    

    
    numberPages.frame = CGRectMake(self.view.frame.size.width-263, 720, 80, 30);
    currentPage++;
    [numberPages setTitle:[NSString stringWithFormat:@"%d of %@",currentPage,document.pageCount] forState:UIControlStateNormal];
    
    [numberPages setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    numberPages.titleLabel.font = [UIFont systemFontOfSize:12];
    [numberPages setTintColor:[UIColor whiteColor]];
    numberPages.backgroundColor = [UIColor blackColor];
    
   
 [self adjustButtons:orientation];
}




-(void)adjustButtons:(UIInterfaceOrientation)orientation{
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        openButton.frame = CGRectMake(self.view.bounds.size.width/2-100, 0, 200, 20);
        numberPages.frame = CGRectMake(687.8, 950, 80, 40);
    } else {
        openButton.frame = CGRectMake(self.view.bounds.size.width/2-191.5, 0, 200, 20);
        numberPages.frame = CGRectMake(self.view.frame.size.width-263, 720, 80, 30);
    }
    


}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
	{
		if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
		{
			[self updateScrollViewContentViews]; // Update content views
		}

		lastAppearSize = CGSizeZero; // Reset view size tracking
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero)) // First time
	{
		[self performSelector:@selector(showDocument:) withObject:nil afterDelay:0.02];
	}

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = YES;

#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	lastAppearSize = self.view.bounds.size; // Track view size

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = NO;

#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	mainToolbar = nil; mainPagebar = nil;

	theScrollView = nil; contentViews = nil; lastHideTime = nil;

	lastAppearSize = CGSizeZero; currentPage = 0;

	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
     gCurrentOrientation=interfaceOrientation;
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   
    
	if (isVisible == NO) return; // iOS present modal bodge

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
//    if([self.searchTable.view isDescendantOfView:self.view ]) {
//        CGRect searchViewRect = CGRectMake((self.view.bounds.size.width-450)/2, 0, 450, self.view.bounds.size.height);
//        self.searchTable.view.frame=searchViewRect;
//         }
//   s
    
//    CGRect noteViewRect = CGRectMake((self.view.bounds.size.width-500)/2, 0, 500, self.view.bounds.size.height);
//    self.noteTable.view.frame=noteViewRect;
    float factor;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        factor=1;
        m_pdfview.frame=CGRectMake ((self.view.bounds.size.width-self.view.bounds.size.width/factor)/2, 5, self.view.bounds.size.width/factor, self.view.bounds.size.height-5);
        numberPages.frame = CGRectMake(m_pdfview.frame.size.width+m_pdfview.frame.origin.x-80, 950, 80, 40);
        openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 20);
        //jis orientation
        if(isMetadataVisible){
            [metadataContainer removeFromSuperview];
              [self.view addSubview:metadataContainer];
               m_pdfview.frame=CGRectMake (325, 0, self.view.bounds.size.width/1.75, self.view.bounds.size.height-5);
            metadataContainer.frame=CGRectMake(0, 0, 320, 1019);
            numberPages.frame = CGRectMake(m_pdfview.frame.size.width+m_pdfview.frame.origin.x-80, 950, 80, 40);
            openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 20);

        }
        //endjis orientation

    } else {
        factor=1.75;
           m_pdfview.frame=CGRectMake ((self.view.bounds.size.width-self.view.bounds.size.width/factor)/2, 5, self.view.bounds.size.width/factor, self.view.bounds.size.height-5);
        numberPages.frame = CGRectMake(self.view.frame.size.width-263, 720, 80, 30);
        
        openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 20);
        
        //jis orientation
        if(isMetadataVisible){
            m_pdfview.frame=CGRectMake(320+(self.view.bounds.size.width-(320+m_pdfview.frame.size.width))/2, 0, m_pdfview.frame.size.width, m_pdfview.frame.size.height);
        }
        //endjis orientation

    }
    
    
    
	if (isVisible == NO) return; // iOS present modal bodge

	[self updateScrollViewContentViews]; // Update content views

	lastAppearSize = CGSizeZero; // Reset view size tracking
    
      [mainToolbar adjustButtons:interfaceOrientation];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//if (isVisible == NO) return; // iOS present modal bodge

	//if (fromInterfaceOrientation == self.interfaceOrientation) return;
  
}

- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Page Curl Animation methods

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    
    @try{
   // NSInteger page = [document.pageNumber integerValue];
    NSInteger maxPage = [document.pageCount integerValue];
    NSInteger minPage = 1; // Minimum
    CGPoint location = [recognizer locationInView:self.view];
    // [self showImageWithText:@"swipe" atPoint:location];
   
    if(mainToolbar.hidden==NO || mainPagebar.hidden==NO){
        [mainToolbar hideToolbar];
      //  [mainPagebar hidePagebar];
        if( mainPagebar.hidden==false){
            [mainPagebar removeFromSuperview];
            mainPagebar.hidden=true;
        }
    }
   
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        // if(![self.searchTable.view isDescendantOfView:self.view ]) {
        location.x -= 220.0;
        NSLog(@"Swip Left");
        
        if ((maxPage > minPage) && (currentPage != maxPage))
        {
            [self TurnPageRight];
        }
       //  }
        
    }
    else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
         //if(![self.searchTable.view isDescendantOfView:self.view ]) {
        location.x += 220.0;
        NSLog(@"Swip Right");
        
        if ((maxPage > minPage) && (currentPage > minPage))
        {
            [self TurnPageLeft];
        }
        // }
    }
    else if(recognizer.direction == UISwipeGestureRecognizerDirectionDown){
        
       // self.attachmentId -=1;
        
        CATransition *transition = [CATransition animation];
        [transition setDelegate:self];
        [transition setDuration:0.5f];
        
        [transition setType:kCATransitionFromTop];
        [transition setSubtype:kCATransitionFromTop];
        
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        
        [self.view.layer addAnimation:transition forKey:@"any"];
        [self ChangeFileOnSwipe: self.attachmentId-1];
    }
    else if(recognizer.direction == UISwipeGestureRecognizerDirectionUp){
       // self.attachmentId +=1;
        
        CATransition *transition = [CATransition animation];
        [transition setDelegate:self];
        [transition setDuration:0.5f];
        
        [transition setType:kCATransitionFromBottom];
        [transition setSubtype:kCATransitionFromBottom];
        
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        
        [self.view.layer addAnimation:transition forKey:@"any"];
        [self ChangeFileOnSwipe:self.attachmentId+1];
    }
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"handleSwipeFrom" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }

}

-(void)TurnPageLeft{
    CATransition *transition = [CATransition animation];
    [transition setDelegate:self];
    [transition setDuration:0.5f];
    
        [transition setSubtype:@"fromRight"];
        [transition setType:@"pageUnCurl"];
        [m_pdfview.layer addAnimation:transition forKey:@"UnCurlAnim"];
    
    
  //  [self showDocumentPage:currentPage-1];
    currentPage--;
    [numberPages setTitle:[NSString stringWithFormat:@"%d of %@",currentPage,document.pageCount] forState:UIControlStateNormal];
    [ m_pdfview OnPrevPage];
    
}
-(void)TurnPageRight{
    CATransition *transition = [CATransition animation];
    [transition setDelegate:self];
    [transition setDuration:0.5f];
    
    
        [transition setSubtype:@"fromRight"];
        [transition setType:@"pageCurl"];
        [m_pdfview.layer addAnimation:transition forKey:@"CurlAnim"];
   
    currentPage++;
    [numberPages setTitle:[NSString stringWithFormat:@"%d of %@",currentPage,document.pageCount] forState:UIControlStateNormal];
   // [self showDocumentPage:currentPage+1];
     [ m_pdfview OnNextPage];
}

-(void)ChangeFileOnSwipe:(NSInteger)newAttachId{
    
    @try
    {
    CCorrespondence *correspondence;
    if(self.menuId!=100)
    {
        correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
    }
    else
    {
        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    }
    
    if(newAttachId<0){
       // self.attachmentId+=1;
    }
   else if(newAttachId >=correspondence.attachmentsList.count){
        // self.attachmentId-=1;
    }
    else{
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
        

       CAttachment *fileToOpen=thumbnailrarray[newAttachId];
        self.attachmentId=newAttachId;
     NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:correspondence.Id fromSharepoint:mainDelegate.isSharepoint];
       // NSString *tempPdfLocation=[CParser loadPdfFile:fileToOpen.url inDirectory:correspondence.Id];
        if ([ReaderDocument isPDF:tempPdfLocation] == NO) // File must exist
        {
          //  [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
            [m_pdfview removeFromSuperview];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Warning")
                                                            message:NSLocalizedString(@"Alert.Extension",@"Document extension not supported.")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK",@"OK")
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
        }else {
            
    ReaderDocument *newDocument=[self OpenPdfReader:tempPdfLocation];
    
       document=newDocument;
    
    contentViews = [NSMutableDictionary new];
    currentPage=0;
    for (UIView *view in self.view.subviews)
    {
        if (![view isKindOfClass:[ReaderMainToolbar class]] && ![view isKindOfClass:[ReaderMainPagebar class]])
            [view removeFromSuperview];
    }
        
    lastHideTime = [NSDate date];
    [self updateScrollViewContentViews];
    lastAppearSize = CGSizeZero;
   
    [self performSelector:@selector(showDocument:) withObject:nil afterDelay:0];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
        mainPagebar.attachmentId=self.attachmentId;
        [mainPagebar updatePagebar];
        }
   }
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"ChangeFileOnSwipe" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }

}

-(ReaderDocument*) OpenPdfReader:(NSString *) pdfPath{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    NSString *filePath = pdfPath;// [pdfs lastObject];
    assert(filePath != nil); // Path to last PDF file
    
    ReaderDocument *newDocument = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
    return newDocument;
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    lastContentOffset = scrollView.contentOffset.x;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    	__block NSInteger page = 0;

	CGFloat contentOffsetX = scrollView.contentOffset.x;

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(id key, id object, BOOL *stop)
		{
			ReaderContentView *contentView = object;

			if (contentView.frame.origin.x == contentOffsetX)
			{
				page = contentView.tag; *stop = YES;
			}
		}
	];

	if (page != 0){  // Show the page
        [self showDocumentPage:page];

                 }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	[self showDocumentPage:theScrollView.tag]; // Show page

	theScrollView.tag = 0; // Clear page number tag
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
	if ([touch.view isKindOfClass:[PDFView class]]) return YES;

	return NO;
}

#pragma mark UIGestureRecognizer action methods

- (void)decrementPageNumber
{
	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum

		if ((maxPage > minPage) && (page != minPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;

			contentOffset.x -= theScrollView.bounds.size.width; // -= 1

			[theScrollView setContentOffset:contentOffset animated:YES];

			theScrollView.tag = (page - 1); // Decrement page number
		}
	}
}

- (void)incrementPageNumber
{
	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum

		if ((maxPage > minPage) && (page != maxPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;

			contentOffset.x += theScrollView.bounds.size.width; // += 1

			[theScrollView setContentOffset:contentOffset animated:YES];

			theScrollView.tag = (page + 1); // Increment page number
		}
	}
}

- (void)handleSingleTap:(UILongPressGestureRecognizer *)recognizer
{
   
    
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view];

		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area

		if (CGRectContainsPoint(areaRect, point)) // Single tap is inside the area
		{
		
				if ([lastHideTime timeIntervalSinceNow] < -0.75) // Delay since hide
				{
					if ((mainToolbar.hidden == YES))
					{
						[mainToolbar showToolbar];
                        //[mainPagebar showPagebar]; // Show
                        [self.view bringSubviewToFront:mainToolbar];
					}else{
                        [mainToolbar hideToolbar];
                       // [mainPagebar hidePagebar];
                        if( mainPagebar.hidden==false){
                            [mainPagebar removeFromSuperview];
                            mainPagebar.hidden=true;
                        }
                    }
				}
		

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}

- (void)twoFingerPinch:(UIPinchGestureRecognizer *)recognizer
{
    //    NSLog(@"Pinch scale: %f", recognizer.scale);
    CGRect viewRect = recognizer.view.bounds; // View bounds
    
    CGPoint point = [recognizer locationInView:recognizer.view];
    
    CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE);
    
        

    if (recognizer.scale >1.0f && recognizer.scale < 2.5f) {
        CGAffineTransform transform = CGAffineTransformMakeScale(recognizer.scale, recognizer.scale);
        
        if (CGRectContainsPoint(zoomArea, point))
        {
            //NSInteger page = [document.pageNumber integerValue];
            
           // NSNumber *key = [NSNumber numberWithInteger:page];
            
            //ReaderContentView *targetView = [contentViews objectForKey:key];
        m_pdfview.transform = transform;
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view];

		CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE);

		if (CGRectContainsPoint(zoomArea, point)) // Double tap is in the zoom area
		{
			//NSInteger page = [document.pageNumber integerValue]; // Current page #

			//NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key

			//ReaderContentView *targetView = [contentViews objectForKey:key];

			switch (recognizer.numberOfTouchesRequired) // Touches count
			{
				case 1: // One finger double tap: zoom ++
				{
					//[targetView zoomIncrement];
                    [m_pdfview OnZoomIn];
                    openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 20);
                    numberPages.frame = CGRectMake(m_pdfview.frame.size.width-82, numberPages.frame.origin.y, 80, 40);
                    break;
				}

				case 2: // Two finger double tap: zoom --
				{
					//[targetView zoomDecrement];
                    [m_pdfview OnZoomOut];
                    openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 20);
                    numberPages.frame = CGRectMake(m_pdfview.frame.size.width-82,numberPages.frame.origin.y, 80, 40);
                    break;
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}
//jen PreviousNext
//-(void)loadNewDocumentReader:(ReaderDocument *)newdocument documentId:(NSInteger)documentId{
-(void)loadNewDocumentReader:(ReaderDocument *)newdocument attachementId:(NSInteger)attachementId{
    @try{
    [self.noteContainer removeFromSuperview];
        //jen PreviousNext
   // self.correspondenceId=documentId;
    //self.attachmentId=1;
    self.attachmentId=attachementId;
    document=newdocument;
    contentViews = [NSMutableDictionary new];
    currentPage=0;
   // Searching=NO;
//    for (UIView *view in self.view.subviews)
//    {
//        if ([view isKindOfClass:[UIImageView class]])
//            [view removeFromSuperview];
//    }
    [m_pdfview removeFromSuperview];
        if( mainPagebar.hidden==false){
            [mainPagebar removeFromSuperview];
            mainPagebar.hidden=true;
        }
    
    
    [self performSelectorInBackground:@selector(updatePagebarByCorrespondence) withObject:nil];
	
    [self.view bringSubviewToFront:mainToolbar];
    
    lastHideTime = [NSDate date];
    [self updateScrollViewContentViews];
    lastAppearSize = CGSizeZero;
    
    [self performSelector:@selector(showDocument:) withObject:nil afterDelay:0];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"loadNewDocumentReader" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
}

-(void)updatePagebarByCorrespondence{
//    CGRect viewRect = self.view.bounds;
//    CGRect pagebarRect = viewRect;
//	pagebarRect.size.height = PAGEBAR_HEIGHT;
//	pagebarRect.origin.y = (viewRect.size.height - PAGEBAR_HEIGHT);
//    mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect  Document:document CorrespondenceId:self.correspondenceId MenuId:self.menuId AttachmentId:self.attachmentId]; // At bottom
//    mainPagebar.delegate = self;
    
	[self.view addSubview:mainPagebar];
   // [mainPagebar hidePagebar];
}

#pragma mark ReaderContentViewDelegate methods

- (void)contentView:(ReaderContentView *)contentView touchesBegan:(NSSet *)touches
{
	if ((mainToolbar.hidden == NO) || (mainPagebar.hidden == NO))
	{
		if (touches.count == 1) // Single touches only
		{
			UITouch *touch = [touches anyObject]; // Touch info

			CGPoint point = [touch locationInView:self.view]; // Touch location

			CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);

			if (CGRectContainsPoint(areaRect, point) == false) return;
		}

		[mainToolbar hideToolbar];
        //[mainPagebar hidePagebar]; // Hide
        if( mainPagebar.hidden==false){
        [mainPagebar removeFromSuperview];
            mainPagebar.hidden=true;
        }
[self.noteContainer removeFromSuperview];
		lastHideTime = [NSDate date];
	}
}

#pragma mark ReaderMainToolbarDelegate methods
//-(void)AcceptReject:(NSString*)note viewController:(CommentViewController *)viewcontroller action:(NSString *)action{
//    @try{
//        
//        CCorrespondence *correspondence;
//        if(self.menuId!=100){
//            correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
//        }else{
//            correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
//        }
//        
//        
//        NSString* params = [NSString stringWithFormat:@"action=%@&correspondenceId=%@&token=%@&transferId=%@&note=%@&inboxId=%@",action,correspondence.Id,mainDelegate.user.token,correspondence.TransferId,note,correspondence.inboxId];
//        
//        NSString* url = [NSString stringWithFormat:@"http://%@?%@",mainDelegate.serverUrl,params];
//        if(!mainDelegate.isOfflineMode){
//        NSURL *xmlUrl = [NSURL URLWithString:url];
//        NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
//        NSString *validationResultAction=[CParser ValidateWithData:xmlData];
//        
//        if(![validationResultAction isEqualToString:@"OK"])
//        {
//            
//                [self ShowMessage:validationResultAction];
//            
//        }else {
//            
//            NSString* correspondenceUrl;
//            NSString* showthumb;
//            if (mainDelegate.ShowThumbnail)
//                showthumb=@"true";
//            else
//                showthumb=@"false";
//            if(mainDelegate.SupportsServlets)
//          
//                correspondenceUrl=[NSString stringWithFormat:@"http://%@?action=GetCorrespondences&token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,[correspondence.inboxId intValue],0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
//            else
//                correspondenceUrl=[NSString stringWithFormat:@"http://%@/GetCorrespondences?token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,[correspondence.inboxId intValue],0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
//            
//            
//          
//            NSURL *xmlUrl = [NSURL URLWithString:correspondenceUrl];
//            NSData *menuXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
//            NSMutableDictionary *correspondences=[CParser loadCorrespondencesWithData:menuXmlData];
//          
//            ((CMenu*)mainDelegate.user.menu[mainDelegate.inboxForArchiveSelected]).correspondenceList=[correspondences objectForKey:[NSString stringWithFormat:@"%d",[correspondence.inboxId intValue]]];
//          
//            mainDelegate.searchModule.correspondenceList = [correspondences objectForKey:[NSString stringWithFormat:@"%d",[correspondence.inboxId intValue]]];
//           
//            [self ShowMessage:[NSString stringWithFormat:@"Action %@ successfuly done.",action]];
//            
//            
//            
//            
//            
//        }}else{
//            [CParser cacheOfflineActions:correspondence.Id url:url action:action];
//        }
//    }
//    @catch (NSException *ex) {
//        [FileManager appendToLogView:@"ActionsTableViewController" function:@"executeAction" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
//    }
//}
-(void)destinationSelected:(CDestination*)dest withRouteLabel:(CRouteLabel*)routeLabel PublicNote:(NSString*)Pnote PrivateNote:(NSString*)note withDueDate:(NSString*)date viewController:(TransferViewController*)viewcontroller{
    
	@try{
	CUser* userTemp =  mainDelegate.user ;
       
    CCorrespondence *correspondence;
    if(self.menuId!=100){
        correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
    }else{
        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    }
     // CAttachment *currentDoc=correspondence.attachmentsList[self.attachmentId];
        NSString* url;
    if(mainDelegate.SupportsServlets)
        url = [NSString stringWithFormat:@"http://%@?action=TransferCorrespondence&token=%@&correspondenceId=%@&destinationId=%@&purposeId=%@&dueDate=%@&publicNote=%@&privateNote=%@",mainDelegate.serverUrl,userTemp.token,correspondence.TransferId,dest.rid,routeLabel.labelId,date,[Pnote stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[note stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    else
        url = [NSString stringWithFormat:@"http://%@/TransferCorrespondence?token=%@&correspondenceId=%@&destinationId=%@&purposeId=%@&dueDate=%@&publicNote=%@&privateNote=%@",mainDelegate.serverUrl,userTemp.token,correspondence.TransferId,dest.rid,routeLabel.labelId,date,[Pnote stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[note stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
        if(!mainDelegate.isOfflineMode){
            
            if(self.menuId !=100)
                [((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList removeObjectAtIndex:self.correspondenceId];
            NSURL *xmlUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
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
                    
                    correspondenceUrl=[NSString stringWithFormat:@"http://%@?action=GetCorrespondences&token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,[correspondence.inboxId intValue],0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
                else
                    correspondenceUrl=[NSString stringWithFormat:@"http://%@/GetCorrespondences?token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,[correspondence.inboxId intValue],0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
  
        NSURL *xmlUrl = [NSURL URLWithString:correspondenceUrl];
        NSData *menuXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
        
        NSMutableDictionary *correspondences=[CParser loadCorrespondencesWithData:menuXmlData];
        mainDelegate.searchModule.correspondenceList = [correspondences objectForKey:[NSString stringWithFormat:@"%d",[correspondence.inboxId intValue]]];
        
        
                [self ShowMessage:NSLocalizedString(@"Alert.ActionSuccess",@"Action successfuly done.")];
        
            }	 // Dismiss the ReaderViewController
            
        }
        else{
            [CParser cacheOfflineActions:correspondence.Id url:url action:@"TransferCorrespondence"];
            [CParser DeleteCorrespondence:correspondence.Id inboxId:correspondence.inboxId];
            NSMutableDictionary *correspondences=[CParser LoadCorrespondences:[correspondence.inboxId intValue]];
            mainDelegate.searchModule.correspondenceList = [correspondences objectForKey:[NSString stringWithFormat:@"%d",[correspondence.inboxId intValue]]];
            
            
        }
        
    if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
	{
        
        [viewcontroller dismissViewControllerAnimated:YES  completion:^{
            [delegate dismissReaderViewController:self];
        }];
    }
	 
        
    }
   // }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"destinationSelected" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
   
   
}

-(void)UploadAnnotations:(NSString*) docId{
    @try{
        if (mainDelegate==nil) mainDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];

        [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Saving",@"Saving ...") maskType:SVProgressHUDMaskTypeBlack];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSString* urlString;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *documentsPath = [documentsDirectory
                                   stringByAppendingPathComponent:@"annotations.xml"];
        NSLog(@"%@",documentsPath);
        
        NSLog(@"Saving xml data to %@...", documentsPath);
        
        NSData *imageData= [NSData dataWithContentsOfFile:documentsPath] ;
        
       
        

        // setting up the URL to post to
        if(mainDelegate.SupportsServlets)
            urlString = [NSString stringWithFormat:@"http://%@",mainDelegate.serverUrl];
        else
            urlString = [NSString stringWithFormat:@"http://%@/SaveAnnotations",mainDelegate.serverUrl];
       
        // setting up the request object now
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        
        // action parameter
        if(mainDelegate.SupportsServlets){
            // action parameter
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"action\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"SaveAnnotations" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        
        
        
        // file
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"annotations\"; filename=\".xml\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        // text parameter
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"correspondenceId\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[docId dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        // close form
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // set request body
        [request setHTTPBody:body];
        
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            NSString *validationResult=[CParser ValidateWithData:returnData];
            if (mainDelegate==nil) mainDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
            if(!mainDelegate.isOfflineMode){
                if(![validationResult isEqualToString:@"OK"]){
                    
                    if([validationResult isEqualToString:@"Cannot access to the server"]){
                        [self ShowMessage:validationResult];
                    }
                    else{
                        [self ShowMessage:validationResult];
                    }
                }else{
                    [self ShowMessage:@"Saved Successfully"];
                }
            }else{
                [self ShowMessage:@"Saved Successfully"];
            }
            
        });
        
    });
}
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"uploadXml" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
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



-(void)uploadXml:(NSString*) docId{
    
    @try{
        if (mainDelegate==nil) mainDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];

        [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Saving",@"Saving ...") maskType:SVProgressHUDMaskTypeBlack];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                       NSString* urlString;

                        
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory
                               stringByAppendingPathComponent:@"annotations.xml"];
    NSLog(@"%@",documentsPath);
  
    NSLog(@"Saving xml data to %@...", documentsPath);
   
    NSData *imageData= [NSData dataWithContentsOfFile:documentsPath] ;
    // setting up the URL to post to
        // setting up the URL to post to
        if(mainDelegate.SupportsServlets)
            urlString = [NSString stringWithFormat:@"http://%@",mainDelegate.serverUrl];
        else
            urlString = [NSString stringWithFormat:@"http://%@/UpdateDocument",mainDelegate.serverUrl];
   	
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
        [body appendData:[@"UpdateDocument" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    }
    
    // file
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"userfile\"; filename=\".xml\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // text parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"correspondenceId\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[docId dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
   
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                            NSString *validationResult=[CParser ValidateWithData:returnData];
                            if (mainDelegate==nil) mainDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
                            if(!mainDelegate.isOfflineMode){
                                if(![validationResult isEqualToString:@"OK"]){
                                    
                                    if([validationResult isEqualToString:@"Cannot access to the server"]){
                                        [self ShowMessage:validationResult];
                                    }
                                    else{
                                        [self ShowMessage:validationResult];
                                    }
                                }else{
                                    [self ShowMessage:@"Saved Successfully"];
                                }
                            }else{
                                [self ShowMessage:@"Saved Successfully"];
                            }
                            
                        });
                        
                    });
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"uploadXml" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
}


- (void)dismiss {
	[SVProgressHUD dismiss];
}

- (void)increaseProgress{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Signing",@"Signing ...") maskType:SVProgressHUDMaskTypeBlack];

}


typedef enum{
    Highlight,Sign,Note,Erase,Save
    
} AnnotationsType;

-(void)openmanagesignature{
    
                ManageSignatureViewController *signatureView = [[ManageSignatureViewController alloc] initWithFrame:CGRectMake(300, 200, 400, 350) ];
    
    
                signatureView.modalPresentationStyle = UIModalPresentationFormSheet;
                signatureView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:signatureView animated:YES completion:nil];
                UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
                if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
                    signatureView.view.superview.frame = CGRectMake(150, 200, 400, 350);
                } else {
                   signatureView.view.superview.frame = CGRectMake(300, 200, 400, 350);
                }
    
    
            signatureView.delegate=self;
}

-(void)performaAnnotation:(int)annotation{
    @try{
    [self.notePopController dismissPopoverAnimated:YES];
    switch (annotation) {
        case Highlight:
            mainDelegate.isAnnotated=YES;
            [m_pdfview setBtnHighlight:YES];
            [m_pdfview setBtnNote:NO];
            [m_pdfview setBtnSign:NO];
            [m_pdfview setBtnErase:NO];
            break;
        case Sign:{
            mainDelegate.isAnnotated=YES;
            [m_pdfview setBtnHighlight:NO];
            [m_pdfview setBtnNote:NO];
            [m_pdfview setBtnSign:YES];
            UIAlertView *alertOk=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Info",@"Info") message:NSLocalizedString(@"Alert.Sign",@"Click on pdf document to sign") delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
            [alertOk show];

            
        }
            break;
        case Note:{
            CCorrespondence *correspondence;
            if(self.menuId!=100){
                correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
            }else{
                correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
            }
            CAttachment *fileToOpen=correspondence.attachmentsList[self.attachmentId];
            [m_pdfview setAttachmentId:fileToOpen.AttachmentId.intValue];
            
            [m_pdfview setBtnHighlight:NO];
            [m_pdfview setBtnNote:YES];
            [m_pdfview setBtnSign:NO];
            [m_pdfview setBtnErase:NO];
            mainDelegate.isAnnotated=YES;
            
            NoteAlertView *noteView = [[NoteAlertView alloc] initWithFrame:CGRectMake(0, 300, 400, 250) fromComment:NO];
            noteView.modalPresentationStyle = UIModalPresentationFormSheet;
            noteView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:noteView animated:YES completion:nil];
            noteView.view.superview.frame = CGRectMake(300, 300, 400, 250);
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
                noteView.view.superview.frame = CGRectMake(150, 300, 400, 250);
            } else {
                noteView.view.superview.frame = CGRectMake(300, 300, 400, 250);
            }

            noteView.delegate=self;
        }
            break;
        case Erase:
            [m_pdfview setBtnHighlight:NO];
            [m_pdfview setBtnNote:NO];
            [m_pdfview setBtnSign:NO];
            [m_pdfview setBtnErase:YES];
            break;
        case Save:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Warning")
                                                            message:NSLocalizedString(@"Alert.SaveDoc",@"Saving annotaions will override the document. Are you sure you want to save?")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"NO",@"NO")
                                                  otherButtonTitles:NSLocalizedString(@"YES",@"YES"), nil];
            alert.tag=TAG_SAVE;
            [alert show];
        }
            break;
     
        default:
            break;
    }
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"performaAnnotation" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
}



-(void)saveAnnotation

{
    

   
    mainDelegate.isAnnotated=NO;
    
    @try {
        
        CCorrespondence *correspondence;
        
        
        if(self.menuId!=100){
            
            correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
            
        }else{
            
            correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
            
        }
        
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
        
        
        
        CAttachment *attachment=thumbnailrarray[self.attachmentId];
        
        if(![mainDelegate.AnnotationsMode isEqualToString:@"CustomAnnotations"]){
            
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Processing",@"Processing ...") maskType:SVProgressHUDMaskTypeBlack];
            //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            //                dispatch_async(dispatch_get_main_queue(), ^{
            //                });
            //
            //            });
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                
                NSString* dir  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                
                NSString* path = [dir stringByAppendingString:@"/FoxitSaveAnnotation.pdf"];
                
                
                
                
                
                NSData* annotData= [NSData dataWithContentsOfFile:path];
                
                [Base64 initialize];
                
                NSString *annotString64=[Base64 encode:annotData];
                
                NSError *error;
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                     
                                                                     NSUserDomainMask, YES);
                
                NSString *documentsDirectory = [paths objectAtIndex:0];
                
                NSString *documentsPath = [documentsDirectory
                                           
                                           stringByAppendingPathComponent:@"annotations.xml"];
                
                
                
                NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:documentsPath];
                
                
                
                GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
                
                BOOL isFound=NO;
                
                GDataXMLElement* rootEl  = [doc rootElement];
                
                
                
                if(rootEl==nil){
                    
                    rootEl =[GDataXMLNode elementWithName:@"Documents" stringValue:@""];
                    
                    
                    
                }
                
                
                
                NSArray *allDocuments=[rootEl elementsForName:@"Document"];
                
                GDataXMLElement *docEl;
                
                if(allDocuments.count>0){
                    
                    for(docEl in allDocuments){
                        
                        
                        
                        NSArray *correspondenceIds=[docEl elementsForName:@"CorrespondenceId"];
                        
                        GDataXMLElement *correspondenceIdEl=[correspondenceIds objectAtIndex:0];
                        
                        
                        
                        NSArray *docIds=[docEl elementsForName:@"DocId"];
                        
                        GDataXMLElement *docIdEl=[docIds objectAtIndex:0];
                        
                        
                        
                        if([correspondenceIdEl.stringValue isEqualToString:correspondence.Id] && [docIdEl.stringValue isEqualToString:attachment.docId]){
                            
                            isFound=YES;
                            
                            NSArray *contents=[docEl elementsForName:@"Content"];
                            
                            GDataXMLElement *contentEl;
                            
                            if(contents.count>0){
                                
                                contentEl=[contents objectAtIndex:0];
                                
                                contentEl.stringValue=annotString64;
                                
                            }
                            
                        }
                        
                        
                        
                        
                        
                    }
                    
                    
                    
                }
                
                
                
                if(isFound==NO){
                    
                    docEl=[GDataXMLNode elementWithName:@"Document" stringValue:@""];
                    
                    
                    
                    GDataXMLElement *correspondenceIdEl=[GDataXMLNode elementWithName:@"CorrespondenceId" stringValue:correspondence.Id];
                    
                    [docEl addChild:correspondenceIdEl];
                    
                    GDataXMLElement *docIdEl=[GDataXMLNode elementWithName:@"DocId" stringValue:attachment.docId];
                    
                    [docEl addChild:docIdEl];
                    
                    GDataXMLElement *urlEl=[GDataXMLNode elementWithName:@"Url" stringValue:attachment.url];
                    
                    [docEl addChild:urlEl];
                    
                    GDataXMLElement *contentEl=[GDataXMLNode elementWithName:@"Content" stringValue:annotString64];
                    
                    [docEl addChild:contentEl];
                    
                    [rootEl addChild:docEl];
                    
                }
                
                
                
                GDataXMLDocument *document2 = [[GDataXMLDocument alloc]
                                               
                                               initWithRootElement:rootEl] ;
                
                NSData *xmlData2 = document2.XMLData;
                
                
                
                NSLog(@"Saving xml data to %@...", documentsPath);
                
                [xmlData2 writeToFile:documentsPath atomically:YES];
                
                
                
                
                
                
                
                NSFileManager* fileManager=[NSFileManager defaultManager];
                
                
                
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:path] ){
                    
                    [fileManager removeItemAtPath:attachment.tempPdfLocation error:nil];
                    
                    [[NSFileManager defaultManager] copyItemAtPath:path toPath:attachment.tempPdfLocation error:nil];
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if(!mainDelegate.isOfflineMode)
                        [self uploadXml:correspondence.Id];
                    else{
                        [CParser cacheBuiltInActions:correspondence.Id action:@"annotations" xml:nil];
                        [SVProgressHUD dismiss];
                    }
                });
                
            });
        }
        
        else{
            mainDelegate.isAnnotated=NO;
            @try {
                
                [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Processing",@"Processing ...") maskType:SVProgressHUDMaskTypeBlack];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    CCorrespondence *correspondence;
                    if(self.menuId!=100){
                        correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
                    }else{
                        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
                    }
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                         
                                                                         NSUserDomainMask, YES);
                    
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *documentsPath = [documentsDirectory stringByAppendingPathComponent:@"annotations.xml"];
                    GDataXMLElement* rootEl =[GDataXMLNode elementWithName:@"Annotations" stringValue:@""];
                    if(mainDelegate.Notes.count>0 || mainDelegate.Highlights.count>0){
                        GDataXMLElement *Height=[GDataXMLNode elementWithName:@"Height" stringValue:[NSString stringWithFormat:@"%f",[m_pdfview getHeight]]];
                        GDataXMLElement *Width=[GDataXMLNode elementWithName:@"Width" stringValue:[NSString stringWithFormat:@"%f",[m_pdfview getWidth]]];
                        GDataXMLElement * pageinfo=[GDataXMLNode elementWithName:@"PageInfo" stringValue:@""];
                        GDataXMLElement * Size=[GDataXMLNode elementWithName:@"Size" stringValue:@""];
                        
                        
                        [Size addChild:Height];
                        [Size addChild:Width];
                        [pageinfo addChild:Size];
                        [rootEl addChild:pageinfo];}
                    
                    GDataXMLElement * NotesEl=[GDataXMLNode elementWithName:@"Notes" stringValue:@""];
                    GDataXMLElement * HighlightsEl=[GDataXMLNode elementWithName:@"Highlights" stringValue:@""];
                    
                    for(note* note in mainDelegate.Notes){
                        GDataXMLElement *docEl=[GDataXMLNode elementWithName:@"Note" stringValue:@""];
                        GDataXMLElement* noteAttribute=[GDataXMLElement attributeWithName:@"status" stringValue:note.status];
                        [docEl addAttribute:noteAttribute];
                        GDataXMLElement *AttachmentId=[GDataXMLNode elementWithName:@"AttachmentId" stringValue:[NSString stringWithFormat:@"%d",note.AttachmentId]];
                        [docEl addChild:AttachmentId];
                        
                        GDataXMLElement *pgnb=[GDataXMLNode elementWithName:@"page" stringValue:[NSString stringWithFormat:@"%d",note.PageNb]];
                        [docEl addChild:pgnb];
                        
                        GDataXMLElement *x=[GDataXMLNode elementWithName:@"noteX" stringValue:[NSString stringWithFormat:@"%f",note.abscissa]];
                        [docEl addChild:x];
                        
                        GDataXMLElement *y=[GDataXMLNode elementWithName:@"noteY" stringValue:[NSString stringWithFormat:@"%f",note.ordinate]];
                        [docEl addChild:y];
                        
                        GDataXMLElement *notee=[GDataXMLNode elementWithName:@"noteMSG" stringValue:note.note];
                        [docEl addChild:notee];
                        
                        [NotesEl addChild:docEl];
                        
                    }
                    for(HighlightClass* obj in mainDelegate.Highlights){
                        GDataXMLElement *docEl=[GDataXMLNode elementWithName:@"Highlight" stringValue:@""];
                        GDataXMLElement* highlightAttribute=[GDataXMLElement attributeWithName:@"status" stringValue:obj.status];
                        [docEl addAttribute:highlightAttribute];
                        GDataXMLElement *pgnb=[GDataXMLNode elementWithName:@"page" stringValue:[NSString stringWithFormat:@"%d",obj.PageNb]];
                        [docEl addChild:pgnb];
                        
                        GDataXMLElement *AttachmentId=[GDataXMLNode elementWithName:@"AttachmentId" stringValue:[NSString stringWithFormat:@"%d",obj.AttachmentId]];
                        [docEl addChild:AttachmentId];
                        GDataXMLElement *x=[GDataXMLNode elementWithName:@"HighlightX1" stringValue:[NSString stringWithFormat:@"%f",obj.abscissa]];
                        [docEl addChild:x];
                        
                        GDataXMLElement *y=[GDataXMLNode elementWithName:@"HighlightY1" stringValue:[NSString stringWithFormat:@"%f",obj.ordinate]];
                        [docEl addChild:y];
                        
                        GDataXMLElement *x1=[GDataXMLNode elementWithName:@"HighlightX2" stringValue:[NSString stringWithFormat:@"%f",obj.x1]];
                        [docEl addChild:x1];
                        
                        GDataXMLElement *y1=[GDataXMLNode elementWithName:@"HighlightY2" stringValue:[NSString stringWithFormat:@"%f",obj.y1]];
                        [docEl addChild:y1];
                        [HighlightsEl addChild:docEl];
                        
                    }
                    [rootEl addChild:NotesEl];
                    [rootEl addChild:HighlightsEl];
                    
                    GDataXMLDocument *document2 = [[GDataXMLDocument alloc] initWithRootElement:rootEl] ;
                    
                    NSData *xmlData2 = document2.XMLData;
                    
                    [xmlData2 writeToFile:documentsPath atomically:YES];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(!mainDelegate.isOfflineMode)
                            [self UploadAnnotations:correspondence.Id];
                        else{
                            [CParser cacheBuiltInActions:correspondence.Id action:@"CustomAnnotations" xml:nil];
                            [SVProgressHUD dismiss];

                        }
                        [mainDelegate.Highlights removeAllObjects];
                        [mainDelegate.Notes removeAllObjects];
                    });
                });
            }
            
            @catch (NSException *ex) {
                
                [FileManager appendToLogView:@"ReaderViewController" function:@"saveAnnotation" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
                
            }
            
        }
        
        
    }
    
    @catch (NSException *ex) {
        
        [FileManager appendToLogView:@"ReaderViewController" function:@"saveAnnotation" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
        
    }
    
    
}
-(void)executeAction:(NSString*)action note:(NSString*)Note movehome:(BOOL)movehome
{
    
    @try{
        CCorrespondence *correspondence;
        if(self.menuId!=100){
            correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
        }else{
            correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
        }
        NSString* params;
        NSString* url;
        if(mainDelegate.SupportsServlets){
            params=[NSString stringWithFormat:@"action=ExecuteCustomActions&token=%@&correspondenceId=%@&TransferId=%@&actionType=%@&note=%@", mainDelegate.user.token,correspondence.Id,correspondence.TransferId,action,Note];
            url = [NSString stringWithFormat:@"http://%@?%@",mainDelegate.serverUrl,params];
            
        }
        else{
            params=[NSString stringWithFormat:@"ExecuteCustomActions?token=%@&correspondenceId=%@&TransferId=%@&actionType=%@&note=%@", mainDelegate.user.token,correspondence.Id,correspondence.TransferId,action,Note];
            url = [NSString stringWithFormat:@"http://%@/%@",mainDelegate.serverUrl,params];
            
        }
        if(!mainDelegate.isOfflineMode){
            NSURL *xmlUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
            NSString *validationResultAction=[CParser ValidateWithData:xmlData];
            
            if(![validationResultAction isEqualToString:@"OK"])
            {
                
                [self ShowMessage:validationResultAction];
                
            }else {
                if(movehome){
                    NSString* correspondenceUrl;
                    NSString* showthumb;
                    if (mainDelegate.ShowThumbnail)
                        showthumb=@"true";
                    else
                        showthumb=@"false";
                    if(mainDelegate.SupportsServlets)
                        
                        correspondenceUrl=[NSString stringWithFormat:@"http://%@?action=GetCorrespondences&token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.selectedInbox,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
                    else
                        correspondenceUrl=[NSString stringWithFormat:@"http://%@/GetCorrespondences?token=%@&inboxId=%d&index=%d&pageSize=%d&language=%@&showThumbnails=%@",mainDelegate.serverUrl,mainDelegate.user.token,mainDelegate.selectedInbox,0,mainDelegate.SettingsCorrNb,mainDelegate.IpadLanguage,showthumb];
                    
                    
                    NSURL *xmlUrl = [NSURL URLWithString:correspondenceUrl];
                    NSData *menuXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
                    
                    NSMutableDictionary *correspondences=[CParser loadCorrespondencesWithData:menuXmlData];
                    
                    
                    mainDelegate.searchModule.correspondenceList = [correspondences objectForKey:[NSString stringWithFormat:@"%d",mainDelegate.selectedInbox]];
                    
                    
                    
                    
                    
                }
                [self ShowMessage:NSLocalizedString(@"Alert.ActionSuccess",@"Action successfuly done.")];
                
            }
        }else{
            [CParser cacheOfflineActions:correspondence.Id url:url action:action];
            if(movehome){
                NSMutableDictionary *correspondences=[CParser LoadCorrespondences:[correspondence.inboxId intValue]];
                mainDelegate.searchModule.correspondenceList = [correspondences objectForKey:[NSString stringWithFormat:@"%d",[correspondence.inboxId intValue]]];
            }
            
        }
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"MoreTableViewController" function:@"executeAction" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    
}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar homeButton:(UIButton *)button
{
    if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
	{
        
		[delegate dismissReaderViewController:self]; // Dismiss the ReaderViewController
    }
    
}
-(void)ShowHidePageBar{
    
    if(folderPagebar.hidden==YES){
        if(mainPagebar.hidden==YES||mainPagebar==nil){
            folderPagebar.hidden=false;
            
            [self.view bringSubviewToFront:folderPagebar];
        }
        else{
            folderPagebar.hidden = true;
            mainPagebar.hidden=true;
            [mainPagebar removeFromSuperview];
            
        }
    }
    else{
        [mainPagebar removeFromSuperview];
        mainPagebar.hidden=true;
        folderPagebar.hidden = true;
        
    }
    
    
}
-(void)ShowUploadAttachmentDialog{
    if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
    {   CCorrespondence *correspondence;
        if(self.menuId!=100){
            correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
        }else{
            correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
        }
        UploadControllerDialog *uploadDialog = [[UploadControllerDialog alloc] initWithFrame:CGRectMake(300, 200, 400, 150)];
        uploadDialog.modalPresentationStyle = UIModalPresentationFormSheet;
        uploadDialog.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        uploadDialog.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self presentViewController:uploadDialog animated:YES completion:nil];
        uploadDialog.view.superview.frame = CGRectMake(300, 200, 400, 150);
        uploadDialog.CorrespondenceId=correspondence.Id;
        uploadDialog.delegate=self;
    }
}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar attachmentButton:(UIButton *)button
{
    
    if ( (mainPagebar.hidden == NO))
    {
        folderPagebar.hidden = true;
        mainPagebar.hidden=true;
        [mainPagebar removeFromSuperview];
    }
    CCorrespondence *correspondence;
    if(self.menuId!=100){
        correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
    }else{
        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    }
    if (correspondence.AttachmentsListMenu.count<=0) {
        [self ShowHidePageBar];
    }
    else{
        AttachmentViewController *uploadViewController=[[AttachmentViewController alloc]initWithStyle:UITableViewStylePlain];
        self.notePopController = [[UIPopoverController alloc] initWithContentViewController:uploadViewController];
        self.notePopController.popoverContentSize = CGSizeMake(300, 50*correspondence.AttachmentsListMenu.count);
        [self.notePopController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        uploadViewController.actions=correspondence.AttachmentsListMenu;
        uploadViewController.delegate=self;
    }
    
}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar lockButton:(UIButton *)button message:(NSString*)msg
{
    [self ShowMessage:msg];
}




- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar annotationButton:(UIButton *)button{
    if ( (mainPagebar.hidden == NO))
    {
        folderPagebar.hidden = true;
        mainPagebar.hidden=true;
        [mainPagebar removeFromSuperview];
        
    }
	AnnotationsController* noteController = [[AnnotationsController alloc] initWithStyle:UITableViewStylePlain];
    CCorrespondence *correspondence;
    CAttachment *attachment;
    
    
    if(self.menuId!=100){
        correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
    }else{
        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    }	NSMutableArray *annotProperties=[[NSMutableArray alloc]init];
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
    
    attachment = [thumbnailrarray objectAtIndex:mainDelegate.attachmentSelected];
    
    BOOL found=NO;
    
    if ([attachment.title rangeOfString:@".pdf"].location != NSNotFound) {
        found = YES;
    }
    
    for(NSString*name in correspondence.AnnotationsList){
        [annotProperties addObject:name];
    }
	noteController.properties=annotProperties;
	noteController.delegate=self;
	self.notePopController = [[UIPopoverController alloc] initWithContentViewController:noteController];
    int x=0;
    if([mainDelegate.SignMode isEqualToString:@"BuiltInSign"])
        x=50;
    else
        x=100;
    self.notePopController.popoverContentSize = CGSizeMake(250, 50*annotProperties.count+x);
	[self.notePopController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar transferButton:(UIButton *)button{
    if ( (mainPagebar.hidden == NO))
    {
        folderPagebar.hidden = true;
        mainPagebar.hidden=true;
        [mainPagebar removeFromSuperview];
    }
    TransferViewController *transferView = [[TransferViewController alloc] initWithFrame:CGRectMake(0, 200, 450, 370)];
    transferView.modalPresentationStyle = UIModalPresentationFormSheet;
    transferView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:transferView animated:YES completion:nil];
    transferView.view.superview.frame = CGRectMake(300, 200, 450, 470); //it's important to do this after presentModalViewController
    // noteView.view.superview.center = self.view.center;
    transferView.delegate=self;
}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar SignActionButton:(UIButton *)button{
    if ( (mainPagebar.hidden == NO))
    {
        folderPagebar.hidden = true;
        mainPagebar.hidden=true;
        [mainPagebar removeFromSuperview];
    }
    CCorrespondence *correspondence;
    if(self.menuId!=100){
        correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
    }else{
        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    }
       SignatureController *SignController=[[SignatureController alloc]initWithStyle:UITableViewStylePlain];
    self.notePopController = [[UIPopoverController alloc] initWithContentViewController:SignController];
    self.notePopController.popoverContentSize = CGSizeMake(250, 50*correspondence.SignActions.count);
    [self.notePopController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    SignController.document=document;
    SignController.m_pdfview=m_pdfview;
    SignController.m_pdfdoc = m_pdfdoc;
    SignController.correspondenceId=correspondence.Id;
    SignController.SignAction=correspondence.SignActions;
    SignController.delegate=self;
}
-(void)tappedInToolbar:(ReaderMainToolbar *)toolbar actionButton:(UIButton *)button{
    NSMutableArray *actionProperties=[[NSMutableArray alloc]init];
    CCorrespondence *correspondence;
    for(id key in correspondence.toolbar){
        if(([key isEqualToString:@"Accept"] ||[key isEqualToString:@"Reject"] || [key isEqualToString:@"Send"] || [key isEqualToString:@"Sign and Send"] )&&[[correspondence.toolbar objectForKey:key] isEqualToString:@"YES"]){
            [actionProperties addObject:key];
        }
    }
    // CCorrespondence *correspondence;
    if(self.menuId!=100){
        correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
    }else{
        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    }
    SignatureController *newactionViewController=[[SignatureController alloc]initWithStyle:UITableViewStylePlain];
    // newactionViewController.action=correspondence.actions;
    self.notePopController = [[UIPopoverController alloc] initWithContentViewController:newactionViewController];
	
	//size as needed
	self.notePopController.popoverContentSize = CGSizeMake(250, 50*correspondence.actions.count);
    
    
	[self.notePopController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    newactionViewController.document=document;
    newactionViewController.delegate=self;
}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar SaveButton:(UIButton *)button
{
    [self saveAnnotation];
    
}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar MoreButton:(UIButton *)button
{
    if ( (mainPagebar.hidden == NO))
    {
        folderPagebar.hidden = true;
        mainPagebar.hidden=true;
        [mainPagebar removeFromSuperview];
    }
    CCorrespondence *correspondence;
    if(self.menuId!=100){
        correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
    }else{
        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    }
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
    
    CAttachment *file=thumbnailrarray[self.attachmentId];
    
    MoreTableViewController* actionController = [[MoreTableViewController alloc] initWithStyle:UITableViewStylePlain];
    actionController.document=document;
	actionController.correspondenceId=correspondence.Id;
    actionController.docId=file.docId;
	actionController.actions=correspondence.actions;
    
	self.notePopController = [[UIPopoverController alloc] initWithContentViewController:actionController];
	
	//size as needed
	self.notePopController.popoverContentSize = CGSizeMake(250, 50*correspondence.actions.count);
    
    
	[self.notePopController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    actionController.delegate=self;
    
}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar CustomButton:(UIButton *)button Item:(ToolbarItem *)item ShowItems:(BOOL)ShowItems{
    if ( (mainPagebar.hidden == NO))
    {
        folderPagebar.hidden = true;
        mainPagebar.hidden=true;
        [mainPagebar removeFromSuperview];
    }
    if(!ShowItems){
        CAction* action = [[CAction alloc] initWithLabel:item.Label action:item.Name popup:item.popup backhome:item.backhome Custom:item.Custom];
        [self PopUpCommentDialog:nil Action:action document:nil];
    }
    else{
        CCorrespondence *correspondence;
        if(self.menuId!=100){
            correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
        }else{
            correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
        }
        CustomViewController *customViewController=[[CustomViewController alloc]initWithStyle:UITableViewStylePlain];
        customViewController.actions=[correspondence.CustomItemsList objectForKey:item.Name];
        
        self.notePopController = [[UIPopoverController alloc] initWithContentViewController:customViewController];
        self.notePopController.popoverContentSize = CGSizeMake(300, 50*customViewController.actions.count);
        [self.notePopController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        customViewController.actions=[correspondence.CustomItemsList objectForKey:item.Name];
        customViewController.delegate=self;
        
    }
    
}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar actionsButton:(UIButton *)button
{
    if ( (mainPagebar.hidden == NO))
    {
        folderPagebar.hidden = true;
        mainPagebar.hidden=true;
        [mainPagebar removeFromSuperview];
    }
    CCorrespondence *correspondence;
    if(self.menuId!=100){
        correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
    }else{
        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    }
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
    
    CAttachment *file=thumbnailrarray[self.attachmentId];
    
    ActionsViewController* actionController = [[ActionsViewController alloc] initWithStyle:UITableViewStylePlain];
    actionController.document=document;
	actionController.correspondenceId=correspondence.Id;
    actionController.docId=file.docId;
	actionController.actions=correspondence.ActionsMenu;
    
	self.notePopController = [[UIPopoverController alloc] initWithContentViewController:actionController];
	
	//size as needed
	self.notePopController.popoverContentSize = CGSizeMake(250, 50*correspondence.ActionsMenu.count);
    
    
	[self.notePopController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    actionController.delegate=self;
    
}
-(void)PopUpCommentDialog:(UITableViewController*)viewcontroller Action:(CAction *)action document:(ReaderDocument*)document1{
    if ( (mainPagebar.hidden == NO))
    {
        folderPagebar.hidden = true;
        mainPagebar.hidden=true;
        [mainPagebar removeFromSuperview];
    }
    if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
    {
        [self.notePopController dismissPopoverAnimated:NO];
        CommentViewController *AcceptView = [[CommentViewController alloc] initWithActionName:CGRectMake(0, 200, 450, 370)  Action:action];
        AcceptView.modalPresentationStyle = UIModalPresentationFormSheet;
        AcceptView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:AcceptView animated:YES completion:nil];
        AcceptView.view.superview.frame = CGRectMake(300, 200, 450, 370); //it's important to do this
        AcceptView.delegate=self;
        AcceptView.Action=action;
        AcceptView.document =document1;
    }
}
-(void)dismissPopUp:(UITableViewController*)viewcontroller{
    [self.notePopController dismissPopoverAnimated:NO];
    
}
-(void)dismissUpload:(UIViewController*)viewcontroller{
    if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
	{
        
        [viewcontroller dismissViewControllerAnimated:YES  completion:^{
           // [delegate dismissReaderViewController:self];
        }];
    }
    
}

-(void)movehome:(TransferViewController *)viewcontroller{
    
    if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
    {
        [self.notePopController dismissPopoverAnimated:NO];
        [delegate dismissReaderViewController:self]; // Dismiss the ReaderViewController
    }
    
}
-(void)ActionMoveHome:(CommentViewController *)viewcontroller{
    if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
	{
        UINavigationController *navController=[mainDelegate.splitViewController.viewControllers objectAtIndex:1];
        [navController setNavigationBarHidden:YES animated:YES];
        
        [delegate dismissReaderViewController:self];
        SearchResultViewController *searchResultViewController = [[SearchResultViewController alloc]initWithStyle:UITableViewStylePlain];
        [navController pushViewController:searchResultViewController animated:YES];
        
        
    }
    
}

-(void)closeMetadata{
    [mainToolbar hideToolbar];
    //[mainPagebar hidePagebar];
    if( mainPagebar.hidden==false){
        [mainPagebar removeFromSuperview];
        mainPagebar.hidden=true;
    }
    [self.noteContainer removeFromSuperview];
    [metadataContainer removeFromSuperview];
    m_pdfview.frame=CGRectMake ((self.view.bounds.size.width-self.view.bounds.size.width/1.75)/2, 5, self.view.bounds.size.width/1.75, self.view.bounds.size.height-5);
    isMetadataVisible=!isMetadataVisible;
}


-(void)hide{
    [self closeMetadata];
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar metadataButton:(UIButton *)button
{
    @try{
        [mainToolbar hideToolbar];
        //[mainPagebar hidePagebar];
        if( mainPagebar.hidden==false){
            [mainPagebar removeFromSuperview];
            mainPagebar.hidden=true;
        }    if(isNoteVisible)
            [self.noteContainer removeFromSuperview];
        if(isMetadataVisible){
            [metadataContainer removeFromSuperview];
            m_pdfview.frame=CGRectMake ((self.view.bounds.size.width-self.view.bounds.size.width/1.75)/2, 5, self.view.bounds.size.width/1.75, self.view.bounds.size.height-5);
        }
        else{
            CGRect viewRect = CGRectMake(0,0, 320, self.view.bounds.size.height);
            CCorrespondence *correspondence;
            if(self.menuId!=100){
                correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
            }else{
                correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
            }
            MetadataViewController  *metadataTable=[[MetadataViewController alloc]initWithStyle:UITableViewStyleGrouped];
            metadataTable.view.frame=viewRect;
            
            
            metadataTable.currentCorrespondence=correspondence;
            
            
            
    [self addChildViewController:metadataTable];
            
            UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
            
            close.frame = CGRectMake(288, 10, 20, 20);
            [close setBackgroundImage:[UIImage imageNamed:@"delete_item.png"] forState:UIControlStateNormal];
            [close addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
            [close setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            
    metadataContainer=[[UIView alloc]initWithFrame:CGRectMake(0,0,320, self.view.bounds.size.height )];

            [metadataContainer addSubview:close];
            
    [metadataContainer addSubview:metadataTable.view];
            [metadataContainer bringSubviewToFront:close];
    [self.view addSubview:metadataContainer];
    m_pdfview.frame=CGRectMake(320+(self.view.bounds.size.width-(320+m_pdfview.frame.size.width))/2, 0, m_pdfview.frame.size.width, m_pdfview.frame.size.height);

            //jis orientation
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
                [metadataContainer removeFromSuperview];
                [self.view addSubview:metadataContainer];
                m_pdfview.frame=CGRectMake (325, 0, self.view.bounds.size.width/1.75, self.view.bounds.size.height-5);
                metadataContainer.frame=CGRectMake(0, 0, 320, 1019);
                numberPages.frame = CGRectMake(360, 950, 80, 40);
            }
            //endjis orientation
        }
    
    isMetadataVisible=!isMetadataVisible;
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"metadataButton" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }

}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar searchButton:(UIButton *)button
{
 
    [self.noteContainer removeFromSuperview];
    for (UIView *view in theScrollView.subviews)
    {
        if ([view isKindOfClass:[ReaderContentView class]])
            view.hidden=YES;
    }
    

}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar commentButton:(UIButton *)button

{
    if(isNoteVisible)
    [self.noteContainer removeFromSuperview];
    else {
        CGRect viewRect = CGRectMake((self.view.bounds.size.width-520)/2,0, 520, self.view.bounds.size.height);
        NotesViewController *noteTable=[[NotesViewController alloc]initWithStyle:UITableViewStyleGrouped];
        noteTable.view.frame=viewRect;
        noteTable.menuId=self.menuId;
        noteTable.correspondenceId=self.correspondenceId;
        noteTable.attachmentId=self.attachmentId;
        [self addChildViewController:noteTable];
        self.noteContainer=[[UIView alloc]initWithFrame:CGRectMake(0, mainToolbar.frame.size.height,self.view.bounds.size.width, 300 )];
       self.noteContainer.backgroundColor = [UIColor colorWithRed:1/255.0f green:1/255.0f  blue:1/255.0f  alpha:0.9];
        CGRect shadowRect = self.view.bounds; shadowRect.origin.y += self.noteContainer.frame.origin.y+self.noteContainer.frame.size.height+ shadowRect.size.height; shadowRect.size.height = 10;
    
        UIXToolbarShadow *shadowView = [[UIXToolbarShadow alloc] initWithFrame:shadowRect];
    
        [self.noteContainer addSubview:shadowView];
    
    
    
        [self.noteContainer addSubview:noteTable.view];
        [self.view addSubview:self.noteContainer];
    }
isNoteVisible=!isNoteVisible;
}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar noteButton:(UIButton *)button
{

    
    NoteAlertView *noteView = [[NoteAlertView alloc] initWithFrame:CGRectMake(0, 300, 400, 250) fromComment:NO];
    noteView.modalPresentationStyle = UIModalPresentationFormSheet;
    noteView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:noteView animated:YES completion:nil];
    noteView.view.superview.frame = CGRectMake(300, 300, 400, 250); //it's important to do this after presentModalViewController
    // noteView.view.superview.center = self.view.center;
    noteView.delegate=self;
  }

//jen PreviousNext
//- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar nextButton:(UIButton *)button documentReader:(ReaderDocument *)newdocument correspondenceId:(NSInteger)correspondenceId
//{
//    [self loadNewDocumentReader:newdocument documentId:correspondenceId];
//}
//
//- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar previousButton:(UIButton *)button documentReader:(ReaderDocument *)newdocument correspondenceId:(NSInteger)correspondenceId
//{
//    [self loadNewDocumentReader:newdocument documentId:correspondenceId];
//    
//}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar nextButton:(UIButton *)button documentReader:(ReaderDocument *)newdocument correspondenceId:(NSInteger)correspondenceId attachementId:(NSInteger)attachementId
{
    [self loadNewDocumentReader:newdocument attachementId:attachementId];
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar previousButton:(UIButton *)button documentReader:(ReaderDocument *)newdocument correspondenceId:(NSInteger)correspondenceId attachementId:(NSInteger)attachementId
{
    [self loadNewDocumentReader:newdocument attachementId:attachementId];
    
}




- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return  YES;
}




#pragma mark ThumbsViewControllerDelegate methods

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
	//[self updateToolbarBookmarkIcon]; // Update bookmark icon

	[self dismissViewControllerAnimated:YES completion:nil]; // Dismiss
}

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
	[self showDocumentPage:page]; // Show the page
}

#pragma mark ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page document:(ReaderDocument*)newdocument fileId:(NSInteger)fileId
{
    @try{
        document=newdocument;
        [numberPages setTitle:[NSString stringWithFormat:@"1 of %@",document.pageCount] forState:UIControlStateNormal];
        self.attachmentId=fileId;
        contentViews = [NSMutableDictionary new];
        currentPage=0;
        for (UIView *view in self.view.subviews)
        {
            if (![view isKindOfClass:[mainToolbar class]] && ![view isKindOfClass:[mainPagebar class]])
                [view removeFromSuperview];
        }
        
        lastHideTime = [NSDate date];
        [self updateScrollViewContentViews];
        lastAppearSize = CGSizeZero;
        [self performSelector:@selector(showDocument:) withObject:nil afterDelay:0];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        //[self showDocumentPage:page]; // Show the page
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"gotoPage" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    
}

#pragma mark UIApplication notification methods

- (void)applicationWill:(NSNotification *)notification
{
	[document saveReaderDocument]; // Save any ReaderDocument object changes
    
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

#pragma mark search methods

//-(void)SearchDataFromPDF{
//    Searching=YES;
//
//    //[searchPopVC dismissPopoverAnimated:YES];
//   [self performSelectorInBackground:@selector(GetFirstPageWithResult) withObject:nil ];
//
//
//
//
//    //[self GetListOfSearchPage];
//}
//static float progress = 0.0f;
//-(void)GetFirstPageWithResult{
//    NSInteger lastPage=currentPage;
//    PDFDocRef = CGPDFDocumentCreateX((__bridge CFURLRef)document.fileURL,document.password);
//    float pages = CGPDFDocumentGetNumberOfPages(PDFDocRef);
//    for (i=0; i<pages; i++) {
//         //[self performSelectorOnMainThread:@selector(PerFormONMainThread:) withObject:[NSString stringWithFormat:@"%f",(i+1/pages)/pages] waitUntilDone:NO];
//        progress=(float)((i+1/pages)/pages);
//        [self performSelectorOnMainThread:@selector(increaseProgress:) withObject:[NSString stringWithFormat:@"%d/%d",i,(int)pages] waitUntilDone:YES];
//        PDFPageRef = CGPDFDocumentGetPage(PDFDocRef,i+1); // Get page
//        if ([[self selections] count]>0) {
//            // [alertmessage hideAlert];
//           // [self.am hideAlert];
//             [self performSelectorOnMainThread:@selector(dismissSuccess) withObject:nil waitUntilDone:YES];
//            currentPage= i+1;
//             contentViews = [NSMutableDictionary new];
//            [self showDocumentPage:currentPage];
//            return;
//        }
//    }
//     //[alertmessage hideAlert];
//     [self performSelectorOnMainThread:@selector(dismissError) withObject:nil waitUntilDone:YES];
//    //[self.am hideAlert];
//        currentPage=lastPage;
//     contentViews = [NSMutableDictionary new];
//    [self showDocumentPage:currentPage];
//    return;
//}




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //cancel clicked ...do your action
    }
    else if (buttonIndex == 1)
    {
        if(alertView.tag==TAG_DEV)
        {
            // [cview setAnnotationNoteMsg:[alertView textFieldAtIndex:0].text];
            
        }
        if(alertView.tag==TAG_SAVE){
            CCorrespondence *correspondence;
            if(self.menuId!=100){
                correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
            }else{
                correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
            }
            CAttachment *fileToOpen=correspondence.attachmentsList[self.attachmentId];
            [m_pdfview setBtnHighlight:NO];
            [m_pdfview setBtnNote:NO];
            [m_pdfview setBtnSign:NO];
            [m_pdfview setBtnErase:NO];
            [m_pdfview setAttachmentId:fileToOpen.AttachmentId.intValue];
            [self saveAnnotation];
        }
        else{
            
        }
        
    }
    
    
    else
    {
        UIAlertView *alertNoSig=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Info",@"Info") message:NSLocalizedString(@"Alert.NoSignature",@"No Signature Available,please configure a signature")delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
        [alertNoSig show];
    }
    
    
}

- (void)tappedSaveNoteText:(NSString*)text private:(BOOL)isPrivate{
    [m_pdfview setAnnotationNoteMsg:text];
    [m_pdfview setBtnHighlight:NO];
    [m_pdfview setBtnNote:YES];
    [m_pdfview setBtnSign:NO];
}

- (void)tappedSaveSignatureWithWidth:(NSString*)width withHeight:(NSString*)height withRed:(NSString *)red withGreen:(NSString *)green withBlue:(NSString *)blue{
    
    
    [Base64 initialize];
    NSData* imgData;
    UIImage *image=[UIImage imageWithData:[Base64 decode:mainDelegate.user.signature]];
    
    imgData=UIImageJPEGRepresentation([self changeColor:image withRed:red withGreen:green withBlue:blue], 1.0);
    
    
    [m_pdfdoc setSignatureData:imgData];
    [m_pdfview setBtnHighlight:NO];
    [m_pdfview setBtnNote:NO];
    [m_pdfview setBtnSign:YES];
    [m_pdfview setAnnotationSignHeight:[height integerValue]];
    [m_pdfview setAnnotationSignWidth:[width integerValue]];
    
    if([mainDelegate.Signaction isEqualToString:@"FreeSign"] || [mainDelegate.Signaction isEqualToString:@"FreeSignAll"]){
    
        UIAlertView *alertOk=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Info",@"Info") message:NSLocalizedString(@"Alert.Sign",@"Click on pdf document to sign") delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
        [alertOk show];
    }
   

}

- (UIImage *) changeColor: (UIImage *)img  withRed:(NSString *)red withGreen:(NSString *)green withBlue:(NSString *)blue{
    
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [[UIColor colorWithRed:[red floatValue]/255.0f green:[green floatValue]/255.0f blue:[blue floatValue]/255.0f alpha:1.0]setFill];
    // [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeColor);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}





- (void)increaseProgress:(NSString*)UpdateProgress{

    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loading ...") maskType:SVProgressHUDMaskTypeBlack];
  
}

@end


