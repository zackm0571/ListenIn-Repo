//
//  ListenInPost.m
//  ListenIn
//
//  Created by Zack Mathews on 12/19/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//

#import "ListenInPost.h"
#import "ListenInUser.h"
@implementation ListenInPost

NSString *_username, *_text;
PFFile *_picture;
NSArray *_playlist;
-(void) createPost : (NSString*) username :(NSString*) text : (PFFile*) picture : (NSArray*) playlist
{
    PFObject *object = [PFObject objectWithClassName:@"Post"];

    [object setValue:picture forKey:@"image"];
    [object setValue:username forKey:@"user"];
    
    if(playlist != nil)
    {
        [object setValue:playlist forKey:@"playlist"];
        NSString *tempText = text;
        text = [self playlistToText:playlist];
        text = [text stringByAppendingString:tempText];
    }
    
        [object setValue:text forKey:@"text"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError* error)
     {
         NSString *message = @"Post succeded: ";
     }];
}


-(NSString*) playlistToText :(NSArray*) playlist
{
    NSString *returnString = @"";
    
    returnString = [playlist objectAtIndex:0];
    
    for(int i = 1; i < playlist.count; i++)
    {
        returnString = [returnString stringByAppendingString:@"\n"];
        returnString = [returnString stringByAppendingString:[playlist objectAtIndex:i]];
    }
    return returnString;
}
@end
