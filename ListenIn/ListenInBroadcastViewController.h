//
//  ListenInBroadcastViewController.h
//  ListenIn
//
//  Created by Zack Mathews on 12/28/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "CocoaLibSpotify.h"
#import "LI_SpotifyMusicManager.h"
#import <AVFoundation/AVPlayer.h>
#import <MediaPlayer/MPMediaPickerController.h>
@interface ListenInBroadcastViewController : UIViewController <SPSessionDelegate, SPSessionPlaybackDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, MPMediaPickerControllerDelegate>

//@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UITextField *chatTextField;
@property (retain, nonatomic) IBOutlet UIButton *chatSendButton;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) SPTrack *currentTrack;
@property (nonatomic, strong) SPPlaybackManager *playbackManager;


@property NSMutableArray *chatPosts;
@property NSString *userBroadcasting;

@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;

@property (retain, nonatomic) IBOutlet UILabel *currentlyPlayingLabel;

@property (retain, nonatomic) IBOutlet UIView *contentView;

@property (retain, nonatomic) IBOutlet UIButton *playPauseButton;
@property (retain, nonatomic)NSArray *playlist;



+(NSArray*) getPlaylistFromParse;
-(void)loadChatFeed;
@end
