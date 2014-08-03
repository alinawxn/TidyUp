//
//  iAKLevelScroller.h
//  TidyUp
//
//  Created by Xiaonan Wang on 8/3/14.
//  Copyright (c) 2014 iAKTU. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
    HORIZONTAL,
    VERTICAL
} ScrollDirection;

@interface iAKLevelScroller : SKSpriteNode

@property (nonatomic) CGSize contentSize;
@property (nonatomic) ScrollDirection scrollDirection;

- (iAKLevelScroller *)initWithSize:(CGSize)size;

@end
