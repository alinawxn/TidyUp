//
//  iAKMyScene.h
//  TidyUp
//

//  Copyright (c) 2014 iAKTU. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "iAKLevelObject.h"
#import "iAKSwap.h"
#import "iaklevelGrid.h"
#import "iAKLevelScroller.h"
#import "iAKGameModel.h"
#import "iAKWorld.h"
#import "iAKObject.h"
#import "iAKLevelObject.h"
#import "iAKChain.h"
#import "iAKLevelButton.h"

typedef NS_ENUM(int, GameState)
{
    GameStateMainMenu,
    GameStateChooseLevel,
    GameStateLevelPlay,
    GameStateGameOverWin,
    GameStateGameOverLose,
};

typedef NS_ENUM(int, Layer) {
    LayerBackground,
    LayerGame,
    LayerObject,
    LayerObject1,
    LayerButtons,
    LayerThree,
    LayerTwo,
    LayerOne,
    LayerZero,
};

extern NSInteger currentScore;
extern NSInteger levelTarget;
extern NSInteger levelMove;
extern NSInteger levelTime;
extern GameState _gamestate;
extern SKNode *_worldNode;
extern NSInteger currentLevel;


@interface iAKMyScene : SKScene
@property (nonatomic) int pagesCount;
@property (nonatomic, assign) int currentPage;
@property (strong, nonatomic) NSMutableArray *content;
@property (strong, nonatomic) NSMutableDictionary *levels;
@property (strong, nonatomic) iAKLevelObject *levelObject;
@property (copy,nonatomic) void (^swipeHandler)(iAKSwap *swap);
@property SKSpriteNode *tidyUpButton,*mainMenuBackground, *mainMenuPlayButton,*box,*box_frontboard, *levelClear, *jingxiang, *GameStateWin_homebutton, *GameStateWin_nextlevelButton, *GameStateWin_levelChooseButton;
@property SKLabelNode *currentScore, *targetScore, *remainMoves, *remainTime;

-(void)addSpritesForObjects:(NSSet *)objects;
- (void)levelSelected:(NSInteger)level;
-(id)initWithSize:(CGSize)size state:(GameState)state;

@end
