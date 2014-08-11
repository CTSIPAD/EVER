//
//  AnnotationsTableViewController.m
//  CTSTest
//
//  Created by DNA on 1/21/14.
//  Copyright (c) 2014 LBI. All rights reserved.
//

#import "AnnotationsController.h"
#import "AppDelegate.h"
#import "CAction.h"
#import "CParser.h"
@interface AnnotationsController ()

@end

@implementation AnnotationsController{
    AppDelegate *mainDelegate;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.clearsSelectionOnViewWillAppear = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mainDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];

    CGFloat red = 29.0f / 255.0f;
    CGFloat green = 29.0f / 255.0f;
    CGFloat blue = 29.0f / 255.0f;
    self.tableView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    [self.tableView setSeparatorColor:[UIColor whiteColor]];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
   [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"annotationCell"];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(CGFloat)  tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([mainDelegate.SignMode isEqualToString:@"BuiltInSign"])
    return self.properties.count+1;//1 for erase
    else
        return self.properties.count+2;// 2 for erase and save buttons

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"annotationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 37, 37)];

   UILabel *labelTitle= [[UILabel alloc] initWithFrame:CGRectMake(70, 5,cell.frame.size.width-140, 40)];
   labelTitle.textColor = [UIColor whiteColor];
   labelTitle.backgroundColor = [UIColor clearColor];

    if(indexPath.row==self.properties.count){
        labelTitle.text=NSLocalizedString(@"Erase",@"Erase");
        imageView.image=[UIImage imageNamed:@"erase.png"];
    }
    else if(indexPath.row==self.properties.count+1){
        if(!mainDelegate.isAnnotated){
            cell.userInteractionEnabled=NO;
            cell.backgroundColor=[UIColor grayColor];
        }
         labelTitle.text=NSLocalizedString(@"Save",@"Save");
        imageView.image=[UIImage imageNamed:@"save.png"];
    }
    else{
        CAction* action=self.properties[indexPath.row];
        NSString *string1;
        if(![action.label isEqualToString:@""]&& action.label!=nil)
            string1 = NSLocalizedString(action.label,@"");
        else
            string1=NSLocalizedString(action.action, action.action);
        labelTitle.text=string1;
        if(action.Custom){
            UIImage * image =  [UIImage imageWithData:[CParser LoadCachedIcons:action.action]];
            [imageView setImage:image];
        }
        else{

        if([action.action isEqualToString:@"Highlight"]){
            imageView.image=[UIImage imageNamed:@"highlight.png"];
        }else if([action.action isEqualToString:@"Note"]){
            imageView.image=[UIImage imageNamed:@"note.png"];
        }
        }
    }
    if([mainDelegate.IpadLanguage.lowercaseString isEqualToString:@"ar"]){
        labelTitle.textAlignment=NSTextAlignmentRight;
        imageView.frame=CGRectMake(cell.frame.size.width-45, 5, 37, 37);
    }
   
        [cell addSubview:imageView];
        [cell addSubview:labelTitle];
    
    return cell;
}
typedef enum{
    Highlight,Sign,Note,Erase,Save
    
} AnnotationsType;
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {    
    int annotation = 0;
    CAction* action;
    if(indexPath.row<self.properties.count){
         action=self.properties[indexPath.row];
        if(action.Custom){
            if(action.popup==NO){
                [_delegate executeAction:action.action note:@"" movehome:action.backhome];
                if(action.backhome)
                    [_delegate movehome:self];
                else
                    [_delegate dismissPopUp:self];
                
            }
            else{
                [_delegate PopUpCommentDialog:self Action:action document:nil];
                
            }
        }
        else{
            if([action.action isEqualToString:@"Highlight"]){
                annotation=Highlight;
            }else if([action.action isEqualToString:@"Sign"]){
                annotation=Sign;
            }else if([action.action isEqualToString:@"Note"]){
                annotation=Note;
            }
            
            
            [self.delegate performaAnnotation:annotation];
        }
    }
    else{
    
    if(indexPath.row==self.properties.count){
        annotation= Erase;
    }else if(indexPath.row==self.properties.count+1){
        annotation=Save;
    }
    
    [self.delegate performaAnnotation:annotation];
    }
}


@end
