//
//  SyncViewController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyncViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property(nonatomic,strong)NSMutableArray* Results;

- (id)initWithFrame:(CGRect)frame;
@end


