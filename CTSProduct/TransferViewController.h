//
//  TransferViewController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionTaskController.h"
#import "PMCalendarController.h"

@class TransferViewController;
@protocol TransferViewDelegate <NSObject>

@required // Delegate protocols

-(void)destinationSelected:(CDestination*)dest withRouteLabel:(CRouteLabel*)routeLabel routeNote:(NSString*)note withDueDate:(NSString*)date viewController:(TransferViewController*)viewcontroller;
@end

@interface TransferViewController : UIViewController<UITextViewDelegate,ActionTaskDelegate,PMCalendarControllerDelegate,UITextFieldDelegate>
{
    CGRect originalFrame;
    BOOL isShown;
    UITextField *txtTransferTo;
    UITextField *txtTransferToSection;
    UITextField *txtDirection;
    UITextField *txtDueDate;
    UITextView *txtNote;
}
@property (nonatomic, unsafe_unretained, readwrite) id <TransferViewDelegate> delegate;
@property (nonatomic,retain) UITextField *txtTransferTo ;
@property (nonatomic,retain) UITextField *txtTransferToSection;
@property (nonatomic,retain) UITextField *txtDirection ;
@property (nonatomic,retain) UITextField *txtDueDate ;
@property (nonatomic,retain) UITextView *txtNote ;
@property (nonatomic) BOOL isShown;
@property (nonatomic, strong) PMCalendarController *pmCC;

- (id)initWithFrame:(CGRect)frame;
-(void)show;
-(void)hide;
-(void)save;


@end
