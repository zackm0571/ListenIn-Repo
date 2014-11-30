//
//  ListenInTimelineViewController.m
//  ListenIn
//
//  Created by Zack Mathews on 12/15/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//
#import "ListenInHelperFunctions.h"
#import "ListenInTimelineViewController.h"
#import "ListenInUser.h"
#import "ListenInUserPageViewController.h"
#import "ListenInPost.h"
#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import <MediaPlayer/MPMediaItem.h>
#import "ListenInPostCell.h"
#import "ListenInBroadcastViewController.h"
#import "CocoaLibSpotify.h"
#import "LI_IcecastManager.h"
#import "LI_RawMP3ParseManager.h"
#import "LI_Manager.h"
#import "LI_CommentsViewController.h"
@interface ListenInTimelineViewController ()

@end

int selectedPost = nil;
CGFloat rowSize = 274;
bool isBroadcasting = NO;
dispatch_queue_t initialLoadQueue;
dispatch_queue_t reloadQueue;
NSTimer *timer;
@implementation ListenInTimelineViewController

@synthesize profilePic;
@synthesize userName;
@synthesize logInViewController;
@synthesize signUpViewController;
@synthesize currentlyPlayingLabel;
@synthesize tableView;
@synthesize posts;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    
    return self;
}

-(void) setupandDisplayLoginControllers
{
    if (![PFUser currentUser]) {
        NSLog(@"No user logged in");
        NSLog(@"Initializing login and signup controllers...");
    logInViewController = [[ListenInLoginViewController alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    
    // Create the sign up view controller
    signUpViewController = [[ListenInSignUpViewController alloc] init];
    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    
        NSLog(@"Loaded");
        NSLog(@"Presenting login controller...");
    // Assign our sign up controller to be displayed from the login controller
    [logInViewController setSignUpController:signUpViewController];
    [self.logInViewController.logInView.dismissButton removeFromSuperview];
        [self presentViewController:logInViewController animated:YES completion:NULL];
        
        NSLog(@"Login controller presented");
    }

}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissModalViewControllerAnimated:YES]; // Dismiss the PFSignUpViewController
}


-(void) loadUser
{
    
    if([PFUser currentUser])
    {
        NSLog(@"Loading user...");
        //PFQuery *object = [PFQuery queryWithClassName:self.];
        // Do any additional setup after loading the view.
        
        PFUser *user = [PFUser currentUser];
        NSLog(@"Loaded current user object");
        
        PFFile *file = [user objectForKey:@"profilePicture"];
        UIImage *image = [UIImage imageNamed:@"logo.jpg"];
        [profilePic setImage:image];
        profilePic.file = file;
        [profilePic loadInBackground];
        NSLog(@"Loaded current user profile picture");
        
        [userName setText: @"Welcome, "];
        NSString *userNameString = [user objectForKey:@"username"];
        [userName setText: [userName.text stringByAppendingString: userNameString]];
        
        
            [[PFUser currentUser] setValue:@"" forKey:@"currentRoom"];
        
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"View did load");
    [self setupandDisplayLoginControllers];
    [self loadUser];
    
    
    if([PFUser currentUser])
    {
        [self loadTimeLine];
    }
    
    [LI_Manager _init];
    
    
}

- (void)viewDidLayoutSubviews
{
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self loadUser];
    [self loadTimeLine];

    [self.tableView reloadData];
    
            NSLog(@"Successfully logged in");
}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    [self setupandDisplayLoginControllers];
            NSLog(@"Logged out");
}
- (IBAction)startBroadcast:(id)sender {
    
    
    
    @try
    {
        
        
  /*  MPMediaItem *song = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
    NSString *title   = [song valueForProperty:MPMediaItemPropertyTitle];
    NSString *artist  = [song valueForProperty:MPMediaItemPropertyArtist];
   
    */
     //   [currentlyPlayingLabel setText:@"Currently Playing: "];
//    [[[currentlyPlayingLabel.text stringByAppendingString:artist] stringByAppendingString:@" - "] stringByAppendingString:title];
    }
    
   @catch(NSException *e)
    {
        
    }
    
            NSLog(@"Broadcast started");
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"Loading custom post cells...");
    static NSString *simpleTableIdentifier = @"PostCell";
    
    ListenInPostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
       cell = [[ListenInPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        
    }
    
    cell.leftContentView.layer.cornerRadius = 5.0;
    int index = (indexPath.row == 0) ? 0 : indexPath.row * 2;
    PFObject *object1 = [posts objectAtIndex:index];
    
    PFFile *thumbnail = [object1 objectForKey:@"image"];
    
    cell.leftImageView.image = [UIImage imageNamed:@"logo.jpg"];
    
    if(thumbnail != nil)
    {
        cell.leftImageView.file = thumbnail;
        [cell.leftImageView loadInBackground];
    }
    [cell.leftTextView setText:[object1 objectForKey:@"text"]];

   
    NSString *leftPostedBy = [object1 objectForKey:@"user"];
    cell.leftUserNameLabel.text = leftPostedBy;

    cell.leftBroadcastIndicator.image = [UIImage imageNamed:@"red circle.png"];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:[object1 valueForKey:@"user"]];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
      {
          NSString *leftIsPlaying = [object valueForKey:@"isBroadcastingString"];
          if([leftIsPlaying isEqualToString:@"true"] && leftIsPlaying != nil)
          {
              cell.leftBroadcastIndicator.image = [UIImage imageNamed:@"green circle.gif"];
          }
          
          else
          {
              cell.leftBroadcastIndicator.image = [UIImage imageNamed:@"red circle.png"];
          }
      }];
    
            NSLog(@"Loaded left post");
            index++;
    
    @try {
        
        if([posts objectAtIndex:index] != nil)
        {
           

            PFObject *object2 = [posts objectAtIndex:index];
            
            
            PFFile *thumbnail = [object2 objectForKey:@"image"];
            
            
            cell.rightContentView.layer.cornerRadius = 5.0;
            [cell.rightContentView setHidden:false];
            cell.rightImageView.image = [UIImage imageNamed:@"logo.jpg"];
            
            if(thumbnail != nil)
            {
                cell.rightImageView.file = thumbnail;
                [cell.rightImageView loadInBackground];
            }
            
            cell.rightTextView.text = [object2 objectForKey:@"text"];
           
            
            NSString *rightPostedBy = [object2 objectForKey:@"user"];
                       cell.rightUserNameLabel.text = rightPostedBy;
            
            
                    NSLog(@"Loaded right post");
           cell.rightBroadcastIndicator.image = [UIImage imageNamed:@"red circle.png"];
            
            PFQuery *query = [PFUser query];
            [query whereKey:@"username" equalTo:[object2 valueForKey:@"user"]];
            
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
             {
                    NSString *rightUserIsPlaying = [object valueForKey:@"isBroadcastingString"];
                 
                                    if([rightUserIsPlaying isEqualToString:@"true"] && rightUserIsPlaying != nil)
                                       {
                                           cell.rightBroadcastIndicator.image = [UIImage imageNamed:@"green circle.gif"];
                                       }
                 
                 else
                 {
                     cell.rightBroadcastIndicator.image = [UIImage imageNamed:@"red circle.png"];
                 }
                                   }];
            

         
            
        }
        
        
       


    }
    @catch (NSException *exception) {
        
        cell.rightImageView.image = nil;

        cell.rightTextView.text = @"";
        cell.rightUserNameLabel.text = @"";
        cell.rightBroadcastIndicator.image = nil;
        [cell.rightContentView setHidden:true];
                NSLog(@"No right post found");
    }
    
       return cell;
}

-(void) loadTimeLine
{

    NSLog(@"Loading timeline...");
     initialLoadQueue = dispatch_queue_create("loadInitialData", NULL);

    dispatch_async(initialLoadQueue, ^(void)
                   {

                        posts =  [[self loadInitialTimeLine] mutableCopy];
                       dispatch_async(dispatch_get_main_queue(), ^(void)
                                      {
                                          //tableView.rowHeight = rowSize;
                                          [tableView reloadData];
                                          NSLog(@"Timeline reloaded");
                                          
                                      });
                       
                   });
   
   
    
}
-(NSArray*) loadInitialTimeLine
{
    PFQuery *friendsQuery = [PFQuery queryWithClassName:@"SocialEvent"];
    [friendsQuery whereKey:@"fromUser" equalTo:[PFUser currentUser][@"username"]];
    [friendsQuery whereKey:@"interactionType" containsString:@"followActivity"];

    PFQuery *friendsPosts = [PFQuery queryWithClassName:@"Post"];
    [friendsPosts whereKey:@"user" matchesKey:@"toUser" inQuery:friendsQuery];
    [friendsPosts whereKeyExists:@"image"];
    
    PFQuery *userPosts = [PFQuery queryWithClassName:@"Post"];
    [userPosts whereKey:@"user" equalTo:[[PFUser currentUser] objectForKey:@"username"]];
    [userPosts whereKeyExists:@"image"];
    
    PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:friendsPosts, userPosts, nil]];
    //[finalQuery includeKey:@"image"];
    [finalQuery orderByDescending:@"createdAt"];

    finalQuery.limit = 4;
    return [finalQuery findObjects];
}


-(NSArray*) loadExtendedTimeline
{
    PFQuery *friendsQuery = [PFQuery queryWithClassName:@"SocialEvent"];
    [friendsQuery whereKey:@"fromUser" equalTo:[[PFUser currentUser] objectForKey: @"username"]];
    [friendsQuery whereKey:@"interactionType" containsString:@"followActivity"];
    
    PFQuery *friendsPosts = [PFQuery queryWithClassName:@"Post"];
    [friendsPosts whereKey:@"user" matchesKey:@"toUser" inQuery:friendsQuery];
    [friendsPosts whereKeyExists:@"image"];
    
    PFQuery *userPosts = [PFQuery queryWithClassName:@"Post"];
    [userPosts whereKey:@"user" equalTo:[[PFUser currentUser] objectForKey:@"username"]];
    [userPosts whereKeyExists:@"image"];
    
    PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:friendsPosts, userPosts, nil]];
    //[finalQuery includeKey:@"image"];
    [finalQuery orderByDescending:@"createdAt"];
    
    finalQuery.skip = posts.count;
    finalQuery.limit = 2;
    
    return [finalQuery findObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;

}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

        if(posts == nil)
        {
            posts = [[NSMutableArray alloc] init];
            return 0;
        }
    
        if(posts.count % 2 != 0)
        {
            return posts.count / 2 + 1;
        }
    return posts.count / 2;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)createPost:(id)sender {
    
}



-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height; //- inset.bottom;
    float h = size.height - 1;

    float complete_reload_distance = -70;
    if(offset.y <= complete_reload_distance)
    {
        NSLog(@"Pulled up to refresh");
        [self loadTimeLine];

    }
    
    float reload_distance = 50;
    int numOfRows = [tableView numberOfRowsInSection:0] - 1;
    
    if(offset.y + reload_distance >  numOfRows * rowSize) {
        
        NSLog(@"Pulled up to refresh");
        reloadQueue = dispatch_queue_create("reloadTimeLineData", NULL);
        
        dispatch_async(reloadQueue, ^(void)
                       {
                           
                           NSLog(@"Loading new posts...");

                           [posts addObjectsFromArray:[self loadExtendedTimeline]];
                           
                           dispatch_async(dispatch_get_main_queue(), ^(void){
                               [tableView reloadData];
                               
                                       NSLog(@"Loaded new posts");
                               
                           });
                           
                           
                       });
        
    }

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if([segue.identifier isEqualToString:@"UserProfileSegue"])
    {
        ListenInUserPageViewController *destViewController = segue.destinationViewController;
        
        ListenInUser *user = [[ListenInUser alloc] init];
        
        
        

        user.userObject = [PFUser currentUser];
        user.userName = [user.userObject objectForKey:@"username"];
        user.profilePicture = [user.userObject objectForKey:@"profilePicture"];
        
        destViewController.user = user;
        
                NSLog(@"Loading current user profile...");
    }
    
    if ([segue.identifier isEqualToString:@"showLeftUser"]) {
        ListenInUserPageViewController *destViewController = segue.destinationViewController;
       
        ListenInPostCell *cell = (ListenInPostCell*) [[[[sender superview] superview] superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        selectedPost = indexPath.row * 2;
        

        
        ListenInUser *user = [[ListenInUser alloc] init];
        PFObject *object = (PFObject*)[posts objectAtIndex:selectedPost];
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"username" equalTo:[object objectForKey:@"user"]];
        PFUser *userObject = [userQuery getFirstObject];
        user.userObject = [userQuery getFirstObject];
        user.userName = [object objectForKey:@"user"];
        
        user.profilePicture = [userObject objectForKey:@"profilePicture"];
        
        destViewController.user = user;
        
        NSString *message = @"Loading profile of: ";
                NSLog([message stringByAppendingString:user.userName]);
    }
    
    if ([segue.identifier isEqualToString:@"showRightUser"]) {
   
        ListenInUserPageViewController *destViewController = segue.destinationViewController;

        ListenInPostCell *cell = (ListenInPostCell*) [[[[sender superview] superview] superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        selectedPost = indexPath.row * 2 + 1;

        ListenInUser *user = [[ListenInUser alloc] init];
        PFObject *object = (PFObject*)[posts objectAtIndex:selectedPost];
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"username" equalTo:[object objectForKey:@"user"]];
        PFUser *userObject = [userQuery getFirstObject];
        
        user.userObject = [userQuery getFirstObject];
        user.userName = [object objectForKey:@"user"];
        user.profilePicture = [userObject objectForKey:@"profilePicture"];
        
        destViewController.user = user;
        
        NSString *message = @"Loading profile of: ";
        NSLog([message stringByAppendingString:user.userName]);
    }
    
    
    if([segue.identifier isEqualToString:@"StartBroadcastSegue"])
    {
        ListenInBroadcastViewController *broadcastView = segue.destinationViewController;
        PFUser *currentUser = [PFUser currentUser];
        broadcastView.userBroadcasting = [currentUser objectForKey:@"username"];
        //[currentUser setObject:broadcastView.userBroadcasting forKey:@"currentRoom"];
        
         NSLog(@"Creating a broadcast...");
    }
    
    
    if([segue.identifier isEqualToString:@"rightPostSelectedSegue"])
    {
        LI_CommentsViewController *destViewController = segue.destinationViewController;
        
        ListenInPostCell *cell = (ListenInPostCell*) [[[[sender superview] superview] superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        selectedPost = indexPath.row * 2 + 1;
        
        PFObject *object = (PFObject*)[posts objectAtIndex:selectedPost];
        
        destViewController.postID = [object objectId];

    }
    
    
    if([segue.identifier isEqualToString:@"leftPostSelectedSegue"])
    {
        LI_CommentsViewController *destViewController = segue.destinationViewController;
        
        ListenInPostCell *cell = (ListenInPostCell*) [[[[sender superview] superview] superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        selectedPost = indexPath.row * 2;
        
        PFObject *object = (PFObject*)[posts objectAtIndex:selectedPost];
        
        destViewController.postID = [object objectId];
        
        NSLog(destViewController.postID);

    }

}

- (IBAction)rightUsernameInPostSelected:(id)sender {
  
    NSLog(@"%d", selectedPost);
}

- (IBAction)leftUsernameInPostSelected:(id)sender {
    NSLog(@"%d", selectedPost);
}



-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
}
+ (void) selectUser:(NSString *)username
{
    
}


- (void)dealloc {
    [self.tableView release];
    [super dealloc];
}
@end
