//
//  containerView.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "SplitViewController.h"


@interface containerView : UIViewController
@property (strong,nonatomic) HeaderView *header;
@property (strong,nonatomic) SplitViewController *splitView;

@end
