//
//  iAKMyScene.m
//  TidyUp
//
//  Created by Xiaonan Wang on 7/31/14.
//  Copyright (c) 2014 iAKTU. All rights reserved.
//

#import "iAKMyScene.h"


GameState _gamestate;
SKNode *_worldNode;
SKSpriteNode *mainMenuBackground, *mainMenuPlayButton, *categoryOneButton, *categoryTwoButton, *categoryThreeButton, *categoryFourButton;

@implementation iAKMyScene

#pragma mark - gamestate inits
-(id)initWithSize:(CGSize)size state:(GameState)state{
    if (self = [super initWithSize:size]) {
        self.anchorPoint = CGPointZero;
        _worldNode = [SKNode node];
        [self addChild:_worldNode];
        switch (state) {
            case GameStateMainMenu:
                _gamestate = GameStateMainMenu;
                [self setUpMainMenuBackground];
                [self setUpMainMenuPlayButton];
                break;
            case GameStateChooseLevel:
                break;
        }
        
    }
    return self;
}

#pragma mark - set ups

-(void)setUpMainMenuBackground{
    mainMenuBackground = [[SKSpriteNode alloc]initWithImageNamed:@"Background@2x.png"];
    mainMenuBackground.anchorPoint = CGPointMake(0.5, 0.5);
    mainMenuBackground.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    mainMenuBackground.zPosition = LayerBackground;
    [_worldNode addChild:mainMenuBackground];
}

-(void)setUpMainMenuPlayButton{
    mainMenuPlayButton = [[SKSpriteNode alloc]initWithImageNamed:@"playButton.png"];
    mainMenuPlayButton.anchorPoint = CGPointMake(0.5, 0.5);
    mainMenuPlayButton.position = CGPointMake(self.size.width / 2, self.size.height * 0.7);
    mainMenuPlayButton.zPosition = LayerButtons;
    [_worldNode addChild:mainMenuPlayButton];
}

#pragma mark - gamestate touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:_worldNode];
    switch (_gamestate) {
        case GameStateMainMenu:
            if (location.x >= mainMenuPlayButton.position.x - mainMenuPlayButton.size.width / 2 && location.x <= mainMenuPlayButton.position.x + mainMenuPlayButton.size.width / 2 && location.y >= mainMenuPlayButton.position.y - mainMenuPlayButton.size.height / 2 &&location.y <= mainMenuPlayButton.position.y +mainMenuPlayButton.size.height /2) {
                [self switchToChooseLevel];
            }
            break;
        case GameStateChooseLevel:
            break;
    }
   
}

#pragma mark - gamestate updates
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

#pragma mark - gamestate switches

-(void)switchToChooseLevel{
    _gamestate = GameStateChooseLevel;
    SKScene *newScene = [[iAKLevelScene alloc]initWithSize:self.size];
    SKTransition *transition = [SKTransition fadeWithColor:[UIColor blackColor] duration:0.5];
    [self.view presentScene:newScene transition:transition];
}
@end
