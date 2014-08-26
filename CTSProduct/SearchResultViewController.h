//
//  SearchResultViewController.h
//  iBoard
//
//  Created by LBI on 11/14/13.
//  Copyright (c) 2013 LBI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSearch.h"
#import "ReaderViewController.h"
#import "REMenu.h"

@interface SearchResultViewController : UITableViewController<UISplitViewControllerDelegate,UIPopoverControllerDelegate,ReaderViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property(nonatomic,strong)IBOutlet UIToolbar *toolbar;
@property (strong, readwrite, nonatomic) REMenu *menu;
@property(nonatomic,strong)UIPopoverController* notePopController ;


@property (nonatomic,strong)CSearch *searchResult;
- (void)didFinishLoad:(NSMutableData *)info;
@end
