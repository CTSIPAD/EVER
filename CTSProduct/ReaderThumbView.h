//
//	ReaderThumbView.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReaderThumbView : UIView
{
@protected // Instance variables

	UIImageView *imageView;
    UILabel *labelview;
}

@property (atomic, strong, readwrite) NSOperation *operation;

@property (nonatomic, assign, readwrite) NSUInteger targetTag;

- (void)showImage:(UIImage *)image;
-(void) showLabel:(NSString *)text;

- (void)showTouched:(BOOL)touched;

- (void)reuse;

@end
