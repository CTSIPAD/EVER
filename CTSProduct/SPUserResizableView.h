//
//  SPUserResizableView.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//  UIView subclass.

#import <Foundation/Foundation.h>
#import "DrawLayerView.h"
typedef struct SPUserResizableViewAnchorPoint {
    CGFloat adjustsX;
    CGFloat adjustsY;
    CGFloat adjustsH;
    CGFloat adjustsW;
} SPUserResizableViewAnchorPoint;

@protocol SPUserResizableViewDelegate;
@class SPGripViewBorderView;

@interface SPUserResizableView : UIView {
    SPGripViewBorderView *borderView;
    DrawLayerView *contentView;
    UIView *imageView;
    CGPoint touchStart;
    CGFloat minWidth;
    CGFloat minHeight;
    
    // Used to determine which components of the bounds we'll be modifying, based upon where the user's touch started.
    SPUserResizableViewAnchorPoint anchorPoint;
    
    id <SPUserResizableViewDelegate> delegate;
}

@property (nonatomic, retain) id <SPUserResizableViewDelegate> delegate;

// Will be retained as a subview.
@property (nonatomic, retain) DrawLayerView *contentView;
@property (nonatomic, retain) UIView *imageView;

// Default is 48.0 for each.
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;

// Defaults to YES. Disables the user from dragging the view outside the parent view's bounds.
@property (nonatomic) BOOL preventsPositionOutsideSuperview;

@property (nonatomic) CGFloat X;
@property (nonatomic) CGFloat Y;
@property (nonatomic) CGFloat XPdf;
@property (nonatomic) CGFloat YPdf;
- (void)hideEditingHandles;
- (void)showEditingHandles;
-(BOOL)ISHiddenBorder;
@end

@protocol SPUserResizableViewDelegate <NSObject>

@optional

// Called when the resizable view receives touchesBegan: and activates the editing handles.
- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView;

// Called when the resizable view receives touchesEnded: or touchesCancelled:
- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView;
-(void)ResizeiDrawLayer:(CGRect)frame view:(SPUserResizableView *)userResizableView;
-(void)cancelSign;
-(void)DisableSwipe;
-(void)EnableSwipe;
-(void)DuplicateSignature;
-(void)cancelAll;
@end
