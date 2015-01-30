//
//	ReaderDocument.h
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReaderDocument : NSObject <NSObject, NSCoding>

@property (nonatomic, strong, readonly) NSString *guid;
@property (nonatomic, strong, readonly) NSDate *fileDate;
@property (nonatomic, strong, readwrite) NSDate *lastOpen;
@property (nonatomic, strong, readonly) NSNumber *fileSize;
@property (nonatomic, strong, readonly) NSNumber *pageCount;
@property (nonatomic, strong, readwrite) NSNumber *pageNumber;
@property (nonatomic, strong, readonly) NSMutableIndexSet *bookmarks;
@property (nonatomic, strong, readonly) NSString *fileName;
@property (nonatomic, strong, readonly) NSString *password;
@property (nonatomic, strong, readonly) NSURL *fileURL;

@property (nonatomic,readwrite) NSNumber *isOriginalMail;
@property (nonatomic,readwrite) NSNumber *isSigned;

+ (ReaderDocument *)withDocumentFilePath:(NSString *)filename password:(NSString *)phrase;

+ (ReaderDocument *)unarchiveFromFileName:(NSString *)filename password:(NSString *)phrase;

- (id)initWithFilePath:(NSString *)fullFilePath password:(NSString *)phrase;

- (void)saveReaderDocument;

- (void)updateProperties;

+ (BOOL)isPDF:(NSString *)filePath;

@end
