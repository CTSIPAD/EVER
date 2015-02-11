//
//  NotesTableViewCell.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotesTableViewCell : UITableViewCell
{
    UILabel *author;
    UILabel *note;
    UILabel *creationDate;
    UIButton *btnDelete;
}
@property(nonatomic,strong)IBOutlet UILabel *author;
@property(nonatomic,strong)IBOutlet UILabel *creationDate;
@property(nonatomic,strong)IBOutlet UILabel *note;
@property(nonatomic,strong) UIButton *btnDelete;
@end

@interface UILabel (dynamicSizeWidth)
-(void)resizeToStretchWidth;
-(void)resizeToStretchHeight;
@end
