//
//  ListenInPost.h
//  ListenIn
//
//  Created by Zack Mathews on 12/19/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface ListenInPost : NSObject


-(void) createPost :(NSString*) username :(NSString*) text : (PFFile*) picture : (NSArray*) playlist;
@end
