//
//  LI_Manager.h
//  ListenIn
//
//  Created by Zack Mathews on 2/3/14.
//  Copyright (c) 2014 Zack Matthews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LI_RawMP3ParseManager.h"



static @interface LI_Manager : NSObject

+(void) _init;

+(LI_RawMP3ParseManager*) getRawMP3Manager;
@end
