//
//  uploadController.h
//  CTSProduct
//
//  Created by DNA on 7/22/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UploadControllerDialog;
@protocol UploadViewDelegate <NSObject>
-(void)dismissUpload:(UIViewController*)viewcontroller;
@required


@end
@interface UploadControllerDialog : UIViewController{
    CGRect originalFrame;
}
@property (nonatomic,retain) UITextField *txtAttachmentName ;
@property(nonatomic,unsafe_unretained,readwrite) id <UploadViewDelegate> delegate;
@property (nonatomic, assign) NSString* CorrespondenceId;

- (id)initWithFrame:(CGRect)frame;
@end








