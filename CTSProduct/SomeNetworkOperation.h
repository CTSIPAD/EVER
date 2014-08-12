//
//  SomeNetworkOperation.h
//  ConcurrentOperationTest
//
//  Created by Justin Palmer on 6/21/09.
//  Copyright 2009 Alternateidea. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol OperationDelegate <NSObject>
- (void)didFinishLoad:(NSMutableData *)info;
@required

@end
@interface SomeNetworkOperation : NSOperation {
    NSURL *_urlToLoad;

    NSURLConnection *_connection;
    NSMutableData   *_responseData;

    BOOL _isFinished;
    BOOL _isExecuting;
}

@property (nonatomic, weak) id <OperationDelegate>delegate;
@property (nonatomic, retain) NSURLRequest *requestToLoad;
@property (strong,nonatomic)NSString* Action;

@end
