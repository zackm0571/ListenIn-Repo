//
//  ListenInHelperFunctions.m
//  ListenIn
//
//  Created by Zack Mathews on 12/20/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//

#import "ListenInHelperFunctions.h"
#import "ListenInUser.h"
#import <Parse/Parse.h>
@implementation ListenInHelperFunctions

-(ListenInUser*) pfUserToListenInUser : (PFUser*) user
{
    ListenInUser *returnUser = [[ListenInUser alloc] init];
    returnUser.userName = user.username;
    //Validation that every user has a profile picture
    if([user objectForKey:@"profilePicture"] == nil)
    {
        returnUser.profilePicture = [PFFile fileWithName:@"logo.jpg:" contentsAtPath:@"logo.jpg"] ;
        [user setObject: returnUser.profilePicture forKey:@"profilePicture"];
        [user saveInBackground];
    }

    else
    {
        //Gets user profile picture
    PFFile *file = [user objectForKey:@"profilePicture"];
    returnUser.profilePicture = file;
    }
    
    //Validation every user has a friends list
    if([user valueForKey:@"friends"] == nil)
    {
        returnUser.friends = [[NSMutableArray alloc] init];
        [user setObject:returnUser.friends forKey:@"friends"];
                [user saveInBackground];
    }
    
    else
    {
        //Gets friends list
        returnUser.friends = (NSMutableArray*)[user valueForKey:@"friends"];
        
    }
    
    if([user valueForKey:@"lastPostDate"] != nil)
    {
        returnUser.lastPostDate = (NSDate*)[user valueForKey:@"lastPostDate"];
    }
    
    //Validation that every user has a mutable collection to contain posts
    if([user valueForKey:@"posts"] == nil)
    {
        returnUser.posts = [[NSMutableArray alloc] init];
        [user setObject:returnUser.posts forKey:@"posts"];
    }
    
    else
    {
        returnUser.posts = [user valueForKey:@"posts"];
    }
    return returnUser;
}





@end
