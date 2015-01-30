//
//  SimpleSearchViewController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleSearchViewController : UIViewController<UITextFieldDelegate>
{
    UILabel *lblTitle;
    UITextField *txtKeyword;
    UIButton *btnSearch;
    UIButton *btnAdvanceSearch;
}
@end
