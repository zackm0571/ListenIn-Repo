//
//  LI_RawMP3ParseManager.h
//  ListenIn
//
//  Created by Zack Mathews on 1/27/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <AVFoundation/AVPlayerItem.h>
#import <MediaPlayer/MPMusicPlayerController.h>
@interface LI_RawMP3ParseManager : NSObject 


@property (nonatomic, strong) NSString *userBroadcasting;

-(void) uploadTrack: (NSData*) data : (NSString*) name :(NSNumber*)playlistIndex;
-(void) streamTrack: (NSString*)user;
-(void) pause;
-(void) resume;
-(NSString*)getCurrentTrackTitle;


@property NSTimer *checkForNewSongTimer;

@property bool isPlaying;
@property (nonatomic, strong) AVPlayerItem *trackItem;
@property (copy) NSString* trackTitle;
@property (nonatomic, strong)  PFFile *pfSongFile;
@property bool ownsStream;
@property (nonatomic, strong) NSArray *queuedTracks;
@property MPMusicPlayerController *ipodController;
@property int queueIndex;
@property (nonatomic, strong) PFObject *broadcastSession;
@property (nonatomic, strong) PFFile *currentFile;

@property (nonatomic, strong) AVPlayer *player;
-(MPMusicPlayerController*) getiPodController;

-(void) uploadQueue:(NSArray*)playlist;
@end
