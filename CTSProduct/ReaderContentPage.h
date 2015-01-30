//
//	ReaderContentPage.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Scanner.h"

@interface ReaderContentPage : UIView
{
@private // Instance variables

	NSMutableArray *_links;

	CGPDFDocumentRef _PDFDocRef;

	CGPDFPageRef _PDFPageRef;

	NSInteger _pageAngle;

	CGSize _pageSize;
    NSArray *selections;
	//Scanner *scanner;
    NSString *keyword;
   
}


- (id)initWithURL:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)phrase;

- (id)processSingleTap:(UITapGestureRecognizer *)recognizer;
//@property (nonatomic, retain) Scanner *scanner;
@property (nonatomic, copy) NSArray *selections;
@property (nonatomic, copy) NSString *keyword;
@end

#pragma mark -

//
//	ReaderDocumentLink class interface
//

@interface ReaderDocumentLink : NSObject
{
@private // Instance variables

	CGPDFDictionaryRef _dictionary;

	CGRect _rect;
}

@property (nonatomic, assign, readonly) CGRect rect;

@property (nonatomic, assign, readonly) CGPDFDictionaryRef dictionary;

+ (id)withRect:(CGRect)linkRect dictionary:(CGPDFDictionaryRef)linkDictionary;

- (id)initWithRect:(CGRect)linkRect dictionary:(CGPDFDictionaryRef)linkDictionary;

@end
