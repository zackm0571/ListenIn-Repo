//
//  ListenInBroadcastViewController.m
//  ListenIn
//
//  Created by Zack Mathews on 12/28/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//

#import "ListenInBroadcastViewController.h"
#import <Parse/Parse.h>
#include <stdint.h>
#include <stdlib.h>
#include "ListenInPost.h"
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import "LI_RawMP3ParseManager.h"
#import "LI_Manager.h"
#import <MediaPlayer/MPMediaPickerController.h>
@interface ListenInBroadcastViewController ()

@end




@implementation ListenInBroadcastViewController

@synthesize chatPosts;

@synthesize userBroadcasting;
@synthesize chatTextField;
@synthesize chatSendButton;

@synthesize contentView;

@synthesize tableView;

@synthesize roomNameLabel;
@synthesize currentlyPlayingLabel;

static LI_SpotifyMusicManager *spotifyManager;

bool userOwnsRoom = false;
@synthesize playlist;
@synthesize playPauseButton;

int chatIndex = 0;

bool loadChat = YES;
bool keyboardShowing = NO;
double loadFrequencyInMills = .500;

NSTimer *loadChatTimer;
NSTimer *loadTrackTitleTimer;
PFObject *broadcastSession;

NSArray *queuedFiles;
static NSString *s_userBroadcasting;

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
 
    PFQuery *query = [PFQuery queryWithClassName:@"BroadcastSession"];
    [query whereKey:@"userBroadcasting" equalTo:userBroadcasting];
    PFObject *broadcastObject = [query getFirstObject];
    
    NSString *roomNameText = [userBroadcasting stringByAppendingString:@"'s room"];
    [roomNameLabel setText:roomNameText];
    
    NSString *currentRoomName = [[PFUser currentUser] valueForKey:@"currentRoom"];
    s_userBroadcasting = userBroadcasting;
    
        NSLog(@"Success");
    
    //Stream logic manager
    [LI_Manager getRawMP3Manager].userBroadcasting = userBroadcasting;
    
    if([PFUser currentUser].username == userBroadcasting)
    {
        
        userOwnsRoom = true;
        [[PFUser currentUser] setValue:@YES forKey:@"isBroadcasting"];
        
        [[PFUser currentUser] setValue:@"true" forKey:@"isBroadcastingString"];
        [[PFUser currentUser] saveInBackground];
        
        if(broadcastObject == nil)
        {
            //Creates broadcast on backend that allows users to join
            broadcastObject = [[PFObject alloc] initWithClassName:@"BroadcastSession"];
            [broadcastObject setValue:userBroadcasting forKey:@"userBroadcasting"];
            [broadcastObject setValue:@0 forKey:@"currentPlaylistIndex"];
                       [broadcastObject saveInBackground];
        }
        
            [LI_Manager getRawMP3Manager].broadcastSession = broadcastSession;
            //Let's admin pick song to broadcast
            [self showMediaPicker];
            
        
        [playPauseButton setTitle:@"Stop Broadcast" forState:UIControlStateNormal];
        
    }
    
    else
    {
        userOwnsRoom = false;
    }
    

    
        if(!userOwnsRoom)
        {
            //If song is not being played locally, begin streaming from cloud
            [[LI_Manager getRawMP3Manager]  streamTrack:userBroadcasting];
        }
    

   
    if(currentRoomName != userBroadcasting)
    {
        //Update room name to the user broadcasting. Validation of room name's could allow primary admin to add on other admins to the broadcast
        [[PFUser currentUser] setValue:userBroadcasting forKey:@"currentRoom"];
        currentRoomName = userBroadcasting;
        [broadcastObject saveInBackground];
       
        
    }

    
    
    
    
    loadChatTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(loadChatFeed) userInfo:nil repeats:YES];
    
    [loadChatTimer fire];
    
    /*Load track title
     
     loadTrackTitleTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(loadCurrentlyBroadcasting) userInfo:nil repeats:YES];
    [loadTrackTitleTimer fire];*/

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
	// Do any additional setup after loading the view.
}


//Load chat
-(void)loadChatFeed
{
    
    PFQuery *query = [PFQuery queryWithClassName:@"SocialEvent"];
    [query whereKey:@"userBroadcasting" equalTo:userBroadcasting];
    [query whereKey:@"interactionType" equalTo:@"broadcastChatMessage"];
    [query orderByAscending:@"createdAt"];
   
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            
                            
                            
                                               chatPosts = [objects mutableCopy];
                                               [tableView reloadData];
                                                 CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
                                               [self.tableView setContentOffset:bottomOffset animated:YES];
                                               
                        }];
                       

                                      


   
}

//Load chat from data queried

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"ChatRoomCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    PFObject *object = [chatPosts objectAtIndex:indexPath.row];
    
    NSString *message = object[@"fromUser"];
    message = [message stringByAppendingString:@": "];
    message = [message stringByAppendingString:object[@"message"]];
    [cell.textLabel setText:message];

    return cell;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(chatPosts == nil)
    {
        chatPosts = [[NSMutableArray alloc] init];
        return 0;
    }
       return chatPosts.count;
}

- (IBAction)sendChatMessage:(id)sender {
    

    PFUser *currentUser = [PFUser currentUser];
    PFObject *object = [[PFObject alloc] initWithClassName:@"SocialEvent"];
    [object setValue:userBroadcasting forKey:@"userBroadcasting"];
    [object setValue:@"broadcastChatMessage" forKey:@"interactionType"];
    
    
    [object setValue:currentUser.username forKey:@"fromUser"];
    [object setValue:chatTextField.text forKey:@"message"];
    
     [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
      {
            if(succeeded == true)
            {
                [self.tableView reloadData];
            }
      }];
   
    

    [chatTextField setText:@""];
}


- (void)keyboardWillShow:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    CGRect keyboardFrameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrameEnd = [self.view convertRect:keyboardFrameEnd fromView:nil];
    
    
        self.contentView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height - keyboardFrameEnd.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);

    
    keyboardShowing = YES;
    

}

- (void)keyboardWillHide:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
   
    CGRect keyboardFrameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrameEnd = [self.view convertRect:keyboardFrameEnd fromView:nil];
    
        self.contentView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    keyboardShowing = NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissKeyboard:(id)sender {
    if(keyboardShowing)
    {
        [self.view endEditing:YES];
    }
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
 
    
    
}

- (IBAction)pausePlayButton:(id)sender {
    

    bool isPlaying = [LI_Manager getRawMP3Manager].isPlaying;//[spotifyManager getPlaybackManager].isPlaying;
    if(!userOwnsRoom)
    {
    if(isPlaying)
        {
            
            [playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
           // [spotifyManager pause];
            
            [[LI_Manager getRawMP3Manager] pause];
            isPlaying = false;
            

        }
    else
    {
            [playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
//        [spotifyManager resume];
        [[LI_Manager getRawMP3Manager] resume];
        isPlaying = true;

    }
        
    }
    
    else
    {
        
        if(isPlaying)
        {
            
            
            UIAlertView *confirmEnd = [[UIAlertView alloc] initWithTitle:@"End Broadcast?" message:@"Are you sure you would like to continue?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"End Broadcast", nil];
            [confirmEnd show];
            
        }
        else
        {
            [playPauseButton setTitle:@"Stop Broadcast" forState:UIControlStateNormal];
            //[spotifyManager resume];
            [[LI_Manager getRawMP3Manager] resume];
            isPlaying = true;
            
        }

        
    }
}

/*-(void) loadCurrentlyBroadcasting
{
   
    
    @try{
        dispatch_async(dispatch_queue_create("getCurrentTrackTitleInBroadcast", NULL),^(void)
                       {
                           NSString *s = @"Currently Playing: ";
                           s = [s stringByAppendingString:[[LI_Manager getRawMP3Manager] getCurrentTrackTitle]];
                           
                           dispatch_async(dispatch_get_main_queue(),^(void)
                                          {
                                              currentlyPlayingLabel.text = s;
                                          });
                           NSLog(s);
                       });
       
        
    }
    
    @catch(NSError* error)
    {
        NSLog([error description]);
    }
    
}*/
/*-(PFObject*) getBroadcastSessionObject
{
    if(broadcastSession == nil)
    {
        PFQuery *query = [[PFQuery alloc] initWithClassName:@"BroadcastSession"];
        [query whereKey:@"userBroadcasting" equalTo:userBroadcasting];
        broadcastSession = [query getFirstObject];
    }
    
    return broadcastSession;
}*/

+(NSArray*) getPlaylistFromParse
{
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"BroadcastSession"];
    [query whereKey:@"userBroadcasting" equalTo:s_userBroadcasting];
    PFObject *object = [query getFirstObject];
    
    return object[@"tracks"];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    

    if([title isEqualToString: @"End Broadcast"])
    {
        
        UIAlertView *publishPlaylist = [[UIAlertView alloc] initWithTitle:@""message:@"Would you like to publish this playlist?"  delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        [publishPlaylist show];
        [[LI_Manager getRawMP3Manager] pause];

        [playPauseButton setTitle:@"Resume Broadcast" forState:UIControlStateNormal];
        //[spotifyManager pause];
        [[LI_Manager getRawMP3Manager] pause];

        PFQuery *query = [PFQuery queryWithClassName:@"BroadcastSession"];
        [query whereKey:@"userBroadcasting" equalTo:userBroadcasting];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
         {
                 [object delete];
             
         }];
        [[PFUser currentUser] setValue:@"false" forKey:@"isBroadcastingString"];
        [[PFUser currentUser] save];
    }
    
    
    if([title isEqualToString:@"Yes"])
    {
        ListenInPost *post = [[ListenInPost alloc] init];
        
        NSString *username = [PFUser currentUser].username;
        PFFile *file = [PFFile fileWithName:@"listeninbackground.jpg" data:[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"listeninbackground" ofType:@"png"]]];
        NSArray *pl = [ListenInBroadcastViewController getPlaylistFromParse];
        NSString *playlistText = @"";
        [post createPost:username:playlistText  :file  :pl];
    }
    
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {

    }
    [super viewWillDisappear:animated];
}


-(void) showMediaPicker
{
    
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"]) {
        //device is simulator
        UIAlertView *alert1;
        alert1 = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"There is no Audio file in the Device" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
        alert1.tag=2;
        [alert1 show];
        //[alert1 release],alert1=nil;
    }else{
        
        MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = YES;
        [self presentViewController:mediaPicker animated:YES completion:nil];
        
    }
}


-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    
    [self dismissViewControllerAnimated:YES completion:nil];

    // We need to dismiss the picker
    
    // Assign the selected item(s) to the music player and start playback.
    if ([mediaItemCollection count] < 1) {
        return;
    }
    

     queuedFiles = [mediaItemCollection items];
    
    [[LI_Manager getRawMP3Manager] uploadQueue:queuedFiles];
    
    [[[LI_Manager getRawMP3Manager] getiPodController] setQueueWithItemCollection:mediaItemCollection];
    [[[LI_Manager getRawMP3Manager] getiPodController] play];
    
    

    
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    
    // User did not select anything
    // We need to dismiss the picker
    
    [self dismissViewControllerAnimated:YES completion:nil ];
}

- (void)dealloc {
    [tableView release];
    [chatTextField release];
    [chatSendButton release];
    [contentView release];
    [tableView release];
    [roomNameLabel release];
    [currentlyPlayingLabel release];
    [playPauseButton release];
    [contentView release];
    [contentView release];
    [super dealloc];
}
@end
