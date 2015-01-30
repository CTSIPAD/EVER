//
//  Signature.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "DrawLayerView.h"
#import "Base64.h"
#import "AppDelegate.h"
#import <CoreMotion/CoreMotion.h>

//static
//CGPoint midPoint(CGPoint p1 ,CGPoint p2){
//    return CGPointMake((p1.x+p2.x)*0.5, (p1.y+p2.y)*0.5);
//}
@implementation DrawLayerView
@synthesize sigView,signatureImage;//userXmlData;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView* imageView=[[UIImageView alloc]initWithFrame:[self bounds]];
        imageView.userInteractionEnabled=YES;
        self.sigView=imageView;
        self.sigView.userInteractionEnabled=YES;
        		self.backgroundColor=[UIColor clearColor];
		self.userInteractionEnabled=YES;
//        CGFloat borderWidth = 2.0f;
//        
//        self.sigView.frame = CGRectInset(self.frame, -borderWidth, -borderWidth);
//        self.sigView.layer.borderColor = [UIColor clearColor].CGColor;
//        self.sigView.layer.borderWidth = borderWidth;
//        [self.sigView setContentMode:UIViewContentModeScaleAspectFill];
//        [self.sigView setClipsToBounds:YES];
//
//        [self addSubview:sigView];
        
        SmoothLineView * smoothLineView =[[SmoothLineView alloc] initWithFrame:self.bounds ];
        self.canvas = smoothLineView;
        self.canvas.delegate=self;
        self.sigView.image=self.canvas.image;
        [self addSubview:smoothLineView];
  

    }
    return self;
}
-(void)refresh:(CGSize)rect{

    [self.canvas refresh:rect];
    self.sigView.image=self.canvas.image;
}
-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [self.canvas clear];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    AppDelegate * mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    mainDelegate.IsInside=YES;
//    UITouch *touch=[touches anyObject];
//    previousPoint1=[touch previousLocationInView:self];
//    previousPoint2=[touch previousLocationInView:self];
//    currentPoint=[touch locationInView:self];
//    [self touchesMoved:touches withEvent:event];
//
//}
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    UITouch *touch=[touches anyObject];
//    previousPoint2=previousPoint1;
//    previousPoint1=[touch previousLocationInView:self];
//    currentPoint=[touch locationInView:self];
//    
//    CGPoint mid1=midPoint(previousPoint1, previousPoint2);
//    CGPoint mid2=midPoint(currentPoint, previousPoint1);
//    CGSize p=self.sigView.frame.size;
//    UIGraphicsBeginImageContext(self.sigView.frame.size);
//    CGContextRef context=UIGraphicsGetCurrentContext();
//    
//    [self.sigView.image drawInRect:CGRectMake(0, 0, self.sigView.frame.size.width, self.sigView.frame.size.height)];
//    CGContextMoveToPoint(context, mid1.x, mid1.y);
//    CGContextAddQuadCurveToPoint(context, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y);
//    CGContextSetLineCap(context, kCGLineCapRound);
//    CGContextSetLineWidth(context, 2.0);
//    
//    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0);
//    CGContextStrokePath(context);
//    self.sigView.image=UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    
//}
//-(void)clearImage{
//    [UIView beginAnimations:nil context:nil];
//    [UIView animateWithDuration:1 animations:nil];
//    sigView.image = nil;
//    [UIView commitAnimations];
//}
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self setSignatureImage:self.sigView.image];
//    
//    
//}
@end
