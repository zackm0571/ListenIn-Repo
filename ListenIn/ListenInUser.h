//
//  ListenInUser.h
//  ListenIn
//
//  Created by Zack Mathews on 12/19/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ListenInUser : NSObject


@property PFFile *profilePicture;
@property NSString *userName;
@property NSMutableArray *friends;
@property NSMutableArray *posts;
@property PFObject *userObject;
@property NSDate *lastPostDate;
@end
