//
//  SearchResultViewController.h
//  iBoard
//
//  Created by LBI on 11/14/13.
//  Copyright (c) 2013 LBI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSearch.h"
#import "ReaderViewController.h"
#import "REMenu.h"
@protocol GridDelegate <NSObject>

@required // Delegate protocols

-(void)uploadXml:(NSString*) docId;
-(void)UploadAnnotations:(NSString*) docId;
-(void)callXML;
@end
@interface SearchResultViewController : UITableViewController<UISplitViewControllerDelegate,UIPopoverControllerDelegate,ReaderViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property(nonatomic,strong)IBOutlet UIToolbar *toolbar;
@property (strong, readwrite, nonatomic) REMenu *menu;

@property (nonatomic,strong)CSearch *searchResult;
@property(nonatomic,unsafe_unretained,readwrite) id <GridDelegate> delegate;

@end
