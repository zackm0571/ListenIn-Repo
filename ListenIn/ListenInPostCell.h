//
//  ListenInPostCell.h
//  ListenIn
//
//  Created by Zack Mathews on 12/25/13.
//  Copyright (c) 2013 Zack Matthews. All rights reserved.
//
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
@interface ListenInPostCell : UITableViewCell

@property (retain, nonatomic) IBOutlet PFImageView *leftImageView;
@property (retain, nonatomic) IBOutlet PFImageView *rightImageView;

@property (retain, nonatomic) IBOutlet UILabel *leftUILabel;
@property (retain, nonatomic) IBOutlet UITextView *leftTextView;
@property (retain, nonatomic) IBOutlet UILabel *rightUILabel;
@property (retain, nonatomic) IBOutlet UITextView *rightTextView;

@property (retain, nonatomic) IBOutlet UIView *leftContentView;


@property (retain, nonatomic) IBOutlet UIView *rightContentView;

@property (retain, nonatomic) IBOutlet UILabel *rightUserNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *leftUserNameLabel;

@property (retain, nonatomic) IBOutlet UIButton *leftUserNameButton;

@property (retain, nonatomic) IBOutlet UIButton *rightUserNameButton;

@property (retain, nonatomic) IBOutlet UIImageView *leftBroadcastIndicator;

@property (retain, nonatomic) IBOutlet UIImageView *rightBroadcastIndicator;




@end
