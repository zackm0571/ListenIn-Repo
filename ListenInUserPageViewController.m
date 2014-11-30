//
//  ListenInUserPageViewController.m
//  ListenIn
//
//  Created by Zack Mathews on 12/28/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//

#import "ListenInUserPageViewController.h"
#import "ListenInPostCell.h"
#import "ListenInBroadcastViewController.h"
@interface ListenInUserPageViewController ()

@end

@implementation ListenInUserPageViewController

@synthesize posts;
@synthesize user;
@synthesize userNameLabel;
@synthesize userProfilePictureView;
@synthesize broadcastIndicator;
int userPagePostIndex = 0;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (IBAction)followUserButton:(id)sender {

     PFObject *followObject = [PFObject objectWithClassName:@"SocialEvent"];
     PFUser *currentUser = [PFUser currentUser];
     
     [followObject setValue:user.userName forKey:@"toUser"];
     [followObject setValue:currentUser[@"username"] forKey:@"fromUser"];
     [followObject setValue:@"followActivity" forKey:@"interactionType"];
     [followObject saveInBackground];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"PostCell";
    
    ListenInPostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        [[ListenInPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    int index = (indexPath.row == 0) ? 0 : indexPath.row * 2;
    PFObject *object1 = [posts objectAtIndex:index];
    
    PFFile *thumbnail = [object1 objectForKey:@"image"];
    
    cell.leftImageView.image = [UIImage imageNamed:@"logo.jpg"];
    cell.leftImageView.file = thumbnail;
    [cell.leftImageView loadInBackground];
    
    cell.leftTextView.text = [object1 objectForKey:@"text"];
    
    cell.leftUserNameLabel.text = [object1 objectForKey:@"user"];
    index++;
    @try {
        if([posts objectAtIndex:index] != nil )
        {
            PFObject *object2 = [posts objectAtIndex:index];
            
            PFFile *thumbnail = [object2 objectForKey:@"image"];
            
            [cell.rightContentView setHidden:false];
            
            cell.rightImageView.image = [UIImage imageNamed:@"logo.jpg"];
            cell.rightImageView.file = thumbnail;
            [cell.rightImageView loadInBackground];
            
            
            cell.rightTextView.text = [object2 objectForKey:@"text"];
            cell.rightUserNameLabel.text = [object2 objectForKey:@"user"];
        }
        
    }
    @catch (NSException *exception) {
        
        cell.rightImageView.image = nil;
        
        cell.rightTextView.text = @"";
        cell.rightUserNameLabel.text = @"";
        cell.rightBroadcastIndicator.image = nil;
        [cell.rightContentView setHidden:true];
    }
    
    return cell;
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

-(void) loadTimeLine
{
    dispatch_queue_t initialLoadQueue = dispatch_queue_create("loadInitialUserData", NULL);
    
    dispatch_async(initialLoadQueue, ^(void)
                   {
                       posts =  [[self loadInitialTimeLine] mutableCopy];
                       dispatch_async(dispatch_get_main_queue(), ^(void)
                                      {
                                          [self.tableView reloadData];
                                      });
                       
                   });

    
}
-(NSArray*) loadInitialTimeLine
{
    
    PFQuery *userPosts = [PFQuery queryWithClassName:@"Post"];
    [userPosts whereKey:@"user" equalTo:user.userName];
    [userPosts whereKeyExists:@"image"];
   
    [userPosts orderByDescending:@"createdAt"];
    userPosts.limit = 2;
    return [userPosts findObjects];
}


-(NSArray*) loadExtendedTimeline
{
    PFQuery *userPosts = [PFQuery queryWithClassName:@"Post"];
    [userPosts whereKey:@"user" equalTo:user.userName];
    [userPosts whereKeyExists:@"image"];
    
    [userPosts orderByDescending:@"createdAt"];
    
    userPagePostIndex = posts.count;
    userPosts.skip = userPagePostIndex;
    userPosts.limit = 2;
    
    return [userPosts findObjects];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height - 1;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    
    float reload_distance = 5;
    
    
    if(y + reload_distance > h) {
        
        
        dispatch_queue_t queue = dispatch_queue_create("reloadUserTimeLineData", NULL);
        
        dispatch_async(queue, ^(void)
                       {
                           
                           [NSThread sleepForTimeInterval:3];
                           [posts addObjectsFromArray:[self loadExtendedTimeline]];
                           
                           dispatch_async(dispatch_get_main_queue(), ^(void){
                               [self.tableView reloadData];
                               
                           });
                           
                           
                       });
        
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [userNameLabel setText: user.userName];
    userProfilePictureView.file = user.profilePicture;
    [userProfilePictureView loadInBackground];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:user.userName];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
                            {
                                NSString *isPlaying = [object valueForKey:@"isBroadcastingString"];
                                if([isPlaying isEqualToString:@"true"])
                                {
                                    [broadcastIndicator setImage:[UIImage imageNamed:@"green circle.gif"]];
                                }
                                
                                else
                                {
                                    [broadcastIndicator setImage:[UIImage imageNamed:@"red circle.png"]];
                                }

                            }];
        [self loadTimeLine];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"broadcastFromProfileSegue"])
        {
            ListenInBroadcastViewController *destinationController = (ListenInBroadcastViewController*)segue.destinationViewController;
            
            destinationController.userBroadcasting = user.userName;
          
        }
}

- (void)dealloc {
    [_tableView release];
    [userNameLabel release];
    [userProfilePictureView release];
    [broadcastIndicator release];
    [super dealloc];
}
@end
