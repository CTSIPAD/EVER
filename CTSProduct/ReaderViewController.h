//
//	ReaderViewController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import"SearchViewController.h"
#import"NotesViewController.h"
#import "ReaderDocument.h"
#import "AnnotationsController.h"
#import "TransferViewController.h"
#import "ManageSignatureViewController.h"
#import "DrawLayerView.h"
#import "MoreTableViewController.h"

@class ReaderViewController;
@class PDFDocument;
@class PDFView;
@protocol ReaderViewControllerDelegate <NSObject>

@optional // Delegate protocols
- (void)dismissReaderViewControllerWithReload:(ReaderViewController *)viewController;
- (void)dismissReaderViewController:(ReaderViewController *)viewController;
-(void)dismissReaderViewControllerToShowResult:(ReaderViewController *)viewController;

@end

@interface ReaderViewController : UIViewController<NoteAlertViewDelegate,AnnotationsTableDelegate,TransferViewDelegate,ManageSignatureViewDelegate,UIImagePickerControllerDelegate,UIScrollViewDelegate>
{
    PDFDocument* m_pdfdoc;
	PDFView* m_pdfview;
    UIAlertView* alertNote;
    NSString *currentFilePath;
    
    UIButton *openButton;
    UIButton *numberPages;
    
    UIView *folderPagebar;
    NSMutableArray *folderarray;
}

@property(nonatomic,strong)UILabel *counter;
@property(nonatomic,strong)UIPopoverController* notePopController ;
@property(nonatomic,assign) NSInteger menuId;
@property(nonatomic,assign) NSInteger correspondenceId;
@property(nonatomic,assign) NSInteger attachmentId;
@property(nonatomic,strong)DrawLayerView* drawLayer;
@property (nonatomic,strong)UIButton *openButton;
@property (nonatomic,strong) UIView *folderPagebar;
@property (nonatomic,strong)UIButton *numberPages;


@property(nonatomic,strong)UIView *noteContainer;
@property (nonatomic, unsafe_unretained, readwrite) id <ReaderViewControllerDelegate> delegate;

@property (nonatomic, copy) NSArray *selections;
@property (nonatomic, copy) NSString *keyword;

- (id)initWithReaderDocument:(ReaderDocument *)object MenuId:(NSInteger)menuId CorrespondenceId:(NSInteger)correspondenceId AttachmentId:(NSInteger)attachmentId;

-(void)openmanagesignature;
+(void)closeMetadata;
-(void)uploadXml:(NSString*) docId;
-(void)UploadAnnotations:(NSString*) docId;
-(void)ShowUploadAttachmentDialog;
@end
