//
//	ReaderViewController.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
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
#import "SPUserResizableView.h"
#import "DrawLayerView.h"
#import "FolderObject.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)


@interface ReaderViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate,
ReaderMainToolbarDelegate, ReaderMainPagebarDelegate, ReaderContentViewDelegate, ThumbsViewControllerDelegate>
@end

@implementation ReaderViewController
{
    CGPoint XH,YH,ZH;
	ReaderDocument *document;
    
	ReaderMainToolbar *mainToolbar;
    
	ReaderMainPagebar *mainPagebar;
    
	NSMutableDictionary *contentViews;
    
	UIPrintInteractionController *printInteraction;
    UISwipeGestureRecognizer *swipeRecognizerLeft;
    UISwipeGestureRecognizer *swipeLeftRecognizerRight;
	NSInteger currentPage;
    
	CGSize lastAppearSize;
    
	NSDate *lastHideTime;
    NSString* type;
	BOOL isVisible;
    NSString* pathToDelete;
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
    SPUserResizableView *currentlyEditingView;
    SPUserResizableView *lastEditedView;
    SPUserResizableView *imageResizableView;
    UIScrollView* PdfScroll;
    UIScrollView* scrollView;
    int orientationHeight;
    int orientationWidth;
    int orientationX;
}

#pragma mark Constants

#define PAGING_VIEWS 3

#define TOOLBAR_HEIGHT 150.0f//135.0f
#define PAGEBAR_HEIGHT 130.0f

#define TAP_AREA_SIZE 48.0f

#define TAG_DEV 1
#define TAG_SIGN 2
#define TAG_SAVE 3

#pragma mark Properties

@synthesize delegate,keyword,selections,openButton,numberPages,folderPagebar,drawLayer;

#pragma mark Support methods





- (void)showDocument:(id)object
{
    @try{
        
        [mainDelegate.DrawLayerViews removeAllObjects];
        
        // Set content size
        
        //[self showDocumentPage:[document.pageNumber integerValue]];
        
        document.lastOpen = [NSDate date]; // Update last opened date
        
        isVisible = YES; // iOS present modal bodge
        CCorrespondence *correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
       
        
        CAttachment *fileToOpen=correspondence.attachmentsList[self.attachmentId];
        [mainToolbar refreshToolbar:fileToOpen.Status];
        
              
        
        mainDelegate.attachmentType =@"";
        
        //CAttachment *fileToOpen;
        
        
        
        [mainToolbar updateTitleWithLocation:fileToOpen.location withName:fileToOpen.title];
        NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:correspondence.Id fromSharepoint:mainDelegate.isSharepoint];
        //NSString *tempPdfLocation=[CParser loadPdfFile:fileToOpen.url inDirectory:correspondence.Id];
        
        const char* file = [tempPdfLocation UTF8String];
        [self initView:file];
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"showDocument" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
}
-(void)disableNext{
    mainToolbar.nextButton.enabled=false;
}
-(void)disablePrev{
    mainToolbar.previousButton.enabled=false;
}
-(void)enablePrev{
    mainToolbar.previousButton.enabled=true;
}
-(void)enableNext{
    mainToolbar.nextButton.enabled=true;
    
}
-(void)setAttachmentIdInToolbar:(int)value{
    [mainToolbar setAttachmentId:value];
    self.attachmentId=value;
}
-(void)initView:(const char*)file{
    m_pdfdoc = [[PDFDocument alloc] init];
    [m_pdfdoc initPDFSDK];
    if(![m_pdfdoc openPDFDocument: file]){
        [m_pdfview removeFromSuperview];
        [PdfScroll removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Warning")
                                                        message:NSLocalizedString(@"Alert.Extension",@"Document extension not supported.")
                                                       delegate:nil
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
                m_pdfview.delegate=self;
                PdfScroll.frame=m_pdfview.frame;
                numberPages.frame = CGRectMake(m_pdfview.frame.size.width+m_pdfview.frame.origin.x-80, 950, 80, 40);
                openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 30);
                
                //jis orientation
                if(isMetadataVisible){
                    [metadataContainer removeFromSuperview];
                    [self.view addSubview:metadataContainer];
                  //  m_pdfview.frame=CGRectMake (325, 5, self.view.bounds.size.width/1.75, self.view.bounds.size.height-5);
                   // PdfScroll.frame=m_pdfview.frame;
                    
                    metadataContainer.frame=CGRectMake(0, 0, 200, 1019);
                    numberPages.frame = CGRectMake(360, 950, 80, 40);
                    openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 30);
                    
                }
                //endjis orientation
            } else {
                factor=1.75;
                m_pdfview = [[PDFView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-self.view.bounds.size.width/factor)/2, 5, self.view.bounds.size.width/factor, self.view.bounds.size.height-5)];
                m_pdfview.delegate=self;
                PdfScroll.frame=m_pdfview.frame;
                if (!SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                    numberPages.frame = CGRectMake(m_pdfview.frame.origin.x+m_pdfview.frame.size.width-300,m_pdfview.frame.origin.y+m_pdfview.frame.size.height-50, 80, 30);
                }
                else
                numberPages.frame = CGRectMake(self.view.frame.size.width-263, 720, 80, 30);
                
                openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 30);
                if(isMetadataVisible){
//                    m_pdfview.frame=CGRectMake(320+(self.view.bounds.size.width-(320+m_pdfview.frame.size.width))/2, 5, m_pdfview.frame.size.width, m_pdfview.frame.size.height);
//                    PdfScroll.frame=m_pdfview.frame;
                    
                }
            }
            
            
            [PdfScroll removeFromSuperview];
            
            
            PdfScroll = [[UIScrollView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-self.view.bounds.size.width/factor)/2, 5, self.view.bounds.size.width/factor, self.view.bounds.size.height-5)];
            PdfScroll.backgroundColor = [UIColor blackColor];
            PdfScroll.contentInset = UIEdgeInsetsZero;
            PdfScroll.delegate = self;
            
            [m_pdfdoc setPDFView:m_pdfview];
            [m_pdfview initPDFDoc:m_pdfdoc pageIndex:currentPage-1];
            
            [m_pdfview addSubview:numberPages];
            
            [self.view addSubview:folderPagebar];
            // [m_pdfview addSubview:folderPagebar];
            
            PdfScroll.contentSize = m_pdfview.frame.size;
            [PdfScroll addSubview:m_pdfview];
            
            PdfScroll.minimumZoomScale = PdfScroll.frame.size.width / m_pdfview.frame.size.width;
            PdfScroll.maximumZoomScale = 4.0;
            [PdfScroll setZoomScale:PdfScroll.minimumZoomScale];
            [m_pdfview addSubview:openButton];
            PdfScroll.frame=m_pdfview.frame;
            [self.view addSubview: PdfScroll];
            
            
            
        }
        else{
            [m_pdfdoc setPDFView:m_pdfview];
            [m_pdfview initPDFDoc:m_pdfdoc pageIndex:currentPage-1];
        }
        
        [self.view bringSubviewToFront:numberPages];
        [self.view bringSubviewToFront:openButton];
        [self.view bringSubviewToFront:mainToolbar];
        [self.view bringSubviewToFront:mainPagebar];
        [self.view bringSubviewToFront:folderPagebar];
        [self centreView];
    }
    
}
- (void)centreView
{
    m_pdfview.frame = [self centeredFrameForScrollView:PdfScroll andUIView:m_pdfview];
}


- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
	CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    
	return frameToCenter;
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    m_pdfview.frame = [self centeredFrameForScrollView:scrollView andUIView:m_pdfview];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return m_pdfview;
}

- (void)zoomReset
{
	if (PdfScroll.zoomScale > PdfScroll.minimumZoomScale)
	{
		PdfScroll.zoomScale = PdfScroll.minimumZoomScale;
	}
}
//- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
//
//    CGRect zoomRect;
//
//    zoomRect.size.height = [m_pdfview frame].size.height / scale;
//    zoomRect.size.width  = [m_pdfview frame].size.width  / scale;
//
//    center = [m_pdfview convertPoint:center fromView:PdfScroll];
//
//    zoomRect.origin.x    = center.x - ((zoomRect.size.width / 2.0));
//    zoomRect.origin.y    = center.y - ((zoomRect.size.height / 2.0));
//
//    return zoomRect;
//}
//
//- (void)handleDoubleTapFrom:(UITapGestureRecognizer *)recognizer {
//
//    float newScale = [PdfScroll zoomScale] *2.0;
//
//    if (PdfScroll.zoomScale > PdfScroll.minimumZoomScale)
//    {
//        [PdfScroll setZoomScale:PdfScroll.minimumZoomScale animated:YES];
//    }
//    else
//    {
//        CGRect zoomRect = [self zoomRectForScale:newScale
//                                      withCenter:[recognizer locationInView:recognizer.view]];
//        [PdfScroll zoomToRect:zoomRect animated:YES];
//    }
//}
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
    if ( (mainPagebar.hidden == NO))
    {
        folderPagebar.hidden = true;
        mainPagebar.hidden=true;
        [mainPagebar removeFromSuperview];

    }
    if (isMetadataVisible) {
        [self closeMetadata];
        isMetadataVisible=false;
    }
    [self.view bringSubviewToFront:mainToolbar];
    CCorrespondence* correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];

    CAttachment* currentAttachment=correspondence.attachmentsList[self.attachmentId];
    if(![[correspondence.Status lowercaseString] isEqualToString:@"readonly"])
        [mainToolbar showToolbar:currentAttachment.Status];
    else
        [mainToolbar showToolbar:@"readonly"];

    
}

-(void)openPagebar:(id)sender{
    NSLog(@"Info: Enter openPagebar method.");
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loading ...") maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        FolderObject*obj=folderarray[[sender tag]];
        mainDelegate.FolderName =obj.Name;
        mainDelegate.FolderId=obj.Id;
        
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
                NSLog(@"Info:Geting FolderAttachments");
                if(mainDelegate.SupportsServlets)
                    attachmentUrl= [NSString stringWithFormat:@"http://%@?action=GetFolderAttachments&token=%@&docId=%d&folderName=%@&folderId=%@&showThumbnails=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,docId,mainDelegate.FolderName,mainDelegate.FolderId,showthumb,mainDelegate.IpadLanguage];
                else
                    attachmentUrl= [NSString stringWithFormat:@"http://%@/GetFolderAttachments?token=%@&docId=%d&folderName=%@&folderId=%@&showThumbnails=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,docId,mainDelegate.FolderName,mainDelegate.FolderId,showthumb,mainDelegate.IpadLanguage];
                NSLog(@"URL:%@",attachmentUrl);
                [CParser GetFolderAttachment:attachmentUrl Id:self.correspondenceId];
                
            }else{
                attachmentXmlData=[CParser LoadXML:@"Attachment" nb:correspondence.Id name:mainDelegate.FolderName];
                
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
           CGSize size = [UIScreen mainScreen].bounds.size;
            size = CGSizeMake(size.height, size.width);
            CGRect viewRect;
            if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                viewRect = CGRectMake( m_pdfview.bounds.origin.x,0,size.width, self.view.bounds.size.height);
            }else{
                viewRect = CGRectMake( 0,0,self.view.frame.size.width, self.view.bounds.size.height);
                
            }
            
            
            //CGRect viewRect = CGRectMake( m_pdfview.bounds.origin.x+218,0,size.width, self.view.bounds.size.height);
            
           // CGRect pagebarRect = viewRect;
            CGRect pagebarRect = CGRectMake(0, 0, 130, self.view.frame.size.height);
           // pagebarRect.size.height = PAGEBAR_HEIGHT;
            //pagebarRect.origin.y = (viewRect.size.height - PAGEBAR_HEIGHT);
            pagebarRect.size.height = self.view.frame.size.height;
            pagebarRect.origin.y = 0;
            mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect Document:document CorrespondenceId:self.correspondenceId MenuId:self.menuId AttachmentId:self.attachmentId]; // At bottom
            
            

            mainPagebar.delegate = self;

            [self.view addSubview:mainPagebar];
            mainPagebar.hidden=false;
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
    [openButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"menu.show",@"Click to see the Menu")] forState:UIControlStateNormal];
    [openButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    openButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [openButton setTintColor:[UIColor whiteColor]];
    [openButton setBackgroundImage:[UIImage imageNamed:@"clickformenu1.png"] forState:UIControlStateNormal];
    [openButton addTarget:self action:@selector(openToolbar) forControlEvents:UIControlEventTouchUpInside];
    openButton.imageEdgeInsets = UIEdgeInsetsMake(-50, -50, 50, -50);
    // [self.view addSubview:openButton];
    
    
	assert(document != nil); // Must have a valid ReaderDocument
    CGFloat red = 173.0f / 255.0f;
    CGFloat green = 208.0f / 255.0f;
    CGFloat blue = 238.0f / 255.0f;
	//self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.view.backgroundColor=[UIColor colorWithRed:red green:green  blue:blue  alpha:1.0];
	CGRect viewRect = self.view.bounds; // View controller's view bounds
    
    
	CGRect toolbarRect = viewRect;
	toolbarRect.size.height = TOOLBAR_HEIGHT;
    
	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect document:document CorrespondenceId:self.correspondenceId MenuId:self.menuId AttachmentId:self.attachmentId]; // At top
	mainToolbar.delegate = self;
    mainToolbar.hidden=true;
    
    
    
    
	[self.view addSubview:mainToolbar];
    
    [mainToolbar hideToolbar];
    
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation])) {
        // landscape
        orientationHeight=252;
    }
    else
    {// portrait
        orientationHeight=255;
        orientationX=100;
    }
    
    
    [self createFolderPageBar];
    
    
    CGRect shadowRect = folderPagebar.bounds; shadowRect.size.height = 10.0f; shadowRect.origin.y -= shadowRect.size.height;
    
    ReaderPagebarShadow *shadowView = [[ReaderPagebarShadow alloc] initWithFrame:shadowRect];
    
    [folderPagebar addSubview:shadowView];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideEditingHandles)];
    gestureRecognizer.numberOfTouchesRequired = 1; gestureRecognizer.numberOfTapsRequired = 2; gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    UILongPressGestureRecognizer *singleTapOne = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[self.view addGestureRecognizer:singleTapOne];
    
    
    
    swipeRecognizerLeft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    swipeRecognizerLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRecognizerLeft];
    
    swipeLeftRecognizerRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    swipeLeftRecognizerRight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeLeftRecognizerRight];
	contentViews = [NSMutableDictionary new]; lastHideTime = [NSDate date];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    
    
    
    
    numberPages = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
    
    numberPages.frame = CGRectMake(self.view.frame.size.width-263, 720, 80, 30);
    currentPage++;
    [numberPages setTitle:[NSString stringWithFormat:@"%d of %@",currentPage,document.pageCount] forState:UIControlStateNormal];
    
    [numberPages setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    numberPages.titleLabel.font = [UIFont systemFontOfSize:12];
    [numberPages setTintColor:[UIColor whiteColor]];
    
    numberPages.backgroundColor = [UIColor colorWithRed:1/255.0f green:49/255.0f  blue:97/255.0f  alpha:1.0];
    if (!UIInterfaceOrientationIsPortrait([[UIDevice currentDevice]orientation])) {
        [self openMetaData];
        isMetadataVisible=YES;

    }
    
    [self adjustButtons:orientation];
    
}

-(void) createFolderPageBar
{
    folderPagebar = [[UIView alloc]init];
  folderPagebar.frame=CGRectMake([UIScreen mainScreen].bounds.origin.x, m_pdfview.frame.origin.y, 130, [UIScreen mainScreen].bounds.size.height);
    
    folderPagebar.autoresizesSubviews = YES;
    folderPagebar.userInteractionEnabled = YES;
    folderPagebar.contentMode = UIViewContentModeRedraw;
    folderPagebar.backgroundColor=mainDelegate.cellColor;
    [self refreshFolderPageBar];
    [self.view addSubview:folderPagebar];
    
}
-(void)refreshFolderPageBar{
    
    CCorrespondence * correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    
    [scrollView removeFromSuperview];
    scrollView = [[UIScrollView alloc] init];
    scrollView.Frame=CGRectMake(0, 0, folderPagebar.bounds.size.width,folderPagebar.bounds.size.height);
    scrollView.backgroundColor = [UIColor clearColor];

    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    
  
    
    
    
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    
    folderarray = [[NSMutableArray alloc] init];
    
                if (correspondence.attachmentsList.count>0)
                {
                    for(CAttachment* doc in correspondence.attachmentsList)
                    {
                        FolderObject* obj=[[FolderObject alloc]init];
                        [obj setId:doc.FolderId];
                        [obj setName:doc.FolderName];
                        if(![self ArrayContainsObject:folderarray folder:obj]){
                            
                            [folderarray addObject:obj];
                            
                        }
                        
                    }
                }
  
    UIImage *image=[UIImage imageNamed:@"Folder.png"];;

    for( i=0 ;i<folderarray.count;i++){
        UIButton *btnFolder;
        UILabel* folderlabel;
        
        btnFolder=[[UIButton alloc]initWithFrame:CGRectMake(30, i*133+15, image.size.width, image.size.height)];
           folderlabel=[[UILabel alloc]initWithFrame:CGRectMake(20, i*133+image.size.height, image.size.width+20, 100)];
        
        [btnFolder setBackgroundImage:image forState:UIControlStateNormal];
        folderlabel.text=((FolderObject*)[folderarray objectAtIndex:i]).Name;
        
        folderlabel.lineBreakMode = NSLineBreakByWordWrapping;
        folderlabel.numberOfLines = 2;
        
        folderlabel.textAlignment=NSTextAlignmentCenter;
        folderlabel.backgroundColor = [UIColor clearColor];
        folderlabel.font = [UIFont fontWithName:@"Helvetica" size:17];
        folderlabel.textColor=[UIColor whiteColor];
        btnFolder.tag =i;
        [btnFolder addTarget:self action:@selector(openPagebar:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:btnFolder];
        [scrollView addSubview:folderlabel];
        
    }
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        scrollView.contentSize = CGSizeMake(75,folderarray.count*155);
    }
    else
     scrollView.contentSize = CGSizeMake(75,folderarray.count*133+15);
       [folderPagebar addSubview:scrollView];
    folderPagebar.hidden=true;

}
-(BOOL)ArrayContainsObject:(NSMutableArray*) array folder:(FolderObject*) folder{
    for(FolderObject* obj in array){
        if([obj.Name isEqualToString:folder.Name]&&[obj.Id isEqualToString:folder.Id])
            return YES;
    }
    return NO;
}
-(void)adjustButtons:(UIInterfaceOrientation)orientation{
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        openButton.frame = CGRectMake(self.view.bounds.size.width/2-100, 0, 200, 30);
        numberPages.frame = CGRectMake(687.8, 950, 80, 40);
    } else {
        openButton.frame = CGRectMake(self.view.bounds.size.width/2-191.5, 0, 200, 30);
        numberPages.frame = CGRectMake(self.view.frame.size.width-263, 720, 80, 30);
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	
    [self performSelector:@selector(showDocument:) withObject:nil afterDelay:0.02];
	
    
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
    
	PdfScroll = nil;
    contentViews = nil; lastHideTime = nil;
    
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
    if(!SYSTEM_VERSION_LESS_THAN(@"8.0")){
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        folderPagebar.frame=CGRectMake([UIScreen mainScreen].bounds.origin.x, m_pdfview.frame.origin.y, 130, [UIScreen mainScreen].bounds.size.width);
    }
    else
        folderPagebar.frame=CGRectMake([UIScreen mainScreen].bounds.origin.x, m_pdfview.frame.origin.y, 130, [UIScreen mainScreen].bounds.size.height);
    }
    [mainPagebar adjustToolbar:toInterfaceOrientation];
    
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    float factor;
    [self zoomReset];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        factor=1;
        m_pdfview.frame=CGRectMake ((self.view.bounds.size.width-self.view.bounds.size.width/factor)/2, 5, self.view.bounds.size.width/factor, self.view.bounds.size.height-5);
        numberPages.frame = CGRectMake(m_pdfview.frame.size.width+m_pdfview.frame.origin.x-80, 950, 80, 40);
        openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 30);
        if(isMetadataVisible){
            [metadataContainer removeFromSuperview];
            [self.view addSubview:metadataContainer];
            m_pdfview.frame=CGRectMake (225, 0, self.view.bounds.size.width/1.50, self.view.bounds.size.height-5);
            PdfScroll.frame=m_pdfview.frame;
            metadataContainer.frame=CGRectMake(0, 0, 200, 1019);
            numberPages.frame = CGRectMake(m_pdfview.frame.size.width+m_pdfview.frame.origin.x-300, 950, 80, 40);
            openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 30);
            
        }
        if(m_pdfview.handsign||m_pdfview.btnSign){
            m_pdfview.frame=CGRectMake ((self.view.bounds.size.width-612)/2, 0, 612, 792);
            PdfScroll.frame=m_pdfview.frame;
            numberPages.frame = CGRectMake((self.view.bounds.size.width-612)/2+452, 720, 80, 30);
            openButton.frame = CGRectMake((m_pdfview.frame.origin.x+m_pdfview.frame.size.width/2)-100, 0, 200, 30);
            
        }
        
    } else {
        factor=1.75;
        m_pdfview.frame=CGRectMake ((self.view.bounds.size.width-self.view.bounds.size.width/factor)/2, 5, self.view.bounds.size.width/factor, self.view.bounds.size.height-5);
        
        if (!SYSTEM_VERSION_LESS_THAN(@"8.0")) {
             numberPages.frame = CGRectMake(m_pdfview.frame.origin.x+m_pdfview.frame.size.width-300,m_pdfview.frame.origin.y+m_pdfview.frame.size.height-50, 80, 30);
        }
        else
        numberPages.frame = CGRectMake(self.view.frame.size.width-263, 720, 80, 30);
        
        openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 30);
        
        if(isMetadataVisible){
//            m_pdfview.frame=CGRectMake(320+(self.view.bounds.size.width-(320+m_pdfview.frame.size.width))/2, 0, m_pdfview.frame.size.width, m_pdfview.frame.size.height);
            m_pdfview.frame=CGRectMake(225, 0, m_pdfview.frame.size.width, m_pdfview.frame.size.height);

            PdfScroll.frame=m_pdfview.frame;
            
        }
        
    }
    
    
    
    [mainToolbar adjustButtons:interfaceOrientation];
    PdfScroll.frame=m_pdfview.frame;
    scrollView.Frame=CGRectMake(0, 0, folderPagebar.bounds.size.width,m_pdfview.frame.size.height);

    [self centreView];
    
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
	if (isVisible == NO) return; // iOS present modal bodge
    
	if (fromInterfaceOrientation == self.interfaceOrientation) return;
   // [self centreView];

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
        NSInteger maxPage = [document.pageCount integerValue];
        NSInteger minPage = 1; // Minimum
        CGPoint location = [recognizer locationInView:self.view];
        
        if(mainToolbar.hidden==NO || mainPagebar.hidden==NO){
            [mainToolbar hideToolbar];
            //  [mainPagebar hidePagebar];
            if( mainPagebar.hidden==false){
                [mainPagebar removeFromSuperview];
                mainPagebar.hidden=true;
            }
        }
        
        
        if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
            location.x -= 220.0;
            
            if ((maxPage > minPage) && (currentPage != maxPage))
            {
                if(mainDelegate.DrawLayerViews.count>0){
                    
                    lastEditedView=nil;
                    lastEditedView=[mainDelegate.DrawLayerViews objectForKey:[NSString stringWithFormat:@"%d",[m_pdfview GetPageIndex]]];
                    if(lastEditedView!=nil)
                        [lastEditedView removeFromSuperview];
                    
                }
                [self TurnPageRight];
            }
            
        }
        else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            
            location.x += 220.0;
            
            if ((maxPage > minPage) && (currentPage > minPage))
            {
                if(mainDelegate.DrawLayerViews.count>0){
                    
                    lastEditedView=nil;
                    lastEditedView=[mainDelegate.DrawLayerViews objectForKey:[NSString stringWithFormat:@"%d",[m_pdfview GetPageIndex]]];
                    if(lastEditedView!=nil)
                        [lastEditedView removeFromSuperview];
                    
                }
                [self TurnPageLeft];
            }
        }
        [m_pdfview setNeedsDisplay];
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"handleSwipeFrom" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    
}

-(void)TurnPageLeft{
    //    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
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
    if(mainDelegate.DrawLayerViews.count>0){
        
        lastEditedView=nil;
        lastEditedView=[mainDelegate.DrawLayerViews objectForKey:[NSString stringWithFormat:@"%d",[m_pdfview GetPageIndex]]];
        
        
        if(lastEditedView!=nil)
            [self.view addSubview:lastEditedView];
        else
            [self EnableSwipe];
    }
    
}
-(void)TurnPageRight{
    //    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
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
    if(mainDelegate.DrawLayerViews.count>0){
        
        lastEditedView=nil;
        lastEditedView=[mainDelegate.DrawLayerViews objectForKey:[NSString stringWithFormat:@"%d",[m_pdfview GetPageIndex]]];

        if(lastEditedView!=nil)
            [self.view addSubview:lastEditedView];
        else
            [self EnableSwipe];
    }
}


-(ReaderDocument*) OpenPdfReader:(NSString *) pdfPath{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    NSString *filePath = pdfPath;// [pdfs lastObject];
    assert(filePath != nil); // Path to last PDF file
    
    ReaderDocument *newDocument = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
    return newDocument;
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
                    //[mainToolbar showToolbar:@""];
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
			//[self incrementPageNumber]; return;
		}
        
		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;
        
		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			//[self decrementPageNumber]; return;
		}
	
    }
    
}

-(void)loadNewDocumentReader:(ReaderDocument *)newdocument attachementId:(NSInteger)attachementId{
    @try{
        [self.noteContainer removeFromSuperview];
        self.attachmentId=attachementId;
        document=newdocument;
        contentViews = [NSMutableDictionary new];
        
        
        [m_pdfview removeFromSuperview];
        if( mainPagebar.hidden==false){
            [mainPagebar removeFromSuperview];
            mainPagebar.hidden=true;
        }
        
        
        [self.view addSubview:mainPagebar];
        [self.view bringSubviewToFront:mainToolbar];

        lastHideTime = [NSDate date];
        [numberPages setTitle:[NSString stringWithFormat:@"%d of %@",currentPage,document.pageCount] forState:UIControlStateNormal];
        [ m_pdfview InitPageIndex];
        [self performSelector:@selector(showDocument:) withObject:nil afterDelay:0];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"loadNewDocumentReader" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
}

-(void)destinationSelected:(CDestination*)dest withRouteLabel:(CRouteLabel*)routeLabel routeNote:(NSString*)note withDueDate:(NSString*)date viewController:(TransferViewController *)viewcontroller{
    if (mainDelegate==nil) mainDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
	@try{
        NSLog(@"Info: Enter Transfer Method.");
        CUser* userTemp =  mainDelegate.user ;
        
        CCorrespondence *correspondence;
        if(!mainDelegate.QuickActionClicked){
            
            if(self.menuId!=100){
                correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
            }else{
                correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
            }
        }
        else{
            correspondence=mainDelegate.searchModule.correspondenceList[mainDelegate.QuickActionIndex];
        }
        // CAttachment *currentDoc=correspondence.attachmentsList[self.attachmentId];
        NSString* url;
        if(mainDelegate.SupportsServlets)
            url = [NSString stringWithFormat:@"http://%@?action=TransferCorrespondence&token=%@&correspondenceId=%@&transferId=%@&destinationId=%@&purposeId=%@&dueDate=%@&note=%@",mainDelegate.serverUrl,userTemp.token,correspondence.Id,correspondence.TransferId,dest.rid,routeLabel.labelId,date,note];
        else
            url = [NSString stringWithFormat:@"http://%@/TransferCorrespondence?token=%@&correspondenceId=%@&transferId=%@&destinationId=%@&purposeId=%@&dueDate=%@&note=%@",mainDelegate.serverUrl,userTemp.token,correspondence.Id,correspondence.TransferId,dest.rid,routeLabel.labelId,date,note];
        NSLog(@"URL=%@",url);
        if(!mainDelegate.isOfflineMode){
            
            

            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
            NSData *xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            NSString *validationResultAction=[CParser ValidateWithData:xmlData];
            
            if(![validationResultAction isEqualToString:@"OK"])
            {
                [self ShowMessage:validationResultAction];
                
            }else {
                NSLog(@"Info:Transfer Success");
                NSLog(@"Info:Getting Correspondences.");
                if(self.menuId !=100)
                    [((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList removeObjectAtIndex:self.correspondenceId];
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
                NSLog(@"URL=%@",correspondenceUrl);
                // NSURL *xmlUrl = [NSURL URLWithString:correspondenceUrl];
                //NSData *menuXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
                NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[correspondenceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
                NSData *menuXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                NSMutableDictionary *correspondences=[CParser loadCorrespondencesWithData:menuXmlData];
                mainDelegate.searchModule.correspondenceList = [correspondences objectForKey:[NSString stringWithFormat:@"%d",[correspondence.inboxId intValue]]];
                
                
                [self ShowMessage:NSLocalizedString(@"Alert.ActionSuccess",@"Action successfuly done.")];
                [CParser DeleteCorrespondence:correspondence.Id inboxId:correspondence.inboxId];

                
            }	 // Dismiss the ReaderViewController
            
        }
        else{
            [CParser cacheOfflineActions:correspondence.Id url:url action:@"TransferCorrespondence"];
            [CParser DeleteCorrespondence:correspondence.Id inboxId:correspondence.inboxId];
            NSMutableDictionary *correspondences=[CParser LoadCorrespondences:[correspondence.inboxId intValue]];
            mainDelegate.searchModule.correspondenceList = [correspondences objectForKey:[NSString stringWithFormat:@"%d",[correspondence.inboxId intValue]]];
            
            
        }
        if(!mainDelegate.QuickActionClicked){
            
            if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
            {
                
                [viewcontroller dismissViewControllerAnimated:YES  completion:^{
                    [delegate dismissReaderViewController:self];
                }];
            }
        }
        
    }
    // }
    @catch (NSException *ex) {

        NSLog(@"Error: Error occured in ReaderViewController Class in method destinationSelected.\n Exception Name:%@ Exception Reason: %@",[ex name],[ex reason]);
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
            [request setTimeoutInterval:mainDelegate.Request_timeOut];
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
                            NSError *error;
                            GDataXMLDocument *doc= [[GDataXMLDocument alloc] initWithData:returnData options:0 error:&error];
                            NSString* path;
                        CCorrespondence* corr=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
                        CAttachment* att=corr.attachmentsList[self.attachmentId];
                            NSArray *signedfileinfo = [doc nodesForXPath:@"//URL" error:nil];
                            if(signedfileinfo.count>0){
                                GDataXMLElement *signedfileinfoXML =  [signedfileinfo objectAtIndex:0];
                                path=signedfileinfoXML.stringValue;
                               
                                att.url=path;
                                NSEnumerator *enumerator = [mainDelegate.DrawLayerViews keyEnumerator];
                                id key;
                                while ((key = [enumerator nextObject])) {
                                    SPUserResizableView *tmp = [mainDelegate.DrawLayerViews objectForKey:key];
                                    tmp.contentView.canvas.layer.borderColor = [UIColor clearColor].CGColor;
                                    [tmp showEditingHandles];
                                    [tmp removeFromSuperview];
                                }
                                [att replaceDocument:corr.Id];

                                [self refreshAfterSign:att correspondenceId:corr.Id];
                                
                            }
                        

                        NSArray *annotationsXml = [doc nodesForXPath:@"//Annotations" error:nil];
                        [mainDelegate.IncomingHighlights removeAllObjects];
                        [mainDelegate.IncomingNotes removeAllObjects];
                        if (annotationsXml.count > 0) {
                            GDataXMLElement *annotationsEl = (GDataXMLElement *) [annotationsXml objectAtIndex:0];
                            NSArray *Notes = [annotationsEl nodesForXPath:@"Notes" error:nil];
                            
                            
                            
                            GDataXMLElement *NotesXML;
                            
                            if(Notes.count>0){
                                
                                NotesXML = [Notes objectAtIndex:0];
                                
                            }
                            
                            NSArray *noteXML = [NotesXML elementsForName:@"Note"];
                            
                            NSString *noteX;
                            
                            NSString *noteY;
                            
                            NSString *notepage;
                            
                            NSString *noteMSG;
                            
                            NSString *noteId;

                            for(GDataXMLElement *notee in noteXML)
                                
                            {
                                NSArray *noteXs = [notee elementsForName:@"X"];
                                
                                if (noteXs.count > 0) {
                                    
                                    GDataXMLElement *noteXEl = (GDataXMLElement *) [noteXs objectAtIndex:0];
                                    
                                    noteX = noteXEl.stringValue;
                                    
                                }
                                
                                NSArray *noteYs = [notee elementsForName:@"Y"];
                                
                                if (noteYs.count > 0) {
                                    
                                    GDataXMLElement *noteYEl = (GDataXMLElement *) [noteYs objectAtIndex:0];
                                    
                                    noteY = noteYEl.stringValue;
                                    
                                }
                                NSArray *Ids = [notee elementsForName:@"AnnotationId"];
                                
                                if (Ids.count > 0) {
                                    
                                    GDataXMLElement *IdEl = (GDataXMLElement *) [Ids objectAtIndex:0];
                                    
                                    noteId = IdEl.stringValue;
                                    
                                }
                                
                                NSArray *pages = [notee elementsForName:@"Page"];
                                
                                if (pages.count > 0) {
                                    
                                    GDataXMLElement *pageEl = (GDataXMLElement *) [pages objectAtIndex:0];
                                    
                                    notepage = pageEl.stringValue;
                                    
                                }
                                
                                NSArray *noteMSGs = [notee elementsForName:@"Text"];
                                
                                if (noteMSGs.count > 0) {
                                    
                                    GDataXMLElement *noteMSGEl = (GDataXMLElement *) [noteMSGs objectAtIndex:0];
                                    
                                    noteMSG = noteMSGEl.stringValue;
                                    
                                }
                                
                                CGPoint ptLeftTop;
                                
                                ptLeftTop.x=[noteX intValue];
                                
                                ptLeftTop.y=[noteY intValue];
                                
                                note* noteObj=[[note alloc]initWithName:ptLeftTop.x ordinate:ptLeftTop.y note:noteMSG PageNb:notepage.intValue AttachmentId:att.AttachmentId.intValue Id:noteId];
                                [mainDelegate.IncomingNotes addObject:noteObj];
                                
                            }
                            
                            NSArray *Highlights = [annotationsEl nodesForXPath:@"Highlights" error:nil];
                            
                            GDataXMLElement *HighlightsXML;
                            
                            if(Highlights.count>0){
                                
                                HighlightsXML = [Highlights objectAtIndex:0];
                                
                            }
                            
                            NSArray *HighlightXML = [HighlightsXML elementsForName:@"Highlight"];
                            
                            NSString *HighlightX1;
                            
                            NSString *HighlightY1;
                            
                            NSString *HighlightX2;
                            
                            NSString *HighlightY2;
                            
                            NSString *Highlightpage;
                            
                            NSString *HighlightId;

                            
                            for(GDataXMLElement *Highlight in HighlightXML)
                            {
                                NSArray *HighlightX1s = [Highlight elementsForName:@"X"];
                                
                                if (HighlightX1s.count > 0) {
                                    
                                    GDataXMLElement *HighlightX1El = (GDataXMLElement *) [HighlightX1s objectAtIndex:0];
                                    
                                    HighlightX1= HighlightX1El.stringValue;
                                    
                                }
                                
                                
                                NSArray *HighlightX2s = [Highlight elementsForName:@"Y"];
                                
                                if (HighlightX2s.count > 0) {
                                    
                                    GDataXMLElement *HighlightX2El = (GDataXMLElement *) [HighlightX2s objectAtIndex:0];
                                    
                                    HighlightX2= HighlightX2El.stringValue;
                                    
                                }
                                
                                
                                NSArray *HighlightY1s = [Highlight elementsForName:@"Z"];
                                
                                if (HighlightY1s.count > 0) {
                                    
                                    GDataXMLElement *HighlightY1El = (GDataXMLElement *) [HighlightY1s objectAtIndex:0];
                                    
                                    HighlightY1= HighlightY1El.stringValue;
                                    
                                }
                                
                                NSArray *HighlightY2s = [Highlight elementsForName:@"W"];
                                
                                if (HighlightY2s.count > 0) {
                                    
                                    GDataXMLElement *HighlightY2El = (GDataXMLElement *) [HighlightY2s objectAtIndex:0];
                                    
                                    HighlightY2= HighlightY2El.stringValue;
                                    
                                }
                                
                                NSArray *Ids = [Highlight elementsForName:@"AnnotationId"];
                                
                                if (Ids.count > 0) {
                                    
                                    GDataXMLElement *IdEl = (GDataXMLElement *) [Ids objectAtIndex:0];
                                    
                                    HighlightId = IdEl.stringValue;
                                    
                                }
                                
                                NSArray *Highlightpages = [Highlight elementsForName:@"Page"];
                                
                                if (Highlightpages.count > 0) {
                                    
                                    GDataXMLElement *HighlightpageEl = (GDataXMLElement *) [Highlightpages objectAtIndex:0];
                                    
                                    Highlightpage = HighlightpageEl.stringValue;
                                    
                                }
                                
                                
                                CGPoint ptLeftTop;
                                
                                CGPoint ptRightBottom;
                                
                                ptLeftTop.x=[HighlightX1 intValue];
                                
                                ptLeftTop.y=[HighlightY1 intValue];
                                
                                ptRightBottom.x=[HighlightX2 intValue];
                                
                                ptRightBottom.y=[HighlightY2 intValue];
                                
                                HighlightClass* obj=[[HighlightClass alloc]initWithName:ptLeftTop.x ordinate:ptRightBottom.x height:ptLeftTop.y width:ptRightBottom.y PageNb:Highlightpage.intValue AttachmentId:att.AttachmentId.intValue Id:HighlightId];
                                [mainDelegate.IncomingHighlights addObject:obj];
                                
                            }
                        }
                        FPDF_PAGE tempPage=[m_pdfdoc getPDFPage:currentPage-1];
//                        if(mainDelegate.IncomingHighlights.count>0||mainDelegate.Highlights.count>0)
                        [m_pdfdoc deleteAllAnnot];
                        for(HighlightClass* obj in mainDelegate.IncomingHighlights){
                            XH=CGPointMake(obj.abscissa, obj.ordinate);
                            YH=CGPointMake(obj.x1, obj.y1);
                            FPDF_PAGE m_curPage = [m_pdfdoc getPDFPage:obj.PageNb];
                            
                            [m_pdfdoc setCurPage:m_curPage];
                            [obj setIndex:[mainDelegate.IncomingHighlights indexOfObject:obj]];
                            
                            [m_pdfdoc AddHighlightAnnot:XH secondPoint:YH previousPoint:ZH];
                            mainDelegate.highlightNow=NO;
                        }
                        for(note* obj in mainDelegate.IncomingNotes){
                            FPDF_PAGE m_curPage = [m_pdfdoc getPDFPage:obj.PageNb];
                            
                            [m_pdfdoc setCurPage:m_curPage];
                            CGPoint point=CGPointMake(obj.abscissa, obj.ordinate);
                            [m_pdfdoc AddNote:point secondPoint:point  note:obj.note];
                            mainDelegate.highlightNow=NO;
                        }
                        [mainDelegate.Highlights removeAllObjects];
                        [mainDelegate.Notes removeAllObjects];
                        [m_pdfdoc setCurPage:tempPage];
                        NSString* dir  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                        dir = [dir stringByAppendingString:@"/FoxitSaveAnnotation.pdf"];
                        [att saveinDirectory:corr.Id strUrl:dir];
                        if(signedfileinfo.count>0)
                            [self refreshAfterSign:att correspondenceId:corr.Id];
                        [self ShowMessage:NSLocalizedString(@"Alert.SaveSuccess", @"Saved Successfully")];
                        
                        [self performSelectorOnMainThread:@selector(dismiss) withObject:@"" waitUntilDone:YES];
                    }
                }else{
                     [self ShowMessage:NSLocalizedString(@"Alert.SaveSuccess", @"Saved Successfully")];
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
    CCorrespondence *correspondence;
    if(self.menuId!=100){
        correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[docId.intValue];
    }else{
        correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
    }
    CAttachment *fileToOpen=correspondence.attachmentsList[self.attachmentId];
    [m_pdfview setAttachmentId:fileToOpen.AttachmentId.intValue];
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
            
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"TransferId\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[correspondence.TransferId dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"AttachmentId\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[fileToOpen.AttachmentId dataUsingEncoding:NSUTF8StringEncoding]];
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
                if(!mainDelegate.isOfflineMode){
                    if(![validationResult isEqualToString:@"OK"]){
                        
                        if([validationResult isEqualToString:@"Cannot access to the server"]){
                            [self ShowMessage:validationResult];
                        }
                        else{
                            [self ShowMessage:validationResult];
                        }
                    }else{
                        if ( [[NSFileManager defaultManager] isReadableFileAtPath:pathToDelete] ){

                          //  [[NSFileManager defaultManager] removeItemAtPath:pathToDelete error:nil];
                            
                            
                        }
                        [self ShowMessage:@"Saved Successfully"];
                        [self dismiss];
                        
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
            case Highlight:{
                CCorrespondence *correspondence;
                if(self.menuId!=100){
                    correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
                }else{
                    correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
                }
                CAttachment *fileToOpen=correspondence.attachmentsList[self.attachmentId];
                [m_pdfview setAttachmentId:fileToOpen.AttachmentId.intValue];
                
                mainDelegate.isAnnotated=YES;
                [m_pdfview setBtnHighlight:YES];
                [m_pdfview setBtnNote:NO];
                [m_pdfview setBtnSign:NO];
                [m_pdfview setBtnErase:NO];
                [m_pdfview setHandsign:NO];
                [self EnableSwipe];
                break;
            }
            case Sign:{
                mainDelegate.isAnnotated=YES;
                [m_pdfview setBtnHighlight:NO];
                [m_pdfview setBtnNote:NO];
                [m_pdfview setBtnErase:NO];
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
                [m_pdfview setHandsign:NO];
                [self EnableSwipe];
                mainDelegate.isAnnotated=YES;
                
                NoteAlertView *noteView = [[NoteAlertView alloc] initWithFrame:CGRectMake(0, 300, 400, 250) fromComment:NO];
                noteView.modalPresentationStyle = UIModalPresentationFormSheet;
                noteView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:noteView animated:YES completion:nil];
                noteView.preferredContentSize=CGSizeMake(400, 250);
                //noteView.view.superview.frame = CGRectMake(300, 300, 400, 250);
                UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
                if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
                    noteView.view.superview.frame = CGRectMake(150, 300, 400, 250);
                } else {
                    noteView.view.superview.frame = CGRectMake(300, 300, 400, 250);
                }
                
                noteView.delegate=self;
            }
                break;
            case Erase:{
                [m_pdfview setBtnHighlight:NO];
                [m_pdfview setBtnNote:NO];
                [m_pdfview setBtnSign:NO];
                [m_pdfview setBtnErase:YES];
                CCorrespondence*correspondence;
                if(self.menuId!=100){
                    correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
                }else{
                    correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
                }
                CAttachment *fileToOpen=correspondence.attachmentsList[self.attachmentId];
                m_pdfdoc.Correspondence=correspondence;
                m_pdfdoc.Attachment=fileToOpen;
            }
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

//
//-(void)savebuiltIn{
//    [self EnableSwipe];
//
//    mainDelegate.isAnnotated=NO;
//
//    @try {
//
//        CCorrespondence *correspondence;
//
//
//        if(self.menuId!=100){
//
//            correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
//
//        }else{
//
//            correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
//
//        }
//
//        NSMutableArray* thumbnailrarray = [[NSMutableArray alloc] init];
//
//
//
//
//
//        if (correspondence.attachmentsList.count>0)
//
//        {
//
//            for(CAttachment* doc in correspondence.attachmentsList)
//
//            {
//
//                if([doc.FolderName isEqualToString:mainDelegate.FolderName]){
//
//                    [thumbnailrarray addObject:doc];
//
//                }
//
//
//
//
//
//            }
//
//        }
//
//
//
//        CAttachment *attachment=thumbnailrarray[self.attachmentId];
//
//        if([mainDelegate.AnnotationsMode isEqualToString:@"CustomAnnotations"]&&[mainDelegate.SignMode isEqualToString:@"BuiltInAnnotations"]){
//            [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Processing",@"Processing ...") maskType:SVProgressHUDMaskTypeBlack];
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//
//                NSString* dir  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//
//                NSString* path;
//                if(m_pdfview.handsign||m_pdfview.btnSign){
//                    path= [self saveSignature:attachment correspondenceId:correspondence.Id];
//                }
//                //                else if (m_pdfview.btnSign){
//                //                    path= [self saveSignature:attachment correspondenceId:correspondence.Id];
//                //                }
//                else
//                    path= [dir stringByAppendingString:@"/FoxitSaveAnnotation.pdf"];
//
//
//
//
//
//                NSData* annotData= [NSData dataWithContentsOfFile:path];
//
//                [Base64 initialize];
//
//                NSString *annotString64=[Base64 encode:annotData];
//
//                NSError *error;
//
//                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//
//                                                                     NSUserDomainMask, YES);
//
//                NSString *documentsDirectory = [paths objectAtIndex:0];
//
//                NSString *documentsPath = [documentsDirectory
//
//                                           stringByAppendingPathComponent:@"annotations.xml"];
//
//
//
//                NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:documentsPath];
//
//
//
//                GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
//
//                BOOL isFound=NO;
//
//                GDataXMLElement* rootEl  = [doc rootElement];
//
//
//
//
//
//                rootEl =[GDataXMLNode elementWithName:@"Documents" stringValue:@""];
//
//
//
//
//
//
//
//                NSArray *allDocuments=[rootEl elementsForName:@"Document"];
//
//                GDataXMLElement *docEl;
//
//                if(allDocuments.count>0){
//
//                    for(docEl in allDocuments){
//
//
//
//                        NSArray *correspondenceIds=[docEl elementsForName:@"CorrespondenceId"];
//
//                        GDataXMLElement *correspondenceIdEl=[correspondenceIds objectAtIndex:0];
//
//
//
//                        NSArray *docIds=[docEl elementsForName:@"DocId"];
//
//                        GDataXMLElement *docIdEl=[docIds objectAtIndex:0];
//
//
//
//                        if([correspondenceIdEl.stringValue isEqualToString:correspondence.Id] && [docIdEl.stringValue isEqualToString:attachment.docId]){
//
//                            isFound=YES;
//
//                            NSArray *contents=[docEl elementsForName:@"Content"];
//
//                            GDataXMLElement *contentEl;
//
//                            if(contents.count>0){
//
//                                contentEl=[contents objectAtIndex:0];
//
//                                contentEl.stringValue=annotString64;
//
//                            }
//
//                        }
//
//
//
//
//
//                    }
//
//
//
//                }
//
//
//
//                if(isFound==NO){
//
//                    docEl=[GDataXMLNode elementWithName:@"Document" stringValue:@""];
//                    CAttachment *fileToOpen=correspondence.attachmentsList[self.attachmentId];
//                    [m_pdfview setAttachmentId:fileToOpen.AttachmentId.intValue];
//
//
//                    GDataXMLElement *correspondenceIdEl=[GDataXMLNode elementWithName:@"CorrespondenceId" stringValue:correspondence.Id];
//
//                    [docEl addChild:correspondenceIdEl];
//
//                    GDataXMLElement *docIdEl=[GDataXMLNode elementWithName:@"DocId" stringValue:attachment.docId];
//
//                    [docEl addChild:docIdEl];
//
//                    GDataXMLElement *urlEl=[GDataXMLNode elementWithName:@"Url" stringValue:attachment.url];
//
//                    [docEl addChild:urlEl];
//
//                    GDataXMLElement *AttachmentId=[GDataXMLNode elementWithName:@"AttachmentId" stringValue:fileToOpen.AttachmentId];
//
//                    [docEl addChild:AttachmentId];
//
//                    GDataXMLElement *TransferId=[GDataXMLNode elementWithName:@"TransferId" stringValue:correspondence.TransferId];
//
//                    [docEl addChild:TransferId];
//
//                    GDataXMLElement *contentEl=[GDataXMLNode elementWithName:@"Content" stringValue:annotString64];
//
//                    [docEl addChild:contentEl];
//
//                    [rootEl addChild:docEl];
//
//                }
//
//
//
//                GDataXMLDocument *document2 = [[GDataXMLDocument alloc]
//
//                                               initWithRootElement:rootEl] ;
//
//                NSData *xmlData2 = document2.XMLData;
//
//
//
//                NSLog(@"Saving xml data to %@...", documentsPath);
//
//                [xmlData2 writeToFile:documentsPath atomically:YES];
//
//
//
//
//
//
//                if(!m_pdfview.handsign&&!m_pdfview.btnSign)
//                {
//                    NSFileManager* fileManager=[NSFileManager defaultManager];
//
//
//
//                    if ( [[NSFileManager defaultManager] isReadableFileAtPath:path] ){
//
//                        [fileManager removeItemAtPath:attachment.tempPdfLocation error:nil];
//
//                        [[NSFileManager defaultManager] copyItemAtPath:path toPath:attachment.tempPdfLocation error:nil];
//
//                    }
//
//                }
//                dispatch_async(dispatch_get_main_queue(), ^{
//
//                    if(!mainDelegate.isOfflineMode)
//                        [self uploadXml:correspondence.Id];
//                    else{
//                        [CParser cacheBuiltInActions:correspondence.Id action:@"annotations" xml:nil];
//                        [SVProgressHUD dismiss];
//                    }
//                });
//
//            });
//        }
//
//
//
//    }
//
//    @catch (NSException *ex) {
//
//        [FileManager appendToLogView:@"ReaderViewController" function:@"saveAnnotation" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
//
//    }
//
//
//}


-(void)saveAnnotation{
    [self EnableSwipe];
  
    mainDelegate.isAnnotated=NO;
    @try {
        
        CCorrespondence *correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
        
       
        CAttachment *attachment=correspondence.attachmentsList[self.attachmentId];
        if (mainDelegate.DrawLayerViews.count==0&& mainDelegate.Highlights.count==0 && mainDelegate.Notes.count==0){
            [self ShowMessage:NSLocalizedString(@"NothingToSave", @"nothing to save")];
            return;
        }
        if([mainDelegate.AnnotationsMode isEqualToString:@"BuiltInAnnotations"]&&[mainDelegate.SignMode isEqualToString:@"BuiltInSign"]){
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Processing",@"Processing ...") maskType:SVProgressHUDMaskTypeBlack];
          
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                
                
                NSString* dir  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                
                NSString* path;
                if(mainDelegate.DrawLayerViews.count>0){
                    path= [self saveSignature:attachment correspondenceId:correspondence.Id];
                }
                else
                    path= [dir stringByAppendingString:@"/FoxitSaveAnnotation.pdf"];
                
                pathToDelete=path;
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
                
                
                
                
                
                rootEl =[GDataXMLNode elementWithName:@"Documents" stringValue:@""];
                

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
                    CAttachment *fileToOpen=correspondence.attachmentsList[self.attachmentId];
                    [m_pdfview setAttachmentId:fileToOpen.AttachmentId.intValue];
                    
                    GDataXMLElement *tokenEl=[GDataXMLNode elementWithName:@"token" stringValue:mainDelegate.user.token];
                    
                    [docEl addChild:tokenEl];
                    
                    GDataXMLElement *correspondenceIdEl=[GDataXMLNode elementWithName:@"CorrespondenceId" stringValue:correspondence.Id];
                    
                    [docEl addChild:correspondenceIdEl];
                    
                    GDataXMLElement *docIdEl=[GDataXMLNode elementWithName:@"DocId" stringValue:attachment.docId];
                    
                    [docEl addChild:docIdEl];
                    
                    GDataXMLElement *urlEl=[GDataXMLNode elementWithName:@"Url" stringValue:attachment.url];
                    
                    [docEl addChild:urlEl];
                    
                    GDataXMLElement *AttachmentId=[GDataXMLNode elementWithName:@"AttachmentId" stringValue:fileToOpen.AttachmentId];
                    
                    [docEl addChild:AttachmentId];
                    
                    GDataXMLElement *TransferId=[GDataXMLNode elementWithName:@"TransferId" stringValue:correspondence.TransferId];
                    
                    [docEl addChild:TransferId];
                    
                    GDataXMLElement *contentEl=[GDataXMLNode elementWithName:@"Content" stringValue:annotString64];
                    
                    [docEl addChild:contentEl];
                    
                    
                    
                    [rootEl addChild:docEl];
                    
                }
                
                
                
                GDataXMLDocument *document2 = [[GDataXMLDocument alloc]
                                               
                                               initWithRootElement:rootEl] ;
                
                NSData *xmlData2 = document2.XMLData;
                
                
                
                NSLog(@"Saving xml data to %@...", documentsPath);
                
                [xmlData2 writeToFile:documentsPath atomically:YES];
                
                
                
                
                [mainDelegate.DocumentsPath addObject:path];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if(!mainDelegate.isOfflineMode)
                        [self uploadXml:correspondence.Id];
                    else{
                        [CParser cacheBuiltInActions:correspondence.Id action:@"BuiltInBuiltIn" xml:xmlData2];
                        [SVProgressHUD dismiss];
                        [self ShowMessage:NSLocalizedString(@"Alert.SaveSuccesssavedSuccessfully", @"Saved Successfully")];
                    }
                });
                
            });
        }
        else
            
            if([mainDelegate.AnnotationsMode isEqualToString:@"CustomAnnotations"]&&[mainDelegate.SignMode isEqualToString:@"CustomSign"]){
              
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
                        GDataXMLElement* rootEl =[GDataXMLNode elementWithName:@"DocumentNotes" stringValue:@""];
                        if(mainDelegate.Notes.count>0 || mainDelegate.Highlights.count>0||mainDelegate.DrawLayerViews.count>0){
                            GDataXMLElement *Height=[GDataXMLNode elementWithName:@"Height" stringValue:[NSString stringWithFormat:@"%f",[m_pdfview getHeight]]];
                            GDataXMLElement *Width=[GDataXMLNode elementWithName:@"Width" stringValue:[NSString stringWithFormat:@"%f",[m_pdfview getWidth]]];
                            GDataXMLElement * pageinfo=[GDataXMLNode elementWithName:@"PageInfo" stringValue:@""];
                            GDataXMLElement * Size=[GDataXMLNode elementWithName:@"Size" stringValue:@""];
                            GDataXMLElement * tokenEl= [GDataXMLNode elementWithName:@"token" stringValue:mainDelegate.user.token];
                            
                            [Size addChild:Height];
                            [Size addChild:Width];
                            [pageinfo addChild:Size];
                            [rootEl addChild:tokenEl];
                            [rootEl addChild:pageinfo];
                        }
                        GDataXMLElement* AnnotationsEl =[GDataXMLNode elementWithName:@"Annotations" stringValue:@""];
                        GDataXMLElement * NotesEl=[GDataXMLNode elementWithName:@"Notes" stringValue:@""];
                        GDataXMLElement * HighlightsEl=[GDataXMLNode elementWithName:@"Highlights" stringValue:@""];
                        
                        for(note* note in mainDelegate.Notes){
                            GDataXMLElement *docEl=[GDataXMLNode elementWithName:@"Note" stringValue:@""];
                            GDataXMLElement* noteAttribute=[GDataXMLElement attributeWithName:@"Status" stringValue:note.status];
                            [docEl addAttribute:noteAttribute];
                            GDataXMLElement *AttachmentId=[GDataXMLNode elementWithName:@"AttachmentId" stringValue:[NSString stringWithFormat:@"%d",note.AttachmentId]];
                            [docEl addChild:AttachmentId];
                            
                            GDataXMLElement *pgnb=[GDataXMLNode elementWithName:@"Page" stringValue:[NSString stringWithFormat:@"%d",note.PageNb]];
                            [docEl addChild:pgnb];
                            GDataXMLElement *IdEl=[GDataXMLNode elementWithName:@"AnnotationId" stringValue:note.Id];
                            [docEl addChild:IdEl];
                            GDataXMLElement *x=[GDataXMLNode elementWithName:@"X" stringValue:[NSString stringWithFormat:@"%f",note.abscissa]];
                            [docEl addChild:x];
                            
                            GDataXMLElement *y=[GDataXMLNode elementWithName:@"Y" stringValue:[NSString stringWithFormat:@"%f",note.ordinate]];
                            [docEl addChild:y];
                            
                            GDataXMLElement *notee=[GDataXMLNode elementWithName:@"Text" stringValue:note.note];
                            [docEl addChild:notee];
                            
                            [NotesEl addChild:docEl];
                            
                        }
                        for(HighlightClass* obj in mainDelegate.Highlights){
                            GDataXMLElement *docEl=[GDataXMLNode elementWithName:@"Highlight" stringValue:@""];
                            GDataXMLElement* highlightAttribute=[GDataXMLElement attributeWithName:@"Status" stringValue:obj.status];
                            [docEl addAttribute:highlightAttribute];
                            GDataXMLElement *pgnb=[GDataXMLNode elementWithName:@"Page" stringValue:[NSString stringWithFormat:@"%d",obj.PageNb]];
                            [docEl addChild:pgnb];
                            
                            GDataXMLElement *AttachmentId=[GDataXMLNode elementWithName:@"AttachmentId" stringValue:[NSString stringWithFormat:@"%d",obj.AttachmentId]];
                            [docEl addChild:AttachmentId];
                            GDataXMLElement *IdEl=[GDataXMLNode elementWithName:@"AnnotationId" stringValue:obj.Id];
                            [docEl addChild:IdEl];
                            GDataXMLElement *x=[GDataXMLNode elementWithName:@"X" stringValue:[NSString stringWithFormat:@"%f",obj.abscissa]];
                            [docEl addChild:x];
                            
                            GDataXMLElement *y=[GDataXMLNode elementWithName:@"Y" stringValue:[NSString stringWithFormat:@"%f",obj.ordinate]];
                            [docEl addChild:y];
                            
                            GDataXMLElement *x1=[GDataXMLNode elementWithName:@"Z" stringValue:[NSString stringWithFormat:@"%f",obj.x1]];
                            [docEl addChild:x1];
                            
                            GDataXMLElement *y1=[GDataXMLNode elementWithName:@"W" stringValue:[NSString stringWithFormat:@"%f",obj.y1]];
                            [docEl addChild:y1];
                            [HighlightsEl addChild:docEl];
                            
                        }
                        [AnnotationsEl addChild:NotesEl];
                        [AnnotationsEl addChild:HighlightsEl];
                        [rootEl addChild:AnnotationsEl];
                        
                        
                        GDataXMLElement* SignaturesEl =[GDataXMLNode elementWithName:@"Signatures" stringValue:@""];
                        
                        NSEnumerator *enumerator = [mainDelegate.DrawLayerViews keyEnumerator];
                        id key;
                        while ((key = [enumerator nextObject])) {
                            SPUserResizableView *tmp = [mainDelegate.DrawLayerViews objectForKey:key];
//                            float x=0;
//                            float yy=0;
//                            UIInterfaceOrientation orient=[[UIApplication sharedApplication]statusBarOrientation];
//                            if (UIInterfaceOrientationIsLandscape(orient)) {
//                                
//                                x=tmp.center.x-(tmp.frame.size.width/2);
//                                float y=abs(tmp.center.y-(tmp.frame.size.height/2));
//                                float space=(self.view.bounds.size.width-self.view.bounds.size.width/1.75)/2;
//                                x=x-space;
//                                //x=[CParser pixelToPoints:x];
//                                float xx=x*612/m_pdfview.frame.size.width;
//                                yy=(y*792/m_pdfview.frame.size.height)+tmp.frame.size.height;
//                                yy=792-yy;
//                                xx=xx*0.75;
//                                yy=yy*0.75;
//                            }
//                            else
//                            {
//                                x=tmp.center.x-(tmp.frame.size.width/2);
//                                float y=abs(tmp.center.y-(tmp.frame.size.height/2));
//                                float space=(self.view.bounds.size.width-620)/2;
//
//                                x=x-space;
//                                //x=[CParser pixelToPoints:x];
//                                //float xx=x*612/m_pdfview.frame.size.width;
//                               // yy=(y*792/m_pdfview.frame.size.height)+tmp.frame.size.height;
//                                y=830-y;
//                                x=x*0.75;
//                                yy=y*0.75;
//                            }
                            float x=tmp.center.x-(tmp.frame.size.width/2);
                            float y=abs(tmp.center.y-(tmp.frame.size.height/2));
                            float space=(self.view.bounds.size.width-self.view.bounds.size.width/1.75)/2;
                            x=x-space;
                            //x=[CParser pixelToPoints:x];
                            float xx=x*612/m_pdfview.frame.size.width;
                            float yy=(y*792/m_pdfview.frame.size.height)+tmp.frame.size.height;
                            yy=792-yy;
                            xx=xx*0.75;
                            yy=yy*0.75;
                            NSString *annotString64;
                            if(tmp.contentView!=nil){
                                UIImage* image = [UIImage imageWithCGImage:(__bridge CGImageRef)([tmp.contentView.sigView layer].contents)];
                                NSData* annotData= 	UIImagePNGRepresentation(image);
                                
                                [Base64 initialize];
                                
                                annotString64=[Base64 encode:annotData];
                            }else{
                                UIImage* image = [UIImage imageWithCGImage:(__bridge CGImageRef)([tmp.imageView layer].contents)];
                                NSData* annotData= 	UIImagePNGRepresentation(image);
                                
                                [Base64 initialize];
                                
                                annotString64=[Base64 encode:annotData];
                            }
                            
                            
                            GDataXMLElement * SignatureEl=[GDataXMLNode elementWithName:@"Signature" stringValue:@""];
                            GDataXMLElement *pgnb=[GDataXMLNode elementWithName:@"Page" stringValue:[NSString stringWithFormat:@"%@",key]];
                            [SignatureEl addChild:pgnb];
                            
                            GDataXMLElement *AttachmentId=[GDataXMLNode elementWithName:@"AttachmentId" stringValue:[NSString stringWithFormat:@"%d",attachment.AttachmentId.intValue]];
                            [SignatureEl addChild:AttachmentId];
                            
                            
                            GDataXMLElement *contentEl=[GDataXMLNode elementWithName:@"Content" stringValue:annotString64];
                            [SignatureEl addChild:contentEl];
                            
                            
                            GDataXMLElement *xEl=[GDataXMLNode elementWithName:@"X" stringValue:[NSString stringWithFormat:@"%f",x]];
                            [SignatureEl addChild:xEl];
                            
                            GDataXMLElement *yEl=[GDataXMLNode elementWithName:@"Y" stringValue:[NSString stringWithFormat:@"%f",yy]];
                            [SignatureEl addChild:yEl];
                            
                            GDataXMLElement *widthEl=[GDataXMLNode elementWithName:@"width" stringValue:[NSString stringWithFormat:@"%f",tmp.frame.size.width]];
                            [SignatureEl addChild:widthEl];
                            
                            GDataXMLElement *heightEl=[GDataXMLNode elementWithName:@"height" stringValue:[NSString stringWithFormat:@"%f",tmp.frame.size.height]];
                            [SignatureEl addChild:heightEl];
                            
                            [SignaturesEl addChild:SignatureEl];
                            
                        }
                        [rootEl addChild:SignaturesEl];
                        
                        
                        
                        GDataXMLDocument *document2 = [[GDataXMLDocument alloc] initWithRootElement:rootEl] ;
                        
                        NSData *xmlData2 = document2.XMLData;
                        
                        [xmlData2 writeToFile:documentsPath atomically:YES];
                        [mainDelegate.DocumentsPath addObject:documentsPath];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(!mainDelegate.isOfflineMode)
                                [self UploadAnnotations:correspondence.Id];
                            else{
                                [CParser cacheBuiltInActions:correspondence.Id action:@"CustomCustom" xml:xmlData2];
                                [SVProgressHUD dismiss];
                                [self ShowMessage:@"Saved Successfully"];
                                
                            }
                            // [mainDelegate.Highlights removeAllObjects];
                            //   [mainDelegate.Notes removeAllObjects];
                        });
                    });
                }
                
                @catch (NSException *ex) {
                    
                    [FileManager appendToLogView:@"ReaderViewController" function:@"saveAnnotation" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
                    
                }
            
            }
            else{
                
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
                            GDataXMLElement *IdEl=[GDataXMLNode elementWithName:@"AnnotationId" stringValue:note.Id];
                            [docEl addChild:IdEl];
                            GDataXMLElement *pgnb=[GDataXMLNode elementWithName:@"Page" stringValue:[NSString stringWithFormat:@"%d",note.PageNb]];
                            [docEl addChild:pgnb];
                            
                            GDataXMLElement *x=[GDataXMLNode elementWithName:@"X" stringValue:[NSString stringWithFormat:@"%f",note.abscissa]];
                            [docEl addChild:x];
                            
                            GDataXMLElement *y=[GDataXMLNode elementWithName:@"Y" stringValue:[NSString stringWithFormat:@"%f",note.ordinate]];
                            [docEl addChild:y];
                            
                            GDataXMLElement *notee=[GDataXMLNode elementWithName:@"Text" stringValue:note.note];
                            [docEl addChild:notee];
                            
                            [NotesEl addChild:docEl];
                            
                        }
                        for(HighlightClass* obj in mainDelegate.Highlights){
                            GDataXMLElement *docEl=[GDataXMLNode elementWithName:@"Highlight" stringValue:@""];
                            GDataXMLElement* highlightAttribute=[GDataXMLElement attributeWithName:@"status" stringValue:obj.status];
                            [docEl addAttribute:highlightAttribute];
                            GDataXMLElement *pgnb=[GDataXMLNode elementWithName:@"Page" stringValue:[NSString stringWithFormat:@"%d",obj.PageNb]];
                            [docEl addChild:pgnb];
                            
                            GDataXMLElement *AttachmentId=[GDataXMLNode elementWithName:@"AttachmentId" stringValue:[NSString stringWithFormat:@"%d",obj.AttachmentId]];
                            [docEl addChild:AttachmentId];
                            GDataXMLElement *IdEl=[GDataXMLNode elementWithName:@"AnnotationId" stringValue:obj.Id];
                            [docEl addChild:IdEl];
                            GDataXMLElement *x=[GDataXMLNode elementWithName:@"X" stringValue:[NSString stringWithFormat:@"%f",obj.abscissa]];
                            [docEl addChild:x];
                            
                            GDataXMLElement *y=[GDataXMLNode elementWithName:@"Y" stringValue:[NSString stringWithFormat:@"%f",obj.ordinate]];
                            [docEl addChild:y];
                            
                            GDataXMLElement *x1=[GDataXMLNode elementWithName:@"Z" stringValue:[NSString stringWithFormat:@"%f",obj.x1]];
                            [docEl addChild:x1];
                            
                            GDataXMLElement *y1=[GDataXMLNode elementWithName:@"W" stringValue:[NSString stringWithFormat:@"%f",obj.y1]];
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
                                [CParser cacheBuiltInActions:correspondence.Id action:@"BuiltInBuiltIn" xml:nil];
                                [SVProgressHUD dismiss];
                                
                            }
                            // [mainDelegate.Highlights removeAllObjects];
                            //   [mainDelegate.Notes removeAllObjects];
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
    if (mainDelegate==nil) mainDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    @try{
        CCorrespondence *correspondence;
        if(!mainDelegate.QuickActionClicked){
            
            if(self.menuId!=100){
                correspondence= ((CMenu*)mainDelegate.user.menu[self.menuId]).correspondenceList[self.correspondenceId];
            }else{
                correspondence=mainDelegate.searchModule.correspondenceList[self.correspondenceId];
            }
        }
        else{
            correspondence=mainDelegate.searchModule.correspondenceList[mainDelegate.QuickActionIndex];
        }
        
        NSString* params;
        NSString* url;
        if(mainDelegate.SupportsServlets){
            params=[NSString stringWithFormat:@"action=ExecuteCustomActions&token=%@&correspondenceId=%@&TransferId=%@&actionType=%@&note=%@&language=%@", mainDelegate.user.token,correspondence.Id,correspondence.TransferId,action,Note,mainDelegate.IpadLanguage.lowercaseString];
            url = [NSString stringWithFormat:@"http://%@?%@",mainDelegate.serverUrl,params];
            
        }
        else{
            params=[NSString stringWithFormat:@"ExecuteCustomActions?token=%@&correspondenceId=%@&TransferId=%@&actionType=%@&note=%@&language=%@", mainDelegate.user.token,correspondence.Id,correspondence.TransferId,action,Note,mainDelegate.IpadLanguage.lowercaseString];
            url = [NSString stringWithFormat:@"http://%@/%@",mainDelegate.serverUrl,params];
            
        }
        if(!mainDelegate.isOfflineMode){
            
            //  NSURL *xmlUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            //   NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
            NSData *xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            
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
                    
                    
                    // NSURL *xmlUrl = [NSURL URLWithString:correspondenceUrl];
                    // NSData *menuXmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlUrl];
                    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[correspondenceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:0 timeoutInterval:mainDelegate.Request_timeOut];
                    NSData *menuXmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                    NSMutableDictionary *correspondences=[CParser loadCorrespondencesWithData:menuXmlData];
                    
                    
                    mainDelegate.searchModule.correspondenceList = [correspondences objectForKey:[NSString stringWithFormat:@"%d",mainDelegate.selectedInbox]];
                    
                    
                    
                    
                    
                }
                [self ShowMessage:NSLocalizedString(@"Alert.ActionSuccess",@"Action successfuly done.")];
                
            }
        }else{
            
            [CParser cacheOfflineActions:correspondence.Id url:url action:action];
            [SVProgressHUD dismiss];
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
        [mainDelegate.Highlights removeAllObjects];
        [mainDelegate.Notes removeAllObjects];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSError *error = nil;
        NSFileManager *fm = [NSFileManager defaultManager];
        for (NSString *file in [fm contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, file] error:&error];
            if (!success || error) {
                NSLog(@"%@",error);
            }
        }

    }
    
}
-(void)ShowHidePageBar{
    [mainToolbar hideToolbar];
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
        UploadControllerDialog *uploadDialog = [[UploadControllerDialog alloc] initWithFrame:CGRectMake(300, 200, 400, 400)];
        uploadDialog.modalPresentationStyle = UIModalPresentationFormSheet;
        uploadDialog.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        uploadDialog.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self presentViewController:uploadDialog animated:YES completion:nil];

            uploadDialog.preferredContentSize=CGSizeMake(400, 400);

        uploadDialog.CorrespondenceId=correspondence.Id;
        [uploadDialog setCorrespondenceIndex:self.correspondenceId];
        uploadDialog.quickActionSelected=NO;
        
        uploadDialog.delegate=self;

    }
}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar attachmentButton:(UIButton *)button
{
    CGRect buttonRect=CGRectMake(button.frame.origin.x, button.frame.origin.y+button.frame.size.height, button.frame.size.width, button.frame.size.height);
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
        CAttachment* currentAttachment=correspondence.attachmentsList[self.attachmentId];

        AttachmentViewController *uploadViewController=[[AttachmentViewController alloc]initWithStyle:UITableViewStylePlain];
        uploadViewController.NewBtnStatus=currentAttachment.Status;
        self.notePopController = [[UIPopoverController alloc] initWithContentViewController:uploadViewController];
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            self.notePopController.popoverContentSize = CGSizeMake(190, 50*correspondence.AttachmentsListMenu.count);

        }
        else
       self.notePopController.popoverContentSize = CGSizeMake(230, 50*correspondence.AttachmentsListMenu.count);
        // self.notePopController.popoverContentSize = CGSizeMake(300, 50*correspondence.AttachmentsListMenu.count);
        //        [self.notePopController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [self.notePopController presentPopoverFromRect:buttonRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        uploadViewController.actions=correspondence.AttachmentsListMenu;
        uploadViewController.delegate=self;
    }
    
}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar lockButton:(UIButton *)button message:(NSString*)msg
{
    [self ShowMessage:msg];
}




- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar annotationButton:(UIButton *)button{
    CGRect buttonRect=CGRectMake(button.frame.origin.x, button.frame.origin.y+button.frame.size.height, button.frame.size.width, button.frame.size.height);
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
    

        self.notePopController.popoverContentSize = CGSizeMake(160, 50*annotProperties.count+50);
    [self.notePopController presentPopoverFromRect:buttonRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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
    transferView.preferredContentSize=CGSizeMake(450, 470);
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation])) {
            transferView.view.superview.frame = CGRectMake(200, 300, 450, 470);
        }
        else
        transferView.view.superview.frame = CGRectMake(300, 200, 450, 470); //it's important to do this after presentModalViewController
    }else{
         transferView.preferredContentSize=CGSizeMake(450, 470);
        
    }
    //transferView.view.superview.frame = CGRectMake(300, 200, 450, 470); //it's important to do this after presentModalViewController
    transferView.delegate=self;
}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar SignActionButton:(UIButton *)button{
    
    CGRect buttonRect=CGRectMake(button.frame.origin.x, button.frame.origin.y+button.frame.size.height, button.frame.size.width, button.frame.size.height);
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
    if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
        self.notePopController.popoverContentSize = CGSizeMake(175, 50*correspondence.SignActions.count);

    }
    else
    self.notePopController.popoverContentSize = CGSizeMake(160, 50*correspondence.SignActions.count);
    //    [self.notePopController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [self.notePopController presentPopoverFromRect:buttonRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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
    [m_pdfview setBtnHighlight:NO];
    [m_pdfview setBtnNote:NO];
    [m_pdfview setBtnSign:NO];
    [m_pdfview setBtnErase:NO];
    [self EnableSwipe];
    [self saveAnnotation];
    
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar MoreButton:(UIButton *)button
{
        CGRect buttonRect=CGRectMake(button.frame.origin.x, button.frame.origin.y+button.frame.size.height, button.frame.size.width, button.frame.size.height);
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
	self.notePopController.popoverContentSize = CGSizeMake(230, 50*correspondence.actions.count);
    
    
	[self.notePopController presentPopoverFromRect:buttonRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
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
        [action setLookupId:item.LookupId];
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
        self.notePopController.popoverContentSize = CGSizeMake(230, 50*customViewController.actions.count);
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
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            
            AcceptView.view.superview.frame = CGRectMake(300, 200, 450, 370); //it's important to do this
        }
        else
            AcceptView.preferredContentSize=CGSizeMake(450, 370);
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

-(void)movehome:(UITableViewController *)viewcontroller{
    
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

    float factor=1;
    [mainToolbar hideToolbar];
    if( mainPagebar.hidden==false){
        [mainPagebar removeFromSuperview];
        mainPagebar.hidden=true;
    }
    [self.noteContainer removeFromSuperview];
    [metadataContainer removeFromSuperview];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        factor=1;
        if(PdfScroll.zoomScale<=PdfScroll.minimumZoomScale){
            m_pdfview.frame=CGRectMake ((self.view.bounds.size.width-self.view.bounds.size.width/factor)/2, 5, self.view.bounds.size.width/factor, self.view.bounds.size.height-5);
            
            PdfScroll.frame=m_pdfview.frame;
            numberPages.frame = CGRectMake(m_pdfview.frame.size.width+m_pdfview.frame.origin.x-80, 950, 80, 40);
            openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 30);
            [self centreView];
        }

    }
    
        isMetadataVisible=!isMetadataVisible;
    
}


-(void)hide{
    if (isMetadataVisible)
    [self closeMetadata];
        
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar metadataButton:(UIButton *)button
{
    [self openMetaData];

    
}
-(void) openMetaData
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
//            m_pdfview.frame=CGRectMake ((self.view.bounds.size.width-self.view.bounds.size.width/1.75)/2, 5, self.view.bounds.size.width/1.75, self.view.bounds.size.height-5);
//            PdfScroll.frame=m_pdfview.frame;
            
            
        }
        else{
            CGRect viewRect = CGRectMake(0,0, 200, self.view.bounds.size.height);
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
            metadataContainer=[[UIView alloc]initWithFrame:CGRectMake(0,0,200, self.view.bounds.size.height )];
            
            UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
            if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
                close.frame = CGRectMake(8, 10, 20, 20);
            else
                close.frame = CGRectMake(metadataContainer.frame.origin.x+metadataContainer.frame.size.width-30, 10, 20, 20);
            [close setBackgroundImage:[UIImage imageNamed:@"delete_item.png"] forState:UIControlStateNormal];
            [close addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
            [close setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            metadataContainer=[[UIView alloc]initWithFrame:CGRectMake(0,0,200, self.view.bounds.size.height )];
            
            
            [metadataContainer addSubview:metadataTable.view];
            [metadataContainer addSubview:close];
            [self.view addSubview:metadataContainer];

//            m_pdfview.frame=CGRectMake(320+(self.view.bounds.size.width-(320+m_pdfview.frame.size.width))/2, 0, m_pdfview.frame.size.width, m_pdfview.frame.size.height);
//            PdfScroll.frame=m_pdfview.frame;
            
            //jis orientation
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
                [metadataContainer removeFromSuperview];
                [self.view addSubview:metadataContainer];
                m_pdfview.frame=CGRectMake (225, 0, self.view.bounds.size.width/1.50, self.view.bounds.size.height-5);
                PdfScroll.frame=m_pdfview.frame;
                
                metadataContainer.frame=CGRectMake(0, 0, 200, 1019);
               // numberPages.frame = CGRectMake(360, 950, 80, 40);
                numberPages.frame = CGRectMake(m_pdfview.frame.size.width+m_pdfview.frame.origin.x-300, 950, 80, 40);
                openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 30);
            }
        }
        [self centreView];
        
        isMetadataVisible=!isMetadataVisible;
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"metadataButton" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }

}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar searchButton:(UIButton *)button
{
    //
    //    [self.noteContainer removeFromSuperview];
    //    for (UIView *view in theScrollView.subviews)
    //    {
    //        if ([view isKindOfClass:[ReaderContentView class]])
    //            view.hidden=YES;
    //    }
    //
    
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
        
//        UIXToolbarShadow *shadowView = [[UIXToolbarShadow alloc] initWithFrame:shadowRect];
//        
//        [self.noteContainer addSubview:shadowView];
        
        
        
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
    noteView.view.superview.frame = CGRectMake(300, 300, 400, 250); 
    noteView.delegate=self;
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar nextButton:(UIButton *)button documentReader:(ReaderDocument *)newdocument correspondenceId:(NSInteger)correspondenceId attachementId:(NSInteger)attachementId
{
    currentPage=1;
    [self loadNewDocumentReader:newdocument attachementId:attachementId];
    
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar previousButton:(UIButton *)button documentReader:(ReaderDocument *)newdocument correspondenceId:(NSInteger)correspondenceId attachementId:(NSInteger)attachementId
{
    currentPage=1;
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
	//[self showDocumentPage:page]; // Show the page
}

#pragma mark ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page document:(ReaderDocument*)newdocument fileId:(NSInteger)fileId
{
    @try{
        document=newdocument;
        [numberPages setTitle:[NSString stringWithFormat:@"1 of %@",document.pageCount] forState:UIControlStateNormal];
       // self.attachmentId=fileId;
        contentViews = [NSMutableDictionary new];
        currentPage=1;
        for (UIView *view in self.view.subviews)
        {
            if (![view isKindOfClass:[mainToolbar class]] && ![view isKindOfClass:[mainPagebar class]])
                [view removeFromSuperview];
        }
        
        lastHideTime = [NSDate date];
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
            // [m_pdfview setBtnSign:NO];
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
-(void)cancelSign{
    lastEditedView=[mainDelegate.DrawLayerViews objectForKey:[NSString stringWithFormat:@"%d",[m_pdfview GetPageIndex]]];
    [mainDelegate.DrawLayerViews removeObjectForKey:[NSString stringWithFormat:@"%d",[m_pdfview GetPageIndex]]];
    [lastEditedView removeFromSuperview];
    if(mainDelegate.DrawLayerViews.count<=0){
        [m_pdfview setBtnSign:NO];
        [m_pdfview setHandsign:NO];
    }
    [self EnableSwipe];
    
}
-(void) cancelAll
{
    NSEnumerator *enumerator = [mainDelegate.DrawLayerViews keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        SPUserResizableView *tmp = [mainDelegate.DrawLayerViews objectForKey:key];
        [tmp removeFromSuperview];
       
    }
    [mainDelegate.DrawLayerViews removeAllObjects];
    if(mainDelegate.DrawLayerViews.count<=0){
        [m_pdfview setBtnSign:NO];
        [m_pdfview setHandsign:NO];
    }
    [self EnableSwipe];

}
-(void) DuplicateSignature{
    for(size_t page = 0; page < [document.pageCount intValue]; page++)
    {
        if(page!=currentPage-1){
            SPUserResizableView* EditedView = [[SPUserResizableView alloc] initWithFrame: lastEditedView.frame];
            UIImage*image;
            if(m_pdfview.btnSign)
                image=[UIImage imageWithData:m_pdfdoc.signatureData];
            else
                image=lastEditedView.contentView.sigView.image;
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            
            EditedView.imageView = imageView;
            
            EditedView.delegate=self;
            [mainDelegate.DrawLayerViews setObject:EditedView forKey:[NSString stringWithFormat:@"%zu",page]];
        }
    }
}
-(void)Sign{
    [self hide];
    [Base64 initialize];
    NSData* imgData;
    if (mainDelegate.user.signature==nil || [mainDelegate.user.signature isEqualToString:@""]) {
        
        [self  ShowMessage:NSLocalizedString(@"Alert.PredefinedSignature", @"Add a Predefined Signature")];
    }
    else
    {
    UIImage *image=[UIImage imageWithData:[Base64 decode:mainDelegate.user.signature]];
    
    imgData=UIImagePNGRepresentation(image);
    [m_pdfdoc setSignatureData:imgData];
    [m_pdfview setBtnHighlight:NO];
    
    [m_pdfview setBtnNote:NO];
    [m_pdfview setBtnSign:YES];
        [m_pdfview setBtnErase:NO];

    if(m_pdfview.handsign){
        m_pdfview.btnSign=NO;
        [self ShowMessage:@"you already chosen hand Signature.\nPlease save or cancel Default hand signature first."];
        return;
    }
  //  [self DisableSwipe];
    float factor;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        factor=1;
        m_pdfview.frame=CGRectMake ((self.view.bounds.size.width-612)/2, 0, 612, 792);
        PdfScroll.frame=m_pdfview.frame;
        numberPages.frame = CGRectMake((self.view.bounds.size.width-612)/2+452, 720, 80, 30);
        openButton.frame = CGRectMake((m_pdfview.frame.origin.x+m_pdfview.frame.size.width/2)-100, 0, 200, 30);
    }else{
        factor=1.75;
        m_pdfview.frame=CGRectMake ((self.view.bounds.size.width-self.view.bounds.size.width/factor)/2, 5, self.view.bounds.size.width/factor, self.view.bounds.size.height-5);
        PdfScroll.frame=m_pdfview.frame;
    }
    
    [self centreView];
    metadataContainer.frame=CGRectMake(0, 0, 320, 1019);
    openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 30);
    
    
    
    lastEditedView=[mainDelegate.DrawLayerViews objectForKey:[NSString stringWithFormat:@"%d",[m_pdfview GetPageIndex]]];
    CGRect imageFrame ;
    if(lastEditedView==nil){
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
            imageFrame = CGRectMake((self.view.bounds.size.width-612)/2, 35,200, 200 );
            
        }
        else{
            imageFrame = CGRectMake(219, 35, 200, 200);
        }
        lastEditedView = [[SPUserResizableView alloc] initWithFrame:imageFrame];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:m_pdfdoc.signatureData]];
        
        lastEditedView.imageView = imageView;
        lastEditedView.delegate = self;
        [mainDelegate.DrawLayerViews setObject:lastEditedView forKey:[NSString stringWithFormat:@"%d",[m_pdfview GetPageIndex]]];
    }
    
    [self.view addSubview:lastEditedView];
    [self.view bringSubviewToFront:openButton];
    [mainToolbar hideToolbar];
    }
}
-(void)HideToolbar{
    [mainToolbar hideToolbar];
    [self hide];
    if ( (mainPagebar.hidden == NO))
    {
        folderPagebar.hidden = true;
        mainPagebar.hidden=true;
        [mainPagebar removeFromSuperview];
        
    }
    
}
-(void)HandSign{
    [self hide];
    [m_pdfview setBtnErase:NO];

    if(m_pdfview.btnSign){
        
        m_pdfview.handsign=NO;
        [self ShowMessage:@"you already chosen Default Signature.\nPlease save or cancel Default signature first."];
        return;
    }
    float factor;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        factor=1;
        m_pdfview.frame=CGRectMake ((self.view.bounds.size.width-612)/2, 0, 612, 792);
        PdfScroll.frame=m_pdfview.frame;
        numberPages.frame = CGRectMake((self.view.bounds.size.width-612)/2+452, 720, 80, 30);
        openButton.frame = CGRectMake((m_pdfview.frame.origin.x+m_pdfview.frame.size.width/2)-100, 0, 200, 30);
    }else{
        factor=1.75;
        m_pdfview.frame=CGRectMake ((self.view.bounds.size.width-self.view.bounds.size.width/factor)/2, 5, self.view.bounds.size.width/factor, self.view.bounds.size.height-5);
        PdfScroll.frame=m_pdfview.frame;
    }
    
    
    [self centreView];
    metadataContainer.frame=CGRectMake(0, 0, 320, 1019);
    //numberPages.frame = CGRectMake(self.view.frame.size.width-263, 720, 80, 30);    openButton.frame = CGRectMake(m_pdfview.frame.size.width/2-100, 0, 200, 30);
    [self DisableSwipe];
    lastEditedView=[mainDelegate.DrawLayerViews objectForKey:[NSString stringWithFormat:@"%d",[m_pdfview GetPageIndex]]];
    if(lastEditedView==nil){
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
            drawLayer=[[DrawLayerView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-612)/2, 35,200, 200 )];
            lastEditedView = [[SPUserResizableView alloc] initWithFrame: CGRectMake((self.view.bounds.size.width-612)/2, 35, 200, 200)];
            
        }
        else{
            drawLayer=[[DrawLayerView alloc]initWithFrame:CGRectMake(219, 35,200, 200 )];
            lastEditedView = [[SPUserResizableView alloc] initWithFrame: CGRectMake(219, 35, 200, 200)];
        }
        //drawLayer=[[DrawLayerView alloc]initWithFrame:CGRectMake (219,35,585,763)];
        //   UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sync.png"]];
        lastEditedView.contentView = drawLayer;
        
        lastEditedView.delegate = self;
        [mainDelegate.DrawLayerViews setObject:lastEditedView forKey:[NSString stringWithFormat:@"%d",[m_pdfview GetPageIndex]]];
    }
    
   
    [self.view addSubview:lastEditedView];
    
    
    [self.view bringSubviewToFront:openButton];
    [mainToolbar hideToolbar];
    
}
-(void)DisableSwipe{
    swipeRecognizerLeft.enabled = NO;
    swipeLeftRecognizerRight.enabled=NO;
}
-(void)EnableSwipe{
    swipeRecognizerLeft.enabled = YES;
    swipeLeftRecognizerRight.enabled=YES;
}

- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView {
    if(m_pdfview.handsign||m_pdfview.btnSign){
        [currentlyEditingView hideEditingHandles];
        currentlyEditingView = userResizableView;
    }
}

- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView {
    if(m_pdfview.handsign||m_pdfview.btnSign)
        lastEditedView = userResizableView;
    
}
-(void)ResizeiDrawLayer:(CGRect)frame view:(SPUserResizableView *)userResizableView{
    [mainDelegate.DrawLayerViews setObject:userResizableView forKey:[NSString stringWithFormat:@"%d",[m_pdfview GetPageIndex]]];
}


- (void)hideEditingHandles {
    // We only want the gesture recognizer to end the editing session on the last
    // edited view. We wouldn't want to dismiss an editing session in progress.
    if(mainDelegate.DrawLayerViews.count>0){
        if(!mainDelegate.IsInside)
            [lastEditedView hideEditingHandles];
        else
            mainDelegate.IsInside=false;
    }

}

-(NSString*)saveSignature: (CAttachment *)fileToOpen correspondenceId:(NSString*)Id{
    
    if(mainDelegate.DrawLayerViews.count>0){
        
        [mainToolbar updateTitleWithLocation:fileToOpen.location withName:fileToOpen.title];
        NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:Id fromSharepoint:mainDelegate.isSharepoint];
        
        NSURL *url = [NSURL fileURLWithPath:tempPdfLocation];
        CGPDFDocumentRef document1 = CGPDFDocumentCreateWithURL ((__bridge_retained CFURLRef) url);
        
        const size_t numberOfPages = CGPDFDocumentGetNumberOfPages(document1);
        
        NSMutableData* data = [NSMutableData data];
        UIGraphicsBeginPDFContextToData(data, CGRectZero, nil);
        
        for(size_t page = 1; page <= numberOfPages; page++)
        {
            lastEditedView=nil;
            lastEditedView=[mainDelegate.DrawLayerViews objectForKey:[NSString stringWithFormat:@"%zu",page-1]];
            
            if(lastEditedView!=nil){
                lastEditedView.contentView.canvas.layer.borderColor = [UIColor clearColor].CGColor;
                [lastEditedView showEditingHandles];
                [lastEditedView removeFromSuperview];
                
            }
           
            
            //  Get the current page and page frame
            CGPDFPageRef pdfPage = CGPDFDocumentGetPage(document1, page);
            
            const CGRect pageFrame = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
            
            float factor;
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
                factor=1;
            }else{
                factor=1.75;
            }
            float x=(self.view.bounds.size.width-self.view.bounds.size.width/factor)/2;
            UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);
            
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSaveGState(ctx);
            CGContextScaleCTM(ctx, 1, -1);
            CGContextTranslateCTM(ctx, 0, -pageFrame.size.height);
            CGContextDrawPDFPage(ctx, pdfPage);
            CGContextRestoreGState(ctx);
            
            if(lastEditedView!=nil){
                
                
                CGContextSaveGState(ctx);
                CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
                float x1=lastEditedView.center.x-(lastEditedView.frame.size.width/2);
                float y1=abs(lastEditedView.center.y-(lastEditedView.frame.size.height/2));
                float xx,yy;
                if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
                    
                    xx=x1*pageFrame.size.width/(m_pdfview.frame.size.width);
                    yy=y1*pageFrame.size.height/m_pdfview.frame.size.height;
                    CGContextTranslateCTM(ctx,x1+5-((self.view.bounds.size.width-612)/2), y1);
                }
                else{
                    xx=(x1-x)*pageFrame.size.width/(m_pdfview.frame.size.width);
                    yy=(y1-5+(5*pageFrame.size.height/m_pdfview.frame.size.height))*pageFrame.size.height/m_pdfview.frame.size.height;
                    if(lastEditedView.contentView!=nil){
                        CGContextTranslateCTM(ctx,xx+20, yy+10);
                        lastEditedView.XPdf=xx+20;
                        lastEditedView.YPdf=yy+10;
                        
                    }
                    else{
                        CGContextTranslateCTM(ctx,xx+5, yy);
                        lastEditedView.XPdf=xx+10;
                        lastEditedView.YPdf=yy;
                    }
                    
                }
                if(lastEditedView.contentView!=nil){
                    [[lastEditedView.contentView.sigView layer] renderInContext:ctx];
                }else{
                    [[lastEditedView layer] renderInContext:ctx];
                }
                
            }
            
            
            
        }
        
        UIGraphicsEndPDFContext();
        
        CGPDFDocumentRelease(document1);
        //pdf = nil;
        if (![[NSFileManager defaultManager] createFileAtPath:tempPdfLocation contents:data attributes:nil])
        {
            return @"";
        }
        
        [drawLayer removeFromSuperview];
        
        
        // ReaderDocument* doc=[self OpenPdfReader:tempPdfLocation];
        // [self loadNewDocumentReader:doc attachementId:self.attachmentId];
        [self refreshAfterSign:fileToOpen correspondenceId:Id];
        [m_pdfview setHandsign:NO];
        [m_pdfview setBtnSign:NO];
        [m_pdfview setNeedsDisplay];
        //  int tempCurrentpage=currentPage;
        FPDF_PAGE tempPage=[m_pdfdoc getPDFPage:currentPage-1];
        
        
        for(HighlightClass* obj in mainDelegate.IncomingHighlights){
            XH=CGPointMake(obj.abscissa, obj.ordinate);
            YH=CGPointMake(obj.x1, obj.y1);
            FPDF_PAGE m_curPage = [m_pdfdoc getPDFPage:obj.PageNb];
            
            [m_pdfdoc setCurPage:m_curPage];
            [obj setIndex:[mainDelegate.IncomingHighlights indexOfObject:obj]];
            
            [m_pdfdoc AddHighlightAnnot:XH secondPoint:YH previousPoint:ZH];
            mainDelegate.highlightNow=NO;
        }
        for(HighlightClass* obj in mainDelegate.Highlights){
            XH=CGPointMake(obj.abscissa, obj.ordinate);
            YH=CGPointMake(obj.x1, obj.y1);
            FPDF_PAGE m_curPage = [m_pdfdoc getPDFPage:obj.PageNb];
            
            [m_pdfdoc setCurPage:m_curPage];
            if(![obj.status isEqualToString:@"DELETE"]){
                [obj setIndex:([mainDelegate.Highlights indexOfObject:obj]+[mainDelegate.IncomingHighlights count])];
                [m_pdfdoc AddHighlightAnnot:XH secondPoint:YH previousPoint:ZH];
            }
            mainDelegate.highlightNow=NO;
        }
        
        for(note* obj in mainDelegate.Notes){
            FPDF_PAGE m_curPage = [m_pdfdoc getPDFPage:obj.PageNb];
            [m_pdfdoc setCurPage:m_curPage];
            CGPoint point=CGPointMake(obj.abscissa, obj.ordinate);
            if(![obj.status isEqualToString:@"DELETE"])
                [m_pdfdoc AddNote:point secondPoint:point  note:obj.note];
            mainDelegate.highlightNow=NO;
        }
        
        for(note* obj in mainDelegate.IncomingNotes){
            FPDF_PAGE m_curPage = [m_pdfdoc getPDFPage:obj.PageNb];
            
            [m_pdfdoc setCurPage:m_curPage];
            CGPoint point=CGPointMake(obj.abscissa, obj.ordinate);
            [m_pdfdoc AddNote:point secondPoint:point  note:obj.note];
            mainDelegate.highlightNow=NO;
        }
        [m_pdfdoc setCurPage:tempPage];
        NSString* dir  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        dir = [dir stringByAppendingString:@"/FoxitSaveAnnotation.pdf"];
        [fileToOpen saveinDirectory:Id strUrl:dir];
        
        return tempPdfLocation;
    }
    return nil;
}

-(void)refreshAfterSign:(CAttachment *)fileToOpen correspondenceId:(NSString*)Id {
    [self performSelectorOnMainThread:@selector(increaseProgress) withObject:@"" waitUntilDone:YES];
    
    // [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Reloading",@"Reloading ...") maskType:SVProgressHUDMaskTypeBlack];
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:Id fromSharepoint:mainDelegate.isSharepoint];
    
    
    
    
    
    
    mainDelegate.FolderName=fileToOpen.FolderName;
    mainDelegate.FolderId=fileToOpen.FolderId;
    ReaderDocument* doc=[self OpenPdfReader:tempPdfLocation];
    document=doc;
    
    m_pdfdoc = [[PDFDocument alloc] init];
    [m_pdfdoc initPDFSDK];
    [self loadNewDocumentReader:doc attachementId:self.attachmentId];
    
    
    
    @try{
        [self.noteContainer removeFromSuperview];
        //self.attachmentId=0;
        contentViews = [NSMutableDictionary new];
        [m_pdfview removeFromSuperview];
        if( mainPagebar.hidden==false){
            [mainPagebar removeFromSuperview];
            mainPagebar.hidden=true;
        }
        
        [self.view addSubview:mainPagebar];
        [self.view bringSubviewToFront:mainToolbar];
        lastHideTime = [NSDate date];
        // [self updateScrollViewContentViews];
        lastAppearSize = CGSizeZero;
        
        [mainDelegate.DrawLayerViews removeAllObjects];
        
        document.lastOpen = [NSDate date];
        
        isVisible = YES;
        const char* file = [tempPdfLocation UTF8String];
        [self initView:file];
        
        
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"showDocument" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    
    
    
    // dispatch_async(dispatch_get_main_queue(), ^{
    
    //[SVProgressHUD dismiss];
    
    //        });
    //
    //    });
    
    
    
    
}
-(void)refreshDocument:(NSString*)PdfLocation attachmentId:(NSString*)attachmentId correspondence:(CCorrespondence *)corr{
    if(corr==nil){
        [mainToolbar.nextButton setEnabled:true];
        mainToolbar.attachementsCount=mainToolbar.attachementsCount+1;
    }else{
        CAttachment *fileToOpen=corr.attachmentsList[0];
        NSString *tempPdfLocation=[fileToOpen saveInCacheinDirectory:corr.Id fromSharepoint:mainDelegate.isSharepoint];
        mainDelegate.FolderName=fileToOpen.FolderName;
        mainDelegate.FolderId=fileToOpen.FolderId;
        ReaderDocument* doc=[self OpenPdfReader:tempPdfLocation];
        document=doc;
        
        m_pdfdoc = [[PDFDocument alloc] init];
        [m_pdfdoc initPDFSDK];
        [self loadNewDocumentReader:doc attachementId:attachmentId.intValue];
        
        
        
        
        
        
        
        @try{
            [self.noteContainer removeFromSuperview];
            self.attachmentId=0;
            contentViews = [NSMutableDictionary new];
            currentPage=1;
            [m_pdfview removeFromSuperview];
            if( mainPagebar.hidden==false){
                [mainPagebar removeFromSuperview];
                mainPagebar.hidden=true;
            }
            
            [self.view addSubview:mainPagebar];
            [self.view bringSubviewToFront:mainToolbar];
            lastHideTime = [NSDate date];
            
            [mainDelegate.DrawLayerViews removeAllObjects];
            
            document.lastOpen = [NSDate date];
            
            isVisible = YES;
            const char* file = [tempPdfLocation UTF8String];
            m_pdfdoc = [[PDFDocument alloc] init];
            [m_pdfdoc initPDFSDK];
            [self initView:file];
            
        }
        
        @catch (NSException *ex) {
            [FileManager appendToLogView:@"ReaderViewController" function:@"showDocument" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
        }
        [m_pdfview setNeedsDisplay];
    }
    
    
}
- (void)tappedSaveSignatureWithWidth:(NSString*)width withHeight:(NSString*)height withRed:(NSString *)red withGreen:(NSString *)green withBlue:(NSString *)blue{
    
    
    [Base64 initialize];
    NSData* imgData;
    
    UIImage *image=[UIImage imageWithData:[Base64 decode:mainDelegate.user.signature]];
    
    // imgData=UIImageJPEGRepresentation([self changeColor:image withRed:red withGreen:green withBlue:blue], 1.0);
    
    imgData=UIImagePNGRepresentation(image);
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


