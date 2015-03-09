//
//  MainMenuViewController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuViewController : UITableViewController<UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableSet *shownIndexes;

@end
