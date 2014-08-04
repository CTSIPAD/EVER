//
//  TableResultCell.h
//  CTSProduct
//
//  Created by DNA on 6/24/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableResultCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *label2;
@property (strong, nonatomic) IBOutlet UILabel *label3;
@property (strong, nonatomic) IBOutlet UILabel *label4;
@property (strong , nonatomic) IBOutlet UIButton *LockButton;
@property (nonatomic, strong) NSString *imageThumbnailBase64;
@property (nonatomic, strong) UIImageView *imageNew;
@property (nonatomic, strong) UIImageView *imagePriority;

-(void)updateCell;
-(void)showNew:(BOOL)lock priority:(BOOL)Priority new:(BOOL)New;
-(void)showPriority:(BOOL)Priority;
-(void)loadmore;
-(void)ResetContent;
-(void)showLockButton:(NSString*)imageName tag:(NSInteger)tag lock:(BOOL)lock priority:(BOOL)Priority new:(BOOL)New;
@end
