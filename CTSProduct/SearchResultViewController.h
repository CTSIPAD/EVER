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
#import "TableResultCell.h"
@interface SearchResultViewController : UITableViewController<UISplitViewControllerDelegate,UIPopoverControllerDelegate,ReaderViewControllerDelegate,UISearchBarDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, readwrite, nonatomic) REMenu *menu;
@property(nonatomic,strong)UIPopoverController* notePopController ;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic,strong)CSearch *searchResult;

-(void) RefreshSerachResult;
@end
