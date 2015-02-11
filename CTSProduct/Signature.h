//
//  Signature.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Signature : UIView{
    CGPoint previousPoint1;
    CGPoint previousPoint2;
    CGPoint currentPoint;
    UIImageView *view1;
}
@property (nonatomic,retain)    UIImageView *sigView;
@property(nonatomic,retain) UIImage* signatureImage;

@property (nonatomic,strong)  NSData *userXmlData;

- (id)initWithFrame:(CGRect)frame signature:(NSString*) signature;
-(void)clearImage;
@end
