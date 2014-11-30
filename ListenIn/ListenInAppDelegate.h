//
//  ListenInAppDelegate.h
//  ListenIn
//
//  Created by Zack Mathews on 12/14/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"

@interface ListenInAppDelegate : UIResponder <UIApplicationDelegate, SPSessionDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
