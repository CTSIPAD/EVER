//
//  HeaderView.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SomeNetworkOperation.h"
#import "ReaderViewController.h"
#import "CSearch.h"
@interface HeaderView : UIViewController<OperationDelegate,ReaderViewControllerDelegate,UIAlertViewDelegate>
@property (strong,nonatomic) UIImageView *seperatorView;
@property (strong,nonatomic) UIButton *usernameButton;
@property (strong,nonatomic) UIButton *statusButton;
@property(nonatomic,strong)UIPopoverController* notePopController ;
@property (nonatomic,strong)CSearch *searchResult;
@end
