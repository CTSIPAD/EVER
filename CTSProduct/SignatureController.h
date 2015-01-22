//
//  NewActionTableViewController.h
//  CTSIpad
//
//  Created by DNA on 6/11/14.
//  Copyright (c) 2014 LBI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReaderDocument.h"
#import "PDFView.h"
#import "CAction.h"
@class CUser;
@class ReaderMainToolbar;
@class SignatureController;
@class TransferViewController;

@protocol SignatureViewDelegate <NSObject>

@required
-(void)SignAndMovehome:(SignatureController *)viewcontroller;
- (void)showDocument:(id)object;
-(void)extractText:(CGPoint)pt1;
-(void)openmanagesignature;
- (void)tappedSaveSignatureWithWidth:(NSString*)width withHeight:(NSString*)height withRed:(NSString *)red withGreen:(NSString *)green withBlue:(NSString *)blue;
-(void)dismissPopUp:(UITableViewController*)viewcontroller;
-(void)movehome:(UITableViewController*)viewcontroller;
-(void)PopUpCommentDialog:(UITableViewController*)viewcontroller Action:(CAction *)action document:(ReaderDocument*)document;
-(void)executeAction:(NSString*)action note:(NSString*)Note movehome:(BOOL)movehome;
-(void)HandSign;
-(void)Sign;
@end

@interface SignatureController : UITableViewController{
     ReaderDocument *document;
    PDFView* m_pdfview;
    PDFDocument *m_pdfdoc;

}
@property(nonatomic,strong)NSMutableArray* SignAction;
@property(nonatomic,strong)	ReaderDocument *document;
@property(nonatomic,unsafe_unretained,readwrite) id <SignatureViewDelegate> delegate;
@property(nonatomic,strong)	PDFView* m_pdfview;
@property(nonatomic,strong)	PDFDocument* m_pdfdoc;
@property(nonatomic,strong)NSString* correspondenceId;


@end
