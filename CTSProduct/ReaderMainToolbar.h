//
//	ReaderMainToolbar.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUser.h"
#import "ReaderDocument.h"
#import "UIXToolbarView.h"
#import "CAction.h"
#import "ToolbarItem.h"
@class ReaderMainToolbar;
@class ReaderDocument;

@protocol ReaderMainToolbarDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar homeButton:(UIButton *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar attachmentButton:(UIButton *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar actionsButton:(UIButton *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar MoreButton:(UIButton *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar CustomButton:(UIButton *)button Item:(ToolbarItem *)item ShowItems:(BOOL)ShowItems;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar SaveButton:(UIButton *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar commentButton:(UIButton *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar metadataButton:(UIButton *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar transferButton:(UIButton *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar annotationButton:(UIButton *)button;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar SignActionButton:(UIButton *)button;
-(void)tappedInToolbar:(ReaderMainToolbar *)toolbar actionButton:(UIButton *)button;
- (void)dismissReaderViewController:(UIViewController *)viewController;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar lockButton:(UIButton *)button message:(NSString*)msg;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar nextButton:(UIButton *)button documentReader:(ReaderDocument*)reader correspondenceId:(NSInteger)correspondenceId attachementId:(NSInteger)attachementId;
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar previousButton:(UIButton *)button documentReader:(ReaderDocument*)reader correspondenceId:(NSInteger)correspondenceId attachementId:(NSInteger)attachementId;
-(void)executeAction:(NSString*)action note:(NSString*)Note movehome:(BOOL)movehome;
-(void) hide;
@end

@interface ReaderMainToolbar : UIXToolbarView{
    UIButton *nextButton;
    UIButton *previousButton;
    UIButton *lockButton;
    UIButton *homeButton;
    UIButton *MoreButton;
    UIButton *transferButton;
    UIButton *commentsButton;
    UIButton *attachmentButton;
    UIButton *metadataButton;
    UIButton *annotationButton;
    UIButton *SignActionButton;
    UIButton *ActionsButton;
    UILabel *lblTitle;
    UIButton *closeButton;
    UIButton* Save;
}

@property (nonatomic, unsafe_unretained, readwrite) id <ReaderMainToolbarDelegate> delegate;
@property (nonatomic,assign) NSInteger menuId;
@property (nonatomic,assign) NSInteger correspondenceId;
@property (nonatomic,assign) NSInteger attachmentId;
@property (nonatomic,strong) CUser* user;
@property (nonatomic,assign) NSInteger attachementsCount;
@property (nonatomic,strong)UILabel *lblTitle;
@property (nonatomic,strong)UIButton *nextButton;
@property (nonatomic,strong)UIButton *previousButton;
@property (nonatomic,strong)UIButton *lockButton;
@property (nonatomic,strong)UIButton *ActionsButton;
@property (nonatomic,strong)UIButton *MoreButton;
@property (nonatomic,strong)UIButton *transferButton;
@property (nonatomic,strong)UIButton *commentsButton;
@property (nonatomic,strong)UIButton *attachmentButton;
@property (nonatomic,strong)UIButton *metadataButton;
@property (nonatomic,strong)UIButton *annotationButton;
@property(nonatomic,strong)UIButton* Save;
@property (nonatomic,strong)UIButton *closeButton;


- (id)initWithFrame:(CGRect)frame document:(ReaderDocument *)object CorrespondenceId:(NSInteger)correspondenceId MenuId:(NSInteger)menuId AttachmentId:(NSInteger)attachmentId;
-(void) updateTitleWithLocation:(NSString*)location withName:(NSString*)name;
- (void)hideToolbar;
- (void)showToolbar:(NSString*)status;
-(void)refreshToolbar:(NSString*)state;
-(void)adjustButtons:(UIInterfaceOrientation)orient;
@end
