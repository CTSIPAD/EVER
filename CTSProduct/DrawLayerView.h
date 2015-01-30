//
//  Signature.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmoothLineView.h"

@interface DrawLayerView : UIView<UIGestureRecognizerDelegate,DrawLayerDelegate>{
    CGPoint previousPoint1;
    CGPoint previousPoint2;
    CGPoint currentPoint;
}
@property (nonatomic,retain)    UIImageView *sigView;
@property(nonatomic,retain) UIImage* signatureImage;

//@property (nonatomic,strong)  NSData *userXmlData;
@property (nonatomic) SmoothLineView * canvas;
//- (id)initWithFrame:(CGRect)frame signature:(NSString*) signature;
//-(void)clearImage;
-(void)refresh:(CGSize)rect;
@end
