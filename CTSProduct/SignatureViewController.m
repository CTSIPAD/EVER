//
//  SignatureViewController.m
//  CTSTest
//
//  Created by DNA on 12/23/13.
//  Copyright (c) 2013 LBI. All rights reserved.
//

#import "SignatureViewController.h"
#import "signature.h"
#import "Base64.h"
#import "AppDelegate.h"
#import "CUser.h"
#import "NSData-AES.h"
#import "GDataXMLNode.h"
#import "CParser.h"
#import "SVProgressHUD.h"
#import "FileManager.h"
#import "StringEncryption.h"
#import "NSData+Base64.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]== NSOrderedAscending)
@interface SignatureViewController ()

@end
@implementation SignatureViewController
{
    AppDelegate *mainDelegate ;
    CGRect _realBounds;

    
    
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.superview.bounds = _realBounds;
}

- (void)viewDidLoad {
    _realBounds = self.view.bounds;
    [super viewDidLoad];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self) {
        //originalFrame = frame;
        // self.view.alpha = 1;
        
                mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        self.view.layer.cornerRadius=5;
        self.view.clipsToBounds=YES;
        self.view.layer.borderWidth=1.0;
        self.view.layer.borderColor=[[UIColor grayColor]CGColor];
        CGFloat red = 1.0f / 255.0f;
        CGFloat green = 49.0f / 255.0f;
        CGFloat blue = 97.0f / 255.0f;
        
        [self.view setBackgroundColor:[UIColor colorWithRed:red green:green blue:blue alpha:1.0]];
        CGFloat textWidth;
        if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
           textWidth=(self.view.frame.size.width/2)-10;
        else
         textWidth=380;
        UIView *paddingView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,10 ,35)];
        UIView *paddingView1=[[UIView alloc] initWithFrame:CGRectMake(0, 0,10 ,35)];
        UIView *paddingView2=[[UIView alloc] initWithFrame:CGRectMake(0, 0,10 ,35)];
        
        
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 25)];
        lblTitle.textColor = [UIColor whiteColor];
        lblTitle.text =NSLocalizedString(@"Signature.YourSignature", @"Your Signature");
        lblTitle.textAlignment=NSTextAlignmentCenter;
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        
        int buttonsY;
        int signViewY;
        if(mainDelegate.PinCodeEnabled){
            signViewY=60;
            buttonsY=450;
            UILabel *lblOldPin = [[UILabel alloc] initWithFrame:CGRectMake(20, 350, 150, 40)];
            lblOldPin.textColor = [UIColor whiteColor];
            lblOldPin.text =NSLocalizedString(@"Signature.OldPinCode",@"Old Pin Code");
            lblOldPin.textAlignment=NSTextAlignmentLeft;
            lblOldPin.backgroundColor = [UIColor clearColor];
            lblOldPin.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
            
            txtOldPin = [[UITextField alloc] initWithFrame:CGRectMake(10, 270, textWidth, 40)];
            txtOldPin.font = [UIFont systemFontOfSize:15];
            txtOldPin.placeholder = NSLocalizedString(@"Signature.OldPinCode",@"Old Pin Code");
            txtOldPin.autocorrectionType = UITextAutocorrectionTypeNo;
            txtOldPin.keyboardType = UIKeyboardTypeNumberPad;
            txtOldPin.returnKeyType = UIReturnKeyDone;
            txtOldPin.clearButtonMode = UITextFieldViewModeWhileEditing;
            txtOldPin.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            txtOldPin.secureTextEntry = YES;
            txtOldPin.delegate=self;
            txtOldPin.backgroundColor=mainDelegate.textColor;
            
            UILabel *lblNewPin = [[UILabel alloc] initWithFrame:CGRectMake(20, 400, 150, 40)];
            lblNewPin.textColor = [UIColor whiteColor];
            lblNewPin.text =NSLocalizedString(@"Signature.PinCode",@"Pin Code");
            lblNewPin.textAlignment=NSTextAlignmentLeft;
            lblNewPin.backgroundColor = [UIColor clearColor];
            lblNewPin.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
            
            txtPin=[[UITextField alloc] initWithFrame:CGRectMake(10, 320,textWidth, 40)];
            txtPin.font = [UIFont systemFontOfSize:15];
            txtPin.placeholder = NSLocalizedString(@"Signature.PinCode",@"Pin Code");
            txtPin.autocorrectionType = UITextAutocorrectionTypeNo;
            txtPin.keyboardType = UIKeyboardTypeNumberPad;
            txtPin.returnKeyType = UIReturnKeyDone;
            txtPin.clearButtonMode = UITextFieldViewModeWhileEditing;
            txtPin.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            txtPin.secureTextEntry = YES;
            txtPin.delegate=self;
            txtPin.backgroundColor=mainDelegate.textColor;
            
            UILabel *lblConfirmPin = [[UILabel alloc] initWithFrame:CGRectMake(20, 450, 150, 40)];
            lblConfirmPin.textColor = [UIColor whiteColor];
            lblConfirmPin.text =NSLocalizedString(@"Signature.ConfirmPin",@"Confirm Pin");
            lblConfirmPin.textAlignment=NSTextAlignmentLeft;
            lblConfirmPin.backgroundColor = [UIColor clearColor];
            lblConfirmPin.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
            
            txtConfirmPin = [[UITextField alloc] initWithFrame:CGRectMake(10, 370, textWidth, 40)];
            txtConfirmPin.font = [UIFont systemFontOfSize:15];
            txtConfirmPin.placeholder = NSLocalizedString(@"Signature.PinCodeConfirmation",@"Pin Code Confirmation");
            txtConfirmPin.autocorrectionType = UITextAutocorrectionTypeNo;
            txtConfirmPin.keyboardType = UIKeyboardTypeNumberPad;
            txtConfirmPin.returnKeyType = UIReturnKeyDone;
            txtConfirmPin.clearButtonMode = UITextFieldViewModeWhileEditing;
            txtConfirmPin.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            txtConfirmPin.secureTextEntry = YES;
            txtConfirmPin.delegate=self;
            txtConfirmPin.backgroundColor=mainDelegate.textColor;
            
            if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
                
                txtOldPin.rightViewMode=UITextFieldViewModeAlways;
                txtPin.rightViewMode=UITextFieldViewModeAlways;
                txtConfirmPin.rightViewMode=UITextFieldViewModeAlways;
                
                txtOldPin.rightView=paddingView;
                txtPin.rightView=paddingView1;
                txtConfirmPin.rightView=paddingView2;
                
                
            }
            else{
                txtOldPin.leftViewMode=UITextFieldViewModeAlways;
                txtPin.leftViewMode=UITextFieldViewModeAlways;
                txtConfirmPin.leftViewMode=UITextFieldViewModeAlways;
                
                txtOldPin.leftView=paddingView;
                txtPin.leftView=paddingView1;
                txtConfirmPin.leftView=paddingView2;
            }
        }
        else
        {
            signViewY=100;
            buttonsY=330;
        }
        sigView=[[Signature alloc]initWithFrame:CGRectMake((frame.size.width-175)/2, signViewY, 175, 175) signature:mainDelegate.user.signature];
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        saveButton.frame =CGRectMake((frame.size.width-385)/3, buttonsY, 115, 35);
        [saveButton setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
        [saveButton setTitle:NSLocalizedString(@"Save",@"Save") forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        saveButton.backgroundColor=mainDelegate.buttonColor;

        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        clearButton.frame = CGRectMake(saveButton.frame.origin.x+115+20, buttonsY, 115, 35);
        [clearButton setTitle:NSLocalizedString(@"Clear",@"Clear") forState:UIControlStateNormal];
        [clearButton setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
        clearButton.backgroundColor=mainDelegate.buttonColor;
        
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = CGRectMake(clearButton.frame.origin.x+115+20, buttonsY, 115, 35);
        [cancelButton setTitleColor:mainDelegate.titleColor forState:UIControlStateNormal];
        [cancelButton setTitle:NSLocalizedString(@"Close",@"Close") forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.backgroundColor=mainDelegate.buttonColor;
        
        if ([mainDelegate.IpadLanguage isEqualToString:@"ar"]) {
            cancelButton.frame=CGRectMake((frame.size.width-385)/3, buttonsY, 115, 35);
            clearButton.frame = CGRectMake(cancelButton.frame.origin.x+115+20, buttonsY, 115, 35);
            saveButton.frame=CGRectMake(clearButton.frame.origin.x+115+20, buttonsY, 115, 35);
        }
        
        [self.view addSubview:lblTitle];
        if(mainDelegate.PinCodeEnabled){
            [self.view addSubview:txtOldPin];
            [self.view addSubview:txtPin];
            [self.view addSubview:txtConfirmPin];
        }
        [self.view addSubview:sigView];
        [self.view addSubview:saveButton];
        [self.view addSubview:clearButton];
        [self.view addSubview:cancelButton];
        
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clear{
    [sigView clearImage];
    // UIImage* img= [self changeColor:[sigView signatureImage] ];
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    //
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
    //														 NSUserDomainMask, YES);
    //    NSString *documentsDirectory = [paths objectAtIndex:0];
    //    NSString *documentsPath = [documentsDirectory
    //							   stringByAppendingPathComponent:@"myimage.png"];
    //    NSData *myImageData = UIImageJPEGRepresentation(img, 1.0);
    //    [fileManager createFileAtPath:documentsPath contents:myImageData attributes:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)save{
    
    
    UIAlertView *alertKO;
    if (sigView.sigView.image !=nil) {

    if((txtPin.text.length==0 || txtConfirmPin.text.length==0)&& mainDelegate.PinCodeEnabled)
    {
        alertKO=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Info",@"Info") message:NSLocalizedString(@"Alert.RequiredFields",@"PLease fill all required fields.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
        [alertKO show];
        
    }
    else{
        if([txtPin.text isEqualToString:txtConfirmPin.text]|| !mainDelegate.PinCodeEnabled)
        {
             [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Updating",@"Updating ...") maskType:SVProgressHUDMaskTypeBlack];
            NSString *str = txtPin.text;
            NSString * _key = @"EverTeamYears202020";
            StringEncryption *crypto = [[StringEncryption alloc] init];
            NSData *_secretData = [str dataUsingEncoding:NSUTF8StringEncoding];
            CCOptions padding = kCCOptionPKCS7Padding;
            NSData *encryptedData = [crypto encrypt:_secretData key:[_key dataUsingEncoding:NSUTF8StringEncoding] padding:&padding];
            NSString* b64EncStrOld=[encryptedData base64EncodingWithLineLength:0];
            
            
            
            
            if([mainDelegate.user.pincode isEqualToString:@""]||mainDelegate.user.pincode ==nil || [mainDelegate.user.pincode isEqualToString:b64EncStrOld] || !mainDelegate.PinCodeEnabled){
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                @try {
                    
                    NSData *myImageData=UIImagePNGRepresentation([sigView signatureImage]);
                    [Base64 initialize];
                    NSString* encodedImage=[[NSString alloc] initWithData:myImageData encoding:NSUTF8StringEncoding];
                    encodedImage=[Base64 encode:myImageData];
                    
                    NSString *str ;
                    NSString* b64EncStr;
                    if(mainDelegate.PinCodeEnabled){
                        str = txtPin.text;
                        // 1) Encrypt
                        NSLog(@"encrypting string = %@",str);
                        NSString * _key = @"EverTeamYears202020";
                        StringEncryption *crypto = [[StringEncryption alloc] init];
                        NSData *_secretData = [str dataUsingEncoding:NSUTF8StringEncoding];
                        CCOptions padding = kCCOptionPKCS7Padding;
                        NSData *encryptedData = [crypto encrypt:_secretData key:[_key dataUsingEncoding:NSUTF8StringEncoding] padding:&padding];
                        b64EncStr=[encryptedData base64EncodingWithLineLength:0];
                    }
                    else{
                        b64EncStr=@"";
                    }
                    
                    NSString *saveString=[self appendXmlSignature:encodedImage withPincode:b64EncStr];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    if([saveString isEqualToString:@"OK"]){
                        mainDelegate.user.signature=encodedImage;
                        mainDelegate.user.pincode=b64EncStr;
                        [FileManager deleteFileName:@"signature.xml"];
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Info",@"Info") message:NSLocalizedString(@"Alert.SignatureSaved",@"Signature Saved Successfully") delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
                        [alert show];
                    }else {
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error",@"Error") message:NSLocalizedString(saveString,@"Retry") delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
                        [alert show];
                    }
                });
                }
                 
                @catch (NSException *ex) {
                    [FileManager appendToLogView:@"SignatureViewController" function:@"save" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
                }
                @finally {
                    
                }
                 });
            }else {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning",@"Warning")  message:NSLocalizedString(@"Alert.WrongPin",@"Wrong Pincode") delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
                [alert show];
            }
            
        }
        else
        {
            alertKO=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning",@"Warning")  message:NSLocalizedString(@"Alert.PinMatch",@"Pin code Confirmation doesn't match") delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
            [alertKO show];
            
        }
    }
       }
    else
    {
        alertKO=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning",@"Warning")  message:NSLocalizedString(@"Alert.SignView",@"Empty Sign View") delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
        [alertKO show];
    
    }
}


- (NSString *)appendXmlSignature:(NSString *)encodedImage withPincode:(NSString*)encodedPin{
    
    NSString *returnStr=@"";
    @try {
        NSError *error;
        NSString* strSig=@"<signatures></signatures>";
        GDataXMLElement* rootSignature=[[GDataXMLElement alloc] initWithXMLString:strSig error:&error];
        
        
        NSArray *signatures2 = [rootSignature nodesForXPath:@"//signatures" error:nil];
        
        if (signatures2.count==0) {
            GDataXMLElement * signatureElement2 = [GDataXMLNode elementWithName:@"signatures" stringValue:@""];
            [rootSignature addChild:signatureElement2];
            signatures2 = [rootSignature nodesForXPath:@"//signatures" error:nil];
        }
        
        GDataXMLElement *signatureXML2 =  [signatures2 objectAtIndex:0];
        
        GDataXMLElement * nameElement1 = [GDataXMLNode elementWithName:@"token" stringValue:mainDelegate.user.token];
        GDataXMLNode *child1 = [signatureXML2.children objectAtIndex:0];
        [signatureXML2 removeChild:child1];
        
        [signatureXML2 addChild:nameElement1];
        GDataXMLElement * nameElement2 = [GDataXMLNode elementWithName:@"signature" stringValue:encodedImage];
        NSArray *sign = [signatureXML2 elementsForName:@"signature"];
        if (sign.count > 0) {
            GDataXMLElement *SignXML2=  [sign objectAtIndex:0];
            GDataXMLNode *Schild2 = [SignXML2.children objectAtIndex:0];
            [signatureXML2 removeChild:Schild2];
            [signatureXML2 removeChild:SignXML2];
        }
        [signatureXML2 addChild:nameElement2];
        
        GDataXMLElement * signatureId = [GDataXMLNode elementWithName:@"SignatureId" stringValue:mainDelegate.user.signatureId];
        NSArray *signid = [signatureXML2 elementsForName:@"SignatureId"];
        if (signid.count > 0) {
            GDataXMLElement *SignXML2=  [signid objectAtIndex:0];
            GDataXMLNode *Schild2 = [SignXML2.children objectAtIndex:0];
            [signatureXML2 removeChild:Schild2];
            [signatureXML2 removeChild:SignXML2];
        }
        [signatureXML2 addChild:signatureId];
        
        
        if(mainDelegate.PinCodeEnabled){
            
            NSArray *pincodes2 = [signatureXML2 elementsForName:@"pinCode"];
            if (pincodes2.count > 0) {
                GDataXMLElement *pinXML2=  [pincodes2 objectAtIndex:0];
                GDataXMLNode *pchild2 = [pinXML2.children objectAtIndex:0];
                [signatureXML2 removeChild:pchild2];
                [signatureXML2 removeChild:pinXML2];
            }
            
            NSString *str = txtPin.text;
            NSString * _key = @"EverTeamYears202020";
            StringEncryption *crypto = [[StringEncryption alloc] init];
            NSData *_secretData = [str dataUsingEncoding:NSUTF8StringEncoding];
            CCOptions padding = kCCOptionPKCS7Padding;
            NSData *encryptedData = [crypto encrypt:_secretData key:[_key dataUsingEncoding:NSUTF8StringEncoding] padding:&padding];
            NSString* b64EncStr=[encryptedData base64EncodingWithLineLength:0];
            
            
            
            GDataXMLElement * pinElement = [GDataXMLNode elementWithName:@"pinCode" stringValue:b64EncStr];
            
            [signatureXML2 addChild:pinElement];
        }
        
        GDataXMLDocument *SignaturedocumentXml = [[GDataXMLDocument alloc] initWithRootElement:rootSignature];
        
        NSData *xmlSignature=SignaturedocumentXml.XMLData;
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *SignaturesPath = [documentsDirectory stringByAppendingPathComponent:@"signature.xml"];
        
        [xmlSignature writeToFile:SignaturesPath atomically:YES];
        if(xmlSignature.length !=0)
            returnStr=[self saveSignature:xmlSignature];
        
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"SignatureViewController" function:@"appendXmlSignature" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    @finally {
        
    }
    return returnStr;
    
}


-(NSString*)saveSignature:(NSData*)fileData{
    NSString *returnString=@"";
    @try{
        NSString* url;
        if(mainDelegate.SupportsServlets)
            url = [NSString stringWithFormat:@"http://%@",mainDelegate.serverUrl];
        else
            url = [NSString stringWithFormat:@"http://%@/UpdateSignature",mainDelegate.serverUrl];
        
        
        // setting up the request object now
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        if(mainDelegate.SupportsServlets){
            // action parameter
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"action\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"UpdateSignature" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        //    // token parameter
        //    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        //    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"token\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        //    [body appendData:[mainDelegate.user.token dataUsingEncoding:NSUTF8StringEncoding]];
        //    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        // file
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"signatureFile\"; filename=\".xml\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:fileData]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        // close form
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // set request body
        [request setHTTPBody:body];
        [request setTimeoutInterval:mainDelegate.Request_timeOut];
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        returnString = [CParser ValidateWithData:returnData];
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"SignatureViewController" function:@"saveSignature" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    return returnString;
}


- (void)show
{
    // NSLog(@"show");
    
    // isShown = YES;
    self.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.view.alpha = 0;
    [UIView beginAnimations:@"showAlert" context:nil];
    [UIView setAnimationDelegate:self];
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 12, 1, 1, 1.0);
    self.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
    self.view.alpha = 1;
    [UIView commitAnimations];
    
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


@end
