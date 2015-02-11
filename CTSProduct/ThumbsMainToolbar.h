//
//	ThumbsMainToolbar.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIXToolbarView.h"

@class ThumbsMainToolbar;

@protocol ThumbsMainToolbarDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInToolbar:(ThumbsMainToolbar *)toolbar doneButton:(UIButton *)button;
- (void)tappedInToolbar:(ThumbsMainToolbar *)toolbar showControl:(UISegmentedControl *)control;

@end

@interface ThumbsMainToolbar : UIXToolbarView

@property (nonatomic, unsafe_unretained, readwrite) id <ThumbsMainToolbarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;

@end
