//
//  LI_CommentsViewController.m
//  ListenIn
//
//  Created by Zack Mathews on 2/10/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import "LI_CommentsViewController.h"
#import <Parse/Parse.h>
@interface LI_CommentsViewController ()

@end

@implementation LI_CommentsViewController

@synthesize tableView;
@synthesize mainImageView;
@synthesize postID;
@synthesize comments;
@synthesize commentTextField;


bool keyboardIsShowing = false;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"CommentCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    //Gets comment object from collection at the index of the UI data cell being loaded
    PFObject *object = [comments objectAtIndex:indexPath.row];
    
    NSString *message = object[@"fromUser"];
    message = [message stringByAppendingString:@": "];
    message = [message stringByAppendingString:object[@"message"]];
    
    UITextView *textView = (UITextView*)[cell viewWithTag:305];
    [textView setText:message];
    
    return cell;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(comments == nil)
    {
        comments = [[NSArray alloc] init];
    }
    return comments.count;
}

- (IBAction)createPost:(id)sender {
    
    NSLog(@"Posting comment...");
    PFObject *comment = [[PFObject alloc] initWithClassName:@"SocialEvent"];
    [comment setValue:[PFUser currentUser].username forKey:@"fromUser"];
    [comment setValue:@"postComment" forKey:@"interactionType"];
    [comment setValue:commentTextField.text forKey:@"message"];
    [comment setValue:postID forKey:@"postID"];
    
    [comment save];
    NSLog(@"Comment posted");
    [self loadComments];
    
    
}

-(void)loadComments
{
    
    NSLog(@"Loading comments...");
    
    //Creates query to load interaction where the action is a comment and the comment belongs to the post arg
    
    PFQuery *query = [PFQuery queryWithClassName:@"SocialEvent"];
    
    [query whereKey:@"interactionType" equalTo:@"postComment"];
    [query whereKey:@"postID" equalTo:postID];
    
    [query orderByDescending:@"createdAt"];
    
   
    
    
   // dispatch_queue_t queue = dispatch_queue_create("loadComments", NULL);
    
   // dispatch_async(queue, ^(void) ----Previously was using grand central dispatch for async network operations -----
                   {
                       
                           [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                               
                               
                               dispatch_async(dispatch_get_main_queue(), ^(void)
                                              {
                                                  comments = [objects mutableCopy];
                                                  [tableView reloadData];
                                                  
                                                  NSLog(@"Comments loaded");
                                                  
                                              });
                               
                               
                           }];
                           
                       
                       
              //     });
    
    
    
    
    
}
//Loads picture attached to post
-(void) loadPicture
{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"objectId" equalTo:postID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
         mainImageView.file = [object objectForKey:@"image"];
         [mainImageView loadInBackground];
     }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self loadPicture];
    [self loadComments];
    
    //Keyboard observers to adjust view size to fit with keyboard on and off screen
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(c_keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(c_keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [mainImageView release];
    [tableView release];
    [_postButton release];
    [commentTextField release];
    [_contentView release];
    
    [super dealloc];
}


- (void)c_keyboardWillShow:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    CGRect keyboardFrameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrameEnd = [self.view convertRect:keyboardFrameEnd fromView:nil];
    
    
    self.contentView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height - keyboardFrameEnd.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    
    
    keyboardIsShowing = YES;
}
- (IBAction)hideKeyboard:(id)sender {
    
    if(keyboardIsShowing)
    {
        [self.view endEditing:YES];
    }
}

- (void)c_keyboardWillHide:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    
    CGRect keyboardFrameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrameEnd = [self.view convertRect:keyboardFrameEnd fromView:nil];
    
    self.contentView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    keyboardIsShowing = NO;
}
@end
