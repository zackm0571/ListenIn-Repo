//
//  LI_IcecastManager.h
//  ListenIn
//
//  Created by Zack Mathews on 1/25/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSAudioStream.h"
#import "FSAudioController.h"
@interface LI_IcecastManager : NSObject 


@property bool isPlaying;

-(void) initialize: (NSString*) url;
-(void) toggleRadio;
@property  FSAudioController *_audioStream;;
@end
