//
//  iAKLevelGrid.h
//  TidyUp
//
//  Created by Xiaonan Wang on 8/3/14.
//  Copyright (c) 2014 iAKTU. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "iAKWorld.h"

@interface iAKLevelGrid : SKSpriteNode

//@property (nonatomic, readonly) CGSize size;
@property (nonatomic, retain) NSString *backgroundFileName;
@property (nonatomic, retain) NSArray *levels;

- (instancetype)initWithWorld:(iAKWorld *)world;

@end