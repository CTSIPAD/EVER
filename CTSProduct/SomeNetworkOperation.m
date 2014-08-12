//
//  SomeNetworkOperation.m
//  ConcurrentOperationTest
//
//  Created by Justin Palmer on 6/21/09.
//  Copyright 2009 Alternateidea. All rights reserved.
//

#import "SomeNetworkOperation.h"
#import "CParser.h"
#import "AppDelegate.h"
#import "OfflineResult.h"
@interface SomeNetworkOperation ()
- (void)finish;
@end

@implementation SomeNetworkOperation
@synthesize delegate = _delegate;
@synthesize requestToLoad=_requestToLoad;

- (id)init
{
   if((self = [super init])) {
       _isExecuting = NO;
       _isFinished = NO;
   }

   return self;
}


- (BOOL)isConcurrent {
    return YES;
}

- (void)start
{
   
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }

    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        _isFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];

    //NSURLRequest *request = [NSURLRequest requestWithURL:self.urlToLoad cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
    _connection = [[NSURLConnection alloc] initWithRequest:self.requestToLoad delegate:self startImmediately:YES];

    if(_connection) {
        _responseData = [[NSMutableData alloc] init];
    } else {
        [self finish];
    }
}

- (void)finish {
    _connection = nil;
    _responseData = nil;

    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];

    _isExecuting = NO;
    _isFinished = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isExecuting {
   return _isExecuting;
}

- (BOOL)isFinished {
   return _isFinished;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_responseData setLength:0];
    AppDelegate* mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.CounterSync++;

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
    AppDelegate* mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(mainDelegate.Downloading){
    [CParser Download:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Action=%@ ",self.Action);
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    AppDelegate* mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    

    BOOL DidAccess=NO;

    if(mainDelegate.Downloading){
        OfflineResult *OR=[[OfflineResult alloc]init];
        OR.Name=@"Download";
        OR.Result=[NSString stringWithFormat:@"Connection failed! Error - %@",
                   [error localizedDescription]];
        [mainDelegate.SyncActions addObject:OR];
        mainDelegate.Downloading=NO;
        
        if([_delegate respondsToSelector:@selector(didFinishLoad:)]) {
            DidAccess=YES;
            [_delegate performSelector:@selector(didFinishLoad:) withObject:
             _responseData];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
        if(DidAccess==NO){
            [mainDelegate.searchResultViewController didFinishLoad:_responseData];
        }

    }
    else{
        OfflineResult *OR=[[OfflineResult alloc]init];
        OR.Name=self.Action;
        OR.Result=[NSString stringWithFormat:@"Connection failed! Error - %@",
                   [error localizedDescription]];
        [mainDelegate.SyncActions addObject:OR];
        [mainDelegate.SyncActions addObject:self.Action];
    mainDelegate.CounterSync++;
    if(mainDelegate.CountOfflineActions==mainDelegate.CounterSync ){
        mainDelegate.CounterSync = 0;
        if([_delegate respondsToSelector:@selector(didFinishLoad:)]) {
            DidAccess=YES;
            [_delegate performSelector:@selector(didFinishLoad:) withObject:
             _responseData];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
        if(DidAccess==NO){
            [mainDelegate.searchResultViewController didFinishLoad:_responseData];
        }
        
    }}
    [self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    UIImage *img = [[UIImage alloc] initWithData:_responseData];
//    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:img, @"img", _urlToLoad, @"url", nil];
   AppDelegate* mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    BOOL DidAccess=NO;
    
    if(mainDelegate.Downloading){
    mainDelegate.Downloading=NO;

    if([_delegate respondsToSelector:@selector(didFinishLoad:)]) {
        DidAccess=YES;
        [_delegate performSelector:@selector(didFinishLoad:) withObject:
         _responseData];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    if(DidAccess==NO){
        [mainDelegate.searchResultViewController didFinishLoad:_responseData];
    }
    }else{
        OfflineResult *OR=[[OfflineResult alloc]init];
        OR.Name=self.Action;
        OR.Result=@"";
        [mainDelegate.SyncActions addObject:OR];
        if(mainDelegate.CountOfflineActions==mainDelegate.CounterSync ){
            mainDelegate.CounterSync = 0;
            if([_delegate respondsToSelector:@selector(didFinishLoad:)]) {
                DidAccess=YES;
                [_delegate performSelector:@selector(didFinishLoad:) withObject:
                 _responseData];
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
            if(DidAccess==NO){
                [mainDelegate.searchResultViewController didFinishLoad:_responseData];
            }

        }
    }
    [self finish];
        
}
@end
