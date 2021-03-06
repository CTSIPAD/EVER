//
//  UserDetailsViewController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol UserDelegate <NSObject>
-(void)dismissPopUp:(UITableViewController*)viewcontroller;
-(void)SetDepartment:(int)departmentId;
@required

@end
@interface UserDetailsViewController : UITableViewController
@property(nonatomic,strong)NSMutableArray* UserDetail;
@property(nonatomic,unsafe_unretained,readwrite) id <UserDelegate> delegate;
@end

