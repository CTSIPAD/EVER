//
//  SettingsViewController
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITextField *NbOfCorrespondences;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
- (IBAction)save:(id)sender;

@end
