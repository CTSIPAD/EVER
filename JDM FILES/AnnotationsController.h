//
//  AnnotationsTableViewController.h
//  CTSTest
//
//  Created by DNA on 1/21/14.
//  Copyright (c) 2014 LBI. All rights reserved.
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
-(void)executeAction:(NSString*)action note:(NSString*)Note movehome:(BOOL)movehome ReasonId:(NSString*)ReasonId;
@end

@interface AnnotationsController : UITableViewController
@property (nonatomic, unsafe_unretained, readwrite) id <AnnotationsTableDelegate> delegate;
@property(nonatomic,strong)NSMutableArray* properties;
@end
