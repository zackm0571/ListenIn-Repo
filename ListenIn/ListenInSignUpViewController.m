//
//  ListenInSignUpViewController.m
//  ListenIn
//
//  Created by Zack Mathews on 12/15/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//

#import "ListenInSignUpViewController.h"

@interface ListenInSignUpViewController ()

@end

@implementation ListenInSignUpViewController

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
    
    
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.jpg"]]];
  
}
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    
    [self dismissViewControllerAnimated:YES completion:NULL]; // Dismiss the PFSignUpViewController
}


- (void)viewDidLayoutSubviews
{
        [self.signUpView.logo setFrame:CGRectMake(80.5f, 50.0f, 150.0f, 150.5f)];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
