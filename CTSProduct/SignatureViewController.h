//
//  SignatureViewController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Signature;
@class CUser;

@interface SignatureViewController : UIViewController<UITextFieldDelegate>
{
    Signature *sigView;
    UITextField *txtOldPin;
    UITextField *txtPin;
    UITextField *txtConfirmPin;
    
}

- (id)initWithFrame:(CGRect)frame;
-(void)show;
-(void)hide;
-(void)save;
@end
