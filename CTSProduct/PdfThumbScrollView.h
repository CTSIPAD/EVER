//
//  PdfThumbScrollView.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CCorrespondence;

@protocol PdfThumbScrollViewDelegate;

@interface PdfThumbScrollView : UIScrollView

@property (nonatomic, weak) id delegate;


- (void)createReaderDocument:(CCorrespondence *)object;
@end

@protocol PdfThumbScrollViewDelegate <NSObject>

- (void)scrollView:(PdfThumbScrollView *)scrollView
             file:(NSInteger)fileId;

@end

