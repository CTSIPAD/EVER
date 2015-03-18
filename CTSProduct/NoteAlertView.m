//
//  NoteAlertView.m
//  CTSIPAD
//
//  Created by MBI.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "NoteAlertView.h"
#import "AppDelegate.h"
@implementation NoteAlertView
{
    CGRect _realBounds;
    CGFloat btnWidth;
    CGFloat btnHeight;
}
@synthesize txtNote,delegate,publicSwitch;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.superview.bounds = _realBounds;
}

- (void)viewDidLoad { _realBounds = self.view.bounds; [super viewDidLoad]; }

- (id)initWithFrame:(CGRect)frame fromComment:(BOOL)isComment
{
    if (self) {
        AppDelegate *mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        originalFrame = frame;
        // self.view.alpha = 1;
        self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"NotePopUpBg.png"]];
        
        
        
        UILabel *Titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, frame.size.width-200, 20)];
        Titlelabel.text = NSLocalizedString(@"Note",@"Note");
        Titlelabel.textAlignment=NSTextAlignmentCenter;
        Titlelabel.backgroundColor = [UIColor clearColor];
        Titlelabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        
        Titlelabel.textColor=mainDelegate.titleColor;
        
        txtNote = [[UITextView alloc] initWithFrame:CGRectMake(50, 60, frame.size.width-100, 150)];
        txtNote.font = [UIFont systemFontOfSize:15];
        txtNote.delegate = self;
        
        txtNote.autocorrectionType = UITextAutocorrectionTypeNo;
        txtNote.keyboardType = UIKeyboardTypeDefault;
        txtNote.returnKeyType = UIReturnKeyDone;
        
        UIButton *saveNote = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnWidth=95;
        btnHeight=35;
        saveNote = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"])
            saveNote.frame = CGRectMake(frame.size.width-btnWidth, 0, btnWidth, btnHeight);
        else
            saveNote.frame = CGRectMake(0, 0, btnWidth, btnHeight);
        
        saveNote.backgroundColor=[UIColor clearColor];
        saveNote.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        [saveNote setTitle:NSLocalizedString(@"Save", @"Save") forState:UIControlStateNormal];
        [saveNote addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        [saveNote setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
        [self.view addSubview:saveNote];

        
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        UIImage*ClearNoteImage;
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            ClearNoteImage=[UIImage imageNamed:@"PopUpbtn.png"];
            clearButton.frame = CGRectMake(50, frame.size.height-70, ClearNoteImage.size.width, ClearNoteImage.size.height);
        }else{
            ClearNoteImage=[UIImage imageNamed:@"PopUpbtn.png"];
            clearButton.frame = CGRectMake((frame.size.width-ClearNoteImage.size.width-50),frame.size.height-70, ClearNoteImage.size.width, ClearNoteImage.size.height);
            
        }
        [clearButton setBackgroundImage:ClearNoteImage forState:UIControlStateNormal];
        
        clearButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:17];
        [clearButton setTitle:NSLocalizedString(@"Clear", @"Clear") forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
        [clearButton setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
        [self.view addSubview:clearButton];
        
        
        
        
        
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"])
            dismissButton.frame = CGRectMake(0, 0, btnWidth, btnHeight);
        else
            dismissButton.frame = CGRectMake(frame.size.width-btnWidth, 0, btnWidth, btnHeight);
        
        dismissButton.backgroundColor=[UIColor clearColor];
        
        dismissButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        [dismissButton setTitle:NSLocalizedString(@"Cancel",@"Cancel") forState:UIControlStateNormal];
        [dismissButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [dismissButton setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
        
        [self.view addSubview:dismissButton];
        
        
        if (isComment) {
            UILabel *publiclabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 155, 90, 20)];
            publiclabel.text =NSLocalizedString(@"Note.Private", @"Private");
            publiclabel.backgroundColor = [UIColor clearColor];
            publiclabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
            
            publiclabel.textColor=[UIColor whiteColor];
            
            publicSwitch=[[UISwitch alloc]initWithFrame:CGRectMake(90, 150, 150, 30)];
            publicSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
            
            if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
                publiclabel.frame=CGRectMake(300, 155, 90, 20);
                publicSwitch.frame=CGRectMake(400-150, 150, 150, 30);
            }
            [self.view addSubview:publiclabel];
            [self.view addSubview:publicSwitch];
        }
        
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
//            Titlelabel.textAlignment=NSTextAlignmentRight;
            txtNote.textAlignment=NSTextAlignmentRight;

        }
        
        [self.view addSubview:Titlelabel];
        [self.view addSubview:txtNote];
        
    }
    return self;
}



- (void)show
{
    
    self.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.view.alpha = 0;
    [UIView beginAnimations:@"showAlert" context:nil];
    [UIView setAnimationDelegate:self];
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 12, 1, 1, 1.0);
    self.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
    self.view.alpha = 1;
    [UIView commitAnimations];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self hide];
        
        //cancel clicked ...do your action
    }
    else if (buttonIndex == 1)
    {
        
        //[alertView textFieldAtIndex:0].text
        
    }
}
-(void)clear{
    txtNote.text=@"";
}
- (void)hide
{
    //    NSLog(@"hide");
    //    isShown = NO;
    //    [UIView beginAnimations:@"hideAlert" context:nil];
    //    [UIView setAnimationDelegate:self];
    //    self.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
    //    self.view.alpha = 0;
    //    [UIView commitAnimations];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)disablesAutomaticKeyboardDismissal { return NO; }

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}




-(void)save{
    UIAlertView *alertKO;
  
    if(txtNote.text.length==0)
    {
        alertKO=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Info",@"Info") message:NSLocalizedString(@"Note.Message",@"Please fill note field.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
        [alertKO show];
        
    }
    else{
        BOOL isPrivate=[publicSwitch isOn];
        [delegate tappedSaveNoteText:self.txtNote.text private:isPrivate];
        [self hide];
    }
}

@end
