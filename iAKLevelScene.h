//
//  iAKLevelScene.h
//  TidyUp
//
//  Created by Xiaonan Wang on 8/3/14.
//  Copyright (c) 2014 iAKTU. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "iAKLevelGrid.h"

@interface iAKLevelScene : SKScene

@property (nonatomic) int pagesCount;
@property (nonatomic, assign) int currentPage;
@property (strong, nonatomic) NSMutableArray *content;
@property (strong, nonatomic) NSMutableDictionary *levels;

- (void)levelSelected:(NSInteger)level;

@end