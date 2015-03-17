//
//  SettingsViewController
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "InfColorPicker.h"

@interface SettingsViewController : UITableViewController<InfColorPickerControllerDelegate,
UIPopoverControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *NbOfCorrespondences;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
- (IBAction)save:(id)sender;
- (IBAction) changeColor: (id) sender;
@property (strong, nonatomic) IBOutlet UIView *colorView;

@end
