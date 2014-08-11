//
//  ActionsTableViewController.h
//  CTSTest
//
//  Created by DNA on 1/22/14.
//  Copyright (c) 2014 LBI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionTaskController.h"
#import "ReaderDocument.h"
#import "CAction.h"
#import "CUser.h"

@protocol MoreDelegate <NSObject>
@required
-(void)movehome:(UITableViewController*)viewcontroller;
-(void)PopUpCommentDialog:(UITableViewController*)viewcontroller Action:(CAction *)action document:(ReaderDocument*)document;
-(void)dismissPopUp:(UITableViewController*)viewcontroller;
-(void)executeAction:(NSString*)action note:(NSString*)Note movehome:(BOOL)movehome;
@end


@interface MoreTableViewController : UITableViewController<UIAlertViewDelegate>
{
    ReaderDocument *document;

}
@property(nonatomic,strong)CUser *user;
@property(nonatomic,strong)NSString* correspondenceId;
@property(nonatomic,strong)NSString* docId;
@property(nonatomic,strong)NSMutableArray* actions;
@property(nonatomic,strong)	ReaderDocument *document;
@property(nonatomic,unsafe_unretained,readwrite) id <MoreDelegate> delegate;

@end
