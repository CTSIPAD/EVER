//
//  SyncViewController.h
//  CTSProduct
//
//  Created by DNA on 8/13/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyncViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property(nonatomic,strong)NSMutableArray* Results;

- (id)initWithFrame:(CGRect)frame;
@end


