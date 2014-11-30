//
//  LI_RawMP3ParseManager.m
//  ListenIn
//
//  Created by Zack Mathews on 1/27/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import "LI_RawMP3ParseManager.h"
#import <Parse/Parse.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAsset.h>
#import <MediaPlayer/MPMediaItem.h>
#import <AVFoundation/AVAssetExportSession.h>


AVQueuePlayer *queuePlayer;
AVAudioPlayer *audioPlayer;
NSTimer *loadTrackTitleTimer;

int seconds;
int totalDataPieces = 0;

int bufferLimit = 6;

int pieceInterval = 20;
NSTimer *updateCurrentTimeTimer;

NSTimer *deletePlayedPiecesTimer;

MPMediaItem *currentItem;

NSMutableArray *trackPieces;
NSMutableData *trackData;
NSMutableArray *tempPieces;

NSNumber *dataIndex;
NSNumber *tempDataIndex;

PFObject *tempTrack = nil;
PFObject *currentTrack = nil;


dispatch_queue_t streamQueue;
dispatch_queue_t nextTrackQueue;
dispatch_queue_t uploadQueue;
bool currentlyDownloading = false;
bool isExporting = false;

NSNumber *currentPlaylistIndex;
PFObject *broadcastObject;

NSNumber *p_index = nil;
@implementation LI_RawMP3ParseManager
@synthesize isPlaying;
@synthesize userBroadcasting;
@synthesize trackItem;
@synthesize pfSongFile;
@synthesize trackTitle;
@synthesize ownsStream;
@synthesize broadcastSession;
@synthesize ipodController;
@synthesize queueIndex;
@synthesize queuedTracks;
@synthesize  currentFile;
@synthesize checkForNewSongTimer;

@synthesize player;
-(void) uploadTrack: (NSData*) data :(NSString*) name :(NSNumber*) playlistIndex
{
    
   
    if(currentPlaylistIndex == nil)
    {
        currentPlaylistIndex = [[NSNumber alloc] initWithInt:0];
    }
    
    if(dataIndex == nil)
    {
        dataIndex = [[NSNumber alloc] initWithInt:0];
    }
        
    PFFile *file = [PFFile fileWithName:name data:data];
    
    PFObject *object = [PFObject objectWithClassName:@"Songs"];
    [object setObject:file forKey:@"songFile"];
    [object setValue:userBroadcasting forKey:@"user"];
    [object setValue:dataIndex forKey:@"dataIndex"];
    
    [object setValue:p_index forKey:@"playlistIndex"];
    
  //  NSString *dataPieces = [NSString stringWithFormat:@"%d", totalDataPieces];
  //  [object setValue:dataPieces forKey:@"totalPieces"];
    
    dataIndex = [[NSNumber alloc] initWithInt:[dataIndex intValue]+1];
    
    NSLog(@"Saving..");
    [object save];
    NSLog(@"Piece saved");
    
    
    
    }


-(void) streamTrack: (NSString*)user
{
    currentFile = nil;
    currentlyDownloading = true;
    trackPieces = nil;
    totalDataPieces = 0;
    
   // self.checkForNewSongTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkForNewTrack)userInfo:nil repeats:YES];
    streamQueue = dispatch_queue_create("streamQueue",NULL);
    
    dispatch_async(streamQueue, ^(void)
                   {
                       
                     //  PFQuery *playlistIndexQuery = [PFQuery queryWithClassName:@"BroadcastSession"];
                      // [playlistIndexQuery whereKey:@"userBroadcasting" equalTo:userBroadcasting];
                      // PFObject *broadcast = [playlistIndexQuery getFirstObject];
                       
                      // currentPlaylistIndex = broadcast[@"currentPlaylistIndex"];
                       
                       PFQuery *query = [PFQuery queryWithClassName:@"Songs"];
                       [query whereKey:@"user" equalTo:user];
                    //   [query whereKey:@"playlistIndex" equalTo:currentPlaylistIndex];
                       [query orderByAscending:@"dataIndex"];

                       NSError *error = nil;
                     /*  trackPieces = [[query findObjects:&error] mutableCopy];
                       
                     if(trackPieces.count < 2 || trackPieces == nil)
                     {
                         NSLog(@"Track pieces is empty");
                           do
                           {
                               
                                trackPieces = [[query findObjects] mutableCopy];
                            
                            
                               NSString *count = [NSString stringWithFormat:@"@%d", trackPieces.count];
                               NSLog(count);
                           }
                           
                           while(trackPieces.count < 2);
                         
                     }
                       */
                       NSError *trackError = nil;
                       PFObject *object;
                       
                       bool continueWithStream = true;
                       int timeouts = 0;
                       do {
                           timeouts++;
                           if(timeouts > 45)
                           {
                               continueWithStream = false;
                           }
                           object = [query getFirstObject:&error];
                       } while (object == nil && continueWithStream);
                     
                       
                       if(continueWithStream)
                       {
                                NSLog(@"Tracks loaded");
                                
                                dataIndex = [object valueForKey:@"dataIndex"];
                                
                                PFFile *file = [object objectForKey:@"songFile"];
                                currentFile = file;
                                NSLog(@"Preparing to play");
                           
                           NSString *url = file.url;
                           url = [url  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                [self playFromURL:[NSURL URLWithString:file.url]];
                           
                                currentTrack = object;
                       
                            
                       }
    
                   });
}





-(void) checkForNewTrack
{
    
    
    streamQueue = dispatch_queue_create("streamQueue",NULL);
    
                       NSLog(@"Checking for new segments");
  
                       NSLog(@"Looking for object");
                       PFQuery *query = [PFQuery queryWithClassName:@"Songs"];
                        
                       [query whereKey:@"user" equalTo:userBroadcasting];
                       [query orderByAscending:@"dataIndex"];
                       
                       [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
                                               {
                                                   
                                                   PFObject *tempObject = object;
                                                   
                                                   PFFile *file = [tempObject objectForKey:@"songFile"];
                                                   
                                                   if(self.currentFile != nil && file != nil)
                                                   {
                                                        tempTrack = tempObject;
                                                    
                                                   }
                                                   NSLog(@"Acquired object");
                                               }];
    

}

bool skipDelete = true;
-(void) deletePiecePlayed
{
    
    NSLog(@"Deleting played piece");
    PFQuery *query = [PFQuery queryWithClassName:@"Songs"];
    [query whereKey:@"user" equalTo:userBroadcasting];
    //[query whereKey:@"playlistIndex" equalTo:currentPlaylistIndex];
    [query orderByAscending:@"dataIndex"];
    
    PFObject *object = [query getFirstObject];
    
        if(object != nil && ipodController.currentPlaybackTime > 30)
        {
            [object deleteInBackground];
        }
    

    
}


       
-(void) resume
{

        isPlaying = true;
    [player play];



}



-(void) pause
{
    
    isPlaying = false;
    [player pause];


}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    // Do stuff here
    
   
        
        if(tempTrack != nil)
        {
        PFFile *file = [tempTrack objectForKey:@"songFile"];
        
 NSLog(@"Finished playing segment");
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:file.url]];
        

        [self.player replaceCurrentItemWithPlayerItem:item];
            [self.player play];
            currentTrack = tempTrack;
            PFFile *newFile = [currentTrack objectForKey:@"songFile"];
            currentFile = newFile;
            tempTrack = nil;
                NSLog(@"Finished playing, starting new segment");
        }

}
-(void) playFromURL :(NSURL*) url
{
    AVPlayer *localPlayer = [[AVPlayer alloc] initWithURL:url];
    self.player = localPlayer;
    
        NSLog(@"Loaded stream");
       // [self.player setVolume:1.0];
       // NSTimeInterval time;
       // PFObject *session = [self getBroadcastObject];
        //NSNumber *hostTime = [session valueForKey:@"currentTimeInSeconds"];
        
        //time = [hostTime doubleValue];
        //time = round(time / pieceInterval);
        
        //Float64 f_time = time;
        //CMTime cmTime = CMTimeMake(f_time, 1);
        //[queuePlayer seekToTime:cmTime];
        
       // self.player.rate = 1.0;
        NSLog(@"About to play.. ");
       // [self.player play];
       
        NSLog(@"Playing.. ");
      // [self.checkForNewSongTimer fire];
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[self.player currentItem]];
        self.isPlaying = true;
        
        currentlyDownloading = false;
        
        [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
        
        checkForNewSongTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkForNewTrack) userInfo:nil repeats:YES];
        [checkForNewSongTimer fire];
    

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.player && [keyPath isEqualToString:@"status"]) {
        if (self.player.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
            
        } else if (self.player.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            [self.player play];
            
            
        } else if (self.player.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
            
        }
    }
}

/*-(void)playWithData :(NSMutableData*) data
{
    
//    audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    
    AVPlayerItem *item = [AVPlayerItem alloc] ini
    player = [AVPlayer alloc] initWithPlayerItem:
    if(error == nil)
    {
        [audioPlayer setVolume:1.0];
        
        
        NSTimeInterval time;
        PFObject *session = [self getBroadcastObject];
        NSNumber *hostTime = [session valueForKey:@"currentTimeInSeconds"];
        
        time = [hostTime doubleValue];
        [audioPlayer setCurrentTime:time];
        
        [audioPlayer play];
        
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                         //  checkForNewSongTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkForNewTrack) userInfo:nil repeats:YES];
                          // [checkForNewSongTimer fire];
                       });
        self.isPlaying = true;
        
        currentlyDownloading = false;
    }
    
    else
    {
        NSLog([error description]);
       // [self streamTrack:userBroadcasting];
    }
    

}
*/
-(MPMusicPlayerController*) getiPodController
{
   
        ipodController = [MPMusicPlayerController iPodMusicPlayer];
    
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
      /*  [notificationCenter
         addObserver: self
         selector:    @selector (onSongChange)
         name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
         object:      ipodController];*/
      //  [ipodController beginGeneratingPlaybackNotifications];
    
 
    return ipodController;
}



-(PFObject*) getBroadcastObject
{
    
        if(broadcastObject == nil)
        {
        PFQuery *query = [PFQuery queryWithClassName:@"BroadcastSession"];
        [query whereKey:@"userBroadcasting" equalTo:userBroadcasting];
            broadcastObject = [query getFirstObject];
    
        }
    
    else
    {
        [broadcastObject refresh];
    }
    return broadcastObject;
}
-(void) updateHostTrackTime
{
    
   
    int currentTime = ipodController.currentPlaybackTime;
    
    NSNumber *NSCurrentTime = [[NSNumber alloc] initWithInt:currentTime];
    int pieceTime = ([NSCurrentTime intValue] > 30) ? ([NSCurrentTime doubleValue] / 30) : (30 / [NSCurrentTime doubleValue]);
    
    NSCurrentTime = [[NSNumber alloc] initWithInt:pieceTime];
    
    PFQuery *query = [PFQuery queryWithClassName:@"BroadcastSession"];
    [query whereKey:@"userBroadcasting" equalTo:userBroadcasting];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
         PFObject *session = object;
         [session setValue:NSCurrentTime forKey:@"currentTimeInSeconds"];
         [session saveInBackground];
     }];
   
    
    
}

-(void) deleteAllSongFiles
{
    PFQuery *query = [PFQuery queryWithClassName:@"Songs"];
    [query whereKey:@"user" equalTo:userBroadcasting];
    query.limit = 1000;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if(objects.count > 0)
         {
        for(int i = 0; i < objects.count; i++)
            {
                NSLog(@"Song deleted");
             [[objects objectAtIndex:i] deleteInBackground];
            }
         }
     }];

}

/*-(void) deleteCopies
{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Songs"];
    [query whereKey:@"user" equalTo:userBroadcasting];
    NSArray *copies = [query findObjects];
    
         PFObject *tempFile = [copies objectAtIndex:0];
         int count = 0;
         for(int i = 0; i < copies.count - 1; i++)
         {
             for(int k = 0; k < copies.count-1; k++)
             {
                 PFObject *currentObject = [copies objectAtIndex:k];
                 if(tempFile[@"dataIndex"]  == currentObject[@"dataIndex"])
                 {
                     count++;
                     if(count > 1)
                     {
                         [tempFile delete];
                         count = 0;
                         break;
                     }
                 }
             }
             
             tempFile = [copies objectAtIndex:i];
             count = 0;
         }
    

}*/

/*-(void) onSongChange
{
    PFQuery *query = [PFQuery queryWithClassName:@"Songs"];
    [query whereKey:@"playlistIndex" equalTo:currentPlaylistIndex];
    NSArray *files = [query findObjects];
    for(int i = 0; i < files.count; i++)
    {
        PFObject *object = [files objectAtIndex:i];
        [object deleteEventually];
    }
    
    PFQuery *broadcastQuery = [PFQuery queryWithClassName:@"BroadcastSession"];
    [broadcastQuery whereKey:@"userBroadcasting" equalTo:userBroadcasting];
    PFObject *currentBroadcast = [broadcastQuery getFirstObject];
    
  
    [currentBroadcast incrementKey:@"currentPlaylistIndex"];
    
    NSString *artist = [ipodController.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
    NSString *privateTrackTitle = [ipodController.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
    
    NSString *name = [artist stringByAppendingString:@"-"];
    name = [name stringByAppendingString:privateTrackTitle];
    NSArray *tracks = [currentBroadcast valueForKey:@"tracks"];
    if(tracks == nil)
    {
        tracks = [[NSArray alloc] init];
    }
    NSMutableArray *temp_tracks = [tracks mutableCopy];
    [temp_tracks addObject:name];
    tracks = temp_tracks;
    [currentBroadcast setValue:tracks forKey:@"tracks"];
    
    [currentBroadcast save];
    
    currentPlaylistIndex = [[NSNumber alloc] initWithInt:[currentPlaylistIndex intValue]+1];
}*/


-(void) uploadQueue:(NSArray*)playlist
{
    
    
    
    if(p_index == nil)
    {
        p_index = [[NSNumber alloc] initWithInt:0];
        [self deleteAllSongFiles];
        queuedTracks = playlist;
        
        NSLog(@"Preparing to export");
        [self mediaItemToData:[queuedTracks objectAtIndex:0]];
        
        updateCurrentTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateHostTrackTime) userInfo:nil repeats:YES];
        [updateCurrentTimeTimer fire];
    }
    
    
    else
    {

        if([p_index intValue] < queuedTracks.count - 1)
        {
             NSLog(@"Preparing to export next file");
            [self mediaItemToData:[queuedTracks objectAtIndex:[p_index intValue]]];
            
        }
    }

    
    
}

int pieceIndex = 0;
bool firedPieceDeleteTimer = false;
-(void)mediaItemToData :(MPMediaItem*) item
{

    
 //   updateCurrentTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateHostTrackTime) userInfo:nil repeats:YES];
  //  [updateCurrentTimeTimer fire];
    
   
    MPMediaItem *curItem = item;
    MPMediaItem __block *tempItem = curItem;
    NSURL *url = [curItem valueForProperty: MPMediaItemPropertyAssetURL];
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL: url options:nil];
    
    CMTime assetTime = [songAsset duration];
    
       NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * myDocumentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    Float64 totalTime = assetTime.value;
    
    int currentTime = 0;//[self getiPodController].currentPlaybackTime;

    int splits = round((totalTime - currentTime) / pieceInterval);
    
        uploadQueue = dispatch_queue_create("uploadQueue", NULL);
    
                       
    
                           AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset
                                                                                             presetName:AVAssetExportPresetAppleM4A];
                           
                           exporter.outputFileType = @"com.apple.m4a-audio";
                           
    
                           CMTime startTime = (pieceIndex == 0) ? CMTimeMake(currentTime, 1) : CMTimeMake(currentTime + (pieceInterval * pieceIndex) , 1);
                           CMTime stopTime = (pieceIndex + 1 == splits) ? assetTime : CMTimeMake(currentTime + ((pieceInterval * pieceIndex) + pieceInterval), 1);
                           CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
                           
                           [[NSDate date] timeIntervalSince1970];
                           NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
                           NSString *intervalSeconds = [NSString stringWithFormat:@"%0.0f",seconds];
                           
                           NSString * fileName = [NSString stringWithFormat:@"LI_%@.m4a",intervalSeconds];
                           
                           NSString *exportFile = [myDocumentsDirectory stringByAppendingPathComponent:fileName];
                           
                           NSURL *exportURL = [NSURL fileURLWithPath:exportFile];
                           exporter.outputURL = exportURL;
                           exporter.timeRange = exportTimeRange;
                           // do the export
                           // (completion handler block omitted)
                           
                           [exporter exportAsynchronouslyWithCompletionHandler:
                            ^{
                                int exportStatus = exporter.status;
                                NSData *data;
                                switch (exportStatus)
                                {
                                    case AVAssetExportSessionStatusFailed:
                                    {
                                        NSError *exportError = exporter.error;
                                        NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                                        break;
                                    }
                                    case AVAssetExportSessionStatusCompleted:
                                    {
                                        NSLog (@"AVAssetExportSessionStatusCompleted");
                                        
                                        
                                        data = [NSData dataWithContentsOfFile: [myDocumentsDirectory
                                                                                stringByAppendingPathComponent:fileName]];
                                        
                                        
                                        if(data != nil && tempItem != nil)
                                        {
                                            NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist];
                                            NSString *privateTrackTitle = [item valueForProperty:MPMediaItemPropertyTitle];
                                           // NSString *fileName = [PFUser currentUser].username;
                                            
                                           // fileName = [fileName stringByAppendingString:@".m4a"];//[privateTrackTitle stringByAppendingString:@".m4a"];
                                            
                                            
                                            
                                           /* fileName = [fileName stringByReplacingOccurrencesOfString:@"," withString:@""];
                                            fileName = [fileName stringByReplacingOccurrencesOfString:@"(" withString:@""];
                                            fileName = [fileName stringByReplacingOccurrencesOfString:@")" withString:@""];
                                            fileName = [fileName stringByReplacingOccurrencesOfString:@"'" withString:@""];
                                            fileName = [fileName stringByReplacingOccurrencesOfString:@"-" withString:@""];
                                            fileName = [fileName stringByReplacingOccurrencesOfString:@"&" withString:@""];
                                            fileName = [fileName stringByReplacingOccurrencesOfString:@"!" withString:@""];
                                            */
                                            
                                            [self uploadTrack:data :fileName :p_index];
                                            
                                            if(pieceIndex < splits)
                                            {
                                                pieceIndex++;
                                                [self mediaItemToData:item];
                                                
                                                if(!firedPieceDeleteTimer)
                                                {
                                                    NSLog(@"Delete timer fired");
                                                        //deletePlayedPiecesTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(deletePiecePlayed) userInfo:nil repeats:YES];
                                                        //[deletePlayedPiecesTimer fire];
                                                    firedPieceDeleteTimer = true;
                                                    

                                                }
                                            }

                                            
                                            if(pieceIndex == splits - 1)
                                            {
                                                
                                                p_index = [[NSNumber alloc] initWithInt:[p_index intValue]+1];
                                                [self uploadQueue:nil];
                                                pieceIndex = 0;
                                                
                                               
                                            }
                                            
                                            
                                            
                                            // [self uploadChoppedNSData:data : fileName];
                                            
                                            /*   PFQuery *query = [PFQuery queryWithClassName:@"BroadcastSession"];
                                             [query whereKey:@"userBroadcasting" equalTo:userBroadcasting];
                                             [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
                                             {
                                             
                                             NSString *name = [artist stringByAppendingString:@"-"];
                                             name = [name stringByAppendingString:privateTrackTitle];
                                             NSArray *tracks = [object valueForKey:@"tracks"];
                                             if(tracks == nil)
                                             {
                                             tracks = [[NSArray alloc] init];
                                             }
                                             NSMutableArray *temp_tracks = [tracks mutableCopy];
                                             [temp_tracks addObject:name];
                                             tracks = temp_tracks;
                                             [object setValue:tracks forKey:@"tracks"];
                                             [object save];
                                             }];
                                             */
                                            
                                            tempItem = nil;
                                        }
                                        
                                        
                                        else
                                        {
                                            NSLog(@"You suck!");
                                        }
                                        
                                        
                                        break;
                                    }
                                }
                            }];
    
    
    
}
-(void)uploadChoppedNSData :(NSData*)data :(NSString*) fileName
{
    NSData* myBlob = data;
    NSUInteger length = [myBlob length];
    NSUInteger chunkSize = 1000 * 1024;
    if(length < 10000 * 1024)
    {
        chunkSize = length;
    }

    NSUInteger offset = 0;
    

    int index = 0;
    
    totalDataPieces = length / chunkSize;
    do {
        NSLog(@"Chopping");
        NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
        NSData* chunk = [NSData dataWithBytes:(char *)[myBlob bytes] + offset
                         length:thisChunkSize];
        index++;
        
          //  dataIndex = [[NSNumber alloc] initWithInt:index];

        offset += thisChunkSize;
        [self uploadTrack:chunk :fileName];
      //  [self deleteCopies];
        // do something with chunk
    } while (offset < length);

    NSLog(@"Done chopping");
    currentPlaylistIndex = [[NSNumber alloc] initWithInt:[currentPlaylistIndex intValue] + 1];
   // dataIndex = 0;
}



@end
