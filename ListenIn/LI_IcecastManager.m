//
//  LI_IcecastManager.m
//  ListenIn
//
//  Created by Zack Mathews on 1/25/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import "LI_IcecastManager.h"
#import "FSCheckContentTypeRequest.h"
#import "FSAudioStream.h"
#import "FSAudioController.h"
@implementation LI_IcecastManager

@synthesize isPlaying;
@synthesize _audioStream;
-(void) initialize : (NSString*) url
{
    FSCheckContentTypeRequest *request = [[FSCheckContentTypeRequest alloc] init];
    request.url = @"http://dir.xiph.org/listen/1847911/listen.m3u";
    request.onCompletion = ^() {
        if (request.playlist) {
            // The URL is a playlist; now do something with it...
            _audioStream = [[FSAudioController alloc] init];
            _audioStream.url = @"http://dir.xiph.org/listen/1847911/listen.m3u";
            [_audioStream play];
            isPlaying = true;
            
            NSLog(@"Connected to icecast server");
        }
    };
    request.onFailure = ^() {
        NSLog(@"Failed");
    };
    
    [request start];
   
   
}

- (void)toggleRadio {
    if (isPlaying) {
        isPlaying = NO;
      
        //[button setTitle:@"Play" forState:UIControlStateNormal];
    }
    else {
        isPlaying = YES;
      
        //[button setTitle:@"Stop" forState:UIControlStateNormal];
    }
}


#pragma mark -

- (void)updateBuffering:(BOOL)value {
    NSLog(@"delegate update buffering %d", value);
}

- (void)interruptRadio {
    NSLog(@"delegate radio interrupted");
}

- (void)resumeInterruptedRadio {
    NSLog(@"delegate resume interrupted radio");
}

- (void)networkChanged {
    NSLog(@"delegate network changed");
}

- (void)connectProblem {
    NSLog(@"delegate connection problem");
}

- (void)audioUnplugged {
    NSLog(@"delegate audio unplugged");
}

- (void)metaTitleUpdated:(NSString *)title {
    NSLog(@"delegate title updated to %@", title);
    
    NSArray *chunks = [title componentsSeparatedByString:@";"];
    if ([chunks count]) {
        NSArray *streamTitle = [[chunks objectAtIndex:0] componentsSeparatedByString:@"="];
        if ([streamTitle count] > 1) {
            //titleLabel.text = [streamTitle objectAtIndex:1];
        }
    }
}

@end
