//
//	ReaderThumbView.m
//	Reader v2.6.1
//
//	Created by Julius Oklamcak on 2011-09-01.
//	Copyright © 2011-2012 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderThumbView.h"
#import "AppDelegate.h"
@implementation ReaderThumbView
{
	NSOperation *_operation;

	NSUInteger _targetTag;
}

#pragma mark Properties

@synthesize operation = _operation;
@synthesize targetTag = _targetTag;

#pragma mark ReaderThumbView instance methods

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = NO;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingNone;
		self.backgroundColor = [UIColor clearColor];

		imageView = [[UIImageView alloc] initWithFrame:self.bounds];

		imageView.autoresizesSubviews = NO;
		imageView.userInteractionEnabled = NO;
		imageView.autoresizingMask = UIViewAutoresizingNone;
		imageView.contentMode = UIViewContentModeScaleAspectFit;

		[self addSubview:imageView];
        
        labelview = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, self.frame.size.width-20, self.frame.size.height)];
//        CGFloat red = 0.0f / 255.0f;
//        CGFloat green = 155.0f / 255.0f;
//        CGFloat blue = 213.0f / 255.0f;
        //labelview.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        labelview.textColor= [UIColor whiteColor];
        labelview.lineBreakMode = NSLineBreakByWordWrapping;
        labelview.numberOfLines = 2;
        
         labelview.font = [UIFont fontWithName:@"Helvetica" size:17];
        
        [imageView addSubview:labelview];
        [imageView bringSubviewToFront:labelview];
	}

	return self;
}

- (void)showImage:(UIImage *)image
{
    AppDelegate* mainDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (mainDelegate.thumbnailDefined) {
        imageView.frame=CGRectMake(0, 0, 120, 120);
    }
    else
    imageView.frame=CGRectMake(10, 10, image.size.width, image.size.height);
	imageView.image = image; // Show image
}

-(void)showLabel:(NSString *)text{
    labelview.text=text;
}

- (void)showTouched:(BOOL)touched
{
	// Implemented by ReaderThumbView subclass
}

- (void)removeFromSuperview
{
	_targetTag = 0; // Clear target tag

	[self.operation cancel]; // Cancel operation

	[super removeFromSuperview]; // Remove view
}

- (void)reuse
{
	_targetTag = 0; // Clear target tag

	[self.operation cancel]; // Cancel operation

	imageView.image = nil; // Release image
}

@end
