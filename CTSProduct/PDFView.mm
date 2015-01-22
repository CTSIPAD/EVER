//
//  PDFView.mm
//  demo_form_field
//
//  Created by Foxit on 12-2-7.
//  Copyright 2012 Foxit Software Corporation. All rights reserved.
//

#import "PDFView.h"
#import "PDFDocument.h"
#import "CUser.h"
#import "CParser.h"
#import "CFPendingAction.h"
#import "AppDelegate.h"
#import "note.h"
#import "HighlightClass.h"
#import "GDataXMLNode.h"
#import "note.h"


@implementation PDFView{
    BOOL isZooming;
    AppDelegate *mainDelegate;
    CGPoint XH,YH,ZH;
}
@synthesize  startLocation,endLocation,annotationSignHeight,annotationSignWidth,attachmentId,doc;
- (void)initPDFDoc:(PDFDocument*) pdoc pageIndex:(int)index
{
    doc=pdoc;
	m_pDocument = pdoc;
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.highlightNow=YES;
    for(HighlightClass* obj in mainDelegate.IncomingHighlights)
        
    {
        
        
        CGPoint ptLeftTop;
        
        CGPoint ptRightBottom;
        
        
        
        ptLeftTop.x=obj.abscissa;
        
        ptLeftTop.y=obj.ordinate;
        
        ptRightBottom.x=obj.x1;
        
        ptRightBottom.y=obj.y1;
        
       

        
        m_pageIndex=obj.PageNb;
        
        m_curPage = [m_pDocument getPDFPage:obj.PageNb];
        
        [m_pDocument setCurPage:m_curPage];
        
        [m_pDocument AddHighlightAnnot:ptLeftTop secondPoint:ptRightBottom previousPoint:ptLeftTop];
        [obj setIndex:[mainDelegate.IncomingHighlights indexOfObject:obj]];
        
        mainDelegate.highlightNow=NO;
        
    }
        for(note *notee in mainDelegate.IncomingNotes)
            
        {
            
            
            CGPoint ptLeftTop;
            
            ptLeftTop.x=notee.abscissa;
            
            ptLeftTop.y=notee.ordinate;
            
            m_pageIndex=notee.PageNb;
            
            m_curPage = [m_pDocument getPDFPage:notee.PageNb];
            
            [m_pDocument setCurPage:m_curPage];
            
            [m_pDocument AddNote:ptLeftTop secondPoint:ptLeftTop note:notee.note];
            
            mainDelegate.highlightNow=NO;

        }
        
        


    m_pageIndex = index;
    m_zoomLevel = 100;
    m_curPage = [m_pDocument getPDFPage:m_pageIndex];
      FPDF_Page_GetSize(m_curPage, &m_pageWidth, &m_pageHeight);
     m_viewRect = [self bounds];
    // m_viewRect.size.height -= 50;
     m_mainsize = m_viewRect.size;
    
    m_nStartX = 0;
    m_nStartY = 0;
    m_nSizeX = m_mainsize.width;
    m_nSizeY = m_mainsize.height;
}

- (CGPoint)PageToDevicePoint:(FPDF_PAGE)page p1:(CGPoint)point
{
	m_nStartX = 0;
	m_nStartY = 0;
	m_nSizeX = self.bounds.size.width;
	m_nSizeY = self.bounds.size.height;
	
	FS_POINT devPoint;
	FPDF_Page_PageToDevicePoint(m_curPage, m_nStartX, m_nStartY, m_nSizeX, m_nSizeY, 0, &devPoint);
	
	return CGPointMake(devPoint.x, devPoint.y);
}
- (CGPoint)DeviceToPagePoint:(FPDF_PAGE)page p1:(CGPoint)point
{
	m_nStartX = 0;
	m_nStartY = 0;
	m_nSizeX = self.bounds.size.width;
	m_nSizeY = self.bounds.size.height;
	
	FS_POINT pagePoint;
	pagePoint.x = point.x;
	pagePoint.y = point.y;
	FPDF_Page_DeviceToPagePoint(m_curPage, m_nStartX, m_nStartY, m_nSizeX, m_nSizeY, 0, &pagePoint);
	
	return CGPointMake(pagePoint.x, pagePoint.y);
}

- (id)initWithFrame:(CGRect)frame {
    m_curPage = NULL;
	m_pageIndex = -1;
    self = [super initWithFrame:frame];
    if (self) {
         m_mainsize = self.bounds.size;
    }
    return self;
}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   NSSet *allTouches = [event allTouches];
    if([allTouches count] > 0)
    {
        previousPoint=currentPoint;
        self.endLocation = [[touches anyObject] locationInView:self];
        currentPoint=self.endLocation;

    }
   
    CGPoint ptLeftTop=[self DeviceToPagePoint:m_curPage p1:CGPointMake(startLocation.x, self.startLocation.y)];
    CGPoint ptRightBottom=[self DeviceToPagePoint:m_curPage p1:CGPointMake(endLocation.x, self.endLocation.y)];
    
    CGPoint ptPrev=[self DeviceToPagePoint:m_curPage p1:CGPointMake(previousPoint.x, previousPoint.y)];
    XH=ptLeftTop;
    YH=ptRightBottom;
    ZH=ptPrev;
    if([self btnHighlight]==YES){
       
       [m_pDocument AddHighlightAnnot:ptLeftTop secondPoint:ptRightBottom previousPoint:ptPrev];

	}
    [self setNeedsDisplay];
    
}
-(void)searchArray:(HighlightClass*)highlight{
    BOOL found=NO;
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for(int i=[mainDelegate.Highlights count]-1;i>=0;i--){
        HighlightClass* obj=mainDelegate.Highlights[i];
        if(obj.abscissa==highlight.abscissa && obj.ordinate==highlight.ordinate){
            found=YES;
            obj.x1=highlight.x1;
            obj.y1=highlight.y1;
            mainDelegate.Highlights[i]=obj;
            break;
        }
        
    }
    if(found==NO){
        FPDF_ANNOT annot;
        FPDF_Annot_GetAtPos(m_curPage, highlight.abscissa,highlight.ordinate, &annot);
        int index=0;
        FPDF_Annot_GetIndex(m_curPage, annot, &index);
        [highlight setIndex:index];
        [mainDelegate.Highlights addObject:highlight];
        
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event]; // Message superclass


    CGPoint pt = [[touches anyObject] locationInView:self];
	
	//[[self superview] bringSubviewToFront:self];
	
	CGPoint startLoc = [self DeviceToPagePoint:m_curPage p1:pt];
	//form fill implemention.
    
    
	NSSet *allTouches = [event allTouches];
    
    if([allTouches count] > 0)
    {
        //Unused variable   uint touchesCount = [allTouches count];
        self.endLocation = [[touches anyObject] locationInView:self];
        
    }
    
    CGPoint ptLeftTop=[self DeviceToPagePoint:m_curPage p1:CGPointMake(startLocation.x, startLocation.y)];
    CGPoint ptRightBottom=[self DeviceToPagePoint:m_curPage p1:CGPointMake(endLocation.x, endLocation.y)];

    if([self btnHighlight]==YES){
        
        HighlightClass* obj=[[HighlightClass alloc]initWithName:ptLeftTop.x ordinate:ptLeftTop.y height:ptRightBottom.x width:ptRightBottom.y PageNb:m_pageIndex AttachmentId:self.attachmentId Id:@"0"];
        [mainDelegate.Highlights addObject:obj];

        mainDelegate.highlightNow=YES;
        [doc deleteAllAnnot];
        FPDF_PAGE tempPage=m_curPage;
        int tempindex=m_pageIndex;
        
        for(HighlightClass* obj in mainDelegate.IncomingHighlights){
            XH=CGPointMake(obj.abscissa, obj.ordinate);
            YH=CGPointMake(obj.x1, obj.y1);
            m_curPage = [m_pDocument getPDFPage:obj.PageNb];
            [m_pDocument setCurPage:m_curPage];
            [obj setIndex:[mainDelegate.IncomingHighlights indexOfObject:obj]];
            
            [m_pDocument AddHighlightAnnot:XH secondPoint:YH previousPoint:ZH];
            mainDelegate.highlightNow=NO;
        }
        for(HighlightClass* obj in mainDelegate.Highlights){
            XH=CGPointMake(obj.abscissa, obj.ordinate);
            YH=CGPointMake(obj.x1, obj.y1);
            m_curPage = [m_pDocument getPDFPage:obj.PageNb];
            [m_pDocument setCurPage:m_curPage];
            if(![obj.status isEqualToString:@"DELETE"]){
                [obj setIndex:([mainDelegate.Highlights indexOfObject:obj]+[mainDelegate.IncomingHighlights count])];
                [m_pDocument AddHighlightAnnot:XH secondPoint:YH previousPoint:ZH];
            }
             mainDelegate.highlightNow=NO;
        }
        
        for(note* obj in mainDelegate.Notes){
            m_curPage = [m_pDocument getPDFPage:obj.PageNb];
            [m_pDocument setCurPage:m_curPage];
            CGPoint point=CGPointMake(obj.abscissa, obj.ordinate);
            if(![obj.status isEqualToString:@"DELETE"])
                [m_pDocument AddNote:point secondPoint:point  note:obj.note];
            mainDelegate.highlightNow=NO;
        }
        
        for(note* obj in mainDelegate.IncomingNotes){
            m_curPage = [m_pDocument getPDFPage:obj.PageNb];
            [m_pDocument setCurPage:m_curPage];
            CGPoint point=CGPointMake(obj.abscissa, obj.ordinate);
            [m_pDocument AddNote:point secondPoint:point  note:obj.note];
            mainDelegate.highlightNow=NO;
        }
        
        [m_pDocument setCurPage:tempPage];
        m_pageIndex=tempindex;
	}
	
   
    if ([self btnErase])
        [m_pDocument eraseAnnotation:startLoc secondPoint:ptLeftTop];
    
    else
        if([self btnNote ])
        {
            mainDelegate.highlightNow=NO;
            self.btnErase=FALSE;
            mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [m_pDocument AddNote:ptLeftTop secondPoint:ptRightBottom note:[self annotationNoteMsg]];
            note* noteObj=[[note alloc]initWithName:ptLeftTop.x ordinate:ptLeftTop.y note:[self annotationNoteMsg] PageNb:m_pageIndex AttachmentId:self.attachmentId Id:@"0"];
            [mainDelegate.Notes addObject:noteObj];
            
        }
    
        if ([self btnNote]){
            self.btnNote =FALSE;
        }
        else{
            if(![self btnErase]&&![self btnHighlight])
                [m_pDocument extractText:ptLeftTop ];
        }
    [self setNeedsDisplay];
    
}
-(int)GetPageIndex{
    return m_pageIndex;
}
-(void)InitPageIndex{
    m_pageIndex=0;
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


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event]; // Message superclass
}




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    self.startLocation = [[touches anyObject] locationInView:self];
    currentPoint.x=0;
    previousPoint.x=0;
    [_delegate HideToolbar];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	//Receive the input text,then set the text to the associated text field.
	
	NSString* pStringValue = [textField text];
	unichar* pBuff = new unichar[[pStringValue length]];
	NSRange range = {0, [pStringValue length]};
	[pStringValue getCharacters:pBuff range:range];
	//form fill implemention.
	
	[textField resignFirstResponder];
	[textField removeFromSuperview]; 
	return YES;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
-(FS_FLOAT)getWidth{
    return m_pageWidth;
}
-(FS_FLOAT)getHeight{
    return m_pageHeight;
}
- (void)drawRect:(CGRect)rect {
	// Drawing code.
    if(isZooming){
        m_zoomLevel = m_nSizeX * 100 / m_pageWidth;
    }
   // if(!isZooming){
        CGContextRef myContext = UIGraphicsGetCurrentContext();
        
        CGRect cliprect = CGContextGetClipBoundingBox(myContext);
        m_nSizeX = self.bounds.size.width;
        m_nSizeY = self.bounds.size.height;
        
        int width, height;

        m_curPage = [m_pDocument getPDFPage:m_pageIndex];
        [m_pDocument setCurPage:m_curPage];
        
        m_nStartX = cliprect.origin.x;
        m_nStartY = cliprect.origin.y;
        width = cliprect.size.width;
        height = cliprect.size.height;
        
        FS_BITMAP dib = [m_pDocument getPageImageByRect:m_curPage p1:m_nStartX p2:m_nStartY
                                                     p3:m_nSizeX p4:m_nSizeY p5:width p6:height];
        
        int bmWidth = FS_Bitmap_GetWidth(dib);
        int bmHeight = FS_Bitmap_GetHeight(dib);
        
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, FS_Bitmap_GetBuffer(dib), FS_Bitmap_GetStride(dib)*bmHeight, NULL);
        CGImageRef image = CGImageCreate(bmWidth,bmHeight, 8, 32, FS_Bitmap_GetStride(dib), \
                                         CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault, \
                                         provider, NULL, YES, kCGRenderingIntentDefault);
        
        UIImage* uiImage = [UIImage imageWithCGImage:image];
        
        [uiImage drawInRect:cliprect]; 
        
        
        CGDataProviderRelease(provider);
        CGImageRelease(image);
        FS_Bitmap_Destroy(dib);
//    }
//    else{
//    m_zoomLevel = m_nSizeX * 100 / m_pageWidth;
//	
//    if(m_viewRect.size.width <= m_mainsize.width)
//        m_viewRect.origin.x = (m_mainsize.width - m_viewRect.size.width) / 2;
//    if(m_viewRect.size.height <= m_mainsize.height)
//        m_viewRect.origin.y = 0;
   
//    if(m_viewRect.size.width > m_mainsize.width)
//        m_viewRect.size.width = m_mainsize.width;
//    if(m_viewRect.size.height > m_mainsize.height)
//        m_viewRect.size.height = m_mainsize.height;
    
//    int sizex = m_viewRect.size.width;
//    int sizey = m_viewRect.size.height;
//    FS_BITMAP dib = NULL;
//	FS_Bitmap_Create(sizex, sizey, FS_DIBFORMAT_RGBA, NULL, 0, &dib);
//    FPDF_RenderPage_SetHalftoneLimit(5000 * 5000);
//    FPDF_RenderPage_Start(dib, m_curPage, -m_nStartX, -m_nStartY, m_nSizeX, m_nSizeY, 0, 0, NULL, NULL);
//	
//	int bmWidth = FS_Bitmap_GetWidth(dib);
//	int bmHeight = FS_Bitmap_GetHeight(dib);
//	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, FS_Bitmap_GetBuffer(dib), FS_Bitmap_GetStride(dib)*bmHeight, NULL);
//	CGImageRef image = CGImageCreate(bmWidth,bmHeight, 8, 32, FS_Bitmap_GetStride(dib), \
//									 CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault, \
//									 provider, NULL, YES, kCGRenderingIntentDefault);
//	
//	UIImage* uiImage = [UIImage imageWithCGImage:image];
//    
//    CGRect rct;
//    rct.origin.x = 0;
//    rct.origin.y = 0;
//    rct.size = m_mainsize;
//    [uiImage drawInRect:m_viewRect];
//   
//    CGDataProviderRelease(provider);
//    CGImageRelease(image);
//	FS_Bitmap_Destroy(dib);
//    }

}


- (void)dealloc {
    if(m_curPage)
        FPDF_Page_Close(m_curPage);
    
}
-(void) OnPrevPage
{
    isZooming=NO;
    m_pageIndex--;
    if(m_pageIndex < 0)
    {
        m_pageIndex++;
        return;
    }
    
    CGRect rect = m_viewRect;
    rect.origin.x = 0;
    rect.size.width = m_mainsize.width;
    [self setNeedsDisplayInRect:rect];
}

-(void) OnNextPage
{
    isZooming=NO;
    m_pageIndex++;
    int count = 0;
    FPDF_Doc_GetPageCount((FPDF_DOCUMENT)[m_pDocument getPDFDoc], &count);
    if(m_pageIndex > count - 1)
    {
        m_pageIndex--;
        return;
    }
    
    CGRect rect = m_viewRect;
    rect.origin.x = 0;
    rect.size.width = m_mainsize.width;
    [self setNeedsDisplayInRect:rect];
}

@end
