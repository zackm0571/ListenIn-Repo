//
//  ListenInPostCell.m
//  ListenIn
//
//  Created by Zack Mathews on 12/25/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//

#import "ListenInPostCell.h"

@implementation ListenInPostCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)leftPostSelected:(id)sender {
    
    
}
- (IBAction)rightPostSelected:(id)sender {
}



- (IBAction)leftUserSelected:(id)sender {
}

- (IBAction)rightUserSelected:(id)sender {
}

- (void)dealloc {
    [_leftImageView release];
    [_rightImageView release];
    [_leftUILabel release];
    [_rightUILabel release];
    [_rightUserNameLabel release];
    [_leftUserNameLabel release];
    [_leftUserNameButton release];
    [_rightUserNameButton release];
    [_rightTextView release];
    [_leftTextView release];
    [_leftBroadcastIndicator release];
    [_rightBroadcastIndicator release];
    [_rightContentView release];
    [_leftContentView release];
    [super dealloc];
}
@end
