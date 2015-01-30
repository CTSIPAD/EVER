//
//	ReaderConstants.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#if !__has_feature(objc_arc)
	#error ARC (-fobjc-arc) is required to build this code.
#endif

#import <Foundation/Foundation.h>

#define READER_BOOKMARKS TRUE
#define READER_ENABLE_MAIL TRUE
#define READER_ENABLE_PRINT TRUE
#define READER_ENABLE_THUMBS TRUE
#define READER_ENABLE_PREVIEW TRUE
#define READER_DISABLE_RETINA FALSE
#define READER_DISABLE_IDLE FALSE
#define READER_SHOW_SHADOWS TRUE
#define READER_STANDALONE FALSE

extern NSString *const kReaderCopyrightNotice;
