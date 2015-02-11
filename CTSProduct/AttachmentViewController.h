//
//  UploadViewController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAction.h"
#import "ReaderDocument.h"
@protocol UploadAttachmentViewDelegate <NSObject>
-(void)ShowHidePageBar;
-(void)ShowUploadAttachmentDialog;
-(void)ShowUploadAttachmentDialog:(int)index;
-(void)PopUpTransferDialog;
-(void)dismissPopUp:(UITableViewController*)viewcontroller;
-(void)movehome:(UITableViewController*)viewcontroller;
-(void)PopUpCommentDialog:(UITableViewController*)viewcontroller Action:(CAction *)action document:(ReaderDocument*)document;
-(void)executeAction:(NSString*)action note:(NSString*)Note movehome:(BOOL)movehome;
@required

@end


@interface AttachmentViewController : UITableViewController<UIAlertViewDelegate>

@property(nonatomic,strong)NSMutableArray* actions;
@property(nonatomic,unsafe_unretained,readwrite) id <UploadAttachmentViewDelegate> delegate;
@property(nonatomic,strong)UIPopoverController* notePopController ;
@property(nonatomic,assign)int index ;
@property(nonatomic,strong)NSString* NewBtnStatus;

@end
