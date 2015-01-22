

#import <UIKit/UIKit.h>

@protocol DrawLayerDelegate <NSObject>

@optional // Delegate protocols

-(void)refresh:(CGSize)rect;


@end


@interface SmoothLineView : UIView 

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) BOOL empty;
@property (nonatomic, retain) UIImage* image;
@property(nonatomic,unsafe_unretained,readwrite) id <DrawLayerDelegate> delegate;

-(void)clear;
-(void)refresh:(CGSize)rect;
@end
