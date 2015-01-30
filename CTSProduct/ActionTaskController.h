//
//  ActionTaskController.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LookUpObject.h"
@class CDestination;
@class CRouteLabel;

@protocol ActionTaskDelegate
- (void)actionSelectedDirection:(CRouteLabel*)route;
- (void)actionSelectedDestination:(CDestination*)destination;
-(void)actionSelectedDestinationSection:(LookUpObject *)destination;
-(void)actionSelectedLookup:(LookUpObject *)destination;
@end

@interface ActionTaskController : UITableViewController<UITextViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>{
	NSMutableArray *actions;
    NSMutableArray *searchData;
    NSMutableDictionary *searchDataDic;

	BOOL displayingLabel;
	UISearchBar * searchBar;
    UISearchDisplayController *searchDisplayController;
	UIActionSheet* sheet;
}
@property (nonatomic, assign)CGRect rectFrame;
@property (nonatomic, assign)BOOL isDirection;
@property (nonatomic, assign)BOOL isDestinationSection;
@property (nonatomic, retain) NSMutableDictionary *Lookup;

@property (nonatomic, retain) NSMutableArray *actions;
@property (nonatomic, assign) id<ActionTaskDelegate> delegate;
@property (nonatomic, readwrite) BOOL displayingLabel;

@property (nonatomic, retain)UIActionSheet* sheet;


@end
