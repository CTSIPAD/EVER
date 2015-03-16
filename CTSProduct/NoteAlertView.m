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
        
        
        
        UILabel *Titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, frame.size.width-100, 20)];
        Titlelabel.text = NSLocalizedString(@"Note",@"Note");
        Titlelabel.textAlignment=NSTextAlignmentLeft;
        Titlelabel.backgroundColor = [UIColor clearColor];
        Titlelabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        
        Titlelabel.textColor=mainDelegate.selectedInboxColor;
        
        txtNote = [[UITextView alloc] initWithFrame:CGRectMake(50, 60, frame.size.width-100, 150)];
        txtNote.font = [UIFont systemFontOfSize:15];
        txtNote.delegate = self;
        
        txtNote.autocorrectionType = UITextAutocorrectionTypeNo;
        txtNote.keyboardType = UIKeyboardTypeDefault;
        txtNote.returnKeyType = UIReturnKeyDone;
        
        UIButton *saveNote = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        UIImage *SaveNoteImage;
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            SaveNoteImage=[UIImage imageNamed:@"PopUpbtn.png"];
            saveNote.frame = CGRectMake(2*SaveNoteImage.size.width+70, txtNote.frame.origin.y+txtNote.frame.size.height+15, SaveNoteImage.size.width, SaveNoteImage.size.height);
        }else{
            SaveNoteImage=[UIImage imageNamed:@"PopUpbtn.png"];
            saveNote.frame = CGRectMake((frame.size.width-70)-(3*SaveNoteImage.size.width), txtNote.frame.origin.y+txtNote.frame.size.height+15, SaveNoteImage.size.width, SaveNoteImage.size.height);
            
        }
        [saveNote setBackgroundImage:SaveNoteImage forState:UIControlStateNormal];
        
        saveNote.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:17];
        [saveNote setTitle:NSLocalizedString(@"Save", @"Save") forState:UIControlStateNormal];
        [saveNote addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        [saveNote setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
        [self.view addSubview:saveNote];
        
        
        
        
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            SaveNoteImage=[UIImage imageNamed:@"PopUpbtn.png"];
            clearButton.frame = CGRectMake(SaveNoteImage.size.width+60, txtNote.frame.origin.y+txtNote.frame.size.height+15, SaveNoteImage.size.width, SaveNoteImage.size.height);
        }else{
            SaveNoteImage=[UIImage imageNamed:@"PopUpbtn.png"];
            clearButton.frame = CGRectMake((frame.size.width-60)-(2*SaveNoteImage.size.width), txtNote.frame.origin.y+txtNote.frame.size.height+15, SaveNoteImage.size.width, SaveNoteImage.size.height);
            
        }
        [clearButton setBackgroundImage:SaveNoteImage forState:UIControlStateNormal];
        
        clearButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:17];
        [clearButton setTitle:NSLocalizedString(@"Clear", @"Clear") forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
        [clearButton setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
        [self.view addSubview:clearButton];
        
        
        
        
        
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        UIImage *closeButtonImage;
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            closeButtonImage=[UIImage imageNamed:@"PopUpCancelBtn_ar.png"];
            
            dismissButton.frame = CGRectMake(50, txtNote.frame.origin.y+txtNote.frame.size.height+15, closeButtonImage.size.width, closeButtonImage.size.height);
        }else{
            closeButtonImage=[UIImage imageNamed:@"PopUpCancelBtn_en.png"];
            dismissButton.frame = CGRectMake((frame.size.width-50)-closeButtonImage.size.width, txtNote.frame.origin.y+txtNote.frame.size.height+15, closeButtonImage.size.width, closeButtonImage.size.height);
            [dismissButton setTitleEdgeInsets: UIEdgeInsetsMake(0,15,0,0)];
        }
        [dismissButton setBackgroundImage:closeButtonImage forState:UIControlStateNormal];
        dismissButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:17];
        [dismissButton setTitle:NSLocalizedString(@"Close", @"Close") forState:UIControlStateNormal];
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
            Titlelabel.textAlignment=NSTextAlignmentRight;
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
