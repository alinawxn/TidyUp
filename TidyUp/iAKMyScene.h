//
//  iAKMyScene.h
//  TidyUp
//

//  Copyright (c) 2014 iAKTU. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
//#import "iAKLevelScene.h"

typedef NS_ENUM(int, GameState)
{
    GameStateMainMenu,
    GameStateChooseLevel,
    GameStateLevelPlay
};

typedef NS_ENUM(int, Layer) {
    LayerBackground,
    LayerButtons
};

extern GameState _gamestate;
extern SKNode *_worldNode;


@interface iAKMyScene : SKScene
@property (nonatomic) int pagesCount;
@property (nonatomic, assign) int currentPage;
@property (strong, nonatomic) NSMutableArray *content;
@property (strong, nonatomic) NSMutableDictionary *levels;

- (void)levelSelected:(NSInteger)level;

-(id)initWithSize:(CGSize)size state:(GameState)state;

@end
