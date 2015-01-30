//
//  TableResultCell.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReaderViewController.h"


@interface TableResultCell : UITableViewCell<ReaderViewControllerDelegate,UIPopoverControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *label2;
@property (strong, nonatomic) IBOutlet UILabel *label3;
@property (strong, nonatomic) IBOutlet UILabel *label4;
@property (strong , nonatomic) IBOutlet UIButton *LockButton;

@property(strong,nonatomic) UIView *cellView;
@property(strong,nonatomic) UIView *iconView;
@property (nonatomic,assign) BOOL isLocked;
@property(nonatomic,assign) BOOL isNew;
@property (nonatomic,assign) BOOL isImportant;
@property (strong,nonatomic) NSString* lockeduserId;

@property (nonatomic, strong) NSString *imageThumbnailBase64;
@property (nonatomic, strong) UIImageView *imageNew;
@property (nonatomic, strong) UIImageView *imagePriority;
@property(nonatomic,strong)UIPopoverController* notePopController ;
@property(nonatomic,assign)int index ;
@property (nonatomic, unsafe_unretained, readwrite) id <ReaderViewControllerDelegate> delegate;

-(void)updateCell;
-(void)showNew:(BOOL)lock priority:(BOOL)Priority new:(BOOL)New;
-(void)showPriority:(BOOL)Priority;
-(void)loadmore;
-(void)ResetContent;
-(void)showLockButton:(NSString*)imageName tag:(NSInteger)tag lock:(BOOL)lock priority:(BOOL)Priority new:(BOOL)New;
-(id)init:(int)index frame:(CGRect) tableFrame;
-(void) hideActions:(BOOL)hide;
@end
