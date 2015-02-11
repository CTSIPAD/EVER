//
//  NoteAlertView.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoteAlertViewDelegate <NSObject>

@required // Delegate protocols

- (void)tappedSaveNoteText:(NSString*)text private:(BOOL)isPrivate;

@end

@interface NoteAlertView : UIViewController<UITextViewDelegate>
{
    CGRect originalFrame;
    UITextView *txtNote;
    UISwitch *publicSwitch;
}
@property (nonatomic, unsafe_unretained, readwrite) id <NoteAlertViewDelegate> delegate;
@property (nonatomic,retain) UITextView *txtNote ;
@property (nonatomic,retain)UISwitch *publicSwitch;


- (id)initWithFrame:(CGRect)frame fromComment:(BOOL)isComment;
-(void)show;
-(void)hide;
-(void)save;

@end
