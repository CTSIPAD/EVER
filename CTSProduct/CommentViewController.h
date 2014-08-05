//
//  AcceptWithCommentViewController.h
//  CTSIpad
//
//  Created by DNA on 6/12/14.
//  Copyright (c) 2014 LBI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionTaskController.h"
#import "ReaderViewController.h"
#import "CAction.h"
@class CommentViewController;
@protocol ActionViewDelegate <NSObject>

@required // Delegate protocols
- (void)dismissReaderViewController:(ReaderViewController *)viewController;
-(void)ActionMoveHome:(CommentViewController*)viewcontroller;
//-(void)AcceptReject:(NSString*)note viewController:(CommentViewController *)viewcontroller action:( NSString *)action;
-(void)SignAndSendIt:(NSString*)action document:(ReaderDocument *)document note:(NSString*)note;
-(void)executeAction:(NSString*)action note:(NSString*)Note movehome:(BOOL)movehome;

@end

@interface CommentViewController : UIViewController<UITextViewDelegate,ActionTaskDelegate>
{
    CGRect originalFrame;
    BOOL isShown;
    UITextView *txtNote;
    NSString* ActionName;
}
@property (nonatomic,retain) UITextView *txtNote ;
@property (nonatomic) BOOL isShown;
@property (nonatomic,retain) CAction * Action;
@property(nonatomic,unsafe_unretained,readwrite) id <ActionViewDelegate> delegate;
@property (nonatomic,retain) ReaderDocument* document;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithActionName:(CGRect)frame Action:(CAction *)action;
-(void)show;
-(void)hide;
-(void)save;


@end