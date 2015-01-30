//
//  ActionsViewController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionTaskController.h"
#import "ReaderDocument.h"
@class CUser;
@class ReaderMainToolbar;
@class MoreTableViewController;
@class TransferViewController;

@protocol TransferViewDelegate <NSObject>

@required
-(void)PopUpCommentDialog:(UITableViewController*)viewcontroller Action:(NSString*)action document:(ReaderDocument*)document;

@end


@interface ActionsViewController : UITableViewController<UIAlertViewDelegate>
{
    ReaderDocument *document;
    
}
@property(nonatomic,strong)CUser *user;
@property(nonatomic,strong)NSString* correspondenceId;
@property(nonatomic,strong)NSString* docId;
@property(nonatomic,strong)NSMutableArray* actions;
@property(nonatomic,strong)	ReaderDocument *document;
@property(nonatomic,unsafe_unretained,readwrite) id <TransferViewDelegate> delegate;

@end
