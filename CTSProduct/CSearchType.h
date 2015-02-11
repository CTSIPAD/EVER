//
//  CSearchType.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSearchType : NSObject
@property(nonatomic,assign)NSInteger typeId;
@property(nonatomic,strong)NSString* label;
@property(nonatomic,strong)NSString* icon;
-(id) initWithId:(NSInteger)typeId label:(NSString*)label icon:(NSString*)icon;
@end
