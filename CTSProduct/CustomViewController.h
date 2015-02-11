//
//  CustomViewController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAction.h"
#import "ReaderDocument.h"
@protocol CustomViewDelegate <NSObject>
-(void)ShowHidePageBar;
-(void)ShowUploadAttachmentDialog;
-(void)dismissPopUp:(UITableViewController*)viewcontroller;
-(void)movehome:(UITableViewController*)viewcontroller;
-(void)PopUpCommentDialog:(UITableViewController*)viewcontroller Action:(CAction *)action document:(ReaderDocument*)document;
-(void)executeAction:(NSString*)action note:(NSString*)Note movehome:(BOOL)movehome;
@required

@end


@interface CustomViewController : UITableViewController<UIAlertViewDelegate>

@property(nonatomic,strong)NSMutableArray* actions;
@property(nonatomic,unsafe_unretained,readwrite) id <CustomViewDelegate> delegate;

@end
