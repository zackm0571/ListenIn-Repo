//
//  ListenInTimelineViewController.h
//  ListenIn
//
//  Created by Zack Mathews on 12/15/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "ListenInLoginViewController.h"
#import "ListenInSignUpViewController.h"
#import "ListenInUser.h"

@interface ListenInTimelineViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate,UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet PFImageView *profilePic;
@property (strong, nonatomic) IBOutlet UILabel *userName;

@property (strong, nonatomic) IBOutlet UIButton *logoutButton;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) ListenInLoginViewController *logInViewController;
@property (strong, nonatomic) ListenInSignUpViewController *signUpViewController;

@property (strong, nonatomic) IBOutlet UILabel *currentlyPlayingLabel;

@property (strong, nonatomic) NSMutableArray *posts;


+(void)selectUser : (NSString*) username;

@end
