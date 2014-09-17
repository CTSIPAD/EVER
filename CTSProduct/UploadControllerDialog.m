//
//  uploadController.m
//  CTSProduct
//
//  Created by DNA on 7/22/14.
//  Copyright (c) 2014 EVER. All rights reserved.
//

#import "UploadControllerDialog.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "CParser.h"
#import "CCorrespondence.h"
#import "FileManager.h"
#import "Base64.h"
#import "GDataXMLElement-Extras.h"
@interface UploadControllerDialog ()
{
    CGRect _realBounds;
    AppDelegate *mainDelegate;
    BOOL isDirectionDropDownOpened;
    BOOL isTransferToDropDownOpened;
    CGPoint centerPoint;
    NSString* imageData;
    
}
@end

@implementation UploadControllerDialog
@synthesize txtAttachmentName,correspondenceIndex;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _realBounds = self.view.bounds;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.superview.bounds = _realBounds;
    self.view.superview.frame=CGRectMake(300, 200, 150, 400);
}
- (id)initWithActionName:(CGRect)frame {
    
    self = [self initWithFrame:frame];
    return self;
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.view.superview.center=centerPoint;
}
- (id)initWithFrame:(CGRect)frame
{
    if (self) {
        originalFrame = frame;
        mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        centerPoint=CGPointMake(500, 400);
        // self.view.alpha = 1;
        self.view.layer.cornerRadius=5;
        self.view.clipsToBounds=YES;
        self.view.layer.borderWidth=1.0;
        self.view.layer.borderColor=[[UIColor grayColor]CGColor];
        //self.view.backgroundColor= [UIColor colorWithRed:29/255.0f green:29/255.0f  blue:29/255.0f  alpha:1.0];
        CGFloat red = 1.0f / 255.0f;
        CGFloat green = 49.0f / 255.0f;
        CGFloat blue = 97.0f / 255.0f;
        self.view.backgroundColor= [UIColor colorWithRed:red green:green  blue:blue  alpha:1.0];
        
        UILabel *Titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width-20, 20)];
        
        
        Titlelabel.text = NSLocalizedString(@"UploadAttachment",@"Upload Attachment");
        Titlelabel.textAlignment=NSTextAlignmentCenter;
        Titlelabel.backgroundColor = [UIColor clearColor];
        Titlelabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        Titlelabel.textColor=[UIColor whiteColor];
        
        NSInteger btnWidth=115;
        
        
        UIButton *Camerabtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        Camerabtn.frame =CGRectMake(frame.size.width-65,62,35, 35);
        Camerabtn.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        [Camerabtn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"camera.png"]]forState:UIControlStateNormal];
        [Camerabtn addTarget:self action:@selector(ChooseExisting) forControlEvents:UIControlEventTouchUpInside];
        [Camerabtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        closeButton.frame =CGRectMake(((frame.size.width-(2*btnWidth +50))/2)+btnWidth+50, frame.size.height-45, btnWidth, 35);
        closeButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        [closeButton setTitle:NSLocalizedString(@"Cancel",@"Cancel") forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        
        UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        uploadButton.frame = CGRectMake((frame.size.width-(2*btnWidth +50))/2-50, frame.size.height-45, btnWidth, 35);
        uploadButton.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
        [uploadButton setTitle:NSLocalizedString(@"Upload",@"Upload") forState:UIControlStateNormal];
        [uploadButton addTarget:self action:@selector(upload) forControlEvents:UIControlEventTouchUpInside];
        [uploadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        UILabel *attachment = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 40)];
        attachment.textColor = [UIColor whiteColor];
        
        attachment.backgroundColor = [UIColor clearColor];
        attachment.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        
        txtAttachmentName = [[UITextField alloc] initWithFrame:CGRectMake(10, 60, 300, 40)];
        txtAttachmentName.borderStyle = UITextBorderStyleRoundedRect;
        txtAttachmentName.font = [UIFont systemFontOfSize:15];
        txtAttachmentName.placeholder = NSLocalizedString(@"AttachmentName",@"Attachment Name");
        txtAttachmentName.autocorrectionType = UITextAutocorrectionTypeNo;
        txtAttachmentName.keyboardType = UIKeyboardTypeNumberPad;
        txtAttachmentName.returnKeyType = UIReturnKeyDone;
        txtAttachmentName.clearButtonMode = UITextFieldViewModeWhileEditing;
        txtAttachmentName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        
        attachment.text =NSLocalizedString(@"AttachmentName",@"Attachment Name:");
        if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
            attachment.textAlignment=NSTextAlignmentRight;
            txtAttachmentName.textAlignment=NSTextAlignmentRight;
            attachment.frame=CGRectMake(((frame.size.width-(2*btnWidth +50))/2)+50, 20, 200, 40);
        }
        else
            attachment.textAlignment=NSTextAlignmentLeft;
        
        [self.view addSubview:Titlelabel];
        [self.view addSubview:txtAttachmentName];
        [self.view addSubview:attachment];
        [self.view addSubview:Camerabtn];
        [self.view addSubview:uploadButton];
        [self.view addSubview:closeButton];
        
        
        
    }
    return self;
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
    txtAttachmentName.text=@"";
}
- (void)hide
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (BOOL)disablesAutomaticKeyboardDismissal { return NO; }



-(IBAction)ChooseExisting{
    UIImagePickerController* picker;
    picker=[[UIImagePickerController alloc]init];
    picker.delegate=self;
    [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:picker animated:YES completion:NULL];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage* image=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    NSData* imgData=UIImageJPEGRepresentation(image,0.2);
    [Base64 initialize];
    imageData=[[NSString alloc] initWithData:imgData encoding:NSUTF8StringEncoding];
    imageData =[Base64 encode:imgData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    centerPoint=CGPointMake(400, 500);
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)appendXml:(NSString *)filename {
    
    @try {
        NSError *error;
        NSString* strSig=@"<Attachment></Attachment>";
        GDataXMLElement* rootSignature=[[GDataXMLElement alloc] initWithXMLString:strSig error:&error];
        
        
        NSArray *signatures2 = [rootSignature nodesForXPath:@"//Attachment" error:nil];
        
        if (signatures2.count==0) {
            GDataXMLElement * signatureElement2 = [GDataXMLNode elementWithName:@"Attachment" stringValue:@""];
            [rootSignature addChild:signatureElement2];
            signatures2 = [rootSignature nodesForXPath:@"//Attachment" error:nil];
        }
        
        GDataXMLElement *signatureXML2 =  [signatures2 objectAtIndex:0];
        
        
        GDataXMLElement * nameElement2 = [GDataXMLNode elementWithName:@"FileContent" stringValue:imageData];
        GDataXMLNode *child2 = [signatureXML2.children objectAtIndex:0];
        [signatureXML2 removeChild:child2];
        
        
        
        NSArray *pincodes2 = [signatureXML2 elementsForName:@"FileName"];
        if (pincodes2.count > 0) {
            GDataXMLElement *pinXML2=  [pincodes2 objectAtIndex:0];
            GDataXMLNode *pchild2 = [pinXML2.children objectAtIndex:0];
            [signatureXML2 removeChild:pchild2];
            [signatureXML2 removeChild:pinXML2];
        }
        GDataXMLElement * pinElement = [GDataXMLNode elementWithName:@"FileName" stringValue:txtAttachmentName.text];
        NSArray *corrId = [signatureXML2 elementsForName:@"CorrespondenceId"];
        if (corrId.count > 0) {
            GDataXMLElement *corrXML=  [corrId objectAtIndex:0];
            GDataXMLNode *corrchild2 = [corrXML.children objectAtIndex:0];
            [signatureXML2 removeChild:corrchild2];
            [signatureXML2 removeChild:corrXML];
        }
        GDataXMLElement * CorrElement = [GDataXMLNode elementWithName:@"CorrespondenceId" stringValue:self.CorrespondenceId];
        [signatureXML2 addChild:CorrElement];
        [signatureXML2 addChild:pinElement];
        
        [signatureXML2 addChild:nameElement2];
        
        GDataXMLDocument *SignaturedocumentXml = [[GDataXMLDocument alloc] initWithRootElement:rootSignature];
        
        NSData *xmlSignature=SignaturedocumentXml.XMLData;
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *SignaturesPath = [documentsDirectory stringByAppendingPathComponent:@"uploadAttachment.xml"];
        
        [xmlSignature writeToFile:SignaturesPath atomically:YES];
        if(xmlSignature.length !=0)
            [self uploadImage:xmlSignature];
    }
    @catch (NSException *ex) {
        NSLog(@"%@",ex);
    }
    @finally {
        
    }
    
}

-(void)upload{
    if([txtAttachmentName.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length>0){
        [self appendXml:imageData];
        [_delegate dismissUpload:self];
    }
    else{
        UIAlertView *alertKO;
        alertKO=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Fields Missing",@"Fields Missing") message:NSLocalizedString(@"Please fill fileName field.",@"Please fill fileName field.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
        [alertKO show];
        
    }
    
}
-(void)uploadImage:(NSData*)image{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading",@"Uploading ...") maskType:SVProgressHUDMaskTypeBlack];
    @try{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
                       NSString* urlString;
                        if(mainDelegate.SupportsServlets)
                            urlString = [NSString stringWithFormat:@"http://%@",mainDelegate.serverUrl];
                        else
                            urlString = [NSString stringWithFormat:@"http://%@/UploadAttachment",mainDelegate.serverUrl];
            
            
                        // setting up the request object now
                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                        [request setURL:[NSURL URLWithString:urlString]];
                        [request setHTTPMethod:@"POST"];
            
            
                        NSString *boundary = @"---------------------------14737809831466499882746641449";
                        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
                        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
            
                        NSMutableData *body = [NSMutableData data];
                        if(mainDelegate.SupportsServlets){
                            // action parameter
                            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"action\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData:[@"UploadAttachment" dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            
                        }
                        // file
                        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\".xml\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[NSData dataWithData:image]];
                        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
                        // text parameter
                        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"correspondenceId\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[self.CorrespondenceId dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
                        // close form
                        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
                        // set request body
                        [request setHTTPBody:body];
                        [request setTimeoutInterval:mainDelegate.Request_timeOut];
                        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
          
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                NSString *validationResult=[CParser ValidateWithData:returnData];
                if (mainDelegate==nil) mainDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
                if(!mainDelegate.isOfflineMode){
                    if(![validationResult isEqualToString:@"OK"]){
                        
                        if([validationResult isEqualToString:@"Cannot access to the server"]){
                            [self ShowMessage:validationResult];
                        }
                        else{
                            [self ShowMessage:validationResult];
                        }
                    }else{
                        if(!self.quickActionSelected){
                            CAttachment* res=[CParser LoadNewAttachmentResults:returnData docId:[NSString stringWithFormat:@"%d",correspondenceIndex]];
                            if(res==nil){
                                [self ShowMessage:NSLocalizedString(@"Check XML", @"Saved Successfully")];
                            }
                            else{
                                
                                if (((CCorrespondence*)mainDelegate.searchModule.correspondenceList[res.docId.intValue]).attachmentsList.count==1)
                                    [_delegate refreshDocument:res.url attachmentId:res.AttachmentId];
                            }
                        }
                        [self ShowMessage:NSLocalizedString(@"Alert.Success", @"Saved Successfully")];
                    }
                }else{
                    [self ShowMessage:NSLocalizedString(@"Alert.Success", @"Saved Successfully")];
                }
                
            });
            
        });
    }
    @catch (NSException *ex) {
        [FileManager appendToLogView:@"ReaderViewController" function:@"uploadXml" ExceptionTitle:[ex name] exceptionReason:[ex reason]];
    }
    
    
	
}
-(void)ShowMessage:(NSString*)message{
    
    NSString *msg = message;
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Alert",@"Alert")
                          message: msg
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK",@"OK")
                          otherButtonTitles: nil];
    [alert show];
    
    
}
#pragma mark delegate methods


-(void)increaseLoading{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Alert.Loading", @"Loading...") maskType:SVProgressHUDMaskTypeBlack];
}
-(void)dismiss{
    [SVProgressHUD dismiss];
}
@end
