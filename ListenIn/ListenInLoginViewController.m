//
//  ListenInLoginViewController.m
//  ListenIn
//
//  Created by Zack Mathews on 12/15/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//

#import "ListenInLoginViewController.h"

@interface ListenInLoginViewController ()

@end

@implementation ListenInLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewDidAppear:(BOOL)animated
{
    
}


-(void)viewDidLayoutSubviews
{
    [self.logInView.logo setFrame:CGRectMake(80.5f, 50.0f, 150.0f, 150.5f)];
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];

  
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.jpg"]]];
    
    UIGraphicsBeginImageContext(self.logInView.frame.size);
    [[UIImage imageNamed:@"listeninbackground.png"] drawInRect:self.logInView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:image]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    
    [self.logInView.usernameField setBackgroundColor:[UIColor whiteColor]];
    [self.logInView.passwordField setBackgroundColor:[UIColor whiteColor]];
    //[self.logInView.signUpButton setBackgroundColor:[UIColor ]@"79bae6"];
   // [self.logInView setBackgroundColor:[UIColor colorWithPatternImage: [UIImage imageNamed:@"listeninbackground.png"]]];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
