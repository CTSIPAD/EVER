//
//	CGPDFDocument.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

//
//	Custom CGPDFDocument[...] functions
//

CGPDFDocumentRef CGPDFDocumentCreateX(CFURLRef theURL, NSString *password);

BOOL CGPDFDocumentNeedsPassword(CFURLRef theURL, NSString *password);
