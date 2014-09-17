//
//  TableResultself.m
//  CTSProduct
//
//  Created by DNA on 6/24/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "TableResultCell.h"
#import "NSData+Base64.h"
#import "AppDelegate.h"
#import "ActionTaskController.h"
#import "CRouteLabel.h"
#import "AttachmentViewController.h"
#import "CCorrespondence.h"
#import "ToolbarItem.h"
#import "ReaderViewController.h"
@implementation TableResultCell{
    AppDelegate* mainDelegate;
    UIButton *dropDownbtn;
    ActionTaskController* actionController;
    BOOL isDropDownOpened;
    AttachmentViewController* actionController1;
    
}
@synthesize imageView=_imageView,label1=_label1,label2=_label2,label3=_label3,label4=_label4,LockButton=_LockButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //        CGFloat red = 29.0f / 255.0f;
        //        CGFloat green = 29.0f / 255.0f;
        //        CGFloat blue = 29.0f / 255.0f;
        CGFloat red = 19.0f / 255.0f;
        CGFloat green = 145.0f / 255.0f;
        CGFloat blue = 247.0f / 255.0f;
        int x;
        if(mainDelegate.ShowThumbnail==YES){
            x=0;
        }
        else
            x=100;
        self.LockButton= [UIButton buttonWithType:UIButtonTypeCustom];
        if(self.imageView==nil)
            self.imageView =[[UIImageView alloc]init];
        dropDownbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dropDownbtn.autoresizingMask = UIViewAutoresizingNone;
        dropDownbtn.layer.borderColor=[[UIColor whiteColor] CGColor];
        dropDownbtn.layer.borderWidth=2.0f;
        dropDownbtn.layer.cornerRadius=10;
        [dropDownbtn setTitle:NSLocalizedString(@"Menu.Actions",@"Actions") forState:UIControlStateNormal];
        [dropDownbtn setImage:[UIImage imageNamed:@"disclosure.png"] forState:UIControlStateNormal];
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            self.imageView.frame=CGRectMake([[UIScreen mainScreen]bounds].size.width-100, 3, 119, 119);
            self.label1=[[UILabel alloc] initWithFrame:CGRectMake(50+x, 5, 600, 30)];
            self.label2=[[UILabel alloc] initWithFrame:CGRectMake(50+x, 40, 600, 25)];
            self.label3=[[UILabel alloc] initWithFrame:CGRectMake(50+x, 65, 600, 20)];
            self.label4=[[UILabel alloc] initWithFrame:CGRectMake(50+x, 85, 600, 20)];
            dropDownbtn.frame = CGRectMake(self.frame.origin.x+55, 10, 100, 30);
            
            self.label1.textAlignment=NSTextAlignmentRight;
            self.label2.textAlignment=NSTextAlignmentRight;
            self.label3.textAlignment=NSTextAlignmentRight;
            self.label4.textAlignment=NSTextAlignmentRight;
            dropDownbtn.titleLabel.textAlignment=NSTextAlignmentRight;
            
        }
        else{
            self.imageView =[[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 119, 119)];
            self.label1=[[UILabel alloc] initWithFrame:CGRectMake(130-x, 5, 600, 30)];
            self.label2=[[UILabel alloc] initWithFrame:CGRectMake(130-x, 40, 600, 25)];
            self.label3=[[UILabel alloc] initWithFrame:CGRectMake(130-x, 65, 600, 20)];
            self.label4=[[UILabel alloc] initWithFrame:CGRectMake(130-x, 85, 600, 20)];
            dropDownbtn.frame = CGRectMake(self.frame.origin.x+555, 10, 100, 30);
            dropDownbtn.titleLabel.textAlignment=NSTextAlignmentLeft;
            
            
            
        }
        
        
        
        [dropDownbtn addTarget:self action:@selector(ShowDirections) forControlEvents:UIControlEventTouchUpInside];
        self.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        
        
        self.label1.backgroundColor=[UIColor clearColor];
        self.label1.textColor=[UIColor whiteColor];
        self.label1.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        
        self.label2.backgroundColor=[UIColor clearColor];
        self.label2.textColor=[UIColor whiteColor];
        self.label2.font=[UIFont fontWithName:@"Helvetica" size:16];
        
        self.label3.backgroundColor=[UIColor clearColor];
        self.label3.textColor=[UIColor whiteColor];
        self.label3.font=[UIFont fontWithName:@"Helvetica" size:16];
        
        self.label4.backgroundColor=[UIColor clearColor];
        self.label4.textColor=[UIColor whiteColor];
        self.label4.font=[UIFont fontWithName:@"Helvetica" size:16];
        
        [self addSubview:self.label1];
        [self addSubview:self.label2];
        [self addSubview:self.label3];
        [self addSubview:self.label4];
        
        [self addSubview:dropDownbtn];
        
        if(mainDelegate.ShowThumbnail)
            [self addSubview:self.imageView];
        
        
    }
    return self;
}

-(void)ShowDirections{
    [UIView beginAnimations:@"rotateDisclosureButt" context:nil];
    [UIView setAnimationDuration:0.2];
    dropDownbtn.imageView.transform = CGAffineTransformMakeRotation(M_PI*2.5);
    [UIView commitAnimations];
    mainDelegate.QuickActionClicked=true;
    CCorrespondence *correspondence=mainDelegate.searchModule.correspondenceList[self.index];
    actionController1 = [[AttachmentViewController alloc] initWithStyle:UITableViewStylePlain];
	actionController1.actions =correspondence.QuickActions;
    
	self.notePopController = [[UIPopoverController alloc] initWithContentViewController:actionController1];
	
	//size as needed
	self.notePopController.popoverContentSize = CGSizeMake(250, 50*3);
    
    
	[self.notePopController presentPopoverFromRect:dropDownbtn.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    actionController1.index=self.index;
    mainDelegate.QuickActionIndex=self.index;
    actionController1.notePopController=self.notePopController;
    actionController1.delegate=_delegate;
    self.notePopController.delegate=self;
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [UIView beginAnimations:@"rotateDisclosureButt" context:nil];
    [UIView setAnimationDuration:0.2];
    dropDownbtn.imageView.transform = CGAffineTransformMakeRotation(0);
    [UIView commitAnimations];
}
-(void)ResetContent{
    [self.label1 removeFromSuperview];
    [self.label2 removeFromSuperview];
    [self.label3 removeFromSuperview];
    [self.label4 removeFromSuperview];
    [self.imageNew removeFromSuperview];
    
    self.label1=nil;
    self.label2=nil;
    self.label3=nil;
    self.label4=nil;
    self.imageNew=nil;
}
-(void)loadmore{
    [dropDownbtn removeFromSuperview];
    [self ResetContent];
    self.label1=[[UILabel alloc]initWithFrame: CGRectMake(self.frame.size.width/2+40,-self.frame.size.height/3,362,73)];
    self.label1.textColor = [UIColor whiteColor];
    self.label1.highlightedTextColor = [UIColor whiteColor];
    self.label1.backgroundColor = [UIColor clearColor];
    self.label1.font=[UIFont fontWithName:@"Verdana" size:20];
    self.label1.textAlignment=NSTextAlignmentCenter;
    self.label1.font=[UIFont boldSystemFontOfSize:20];
    if([mainDelegate.IpadLanguage isEqualToString:@"ar"])
        self.label1.text=@"اضغط هنا لتحميل المزيد";
    else
        self.label1.text=@"Tap here to Load More";
    [self addSubview:self.label1];
    
}
-(void)showLockButton:(NSString*)imageName tag:(NSInteger)tag lock:(BOOL)lock priority:(BOOL)Priority new:(BOOL)New{
    self.LockButton= [UIButton buttonWithType:UIButtonTypeCustom];
    
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        if(Priority && New)
            self.LockButton.frame = CGRectMake(self.frame.origin.x+85, 0, 30, 30);
        
        else
            if ((Priority && !New)||(!Priority  && New))
                self.LockButton.frame = CGRectMake(self.frame.origin.x+45, 0, 30, 30);
            else
                self.LockButton.frame = CGRectMake(self.frame.origin.x+15, 0, 30, 30);
        
    }
    else{
        if(Priority && New)
            self.LockButton.frame = CGRectMake(self.frame.origin.x+680, 0, 30, 30);
        else
            if ((Priority && !New)||(!Priority && New))
                self.LockButton.frame = CGRectMake(self.frame.origin.x+720, 0, 30, 30);
            else
                self.LockButton.frame = CGRectMake(self.frame.origin.x+755, 0, 30, 30);
        
    }
    [self.LockButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self addSubview:self.LockButton];
    
    
}
-(void)showNew:(BOOL)lock priority:(BOOL)Priority new:(BOOL)New{
    if(New){
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            if(Priority)
                self.imageNew= [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x+50, 0, 30, 30)];
            else
                self.imageNew= [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x+15, 0, 30, 30)];
            
        }
        else{
            if(Priority)
                self.imageNew= [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x+720, 0, 30, 30)];
            else
                self.imageNew=[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x+755, 0, 30, 30)];
            
        }
        [self.imageNew setImage:[UIImage imageNamed:@"cts_New.png"]];
        [self addSubview:self.imageNew];
    }
}
-(void)showPriority:(BOOL)Priority{
    if(Priority){
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
            self.imagePriority = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x+15, 0, 30, 30)];
        else
            self.imagePriority = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x+755, 0, 30, 30)];
        
        [self.imagePriority setImage:[UIImage imageNamed:@"cts_Priority.png"]];
        [self addSubview:self.imagePriority];
    }
}
-(void)updateCell {
    
    
    UIImage *cellImage;
    
    NSData * data = [NSData dataWithBase64EncodedString:self.imageThumbnailBase64];
    
    cellImage = [UIImage imageWithData:data];
    self.imageView.clipsToBounds = YES;
    
    [self.imageView setImage:cellImage];
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
