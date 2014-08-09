//
//  iAKObject.h
//  tidyUp
//
//  Created by Xiaonan Wang on 7/29/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SpriteKit;

static const NSUInteger NumObjectTypes = 6;

@interface iAKObject : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSUInteger objectType;
@property (strong, nonatomic) SKSpriteNode *sprite;

- (NSString *)spriteName;
- (NSString *)highlightedSpriteName;

@end