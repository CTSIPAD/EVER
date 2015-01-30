//
//	ThumbsViewController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ThumbsMainToolbar.h"
#import "ReaderThumbsView.h"

@class ReaderDocument;
@class ThumbsViewController;

@protocol ThumbsViewControllerDelegate <NSObject>

@required // Delegate protocols

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page;

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController;

@end

@interface ThumbsViewController : UIViewController

@property (nonatomic, unsafe_unretained, readwrite) id <ThumbsViewControllerDelegate> delegate;

- (id)initWithReaderDocument:(ReaderDocument *)object;

@end

#pragma mark -

//
//	ThumbsPageThumb class interface
//

@interface ThumbsPageThumb : ReaderThumbView

- (CGSize)maximumContentSize;

- (void)showText:(NSString *)text;

- (void)showBookmark:(BOOL)show;

@end
