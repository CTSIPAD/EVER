//
//  main.m
//  CTSProduct
//
//  Created by DNA on 6/21/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char* argv[])
{
    @autoreleasepool
    {
        int returnValue;
        @try
        {
            returnValue = UIApplicationMain(argc, argv, nil,
                                            NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException* exception)
        {
            NSLog(@"Uncaught exception: %@, %@", [exception description],
                     [exception callStackSymbols]);
            @throw exception;
        }
        return returnValue;
    }
}