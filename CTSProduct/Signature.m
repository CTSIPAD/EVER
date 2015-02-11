//
//  Signature.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "Signature.h"
#import "Base64.h"
#import "CParser.h"
#import "FileManager.h"
static
CGPoint midPoint(CGPoint p1 ,CGPoint p2){
    return CGPointMake((p1.x+p2.x)*0.5, (p1.y+p2.y)*0.5);
}
@implementation Signature
@synthesize sigView,signatureImage,userXmlData;
- (id)initWithFrame:(CGRect)frame signature:(NSString*) signature
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView* imageView=[[UIImageView alloc]initWithFrame:[self bounds]];
        imageView.userInteractionEnabled=YES;
        self.sigView=imageView;
        self.sigView.userInteractionEnabled=YES;
		self.backgroundColor=[UIColor whiteColor];
		self.userInteractionEnabled=YES;
        
        if(![signature isEqualToString:@""]){
            [Base64 initialize];
            NSData* imgData;
            imgData=[Base64 decode:signature];
            UIImage *myImage=[UIImage imageWithData:imgData];
            [self.sigView setImage:myImage];
            [self setSignatureImage:myImage];
            
        }
        [self addSubview:sigView];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[touches anyObject];
    previousPoint1=[touch previousLocationInView:self];
    previousPoint2=[touch previousLocationInView:self];
    currentPoint=[touch locationInView:self];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch=[touches anyObject];
    previousPoint2=previousPoint1;
    previousPoint1=[touch previousLocationInView:self];
    currentPoint=[touch locationInView:self];
    
    CGPoint mid1=midPoint(previousPoint1, previousPoint2);
    CGPoint mid2=midPoint(currentPoint, previousPoint1);
    
    UIGraphicsBeginImageContextWithOptions(self.sigView.frame.size,NO,0.0);
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    [self.sigView.image drawInRect:CGRectMake(0, 0, self.sigView.frame.size.width, self.sigView.frame.size.height)];
    CGContextMoveToPoint(context, mid1.x, mid1.y);
    CGContextAddQuadCurveToPoint(context, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 2.0);
    
    CGContextSetRGBStrokeColor(context, 0, 18/255.0, 282/255.0, 1.0);
    CGContextStrokePath(context);
    self.sigView.image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
}
-(void)clearImage{
    [UIView beginAnimations:nil context:nil];
    [UIView animateWithDuration:1 animations:nil];
    sigView.image = nil;
    [UIView commitAnimations];
}
- (UIImage *)invertImage:(UIImage *)originalImage
{
    UIGraphicsBeginImageContext(originalImage.size);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    CGRect imageRect = CGRectMake(0, 0, originalImage.size.width, originalImage.size.height);
    [originalImage drawInRect:imageRect];
    
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, originalImage.size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    //mask the image
    CGContextClipToMask(UIGraphicsGetCurrentContext(), imageRect,  originalImage.CGImage);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor whiteColor].CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, originalImage.size.width, originalImage.size.height));
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}
-(UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [self changeWhiteColorTransparent:img];
}
-(UIImage *)changeWhiteColorTransparent: (UIImage *)image
{
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath1 = [documentsDirectory
                                stringByAppendingPathComponent:@"trans0.jpg"];
    [fileManager createFileAtPath:documentsPath1 contents:UIImagePNGRepresentation(image) attributes:nil];
    
    CGImageRef rawImageRef=image.CGImage;
    const float colorMasking[6] = {222, 255, 222, 255, 222, 255};
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        //if in iPhone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    
    
    result=[UIImage imageWithData:UIImagePNGRepresentation(image)];
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    return result;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //    [self setSignatureImage:[self invertImage:self.sigView.image]];
    //    self.sigView.image=self.signatureImage;
    [self setSignatureImage:[self changeWhiteColorTransparent:self.sigView.image]];
}
@end
