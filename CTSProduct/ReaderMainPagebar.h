//
//	ReaderMainPagebar.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ReaderThumbView.h"

//#import "CSearch.h"
//#import "CArchive.h"
//#import "CMeeting.h"
@class ReaderMainPagebar;
@class ReaderTrackControl;
@class ReaderPagebarThumb;
@class ReaderDocument;
@class CUser;

@protocol ReaderMainPagebarDelegate <NSObject>

@required // Delegate protocols

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page document:(ReaderDocument*)newDocument fileId:(NSInteger)fileId;
-(void)disableNext;
-(void)disablePrev;
-(void)enablePrev;
-(void)enableNext;
-(void)setAttachmentIdInToolbar:(int)value;
-(void)closePagebar;
@end

@interface ReaderMainPagebar : UIView{
    NSMutableArray *thumbnailrarray;
}

@property (nonatomic, unsafe_unretained, readwrite) id <ReaderMainPagebarDelegate> delegate;
@property (nonatomic,assign) NSInteger correspondenceId;
@property (nonatomic,assign) NSInteger menuId;
@property (nonatomic,assign) NSInteger attachmentId;
@property (nonatomic,strong) CUser* user;
//@property (nonatomic,strong) CSearch* searchResult;
//@property (nonatomic,strong) CMeeting* archiveFolder;
@property (nonatomic,assign) NSString* pageName;

- (id)initWithFrame:(CGRect)frame Document:(ReaderDocument *)object CorrespondenceId:(NSInteger)correspondenceId MenuId:(NSInteger)menuId AttachmentId:(NSInteger)attachmentId;

- (void)updatePagebar;

- (void)hidePagebar;
- (void)showPagebar;
-(void) adjustToolbar:(UIInterfaceOrientation) tointerfaceOrientation;
- (void)updatePageNumberText:(NSInteger)page;
@end

#pragma mark -

//
//	ReaderTrackControl class interface
//

@interface ReaderTrackControl : UIControl

@property (nonatomic, assign, readonly) CGFloat value;

@end

#pragma mark -

//
//	ReaderPagebarThumb class interface
//

@interface ReaderPagebarThumb : ReaderThumbView

- (id)initWithFrame:(CGRect)frame small:(BOOL)small;

@end

#pragma mark -

//
//	ReaderPagebarShadow class interface
//

@interface ReaderPagebarShadow : UIView

@end
