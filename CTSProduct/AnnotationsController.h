//
//  AnnotationsTableViewController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAction.h"
#import "ReaderDocument.h"
@protocol AnnotationsTableDelegate <NSObject>

@required

- (void) performaAnnotation:(int)annotation;
-(void)dismissPopUp:(UITableViewController*)viewcontroller;
-(void)movehome:(UITableViewController*)viewcontroller;
-(void)PopUpCommentDialog:(UITableViewController*)viewcontroller Action:(CAction *)action document:(ReaderDocument*)document;
-(void)executeAction:(NSString*)action note:(NSString*)Note movehome:(BOOL)movehome;
@end

@interface AnnotationsController : UITableViewController
@property (nonatomic, unsafe_unretained, readwrite) id <AnnotationsTableDelegate> delegate;
@property(nonatomic,strong)NSMutableArray* properties;
@end
