//
//  CCorrespondence.h
//  CTSTest
//
//  Created by DNA on 12/12/13.
//  Copyright (c) 2013 LBI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCorrespondence : NSObject

@property (nonatomic, retain) NSString *Id;
@property (nonatomic, retain) NSString *inboxId;
@property (nonatomic, retain) NSString *TransferId;
@property (nonatomic, assign) BOOL Priority;
@property (nonatomic, assign) BOOL New;
@property (nonatomic, assign) BOOL ShowLocked;
@property (nonatomic, retain) NSMutableDictionary *systemProperties;
@property (nonatomic, retain) NSMutableDictionary *properties;
@property (nonatomic, retain) NSMutableArray *attachmentsList;
@property (nonatomic, retain) NSMutableDictionary *toolbar;
@property (nonatomic, retain) NSMutableArray *actions;
@property (nonatomic, retain) NSMutableArray *ActionsMenu;
@property (nonatomic, retain) NSMutableArray *SignActions;
@property (nonatomic, retain) NSMutableArray *AttachmentsListMenu;
@property (nonatomic, retain) NSMutableArray *AnnotationsList;
@property (nonatomic, retain) NSMutableDictionary *CustomItemsList;
@property (retain,nonatomic) NSMutableArray* QuickActions;


@property(nonatomic,retain) NSString* ThumnailUrl;
@property (nonatomic,retain)NSMutableArray*action;

-(id) initWithId:(NSString*)correspondenceId Priority:(BOOL)priority New:(BOOL)isNew SHOWLOCK:(BOOL)showlock ;

-(BOOL)performCorrespondenceAction:(NSString*)action;
@end
