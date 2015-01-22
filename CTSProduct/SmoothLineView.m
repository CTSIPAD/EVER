

#import "SmoothLineView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#define DEFAULT_COLOR               [UIColor blackColor]
#define DEFAULT_WIDTH               3.0f
#define DEFAULT_BACKGROUND_COLOR    [UIColor clearColor]

static const CGFloat kPointMinDistance = 5.0f;
static const CGFloat kPointMinDistanceSquared = kPointMinDistance * kPointMinDistance;

@interface SmoothLineView ()
@property (nonatomic,assign) CGPoint currentPoint;
@property (nonatomic,assign) CGPoint previousPoint;
@property (nonatomic,assign) CGPoint previousPreviousPoint;

#pragma mark Private Helper function
CGPoint midPoint(CGPoint p1, CGPoint p2);
@end

@implementation SmoothLineView {

@private
	CGMutablePathRef _path;
}
@synthesize image;
#pragma mark UIView lifecycle methods

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  
  if (self) {
    // NOTE: do not change the backgroundColor here, so it can be set in IB.
		_path = CGPathCreateMutable();
    _lineWidth = DEFAULT_WIDTH;
    _lineColor = DEFAULT_COLOR;
    _empty = YES;
  }
  
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  
  if (self) {
    self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
      CGFloat borderWidth = 2.0f;
      
      self.frame = CGRectInset(self.frame, -borderWidth, -borderWidth);
      self.layer.borderColor = [UIColor clearColor].CGColor;
      self.layer.borderWidth = borderWidth;
		_path = CGPathCreateMutable();
    _lineWidth = DEFAULT_WIDTH;
    _lineColor = DEFAULT_COLOR;
    _empty = YES;
  }
  
  return self;
}

- (void)drawRect:(CGRect)rect {
  // clear rect
  [self.backgroundColor set];
  UIRectFill(rect);
  
  // get the graphics context and draw the path
  CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextAddPath(context, _path);
  CGContextSetLineCap(context, kCGLineCapRound);
  CGContextSetLineWidth(context, self.lineWidth);
  CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
  
  CGContextStrokePath(context);
  CGContextFillRect(context, rect);
  self.empty = NO;
}

-(void)dealloc {
	CGPathRelease(_path);
}

#pragma mark private Helper function

CGPoint midPoint(CGPoint p1, CGPoint p2) {
  return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

#pragma mark Touch event handlers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    AppDelegate * mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
      mainDelegate.IsInside=YES;
  UITouch *touch = [touches anyObject];

  // initializes our point records to current location
  self.previousPoint = [touch previousLocationInView:self];
  self.previousPreviousPoint = [touch previousLocationInView:self];
  self.currentPoint = [touch locationInView:self];

  // call touchesMoved:withEvent:, to possibly draw on zero movement
  [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
	
	CGPoint point = [touch locationInView:self];
	
	// if the finger has moved less than the min dist ...
  CGFloat dx = point.x - self.currentPoint.x;
  CGFloat dy = point.y - self.currentPoint.y;
	
  if ((dx * dx + dy * dy) < kPointMinDistanceSquared) {
    // ... then ignore this movement
    return;
  }
  
  // update points: previousPrevious -> mid1 -> previous -> mid2 -> current
  self.previousPreviousPoint = self.previousPoint;
  self.previousPoint = [touch previousLocationInView:self];
  self.currentPoint = [touch locationInView:self];
  
  CGPoint mid1 = midPoint(self.previousPoint, self.previousPreviousPoint);
  CGPoint mid2 = midPoint(self.currentPoint, self.previousPoint);

  // to represent the finger movement, create a new path segment,
  // a quadratic bezier path from mid1 to mid2, using previous as a control point
  CGMutablePathRef subpath = CGPathCreateMutable();
  CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
  CGPathAddQuadCurveToPoint(subpath, NULL,
                            self.previousPoint.x, self.previousPoint.y,
                            mid2.x, mid2.y);
  
  // compute the rect containing the new segment plus padding for drawn line
  CGRect bounds = CGPathGetBoundingBox(subpath);
  CGRect drawBox = CGRectInset(bounds, -2.0 * self.lineWidth, -2.0 * self.lineWidth);
  
  // append the quad curve to the accumulated path so far.
	CGPathAddPath(_path, NULL, subpath);
	CGPathRelease(subpath);

  [self setNeedsDisplayInRect:drawBox];
}

#pragma mark interface

-(void)clear {
  CGMutablePathRef oldPath = _path;
  CFRelease(oldPath);
  _path = CGPathCreateMutable();
  [self setNeedsDisplay];
}
-(void)refresh:(CGSize)rect{
    
    
    
    image = [self capture];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                         NSUserDomainMask, YES);
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *documentsPath1 = [documentsDirectory
//                                stringByAppendingPathComponent:@"trans0.jpg"];
//    [fileManager createFileAtPath:documentsPath1 contents:UIImagePNGRepresentation(image) attributes:nil];
    
    }
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [_delegate refresh:self.frame.size];
}
- (UIImage*) capture {
     self.layer.borderColor = [UIColor clearColor].CGColor;
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     self.layer.borderColor = [UIColor yellowColor].CGColor;
    return img;
}
@end

