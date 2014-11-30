//
//  ListenInHelperFunctions.h
//  ListenIn
//
//  Created by Zack Mathews on 12/20/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListenInUser.h"

@interface ListenInHelperFunctions : NSObject

-(ListenInUser*) pfUserToListenInUser : (PFUser*) user;


@end
