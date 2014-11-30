//
//  LI_SpotifyMusicManager.h
//  ListenIn
//
//  Created by Zack Mathews on 1/14/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLibSpotify.h"
@interface LI_SpotifyMusicManager : NSObject<SPPlaybackManagerDelegate, SPSessionDelegate>

-(void) initalize;
-(void) unload;
-(void) playTrack : (NSString*)trackName;
-(void) pause;
-(void) resume;
-(void) loadCurrentTrackFromBroadcast : (NSString*) username;
-(SPPlaybackManager*)getPlaybackManager;
@property(strong, nonatomic) SPPlaybackManager *playbackManager;
@property(strong, nonatomic) SPTrack *currentTrack;
@property(strong, nonatomic) SPSearch *search;
@property bool paused;
@property bool songIsPlayingOutsideOfViewController;
@end
