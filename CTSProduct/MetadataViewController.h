//
//  MetadataViewController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CCorrespondence;
@interface MetadataViewController : UITableViewController
{
    UITableViewCell *cell;
}
@property(nonatomic,strong)CCorrespondence *currentCorrespondence;
@end
