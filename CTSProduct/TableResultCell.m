//
//  TableResultself.m
//  CTSIPAD
//
//  Created by MBI.
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
#import "CParser.h"
#import "SVProgressHUD.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)
@implementation TableResultCell{
    AppDelegate* mainDelegate;
    UIButton *dropDownbtn;
    ActionTaskController* actionController;
    BOOL isDropDownOpened;
    AttachmentViewController* actionController1;
    NSString* lockedById;
    NSString* lockedBy;
    CGRect frame;
    CCorrespondence *correspondence;

}
@synthesize imageView=_imageView,label1=_label1,label2=_label2,label3=_label3,label4=_label4,LockButton=_LockButton;
-(id)init:(int)index frame:(CGRect)tableFrame{
    self.index=index;
    frame=tableFrame;
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    correspondence=mainDelegate.searchModule.correspondenceList[self.index];
    
    self.isNew=correspondence.New;
    self.isLocked=correspondence.IsLocked;
    self.ShowLock=correspondence.ShowLock;
    self.ClickableLock=correspondence.ClickableLock;
    self.isImportant=correspondence.Priority;
    
    

    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

//        CGFloat red = 19.0f / 255.0f;
//        CGFloat green = 145.0f / 255.0f;
//        CGFloat blue = 247.0f / 255.0f;
        int x;
        int y;
        
//             self.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        self.cellView=[[UIView alloc] init];
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation]) && SYSTEM_VERSION_LESS_THAN(@"8.0") && ![mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            self.cellView.Frame=CGRectMake(15, 13, frame.size.width-120, 150);
        }
        else
        {
            if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation]) && SYSTEM_VERSION_LESS_THAN(@"8.0") && [mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
                self.cellView.Frame=CGRectMake(15, 13, frame.size.width-35, 150);
            }
            else
        self.cellView.Frame=CGRectMake(15, 13, frame.size.width-55, 150);
        }
            //self.cellView=[[UIView alloc] initWithFrame:CGRectMake(15, 13, [UIScreen mainScreen].bounds.size.width-10, 150)];
       
        self.cellView.backgroundColor=mainDelegate.CorrespondenceCellColor;

        [self addSubview:self.cellView];
        
        [self createIconView];

       
        if(mainDelegate.ShowThumbnail==YES){
 
            x=100;
            y=130;
            
        }
        else
        {
            x=0;
            y=40;
        }
        
        if(self.imageView==nil)
            self.imageView =[[UIImageView alloc]init];
        dropDownbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dropDownbtn.autoresizingMask = UIViewAutoresizingNone;
        dropDownbtn.layer.borderColor=[[UIColor whiteColor] CGColor];
        dropDownbtn.layer.borderWidth=2.0f;
        dropDownbtn.layer.cornerRadius=10;
        [dropDownbtn setTitle:NSLocalizedString(@"Menu.Actions",@"Actions") forState:UIControlStateNormal];
        [dropDownbtn setImage:[UIImage imageNamed:@"disclosure.png"] forState:UIControlStateNormal];
        
        UIImage *image;BOOL ThumbnailDefined=NO;
        if(![correspondence.ThumnailUrl isEqualToString:@""]){
            NSString* path=[correspondence.ThumnailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL* url=[NSURL URLWithString:path];
           image =[UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            
            if(image==nil)
                image =[UIImage imageNamed:@"subjectimg.png"];
            else
                ThumbnailDefined=YES;
            
        }
        else{
            image =[UIImage imageNamed:@"subjectimg.png"];
        }
     
        [self.imageView setImage:image];
        
        
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){

            
            
                    self.label1=[[UILabel alloc] initWithFrame:CGRectMake(200, 30, 530-x, 30)];
                    self.label2=[[UILabel alloc] initWithFrame:CGRectMake(200, 60, 530-x, 25)];
                    self.label3=[[UILabel alloc] initWithFrame:CGRectMake(200, 85, 530-x, 20)];
                    self.label4=[[UILabel alloc] initWithFrame:CGRectMake(200, 105, 530-x, 20)];
            
            
            dropDownbtn.frame = CGRectMake(self.cellView.frame.origin.x+80, self.cellView.frame.origin.y+15, 100, 30);

            self.label1.textAlignment=NSTextAlignmentRight;
            self.label2.textAlignment=NSTextAlignmentRight;
            self.label3.textAlignment=NSTextAlignmentRight;
            self.label4.textAlignment=NSTextAlignmentRight;
            dropDownbtn.titleLabel.textAlignment=NSTextAlignmentRight;
            int Space=self.cellView.frame.size.width-(self.label1.frame.origin.x+self.label1.frame.size.width);
            
            if (ThumbnailDefined)
            {
                int ImageX=self.cellView.frame.size.width-70-(Space/4);
                self.imageView.frame=CGRectMake(ImageX, 40, 70, 90);
           
            }else
            {
                int ImageX=self.cellView.frame.size.width-image.size.width-(Space/4);
                self.imageView.frame=CGRectMake(ImageX, 45, image.size.width,image.size.height);
            }
        }
        else{
            if (ThumbnailDefined)
                self.imageView.frame=CGRectMake(15, 30, 70, 90);
            else
                self.imageView.frame=CGRectMake(15, 35, image.size.width,image.size.height);
            self.label1=[[UILabel alloc] initWithFrame:CGRectMake(y, 40, 540-x, 30)];
            self.label2=[[UILabel alloc] initWithFrame:CGRectMake(y, 60, 540-x, 25)];
            self.label3=[[UILabel alloc] initWithFrame:CGRectMake(y, 85, 540-x, 20)];
            self.label4=[[UILabel alloc] initWithFrame:CGRectMake(y, 105, 540-x, 20)];
            
            dropDownbtn.frame = CGRectMake(self.cellView.frame.size.width-165, self.cellView.frame.origin.y+15, 100, 30);
            dropDownbtn.titleLabel.textAlignment=NSTextAlignmentLeft;
            
            
            
        }        
        
        [dropDownbtn addTarget:self action:@selector(ShowDirections) forControlEvents:UIControlEventTouchUpInside];
   
        
        
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
        if(correspondence.QuickActions.count>0 )
       // if(correspondence.QuickActions.count>0 && !self.isLocked)
            [self addSubview:dropDownbtn];
        
        if(mainDelegate.ShowThumbnail)
            [self.cellView addSubview:self.imageView];
        
        [self.cellView addSubview:self.iconView];
        [self.cellView bringSubviewToFront:self.iconView];
    }
    return self;
}

-(void)hideActions:(BOOL)hide
{
    if (hide)
        [dropDownbtn removeFromSuperview];
    else
        [self addSubview:dropDownbtn];
}

-(void)ShowDirections{
  
   
    mainDelegate.QuickActionClicked=true;
    correspondence=mainDelegate.searchModule.correspondenceList[self.index];
    if(!mainDelegate.isOfflineMode){
    [self performSelectorOnMainThread:@selector(increaseProgress) withObject:@"" waitUntilDone:YES];
  
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString* searchUrl;
       
        
        if(mainDelegate.SupportsServlets)
            searchUrl = [NSString stringWithFormat:@"http://%@?action=IsLockedCorrespondence&token=%@&transferId=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.TransferId,mainDelegate.IpadLanguage];
        else
            searchUrl = [NSString stringWithFormat:@"http://%@/IsLockedCorrespondence?token=%@&transferId=%@&language=%@",mainDelegate.serverUrl,mainDelegate.user.token,correspondence.TransferId,mainDelegate.IpadLanguage];
        
        NSMutableDictionary* LockResult=[CParser IsLockedCorrespondence:searchUrl];
       
        dispatch_async(dispatch_get_main_queue(), ^{
            
        lockedById=[LockResult objectForKey:@"lockedby"];
        lockedBy=[LockResult objectForKey:@"UserId"];
        
        if (![mainDelegate.user.userId isEqual:lockedBy] && correspondence.IsLocked) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tasktable.locked",@"Task is locked")
                                                            message:[NSString stringWithFormat:@"%@ %@",lockedById,NSLocalizedString(@"tasktable.locked.dialog",@"has locked the task.")]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [SVProgressHUD dismiss];
           
        }
        else
        {
            
            [self OpenQuickActions:correspondence];
        }
        
            
            
        });
    });
   
    }else{
        [self OpenQuickActions:correspondence];
   
    }
   
    
}
-(void)OpenQuickActions:(CCorrespondence *)corresp{

    actionController1 = [[AttachmentViewController alloc] initWithStyle:UITableViewStylePlain];
    actionController1.actions =corresp.QuickActions;
    
    self.notePopController = [[UIPopoverController alloc] initWithContentViewController:actionController1];
    
    //size as needed
    int maxheight=corresp.QuickActions.count>=3?3:corresp.QuickActions.count;
    if ([mainDelegate.IpadLanguage isEqualToString:@"ar" ]) {
        self.notePopController.popoverContentSize = CGSizeMake(190, 50*maxheight);
    }
    else
    self.notePopController.popoverContentSize = CGSizeMake(240, 50*maxheight);
    
    [UIView beginAnimations:@"rotateDisclosureButt" context:nil];
    [UIView setAnimationDuration:0.2];
    dropDownbtn.imageView.transform = CGAffineTransformMakeRotation(M_PI*2.5);
    [UIView commitAnimations];
    [self.notePopController presentPopoverFromRect:dropDownbtn.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [SVProgressHUD dismiss];
    
    actionController1.index=self.index;
    mainDelegate.QuickActionIndex=self.index;
    actionController1.notePopController=self.notePopController;
    actionController1.delegate=_delegate;
    self.notePopController.delegate=self;
}
- (void)increaseProgress{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Loding ...") maskType:SVProgressHUDMaskTypeBlack];
    
    
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
    [self.cellView removeFromSuperview];
    [self.iconView removeFromSuperview];
    self.label1=nil;
    self.label2=nil;
    self.label3=nil;
    self.label4=nil;
    self.imageNew=nil;
}
-(void)loadmore{
    [dropDownbtn removeFromSuperview];
    [self.imageView removeFromSuperview];
    [self ResetContent];
    self.label1=[[UILabel alloc]initWithFrame: CGRectMake(self.frame.size.width/2+40,-self.frame.size.height/4,362,73)];
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
    
    UIImage *taptoloadImage=[UIImage imageNamed:@"tapToload.png"];
    UIImageView *taptoloadview=[[UIImageView alloc] initWithFrame:CGRectMake(self.label1.frame.origin.x+20,5, taptoloadImage.size.width, taptoloadImage.size.height)];
    taptoloadview.image=taptoloadImage;
    [self addSubview:taptoloadview];
    [self addSubview:self.label1];
    
}

-(void) createIconView
{
    self.iconView=[[UIView alloc] init];
    if ([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]) {
         self.iconView.Frame=CGRectMake(0, 0, 60,self.cellView.frame.size.height);
        
    }
    else
    {

        self.iconView.Frame=CGRectMake(self.cellView.frame.size.width-60, 0, 60,self.cellView.frame.size.height);
        
        
    }

    self.iconView.backgroundColor=mainDelegate.iconViewColor;
    // lock button
    self.LockButton=[[UIButton alloc] init];
    
   
    
    
    // seperator image
    UIImageView *seperatorView=[[UIImageView alloc] init];
    UIImage *seperatorImage=[UIImage imageNamed:@"iconViewSeperator.png"];
    seperatorView.image=seperatorImage;
    //
    
    // new button
    UIButton *newButton=[[UIButton alloc] init];
    UIImage *newImage=[UIImage imageNamed:@"newimg.png"];
    [newButton setImage:newImage forState:UIControlStateNormal];
    newButton.enabled=false;
    //
    
    // seperator1 image
    UIImageView *seperatorView1=[[UIImageView alloc] init];
    UIImage *seperatorImage1=[UIImage imageNamed:@"iconViewSeperator.png"];
    seperatorView1.image=seperatorImage1;
    //
    
    // priority button
    UIButton *priorityButton=[[UIButton alloc] init];
    UIImage *priorityImage=[UIImage imageNamed:@"Priorityimg.png"];
    [priorityButton setImage:priorityImage forState:UIControlStateNormal];
    priorityButton.enabled=false;
    //
    
    
    if (self.isLocked) {
        UIImage *lockImage=[UIImage imageNamed:@"lockimg.png"];
        [self.LockButton setImage:lockImage forState:UIControlStateNormal];
        self.LockButton.frame=CGRectMake(0, 0, self.iconView.frame.size.width,38);
       
        
       // [dropDownbtn removeFromSuperview];
    }
    else
    {
        UIImage *lockImage=[UIImage imageNamed:@"cts_Unlock.png"];
        [self.LockButton setImage:lockImage forState:UIControlStateNormal];
        self.LockButton.frame=CGRectMake(0, 0, self.iconView.frame.size.width,38);
        
    
    
    }
       seperatorView.frame=CGRectMake(0,self.LockButton.frame.size.height+2, self.iconView.frame.size.width, 5);
    if (!mainDelegate.isOfflineMode&& ! [[correspondence.Status lowercaseString] isEqualToString:@"readonly"]) {
        if(self.ShowLock){
            [self.iconView addSubview:self.LockButton];
            [self.iconView addSubview:seperatorView];

        }
        if(self.ClickableLock)
            self.LockButton.enabled=true;
        else
            self.LockButton.enabled=false;

        
    

    }
    if (self.isNew) {
    newButton.frame=CGRectMake(0, seperatorView.frame.origin.y+seperatorView.frame.size.height+2, self.iconView.frame.size.width, 38);
 
    [self.iconView addSubview:newButton];
    
    
    seperatorView1.frame=CGRectMake(0, newButton.frame.origin.y+newButton.frame.size.height+2, self.iconView.frame.size.width, 5);
  
    [self.iconView addSubview:seperatorView1];
    }
    else{
    seperatorView.frame=CGRectMake(0,self.LockButton.frame.size.height+2, self.iconView.frame.size.width, 5);
        [seperatorView setNeedsDisplay];
    }
    if (self.isImportant) {
   
    
    priorityButton.frame=CGRectMake(0, seperatorView1.frame.origin.y+seperatorView1.frame.size.height+2, self.iconView.frame.size.width, 38);
 
    [self.iconView addSubview:priorityButton];
    }
    

}



//-(void)showLockButton:(NSString*)imageName tag:(NSInteger)tag lock:(BOOL)lock priority:(BOOL)Priority new:(BOOL)New{
//    self.LockButton= [UIButton buttonWithType:UIButtonTypeCustom];
//    
//    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
//        if(Priority && New)
//            self.LockButton.frame = CGRectMake(self.frame.origin.x+85, 0, 30, 30);
//        
//        else
//            if ((Priority && !New)||(!Priority  && New))
//                self.LockButton.frame = CGRectMake(self.frame.origin.x+45, 0, 30, 30);
//            else
//                self.LockButton.frame = CGRectMake(self.frame.origin.x+15, 0, 30, 30);
//        
//    }
//    else{
//        if(Priority && New)
//            self.LockButton.frame = CGRectMake(self.frame.origin.x+680, 0, 30, 30);
//        else
//            if ((Priority && !New)||(!Priority && New))
//                self.LockButton.frame = CGRectMake(self.frame.origin.x+720, 0, 30, 30);
//            else
//                self.LockButton.frame = CGRectMake(self.frame.origin.x+755, 0, 30, 30);
//        
//    }
//    [self.LockButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//    [self addSubview:self.LockButton];
//    
//    
//}

//-(void)showNew:(BOOL)lock priority:(BOOL)Priority new:(BOOL)New{
//    if(New){
//        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
//            if(Priority)
//                self.imageNew= [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x+50, 0, 30, 30)];
//            else
//                self.imageNew= [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x+15, 0, 30, 30)];
//            
//        }
//        else{
//            if(Priority)
//                self.imageNew= [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x+720, 0, 30, 30)];
//            else
//                self.imageNew=[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x+755, 0, 30, 30)];
//            
//        }
//        [self.imageNew setImage:[UIImage imageNamed:@"cts_New.png"]];
//        [self addSubview:self.imageNew];
//    }
//}

//-(void)showPriority:(BOOL)Priority{
//    if(Priority){
//        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"])
//            self.imagePriority = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x+15, 0, 30, 30)];
//        else
//            self.imagePriority = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x+755, 0, 30, 30)];
//        
//        [self.imagePriority setImage:[UIImage imageNamed:@"cts_Priority.png"]];
//        [self addSubview:self.imagePriority];
//    }
//}

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
