//
//	UIXToolbarView.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "UIXToolbarView.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIXToolbarView

#pragma mark Constants

#define SHADOW_HEIGHT 10.0f

#pragma mark UIXToolbarView class methods

+ (Class)layerClass
{
	return [CAGradientLayer class];
}

#pragma mark UIXToolbarView instance methods

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = YES;
		self.userInteractionEnabled = YES;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
		self.backgroundColor = [UIColor colorWithRed:3/255.0f green:3/255.0f  blue:3/255.0f  alpha:0.9];

//		CAGradientLayer *layer = (CAGradientLayer *)self.layer;
//		UIColor *liteColor = [UIColor colorWithWhite:0.92f alpha:0.8f];
//		UIColor *darkColor = [UIColor colorWithWhite:0.32f alpha:0.8f];
//		layer.colors = [NSArray arrayWithObjects:(id)liteColor.CGColor, (id)darkColor.CGColor, nil];
//
		CGRect shadowRect = self.bounds; shadowRect.origin.y += shadowRect.size.height; shadowRect.size.height = SHADOW_HEIGHT;

		UIXToolbarShadow *shadowView = [[UIXToolbarShadow alloc] initWithFrame:shadowRect];

		//[self addSubview:shadowView];
	}

	return self;
}

@end

#pragma mark -

//
//	UIXToolbarShadow class implementation
//

@implementation UIXToolbarShadow

#pragma mark UIXToolbarShadow class methods

+ (Class)layerClass
{
	return [CAGradientLayer class];
}

#pragma mark UIXToolbarShadow instance methods

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = NO;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];

		CAGradientLayer *layer = (CAGradientLayer *)self.layer;
		//UIColor *blackColor = [UIColor colorWithWhite:0.24f alpha:1.0f];
		//UIColor *clearColor = [UIColor colorWithWhite:0.24f alpha:0.0f];
        UIColor *blackColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
		UIColor *clearColor = [UIColor colorWithWhite:0.1f alpha:0.8f];
		layer.colors = [NSArray arrayWithObjects:(id)blackColor.CGColor, (id)clearColor.CGColor, nil];
	}

	return self;
}

@end
