//
//  ListenInUserPageViewController.h
//  ListenIn
//
//  Created by Zack Mathews on 12/28/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListenInUser.h"
@interface ListenInUserPageViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property ListenInUser *user;
@property NSMutableArray *posts;

@property (retain, nonatomic) IBOutlet PFImageView *userProfilePictureView;

@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;

@property (retain, nonatomic) IBOutlet UIImageView *broadcastIndicator;



@end
