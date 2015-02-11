//
//  AdvanceSearchTableViewCell.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMCalendarController.h"
#import "DropDownView.h"

#import "ActionTaskController.h"
@class CSearchCriteria;
@interface AdvanceSearchTableViewCell : UITableViewCell<PMCalendarControllerDelegate,DropDownViewDelegate>
{
    UITextField* txtCriteria;
    UILabel *lbltitle;
}


@property(nonatomic,strong)UITextField* txtCriteria;
@property(nonatomic,assign)int tag;
@property(nonatomic,retain)LookUpObject* listobj;
@property(nonatomic,strong)UILabel *lbltitle;
@property (nonatomic, strong) PMCalendarController *pmCC;
@property (nonatomic, strong) CSearchCriteria* criteria;



-(void)updateCellwithCriteria:(CSearchCriteria*)searchCriteria;
@end
