//
//  SPUserResizableView.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "SPUserResizableView.h"

/* Let's inset everything that's drawn (the handles and the content view)
 so that users can trigger a resize from a few pixels outside of
 what they actually see as the bounding box. */
#define kSPUserResizableViewGlobalInset 5.0

#define kSPUserResizableViewDefaultMinWidth 48.0
#define kSPUserResizableViewDefaultMinHeight 48.0
#define kSPUserResizableViewInteractiveBorderSize 10.0

static SPUserResizableViewAnchorPoint SPUserResizableViewNoResizeAnchorPoint = { 0.0, 0.0, 0.0, 0.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewUpperLeftAnchorPoint = { 1.0, 1.0, -1.0, 1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewMiddleLeftAnchorPoint = { 1.0, 0.0, 0.0, 1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewLowerLeftAnchorPoint = { 1.0, 0.0, 1.0, 1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewUpperMiddleAnchorPoint = { 0.0, 1.0, -1.0, 0.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewUpperRightAnchorPoint = { 0.0, 1.0, -1.0, -1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewMiddleRightAnchorPoint = { 0.0, 0.0, 0.0, -1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewLowerRightAnchorPoint = { 0.0, 0.0, 1.0, -1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewLowerMiddleAnchorPoint = { 0.0, 0.0, 1.0, 0.0 };

@interface SPGripViewBorderView : UIView
@end

@implementation SPGripViewBorderView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Clear background to ensure the content view shows through.
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // (1) Draw the bounding box.
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextAddRect(context, CGRectInset(self.bounds, kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewInteractiveBorderSize/2));
    CGContextStrokePath(context);
    
    // (2) Calculate the bounding boxes for each of the anchor points.
    CGRect upperLeft = CGRectMake(0.0, 0.0, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    CGRect upperRight = CGRectMake(self.bounds.size.width - kSPUserResizableViewInteractiveBorderSize, 0.0, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    CGRect lowerRight = CGRectMake(self.bounds.size.width - kSPUserResizableViewInteractiveBorderSize, self.bounds.size.height - kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    CGRect lowerLeft = CGRectMake(0.0, self.bounds.size.height - kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    CGRect upperMiddle = CGRectMake((self.bounds.size.width - kSPUserResizableViewInteractiveBorderSize)/2, 0.0, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    CGRect lowerMiddle = CGRectMake((self.bounds.size.width - kSPUserResizableViewInteractiveBorderSize)/2, self.bounds.size.height - kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    CGRect middleLeft = CGRectMake(0.0, (self.bounds.size.height - kSPUserResizableViewInteractiveBorderSize)/2, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    CGRect middleRight = CGRectMake(self.bounds.size.width - kSPUserResizableViewInteractiveBorderSize, (self.bounds.size.height - kSPUserResizableViewInteractiveBorderSize)/2, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    
    // (3) Create the gradient to paint the anchor points.
    CGFloat colors [] = {
        0.4, 0.8, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    // (4) Set up the stroke for drawing the border of each of the anchor points.
    CGContextSetLineWidth(context, 1);
    CGContextSetShadow(context, CGSizeMake(0.5, 0.5), 1);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // (5) Fill each anchor point using the gradient, then stroke the border.
    CGRect allPoints[8] = { upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight };
    for (NSInteger i = 0; i < 8; i++) {
        CGRect currPoint = allPoints[i];
        CGContextSaveGState(context);
        CGContextAddEllipseInRect(context, currPoint);
        CGContextClip(context);
        CGPoint startPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMinY(currPoint));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMaxY(currPoint));
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGContextRestoreGState(context);
        CGContextStrokeEllipseInRect(context, CGRectInset(currPoint, 1, 1));
    }
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);
}

@end

@implementation SPUserResizableView

@synthesize contentView,imageView, minWidth, minHeight, preventsPositionOutsideSuperview, delegate;

- (void)setupDefaultAttributes {
    borderView = [[SPGripViewBorderView alloc] initWithFrame:CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset)];
    [borderView setHidden:NO];
    [self addSubview:borderView];
    self.minWidth = kSPUserResizableViewDefaultMinWidth;
    self.minHeight = kSPUserResizableViewDefaultMinHeight;
    self.preventsPositionOutsideSuperview = YES;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
        UILongPressGestureRecognizer *singleTapOne = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleTapOne];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (void)setContentView:(DrawLayerView *)newContentView {
    [contentView removeFromSuperview];
    contentView = newContentView;
    contentView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset-10 + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset -10+ kSPUserResizableViewInteractiveBorderSize/2);
    contentView.canvas.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    contentView.sigView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    [self addSubview:contentView];
    
    
    // Ensure the border view is always on top by removing it and adding it to the end of the subview list.
    [borderView removeFromSuperview];
    [self addSubview:borderView];
}

- (void)setImageView:(UIView *)newContentView {
    [imageView removeFromSuperview];
    imageView = newContentView;
    imageView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    
    [self addSubview:imageView];
    
    // Ensure the border view is always on top by removing it and adding it to the end of the subview list.
    [borderView removeFromSuperview];
    [self addSubview:borderView];
}
- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
    if(contentView!=nil){
        contentView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset-10 + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset-10 + kSPUserResizableViewInteractiveBorderSize/2);
        contentView.canvas.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
        contentView.sigView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
        [contentView refresh:contentView.canvas.frame.size];
    }else{
        imageView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    }
    borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
    [borderView setNeedsDisplay];
}

static CGFloat SPDistanceBetweenTwoPoints(CGPoint point1, CGPoint point2) {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy);
};

typedef struct CGPointSPUserResizableViewAnchorPointPair {
    CGPoint point;
    SPUserResizableViewAnchorPoint anchorPoint;
} CGPointSPUserResizableViewAnchorPointPair;

- (SPUserResizableViewAnchorPoint)anchorPointForTouchLocation:(CGPoint)touchPoint {
    // (1) Calculate the positions of each of the anchor points.
    CGPointSPUserResizableViewAnchorPointPair upperLeft = { CGPointMake(0.0, 0.0), SPUserResizableViewUpperLeftAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair upperMiddle = { CGPointMake(self.bounds.size.width/2, 0.0), SPUserResizableViewUpperMiddleAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair upperRight = { CGPointMake(self.bounds.size.width, 0.0), SPUserResizableViewUpperRightAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair middleRight = { CGPointMake(self.bounds.size.width, self.bounds.size.height/2), SPUserResizableViewMiddleRightAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair lowerRight = { CGPointMake(self.bounds.size.width, self.bounds.size.height), SPUserResizableViewLowerRightAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair lowerMiddle = { CGPointMake(self.bounds.size.width/2, self.bounds.size.height), SPUserResizableViewLowerMiddleAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair lowerLeft = { CGPointMake(0, self.bounds.size.height), SPUserResizableViewLowerLeftAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair middleLeft = { CGPointMake(0, self.bounds.size.height/2), SPUserResizableViewMiddleLeftAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair centerPoint = { CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2), SPUserResizableViewNoResizeAnchorPoint };
    
    // (2) Iterate over each of the anchor points and find the one closest to the user's touch.
    CGPointSPUserResizableViewAnchorPointPair allPoints[9] = { upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight, centerPoint };
    CGFloat smallestDistance = MAXFLOAT; CGPointSPUserResizableViewAnchorPointPair closestPoint = centerPoint;
    for (NSInteger i = 0; i < 9; i++) {
        CGFloat distance = SPDistanceBetweenTwoPoints(touchPoint, allPoints[i].point);
        if (distance < smallestDistance) {
            closestPoint = allPoints[i];
            smallestDistance = distance;
        }
    }
    return closestPoint.anchorPoint;
}

- (BOOL)isResizing {
    return (anchorPoint.adjustsH || anchorPoint.adjustsW || anchorPoint.adjustsX || anchorPoint.adjustsY);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've begun our editing session.
    if (self.delegate && [self.delegate respondsToSelector:@selector(userResizableViewDidBeginEditing:)]) {
        [self.delegate userResizableViewDidBeginEditing:self];
    }
    
    [borderView setHidden:NO];
    UITouch *touch = [touches anyObject];
    anchorPoint = [self anchorPointForTouchLocation:[touch locationInView:self]];
    
    // When resizing, all calculations are done in the superview's coordinate space.
    touchStart = [touch locationInView:self.superview];
    if (![self isResizing]) {
        // When translating, all calculations are done in the view's coordinate space.
        touchStart = [touch locationInView:self];
    }
    [contentView refresh:contentView.canvas.frame.size];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if (self.delegate && [self.delegate respondsToSelector:@selector(userResizableViewDidEndEditing:)]) {
        [self.delegate userResizableViewDidEndEditing:self];
    }
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if (self.delegate && [self.delegate respondsToSelector:@selector(userResizableViewDidEndEditing:)]) {
        [self.delegate userResizableViewDidEndEditing:self];
    }
}
-(BOOL)ISHiddenBorder{
    return [borderView isHidden];
}
- (void)showEditingHandles {
    [borderView setHidden:YES];
}

- (void)hideEditingHandles {
    if ([borderView isHidden]) {
        [delegate EnableSwipe];
        if(contentView!=nil){
            
            self.contentView.canvas.layer.borderColor = [UIColor clearColor].CGColor;
            
        }
        [borderView setHidden:NO];
        
    }
    else{
        [delegate DisableSwipe];
        if(contentView!=nil){
            
            self.contentView.canvas.layer.borderColor = [UIColor yellowColor].CGColor;
            
        }
        [borderView setHidden:YES];
    }
}

- (void)resizeUsingTouchLocation:(CGPoint)touchPoint {
    // (1) Update the touch point if we're outside the superview.
    if (self.preventsPositionOutsideSuperview) {
        CGFloat border = kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2;
        if (touchPoint.x < border) {
            touchPoint.x = border;
        }
        if (touchPoint.x > self.superview.bounds.size.width - border) {
            touchPoint.x = self.superview.bounds.size.width - border;
        }
        if (touchPoint.y < border) {
            touchPoint.y = border;
        }
        if (touchPoint.y > self.superview.bounds.size.height - border) {
            touchPoint.y = self.superview.bounds.size.height - border;
        }
    }
    
    // (2) Calculate the deltas using the current anchor point.
    CGFloat deltaW = anchorPoint.adjustsW * (touchStart.x - touchPoint.x);
    CGFloat deltaX = anchorPoint.adjustsX * (-1.0 * deltaW);
    CGFloat deltaH = anchorPoint.adjustsH * (touchPoint.y - touchStart.y);
    CGFloat deltaY = anchorPoint.adjustsY * (-1.0 * deltaH);
    
    // (3) Calculate the new frame.
    CGFloat newX = self.frame.origin.x + deltaX;
    CGFloat newY = self.frame.origin.y + deltaY;
    CGFloat newWidth = self.frame.size.width + deltaW;
    CGFloat newHeight = self.frame.size.height + deltaH;
    
    // (4) If the new frame is too small, cancel the changes.
    if (newWidth < self.minWidth) {
        newWidth = self.frame.size.width;
        newX = self.frame.origin.x;
    }
    if (newHeight < self.minHeight) {
        newHeight = self.frame.size.height;
        newY = self.frame.origin.y;
    }
    
    // (5) Ensure the resize won't cause the view to move offscreen.
    if (self.preventsPositionOutsideSuperview) {
        if (newX < self.superview.bounds.origin.x) {
            // Calculate how much to grow the width by such that the new X coordintae will align with the superview.
            deltaW = self.frame.origin.x - self.superview.bounds.origin.x;
            newWidth = self.frame.size.width + deltaW;
            newX = self.superview.bounds.origin.x;
        }
        if (newX + newWidth > self.superview.bounds.origin.x + self.superview.bounds.size.width) {
            newWidth = self.superview.bounds.size.width - newX;
        }
        if (newY < self.superview.bounds.origin.y) {
            // Calculate how much to grow the height by such that the new Y coordintae will align with the superview.
            deltaH = self.frame.origin.y - self.superview.bounds.origin.y;
            newHeight = self.frame.size.height + deltaH;
            newY = self.superview.bounds.origin.y;
        }
        if (newY + newHeight > self.superview.bounds.origin.y + self.superview.bounds.size.height) {
            newHeight = self.superview.bounds.size.height - newY;
        }
    }
    
    self.frame = CGRectMake(newX, newY, newWidth, newHeight);
    self.X=newX;
    self.Y=newY;
    if(contentView!=nil)
        [self.delegate ResizeiDrawLayer:self.frame view:self];
    touchStart = touchPoint;
}

- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x, self.center.y + touchPoint.y - touchStart.y);
    if (self.preventsPositionOutsideSuperview) {
        // Ensure the translation won't cause the view to move offscreen.
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX) {
            newCenter.x = self.superview.bounds.size.width - midPointX;
        }
        if (newCenter.x < midPointX) {
            newCenter.x = midPointX;
        }
        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY) {
            newCenter.y = self.superview.bounds.size.height - midPointY;
        }
        if (newCenter.y < midPointY) {
            newCenter.y = midPointY;
        }
    }
    self.X=newCenter.x ;
    self.Y=newCenter.y;
    self.center = newCenter;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isResizing]) {
        [self resizeUsingTouchLocation:[[touches anyObject] locationInView:self.superview]];
        if(contentView!=nil)
            [self.delegate ResizeiDrawLayer:self.frame view:self];
        
    } else {
        [self translateUsingTouchLocation:[[touches anyObject] locationInView:self]];
        if(contentView!=nil)
            [self.delegate ResizeiDrawLayer:self.frame view:self];
        
    }
}
- (void)handleSingleTap:(UILongPressGestureRecognizer *)recognizer
{
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"clear") action:@selector(clear)];
        UIMenuItem *cancel = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"cancel") action:@selector(cancel)];
        UIMenuItem *duplicate = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Sign.Duplicate", @"Duplicate on all page") action:@selector(duplicate)];
        UIMenuItem *copyy = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Sign.ClearDuplicated", @"Remove Duplicate signature") action:@selector(RemoveAllSignatures)];

        UIMenuController *menu = [UIMenuController sharedMenuController];
        NSMutableArray* array=[NSMutableArray arrayWithObjects:copy,cancel,duplicate,copyy, nil];
        [menu setMenuItems:array];
        
        
        [menu setTargetRect:self.contentView.frame inView:self];
        [menu setMenuVisible:YES animated:YES];
        
        
	}
}
- (BOOL)canBecomeFirstResponder {
    return YES;
}
-(void) RemoveAllSignatures
{
    [delegate cancelAll];
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    BOOL result = NO;
    if(@selector(clear) == action||@selector(cancel) == action||@selector(duplicate) == action || @selector(RemoveAllSignatures)==action) {
        result = YES;
    }
    return result;
    
}
-(void)clear{
    [self.contentView.canvas clear];
}
-(void)cancel{
    [delegate cancelSign];
}
-(void)duplicate{
    [delegate DuplicateSignature];
}
- (void)dealloc {
    [contentView removeFromSuperview];
    [imageView removeFromSuperview];
    
}

@end
