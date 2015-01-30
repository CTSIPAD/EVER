//
//  CSearch.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSearch : NSObject

@property(nonatomic,strong)NSMutableArray* criterias;
@property(nonatomic,strong)NSMutableArray* searchTypes;
@property (nonatomic, retain) NSMutableArray *correspondenceList;
@end
