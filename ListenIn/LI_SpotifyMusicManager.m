//
//  LI_SpotifyMusicManager.m
//  ListenIn
//
//  Created by Zack Mathews on 1/14/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import "LI_SpotifyMusicManager.h"
#import "CocoaLibSpotify.h"
#import <Parse/Parse.h>
@implementation LI_SpotifyMusicManager

@synthesize currentTrack;
@synthesize playbackManager;
@synthesize search;

@synthesize paused;
const uint8_t g_appkey[] = {
	0x01, 0xDA, 0x29, 0x39, 0x99, 0x13, 0xD5, 0x6A, 0x62, 0x0B, 0x9C, 0xEA, 0x99, 0xE4, 0x58, 0x46,
	0xC9, 0x95, 0xCA, 0x59, 0x1C, 0xDD, 0xD5, 0x15, 0x41, 0x22, 0x6C, 0xD0, 0x54, 0x09, 0x5E, 0xA1,
	0xC3, 0xDE, 0x20, 0x25, 0x50, 0x4B, 0x20, 0xCA, 0x7C, 0x59, 0x63, 0x7C, 0xD1, 0xC8, 0x8A, 0x5C,
	0x40, 0x7F, 0x90, 0x7C, 0x3C, 0x42, 0x2E, 0x80, 0x79, 0xA3, 0xF6, 0xE2, 0xBE, 0x54, 0x4A, 0x70,
	0xEB, 0x98, 0x2E, 0x30, 0x84, 0x33, 0x6A, 0xB6, 0xDE, 0x92, 0xCD, 0xF1, 0x96, 0x3F, 0x64, 0xA2,
	0x10, 0x52, 0xBB, 0xB3, 0x4D, 0x39, 0xD8, 0xF6, 0x75, 0xC2, 0xCE, 0xA2, 0x9A, 0xBB, 0x3F, 0xFA,
	0x12, 0x15, 0xAA, 0xDE, 0x8E, 0xA5, 0x3F, 0x5C, 0xED, 0x84, 0xA6, 0xCE, 0x04, 0xFD, 0xF2, 0x3D,
	0x5D, 0xE0, 0xFE, 0x08, 0x31, 0xCB, 0xF4, 0x4F, 0xA4, 0xF0, 0x83, 0x9B, 0xE9, 0xAE, 0x20, 0x80,
	0xA1, 0x55, 0x4D, 0xBB, 0x8D, 0x4F, 0x3C, 0x21, 0x21, 0x3C, 0xCE, 0x1A, 0x26, 0x1A, 0x5E, 0x70,
	0x22, 0x82, 0x76, 0xB2, 0xB6, 0xA7, 0x0D, 0x2A, 0xAE, 0xB3, 0xB0, 0xD6, 0x97, 0x1C, 0x01, 0x6D,
	0xC4, 0xE5, 0x5A, 0x1C, 0x5D, 0xE0, 0xBB, 0xE0, 0x86, 0x37, 0xF5, 0x6C, 0x47, 0xF1, 0xC7, 0x27,
	0xFD, 0x89, 0xA4, 0x15, 0xDA, 0x84, 0x44, 0xFC, 0xDB, 0x69, 0x60, 0x16, 0x18, 0x86, 0x2E, 0xF1,
	0xF4, 0x85, 0x39, 0x61, 0x6B, 0xAD, 0xEF, 0x3A, 0x49, 0xD0, 0xC8, 0x81, 0xE0, 0x00, 0xBD, 0xD5,
	0xC1, 0x22, 0x8F, 0x42, 0xB9, 0x53, 0xEB, 0x9F, 0x8C, 0x43, 0xE9, 0xB2, 0x90, 0x7E, 0xF8, 0x9F,
	0x50, 0xF6, 0xCC, 0x05, 0xD7, 0x87, 0xB9, 0x0D, 0x3B, 0x02, 0x19, 0x17, 0xDF, 0xC1, 0xD4, 0x69,
	0xE2, 0x3F, 0x55, 0xD5, 0x40, 0xEF, 0xF3, 0x24, 0x4F, 0x32, 0x71, 0xDA, 0xF8, 0xEF, 0xD6, 0x8D,
	0x0C, 0x9A, 0x35, 0x15, 0x20, 0xA1, 0xFD, 0x5E, 0xB7, 0xFB, 0xDE, 0xD5, 0x6E, 0x06, 0x2C, 0x95,
	0x7F, 0x36, 0xC0, 0x43, 0xE1, 0x61, 0x1F, 0xB1, 0x9D, 0xBA, 0x60, 0xC5, 0x53, 0x65, 0xBF, 0xA4,
	0x2A, 0x0F, 0x6E, 0xFE, 0x0D, 0xEA, 0x4A, 0x2E, 0xBB, 0x17, 0xFE, 0xDE, 0xE0, 0x46, 0xA1, 0xD6,
	0xE2, 0x70, 0xD9, 0xD7, 0x9F, 0x86, 0x4A, 0xBC, 0xA9, 0xD3, 0x67, 0x99, 0xEB, 0xCF, 0x67, 0x93,
	0xD7,
};
const size_t g_appkey_size = sizeof(g_appkey);
-(void) initalize
{
    

    if([SPSession sharedSession] == nil)
    {
        NSLog(@"Initializing spotify");
	[SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size]
											   userAgent:@"com.mattie.montgomery.listenin"
										   loadingPolicy:SPAsyncLoadingManual
												   error:nil];
    [[SPSession sharedSession] setDelegate:self];
        
       
    }
    
    if([SPSession sharedSession] != nil && [SPSession sharedSession].user == nil)
    {
        NSString *userName = @"ayyson", *password = @"stephano12";
        
        [[SPSession sharedSession] attemptLoginWithUserName:userName password:password];
    }
    
             NSLog(@"Spotify initialized");
   
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if([object class] == [SPPlaybackManager class])
    {
        if(((SPPlaybackManager*)object).playbackSession == [self getPlaybackManager].playbackSession)
        {
            if([self getPlaybackManager].isPlaying == NO && [self getPlaybackManager].currentTrack == nil)
            {
                paused = true;
                return;
            }
            
            
            if([self getPlaybackManager].isPlaying == NO && currentTrack != nil && paused == false)
            {
                [self loadCurrentTrackFromBroadcast:[[PFUser currentUser] objectForKey:@"currentRoom"]];
            }
        }
    }

    if(object == search)
    {
    SPTrack *track = [[(SPSearch*)object tracks] objectAtIndex:0];
    NSURL *trackURL = track.spotifyURL;
    
        NSLog(@"Searching for track on spotify servers...");
    [[SPSession sharedSession] trackForURL:trackURL callback:^(SPTrack *track) {
        

        if (track != nil) {

                        NSLog(@"Found track");
                           [SPAsyncLoading waitUntilLoaded:track timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *tracks, NSArray *notLoadedTracks) {
                    [[self getPlaybackManager] playTrack:track callback:^(NSError *error) {
                        
                        if (error) {
                            
                            NSLog(@"Error playing track");
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Track"
                                                                            message:[error localizedDescription]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                        } else {
                            
                            NSLog(@"Playing track");
                            //[[self getPlaybackManager] seekToTrackPosition:120];
                            currentTrack = track;
                            paused = false;
                        }
                        
                    }];
            }];
        }
    }];
    
    }
    
   
}



-(void) loadCurrentTrackFromBroadcast : (NSString*) username
{
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"BroadcastSession"];
    [query whereKey:@"userBroadcasting" equalTo:username];
    
    NSLog(@"Finding latest track from backend...");
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {

         NSArray *tracks = [object objectForKey:@"tracks"];
         
         [self playTrack:[tracks objectAtIndex: tracks.count -1]];
         NSLog(@"Track name found");
         
     }];
}

-(void)playbackManagerWillStartPlayingAudio:(SPPlaybackManager *)aPlaybackManager
{
    
}
-(void) playTrack:(NSString *)trackName
{
    search = [SPSearch liveSearchWithSearchQuery:trackName inSession:[SPSession sharedSession]];
    [search addObserver:self forKeyPath:@"loaded" options:NSKeyValueObservingOptionNew context:NULL];

}

-(void) resume
{

 
                paused = false;
        [[self getPlaybackManager] setIsPlaying:YES];
       NSLog(@"Spotify playback resumed");

}

-(void) pause
{
 
       paused = true;
    [[self getPlaybackManager] setIsPlaying:NO];
    NSLog(@"Spotify playback paused");
    
}

-(void) unload
{
    
}

-(SPPlaybackManager*)getPlaybackManager
{
    if(playbackManager == nil)
    {
        
        playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
        [playbackManager addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionNew context:NULL];
        
        NSLog(@"Loaded spotify playback manager");
    }
    
    return playbackManager;
}
@end
