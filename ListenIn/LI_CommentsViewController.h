//
//  LI_CommentsViewController.h
//  ListenIn
//
//  Created by Zack Mathews on 2/10/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface LI_CommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet PFImageView *mainImageView;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) IBOutlet UIButton *postButton;
@property (retain, nonatomic) IBOutlet UITextField *commentTextField;
@property (retain, nonatomic) IBOutlet UIView *contentView;

@property NSArray *comments;
@property NSString *postID;

@end
