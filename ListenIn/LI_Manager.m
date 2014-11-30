//
//  LI_Manager.m
//  ListenIn
//
//  Created by Zack Mathews on 2/3/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import "LI_Manager.h"

@implementation LI_Manager

static LI_RawMP3ParseManager *mp3Manager;

+(void) _init
{
   mp3Manager =  [[LI_RawMP3ParseManager alloc] init];
}

+(LI_RawMP3ParseManager*) getRawMP3Manager
{
    return mp3Manager;
}
@end
