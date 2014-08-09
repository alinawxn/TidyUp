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
NSInteger currentLevel,currentScore, levelTarget, levelMove, levelTime;
NSSet *newObjects;
static const CGFloat TileWidth = 64.0;
static const CGFloat TileHeight = 72.0;

@interface iAKMyScene() {
    
    iAKGameModel *gameModel;
    iAKLevelScroller *levelsScroller;
    CGPoint initialPosition, initialTouch, initialParallaxBackPosition, initialParallaxMidPosition;
    int minimum_detect_distance;
    CGFloat moveAmtX, moveAmtY;
    SKLabelNode *pageLabel;
    SKSpriteNode *parallaxBackground, *parallaxMidground;
    iAKLevelGrid *levelGrid;
}

@property (assign, nonatomic) NSInteger swipeFromColumn;
@property (assign, nonatomic) NSInteger swipeFromRow;
@end

@implementation iAKMyScene
@synthesize pagesCount, content, currentPage;

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
                gameModel = [iAKGameModel sharedManager];
                content = [[NSMutableArray alloc] init];
                
                self.anchorPoint = CGPointMake(0.5, 0.5);
                self.currentPage = 1;
                //the minimum amount the user must scroll before the page gets flipped to the next or previous one
                minimum_detect_distance = 200;
                
                
                levelsScroller = [[iAKLevelScroller alloc] initWithSize:self.size];
                levelsScroller.scrollDirection = VERTICAL;
                [self addChild:levelsScroller];
                
                
                //add parallax backgrounds
                parallaxBackground = [self createParallaxBackground:@"bg"];
                [self addChild:parallaxBackground];
                
                parallaxMidground = [self createParallaxBackground:@"mg"];
                [self addChild:parallaxMidground];
                
                
                [self loadContent];
                
                
                //temporary label at bottom of screen to show which page we are on
                pageLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
                pageLabel.position = CGPointMake(-(self.size.width / 2) + 20, -(self.size.height / 2) + 20);
                pageLabel.fontColor = [SKColor blackColor];
                pageLabel.zPosition = 50;
                pageLabel.text = @"1";
                [self addChild:pageLabel];

                break;
            case GameStateLevelPlay:{
                self.anchorPoint = CGPointZero;
                [self setUpMainMenuBackground];
                [self setUpLabelsInPlay];
                [self setUpTidyUpButton];
                self.levelObject = [[iAKLevelObject alloc]initWithFile:[NSString stringWithFormat:@"Level_%d",currentLevel]];
                id block = ^(iAKSwap *swap) {
                    self.view.userInteractionEnabled = NO;
                    
                    if ([self.levelObject isPossibleSwap:swap]) {
                        [self.levelObject performSwap:swap];
                        [self animateSwap:swap completion:^{
                            self.view.userInteractionEnabled = YES;
                        }];
                        [self.levelObject detectPossibleSwaps];
                    } else {
                        [self animateInvalidSwap:swap completion:^{
                            self.view.userInteractionEnabled = YES;
                        }];
                    }
                };
                
                self.swipeHandler = block;
                [self setUpTargetsInPlay];
                [self beginGame];
                [self addTiles];
                self.swipeFromColumn = self.swipeFromRow = NSNotFound;

                break;
            }
            case GameStateGameOverWin:{
                break;
            }
            case GameStateGameOverLose:{
                break;
            }
        }
        
    }
    return self;
}

#pragma mark - set ups

-(void)setUpTidyUpButton{
    //add tidyupbutton
    self.tidyUpButton = [[SKSpriteNode alloc]initWithImageNamed:@"tidyUpButton.png"];
    self.tidyUpButton.anchorPoint = CGPointMake(0.5, 0.5);
    self.tidyUpButton.position = CGPointMake(self.size.width/2, self.size.height * 0.1);
    self.tidyUpButton.zPosition = LayerObject;
    [_worldNode addChild:self.tidyUpButton];
}

- (SKSpriteNode *)createParallaxBackground:(NSString *)prefix {
    
    //we pass in a prefix for the images so that we can use this method to create multiple background layers
    //the parallax background images must have the numbering format of "bg0001, mg0001, etc." for this code to work.
    //you must manually set the number of images in your parallax background
    int numberOfBackgroundImages = 5;
    int backgroundPositionX = 0, backgroundPositionY = 0;
    int width = self.size.width, height = self.size.height;
    SKSpriteNode *subBackground;
    SKTexture *backgroundTexture;
    
    //take all of the images and paste them together into 1 big background image
    //set a dummy size for now, we will change it after we know how big the individual images are
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(width, height)];
    background.position = CGPointMake(0, 0);
    background.zPosition = -100;
    
    for (int x = 1; x <= numberOfBackgroundImages; x++) {
        
        backgroundTexture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@%04d", prefix, x]];
        
        //cycle through the images and place them accordingly into the larger background image
        //we are also keeping track of their size so that we can sdjust the size of the bacjground image afterwards
        //if we are scrolling vertically it is assumed the the width will be the width of the page and vice versa for horizontal
        if (x == 1) {
            
            if (levelsScroller.scrollDirection == VERTICAL) {
                
                backgroundPositionY = -(backgroundTexture.size.height / 2);
                height = backgroundTexture.size.height;
            }
            else {
                
                backgroundPositionX = -(backgroundTexture.size.width / 2);
                width = backgroundTexture.size.width;
            }
        }
        else {
            
            if (levelsScroller.scrollDirection == VERTICAL) {
                
                backgroundPositionY += backgroundTexture.size.height;
                height += backgroundTexture.size.height;
            }
            else {
                
                backgroundPositionX += backgroundTexture.size.width;
                width += backgroundTexture.size.width;
            }
        }
        
        //create the sprite and add it to the background sprite
        subBackground = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
        subBackground.position = CGPointMake(backgroundPositionX, backgroundPositionY);
        [background addChild:subBackground];
    }
    
    background.size = CGSizeMake(width, height);
    
    //return the large background sprite only
    return background;
}

- (void)setCurrentPage:(int)_currentPage {
    
    currentPage = _currentPage;
    //changes the temporary label to show what the current page is
    pageLabel.text = [NSString stringWithFormat:@"%d", currentPage];
}

- (void)loadContent {
    
    //go through each world and load the levels for that world
    for (NSDictionary *tempWorld in gameModel.worlds) {
        
        //create an istance of the world to pass into the levelGrid object
        iAKWorld *world = [[iAKWorld alloc] init];
        world.title = [tempWorld objectForKey:@"WorldTitle"];
        world.worldID = [[tempWorld objectForKey:@"WorldID"] intValue];
        
        levelGrid = [[iAKLevelGrid alloc] initWithWorld:world];
        levelGrid.position = CGPointMake((self.size.width - levelGrid.size.width) / 2, (self.size.height - levelGrid.size.height) / 2);
        
        //create a container to hold the level grid and to put into the levelScroller
        SKSpriteNode *worldContent = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:self.size];
        worldContent.position = CGPointMake(-(self.size.width / 2), 0);
        worldContent.name = world.title;
        worldContent.anchorPoint = CGPointZero;
        
        [worldContent addChild:levelGrid];
        [content addObject:worldContent];
    }
    
    pagesCount = (int)content.count;
    
    if (levelsScroller.scrollDirection == HORIZONTAL)
        levelsScroller.size = CGSizeMake(self.size.width * pagesCount, self.size.height);
    else
        levelsScroller.size = CGSizeMake(self.size.width, self.size.height * pagesCount);
    
    [self positionPages];
}

- (void)positionPages {
    
	for (int i = 0; i < pagesCount; i++) {
        
        SKSpriteNode *page = [content objectAtIndex:i];
        
        //load the levels grids in the scroller side by side
        if (levelsScroller.scrollDirection == HORIZONTAL)
            page.position = CGPointMake(-(page.size.width / 2) + self.size.width * i, -(page.size.height / 2));
        else
            page.position = CGPointMake(-(page.size.width / 2), -(page.size.height / 2) + self.size.height * i);
        
        [levelsScroller addChild:page];
	}
}

//main menu
-(void)setUpTargetsInPlay{
    //score
    self.currentScore = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy-Bold"];
    self.currentScore.text = [NSString stringWithFormat:@"%d",currentScore];
    self.currentScore.position = CGPointMake(self.size.width*0.8, self.size.height*0.87);
    self.currentScore.zPosition = LayerObject;
    [_worldNode addChild:self.currentScore];
    
    //moves
    self.remainMoves = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy-Bold"];
    self.remainMoves.text = [NSString stringWithFormat:@"%d",levelMove];
    self.remainMoves.position = CGPointMake(self.size.width*0.4, self.size.height*0.87);
    self.remainMoves.zPosition = LayerObject;
    [_worldNode addChild:self.remainMoves];
    
    //targetscore
    self.targetScore = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy-Bold"];
    self.targetScore.text = [NSString stringWithFormat:@"%d",levelTarget];
    self.targetScore.position = CGPointMake(self.size.width*0.6, self.size.height*0.87);
    self.targetScore.zPosition = LayerObject;
    [_worldNode addChild:self.targetScore];

    
    
    //time
    self.remainTime = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy-Bold"];
    if (levelTime < 1000){
        self.remainTime.text = [NSString stringWithFormat:@"%d",levelTime];
    }else{
        self.remainTime.text = @"";
    }
    
    self.remainTime.position = CGPointMake(self.size.width*0.2, self.size.height*0.87);
    self.remainTime.zPosition = LayerObject;
    [_worldNode addChild:self.remainTime];
}

-(void)setUpLabelsInPlay{
    SKLabelNode *time = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy-Bold"];
    time.text = [NSString stringWithFormat:@"Time:"];
    time.position = CGPointMake(self.size.width*0.2, self.size.height*0.91);
    time.zPosition = LayerObject;
    [_worldNode addChild:time];
    
    SKLabelNode *move = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy-Bold"];
    move.text = [NSString stringWithFormat:@"Move:"];
    move.position = CGPointMake(self.size.width*0.4, self.size.height*0.91);
    move.zPosition = LayerObject;
    [_worldNode addChild:move];
    
    SKLabelNode *target = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy-Bold"];
    target.text = [NSString stringWithFormat:@"Target:"];
    target.position = CGPointMake(self.size.width*0.6, self.size.height*0.91);
    target.zPosition = LayerObject;
    [_worldNode addChild:target];
    
    SKLabelNode *score = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy-Bold"];
    score.text = [NSString stringWithFormat:@"Score:"];
    score.position = CGPointMake(self.size.width*0.8, self.size.height*0.91);
    score.zPosition = LayerObject;
    [_worldNode addChild:score];
}

-(void)setUpMainMenuBackground{
    self.mainMenuBackground = [[SKSpriteNode alloc]initWithImageNamed:@"Background"];
    self.mainMenuBackground.anchorPoint = CGPointMake(0.5, 0.5);
    self.mainMenuBackground.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    self.mainMenuBackground.zPosition = LayerBackground;
    [_worldNode addChild:self.mainMenuBackground];
}

-(void)setUpMainMenuPlayButton{
    self.mainMenuPlayButton = [[SKSpriteNode alloc]initWithImageNamed:@"playButton.png"];
    self.mainMenuPlayButton.anchorPoint = CGPointMake(0.5, 0.5);
    self.mainMenuPlayButton.position = CGPointMake(self.size.width / 2, self.size.height * 0.7);
    self.mainMenuPlayButton.zPosition = LayerObject;
    [_worldNode addChild:self.mainMenuPlayButton];
}

#pragma mark - moves
- (void)trySwapHorizontal:(NSInteger)horzDelta vertical:(NSInteger)vertDelta {
    // 1
    NSInteger toColumn = self.swipeFromColumn + horzDelta;
    NSInteger toRow = self.swipeFromRow + vertDelta;
    
    // 2
    if (toColumn < 0 || toColumn >= NumColumns) return;
    if (toRow < 0 || toRow >= NumRows) return;
    
    // 3
    iAKObject *toObject = [self.levelObject objectAtColumn:toColumn row:toRow];
    if (toObject == nil) return;
    
    // 4
    iAKObject *fromObject = [self.levelObject objectAtColumn:self.swipeFromColumn row:self.swipeFromRow];
    
    if (self.swipeHandler != nil) {
        iAKSwap *swap = [[iAKSwap alloc] init];
        swap.objectA = fromObject;
        swap.objectB = toObject;
        
        self.swipeHandler(swap);
    }
}

- (void)swipeLeft {
    
    if (self.currentPage == pagesCount) {
        
        //they are on the last page and trying to go forwards so reset the page
        [self resetLevels];
        return;
    }
    
    //adjust the parallax backgrounds and levels scroll to the next or previous page based on their swipe direction
    [self xMoveActions:-(self.currentPage * self.size.width)];
    
    self.currentPage++;
}

- (void)swipeRight {
    
    if (self.currentPage == 1) {
        
        //they are on the first page and trying to go backwards so reset the page
        [self resetLevels];
        return;
    }
    
    self.currentPage--;
    
    //adjust the parallax backgrounds and levels scroll to the next or previous page based on their swipe direction
    [self xMoveActions:-((self.currentPage - 1) * self.size.width)];
}

- (void)swipeUp {
    
    if (self.currentPage == 1) {
        
        //they are on the first page and trying to go backwards so reset the page
        [self resetLevels];
        return;
    }
    
    self.currentPage--;
    
    //adjust the parallax backgrounds and levels scroll to the next or previous page based on their swipe direction
    [self yMoveActions:-((self.currentPage - 1) * self.size.height)];
}

- (void)swipeDown {
    
    if (self.currentPage == pagesCount) {
        
        //they are on the last page and trying to go forwards so reset the page
        [self resetLevels];
        return;
    }
    
    //adjust the parallax backgrounds and levels scroll to the next or previous page based on their swipe direction
    [self yMoveActions:-(self.currentPage * self.size.height)];
    
    self.currentPage++;
}

- (void)resetLevels {
    
    //just reset the levels scroller to the central position based on whatever the current page is
    if (levelsScroller.scrollDirection == HORIZONTAL)
        [self xMoveActions:-((self.currentPage - 1) * self.size.width)];
    else if (levelsScroller.scrollDirection == VERTICAL)
        [self yMoveActions:-((self.currentPage - 1) * self.size.height)];
}

- (void)xMoveActions:(int)moveTo {
    
    //this is the amount that we need to scroll the level scroller as well as the amount that we need to scroll the parallax background
    
    //parallax background moves the slowest so times the movement by a small number
    SKAction *move = [SKAction moveToX:(moveTo * 0.2) duration:0.5];
    move.timingMode = SKActionTimingEaseIn;
    [parallaxBackground runAction:move];
    
    //parallax midground moves faster so times the movement by a bigger number than the parallax background
    move = [SKAction moveToX:(moveTo * 0.3) duration:0.5];
    move.timingMode = SKActionTimingEaseIn;
    [parallaxMidground runAction:move];
    
    //duration must be the same for all 3 or it looks like the backgrounds are trying to play catch up
    move = [SKAction moveToX:moveTo duration:0.5];
    move.timingMode = SKActionTimingEaseIn;
    [levelsScroller runAction:move];
}

- (void)yMoveActions:(int)moveTo {
    
    //this is the amount that we need to scroll the level scroller as well as the amount that we need to scroll the parallax background
    
    //parallax background moves the slowest so times the movement by a small number
    SKAction *move = [SKAction moveToY:(moveTo * 0.2) duration:0.5];
    move.timingMode = SKActionTimingEaseIn;
    [parallaxBackground runAction:move];
    
    //parallax midground moves faster so times the movement by a bigger number than the parallax background
    move = [SKAction moveToY:(moveTo * 0.3) duration:0.5];
    move.timingMode = SKActionTimingEaseIn;
    [parallaxMidground runAction:move];
    
    //duration must be the same for all 3 or it looks like the backgrounds are trying to play catch up
    move = [SKAction moveToY:moveTo duration:0.5];
    move.timingMode = SKActionTimingEaseIn;
    [levelsScroller runAction:move];
}


#pragma mark - gamestate touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:_worldNode];
    switch (_gamestate) {
        case GameStateMainMenu:{
            if (location.x >= self.mainMenuPlayButton.position.x - self.mainMenuPlayButton.size.width / 2 && location.x <= self.mainMenuPlayButton.position.x + self.mainMenuPlayButton.size.width / 2 && location.y >= self.mainMenuPlayButton.position.y - self.mainMenuPlayButton.size.height / 2 &&location.y <= self.mainMenuPlayButton.position.y +self.mainMenuPlayButton.size.height /2) {
                [self.mainMenuPlayButton runAction:[self animateButton]completion:^{[self switchToChooseLevel];}];
            }
            break;
        }
        case GameStateChooseLevel:{
            initialTouch = [touch locationInView:self.view];
            moveAmtY = 0;
            moveAmtX = 0;
            
            initialPosition = levelsScroller.position;
            initialParallaxBackPosition = parallaxBackground.position;
            initialParallaxMidPosition = parallaxMidground.position;
            break;
        }
        case GameStateLevelPlay:{
            CGPoint locationOfTidyUpButton = [touch locationInNode:self];
            if (locationOfTidyUpButton.x >= -self.tidyUpButton.size.width / 2 +self.tidyUpButton.position.x&& locationOfTidyUpButton.x <= self.tidyUpButton.size.width / 2 +self.tidyUpButton.position.x&& locationOfTidyUpButton.y >= self.tidyUpButton.position.y - self.tidyUpButton.size.height / 2 && locationOfTidyUpButton.y <= +self.tidyUpButton.position.y + self.tidyUpButton.size.height /2) {
                
                if (levelMove != 1000 && [self.remainMoves.text integerValue] > 1) {
                    self.remainMoves.text = [NSString stringWithFormat:@"%d",[self.remainMoves.text integerValue]-1];
                    [self.tidyUpButton runAction:[self animateButton]];
                    [self handleMatches];
                }else if([self.remainMoves.text integerValue] == 1){
                    self.remainMoves.text = [NSString stringWithFormat:@"%d",[self.remainMoves.text integerValue]-1];
                    [self.tidyUpButton runAction:[self animateButton]];
                    [self handleMatches];
                    if (currentScore >= levelTarget) {
                        [self switchToGameOverWin];
                    }else{
                        [self switchToGameOverFailed];
                    }
                }
            }
            NSInteger column, row;
            if ([self convertPoint:location toColumn:&column row:&row]) {
                
                iAKObject *object = [self.levelObject objectAtColumn:column row:row];
                if (object != nil) {
                    self.swipeFromColumn = column;
                    self.swipeFromRow = row;
                }                
            }
            break;
        }
        case GameStateGameOverWin:{
            if (location.x >= self.levelClear.position.x - self.levelClear.size.width/2 && location.x <= self.levelClear.position.x + self.levelClear.size.width/2 && location.y >= self.levelClear.position.y - self.levelClear.size.height/2 && self.levelClear.position.y +self.levelClear.size.height/2) {
                [self.levelClear runAction:[self animateButton]];
            }else if(location.x >= self.GameStateWin_homebutton.position.x - self.GameStateWin_homebutton.size.width/2 && location.x <= self.GameStateWin_homebutton.position.x + self.GameStateWin_homebutton.size.width/2 && location.y >= self.GameStateWin_homebutton.position.y - self.GameStateWin_homebutton.size.height/2 && self.GameStateWin_homebutton.position.y +self.GameStateWin_homebutton.size.height/2){
                [self.GameStateWin_homebutton runAction:[self animateButton] completion:^{
                    [self switchToMainMenu];
                }];
            }else if(location.x >= self.GameStateWin_nextlevelButton.position.x - self.GameStateWin_nextlevelButton.size.width/2 && location.x <= self.GameStateWin_nextlevelButton.position.x + self.GameStateWin_nextlevelButton.size.width/2 && location.y >= self.GameStateWin_nextlevelButton.position.y - self.GameStateWin_nextlevelButton.size.height/2 && self.GameStateWin_nextlevelButton.position.y +self.GameStateWin_nextlevelButton.size.height/2){
                [self.GameStateWin_nextlevelButton runAction:[self animateButton]];
            }else if(location.x >= self.GameStateWin_levelChooseButton.position.x - self.GameStateWin_levelChooseButton.size.width/2 && location.x <= self.GameStateWin_levelChooseButton.position.x + self.GameStateWin_levelChooseButton.size.width/2 && location.y >= self.GameStateWin_levelChooseButton.position.y - self.GameStateWin_levelChooseButton.size.height/2 && self.GameStateWin_levelChooseButton.position.y +self.GameStateWin_levelChooseButton.size.height/2){
                [self.GameStateWin_levelChooseButton runAction:[self animateButton] completion:^{
                    [self switchToChooseLevel];
                }];
            }
            break;
        }
        case GameStateGameOverLose:{
            break;
        }
    }
   
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint movingPoint = [touch locationInView:self.view];
    switch (_gamestate) {
        case GameStateMainMenu:{
            break;
        }
        case GameStateChooseLevel:{
            
            moveAmtX = movingPoint.x - initialTouch.x;
            moveAmtY = movingPoint.y - initialTouch.y;
            
            if (levelsScroller.scrollDirection == HORIZONTAL) {
                
                //their finger is on the page and is moving around just move the scroller and parallax backgrounds around with them
                //Check if it needs to scroll to the next page when they release their finger
                levelsScroller.position = CGPointMake(initialPosition.x + moveAmtX, initialPosition.y);
                parallaxBackground.position = CGPointMake(initialParallaxBackPosition.x + moveAmtX * 0.2, initialParallaxBackPosition.y);
                parallaxMidground.position = CGPointMake(initialParallaxMidPosition.x + moveAmtX * 0.4, initialParallaxMidPosition.y);
            }
            else {
                
                //their finger is on the page and is moving around just move the scroller and parallax backgrounds around with them
                //Check if it needs to scroll to the next page when they release their finger
                levelsScroller.position = CGPointMake(initialPosition.x, initialPosition.y - moveAmtY);
                parallaxBackground.position = CGPointMake(initialParallaxBackPosition.x, initialParallaxBackPosition.y - moveAmtY * 0.2);
                parallaxMidground.position = CGPointMake(initialParallaxMidPosition.x, initialParallaxMidPosition.y - moveAmtY * 0.4);
            }
            break;
        }
        case GameStateLevelPlay:{
            // 1
            if (self.swipeFromColumn == NSNotFound) return;
            
            // 2
            UITouch *touch = [touches anyObject];
            CGPoint location = [touch locationInNode:_worldNode];
            
            NSInteger column, row;
            if ([self convertPoint:location toColumn:&column row:&row]) {
                
                // 3
                NSInteger horzDelta = 0, vertDelta = 0;
                if (column < self.swipeFromColumn) {          // swipe left
                    horzDelta = -1;
                } else if (column > self.swipeFromColumn) {   // swipe right
                    horzDelta = 1;
                } else if (row < self.swipeFromRow) {         // swipe down
                    vertDelta = -1;
                } else if (row > self.swipeFromRow) {         // swipe up
                    vertDelta = 1;
                }
                
                // 4
                if (horzDelta != 0 || vertDelta != 0) {
                    [self trySwapHorizontal:horzDelta vertical:vertDelta];
                    
                    // 5
                    self.swipeFromColumn = NSNotFound;
                }
            }
            break;
        }
        case GameStateGameOverWin:{
            break;
        }
        case GameStateGameOverLose:{
            break;
        }
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    switch (_gamestate) {
        case GameStateMainMenu:{
            break;
        }
        case GameStateChooseLevel:{
            
            if (levelsScroller.scrollDirection == HORIZONTAL) {
                
                //they havent moved far enough so just reset the page to the original position
                if (abs(moveAmtX) < minimum_detect_distance)
                    [self resetLevels];
                
                //the user has swiped past the designated distance, so assume that they want the page to scroll
                if (moveAmtX < -minimum_detect_distance)
                    [self swipeLeft];
                else if (moveAmtX > minimum_detect_distance)
                    [self swipeRight];
                
                //the scroller should never have a position higher than 0 so reset it
                if (levelsScroller.position.x > 0)
                    [self resetLevels];
            }
            else {
                
                if (abs(moveAmtY) < minimum_detect_distance)
                    [self resetLevels];
                
                //the user has swiped past the designated distance, so assume that they want the page to scroll
                if (moveAmtY < -(minimum_detect_distance))
                    [self swipeUp];
                else if (moveAmtY > minimum_detect_distance)
                    [self swipeDown];
                
                //the scroller should never have a position higher than 0 so reset it
                if (levelsScroller.position.y > 0)
                    [self resetLevels];
            }
            break;
        }
        case GameStateLevelPlay:{
            self.swipeFromColumn = self.swipeFromRow = NSNotFound;
            self.currentScore.text = [NSString stringWithFormat:@"%d",currentScore];
            break;
        }
        case GameStateGameOverWin:{
            break;
        }
        case GameStateGameOverLose:{
            break;
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    switch (_gamestate) {
        case GameStateMainMenu:
            break;
        case GameStateChooseLevel:
            break;
        case GameStateLevelPlay:{
            [self touchesEnded:touches withEvent:event];
            break;
        }
        case GameStateGameOverWin:{
            break;
        }
        case GameStateGameOverLose:{
            break;
        }
    }
   
}

#pragma mark - gamestate updates
-(void)update:(CFTimeInterval)currentTime {
    switch (_gamestate) {
        case GameStateMainMenu:
            break;
        case GameStateChooseLevel:
            break;
        case GameStateLevelPlay:{
            break;
        }
        case GameStateGameOverWin:{
            SKAction *rotate = [SKAction rotateByAngle:0.01 duration:5.0];
            [self.jingxiang runAction:rotate];
            break;
        }
        case GameStateGameOverLose:{
            break;
        }
    }
}

#pragma mark - gamestate switches
-(void)switchToMainMenu{
    _gamestate = GameStateMainMenu;
    SKScene *newScene = [[iAKMyScene alloc]initWithSize:self.size state:_gamestate];
    SKTransition *transition = [SKTransition fadeWithColor:[UIColor blackColor] duration:0.5];
    [self.view presentScene:newScene transition:transition];

}

-(void)switchToGameOverWin{
    _gamestate = GameStateGameOverWin;
    self.GameStateWin_homebutton = [[SKSpriteNode alloc]initWithImageNamed:@"homeButton"];
    self.GameStateWin_homebutton.anchorPoint = CGPointMake(0.5, 0.5);
    self.GameStateWin_homebutton.position = CGPointMake(self.size.width*0.3, self.size.height*0.4);
    self.GameStateWin_homebutton.zPosition = LayerZero;
    self.GameStateWin_homebutton.alpha = 0.0;
    [_worldNode addChild:self.GameStateWin_homebutton];
    
    self.GameStateWin_nextlevelButton = [[SKSpriteNode alloc]initWithImageNamed:@"nextLevelButton"];
    self.GameStateWin_nextlevelButton.anchorPoint = CGPointMake(0.5, 0.5);
    self.GameStateWin_nextlevelButton.position = CGPointMake(self.size.width*0.7, self.size.height*0.4);
    self.GameStateWin_nextlevelButton.zPosition = LayerZero;
    self.GameStateWin_nextlevelButton.alpha = 0.0;
    [_worldNode addChild:self.GameStateWin_nextlevelButton];
    
    self.GameStateWin_levelChooseButton = [[SKSpriteNode alloc]initWithImageNamed:@"levelChooseButton"];
    self.GameStateWin_levelChooseButton.anchorPoint = CGPointMake(0.5, 0.5);
    self.GameStateWin_levelChooseButton.position = CGPointMake(self.size.width*0.5, self.size.height*0.4);
    self.GameStateWin_levelChooseButton.zPosition = LayerZero;
    self.GameStateWin_levelChooseButton.alpha = 0.0;
    [_worldNode addChild:self.GameStateWin_levelChooseButton];
    
    self.jingxiang = [[SKSpriteNode alloc]initWithImageNamed:@"jingxiang"];
    self.jingxiang.anchorPoint = CGPointMake(0.5, 0.5);
    self.jingxiang.position = CGPointMake(self.size.width/2, self.size.height/2);
    self.jingxiang.zPosition = LayerButtons;
    self.jingxiang.alpha = 0.0;
    [_worldNode addChild:self.jingxiang];
    
    self.box = [[SKSpriteNode alloc]initWithImageNamed:@"box"];
    self.box.zPosition = LayerThree;
    self.box.anchorPoint = CGPointMake(0.5, 0.5);
    self.box.position = CGPointMake(self.size.width/2, self.size.height * 0.3);
    self.box.alpha = 0.0;
    [_worldNode addChild:self.box];
    
    self.box_frontboard = [[SKSpriteNode alloc]initWithImageNamed:@"box-frontboard"];
    self.box_frontboard.zPosition = LayerOne;
    self.box_frontboard.anchorPoint = CGPointMake(0.5, 0.5);
    self.box_frontboard.position = CGPointMake(self.size.width/2, self.size.height * 0.3);
    self.box_frontboard.alpha = 0.0;
    [_worldNode addChild:self.box_frontboard];
    
    
    self.levelClear = [[SKSpriteNode alloc]initWithImageNamed:@"levelClear"];
    self.levelClear.zPosition = LayerTwo;
    self.levelClear.anchorPoint = CGPointMake(0.5, 0.5);
    self.levelClear.position = self.box.position;
    self.levelClear.alpha = 0.0;
    [_worldNode addChild:self.levelClear];
    
    
    CGPoint levelClearPosition = CGPointMake(self.size.width/2, self.size.height * 0.7);
    SKAction *smallSize = [SKAction scaleBy:0 duration:0];
    SKAction *show = [SKAction scaleTo:1 duration:1];
    show.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *move = [SKAction moveTo:levelClearPosition duration:1];
    move.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *fadeIn = [SKAction fadeInWithDuration:1.0];
    
    [self.box runAction:fadeIn completion:^{[self.box runAction:[self animateButton]];}];
    [self.box_frontboard runAction:fadeIn completion:^{[self.box_frontboard runAction:[self animateButton]];
            [self.jingxiang runAction:fadeIn];
            [self.levelClear runAction:smallSize completion:^{
                [self.levelClear runAction:fadeIn];
                [self.levelClear runAction:show];
                [self.levelClear runAction:move];
                [self.GameStateWin_homebutton runAction:fadeIn];
                [self.GameStateWin_nextlevelButton runAction:fadeIn];
                [self.GameStateWin_levelChooseButton runAction:fadeIn];
            }];
    }];
}

-(void)switchToGameOverFailed{
    NSLog(@"FAILED");
}

-(void)switchToLevelPlay:(int)level{
    _gamestate = GameStateLevelPlay;
    currentLevel = level;
    SKScene *newScene = [[iAKMyScene alloc]initWithSize:self.size state:GameStateLevelPlay];
    SKTransition *transition = [SKTransition fadeWithColor:[UIColor blackColor] duration:0];
    [self.view presentScene:newScene transition:transition];
    
}

-(void)switchToChooseLevel{
    _gamestate = GameStateChooseLevel;
    SKScene *newScene = [[iAKMyScene alloc]initWithSize:self.size state:_gamestate];
    SKTransition *transition = [SKTransition fadeWithColor:[UIColor blackColor] duration:0.3];
    [self.view presentScene:newScene transition:transition];
}

#pragma mark - Animations

-(SKAction *)animateButton{
    SKAction *squish = [SKAction scaleXTo:1.2 y:0.8 duration:0.1];
    squish.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *moveDownSquish = [SKAction moveByX:0.0 y:10 duration:0.2];
    moveDownSquish.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction *grow = [SKAction scaleXTo:0.8 y:1.2 duration:0.2];
    grow.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction *normal = [SKAction scaleXTo:1.0 y:1.0 duration:0.2];
    normal.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *moveUpNormal = [SKAction moveByX:0.0 y:-10 duration:0.2];
    moveUpNormal.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction *groupSquish = [SKAction group:@[squish]];
    SKAction *groupGrow = [SKAction group:@[moveDownSquish, grow]];
    SKAction *groupNormal = [SKAction group:@[normal, moveUpNormal]];
    
    SKAction *sequence = [SKAction sequence:@[groupSquish, groupGrow, groupNormal]];
    return sequence;
}

- (void)animateNewObjects:(NSArray *)columns completion:(dispatch_block_t)completion {
    // 1
    __block NSTimeInterval longestDuration = 0;
    
    for (NSArray *array in columns) {
        
        // 2
        NSInteger startRow = ((iAKObject *)[array firstObject]).row + 1;
        
        [array enumerateObjectsUsingBlock:^(iAKObject *object, NSUInteger idx, BOOL *stop) {
            
            // 3
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[object spriteName]];
            sprite.position = [self pointForColumn:object.column row:startRow];
            sprite.zPosition = LayerObject;
            [_worldNode addChild:sprite];
            object.sprite = sprite;
            
            // 4
            NSTimeInterval delay = 0.2*([array count] - idx - 1);
            
            // 5
            NSTimeInterval duration = (startRow - object.row) * 0.1;
            longestDuration = MAX(longestDuration, duration + delay);
            
            // 6
            CGPoint newPosition = [self pointForColumn:object.column row:object.row];
            SKAction *moveAction = [SKAction moveTo:newPosition duration:duration];
            moveAction.timingMode = SKActionTimingEaseOut;
            object.sprite.alpha = 0;
            [object.sprite runAction:[SKAction sequence:@[
                                                          [SKAction waitForDuration:delay],
                                                          [SKAction group:@[
                                                                            [SKAction fadeInWithDuration:0.05], moveAction]]]]];
        }];
    }
    
    // 7
    [self runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:longestDuration],
                                         [SKAction runBlock:completion]
                                         ]]];
}

- (void)animateFallingObjects:(NSArray *)columns completion:(dispatch_block_t)completion {
    // 1
    __block NSTimeInterval longestDuration = 0;
    
    for (NSArray *array in columns) {
        [array enumerateObjectsUsingBlock:^(iAKObject *object, NSUInteger idx, BOOL *stop) {
            CGPoint newPosition = [self pointForColumn:object.column row:object.row];
            
            // 2
            NSTimeInterval delay = 0.05 + 0.15*idx;
            
            // 3
            NSTimeInterval duration = ((object.sprite.position.y - newPosition.y) / TileHeight) * 0.1;
            
            // 4
            longestDuration = MAX(longestDuration, duration + delay);
            
            // 5
            SKAction *moveAction = [SKAction moveTo:newPosition duration:duration];
            moveAction.timingMode = SKActionTimingEaseOut;
            [object.sprite runAction:[SKAction sequence:@[
                                                          [SKAction waitForDuration:delay],
                                                          [SKAction group:@[moveAction]]]]];
        }];
    }
    
    // 6
    [self runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:longestDuration],
                                         [SKAction runBlock:completion]
                                         ]]];
}

- (void)animateMatchedObjects:(NSSet *)chains completion:(dispatch_block_t)completion {
    
    for (iAKChain *chain in chains) {
        for (iAKObject *object in chain.objects) {
            
            // 1
            if (object.sprite != nil) {
                
                // 2
                SKAction *scaleAction = [SKAction scaleTo:0.1 duration:0.3];
                scaleAction.timingMode = SKActionTimingEaseOut;
                [object.sprite runAction:[SKAction sequence:@[scaleAction, [SKAction removeFromParent]]]];
                
                // 3
                object.sprite = nil;
            }
        }
    }
    // 4
    [self runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:0.3],
                                         [SKAction runBlock:completion]
                                         ]]];
}

- (void)animateInvalidSwap:(iAKSwap *)swap completion:(dispatch_block_t)completion {
    swap.objectA.sprite.zPosition = LayerObject1;
    swap.objectB.sprite.zPosition = LayerObject;
    
    const NSTimeInterval Duration = 0.2;
    
    SKAction *moveA = [SKAction moveTo:swap.objectB.sprite.position duration:Duration];
    moveA.timingMode = SKActionTimingEaseOut;
    
    SKAction *moveB = [SKAction moveTo:swap.objectA.sprite.position duration:Duration];
    moveB.timingMode = SKActionTimingEaseOut;
    
    [swap.objectA.sprite runAction:[SKAction sequence:@[moveA, moveB, [SKAction runBlock:completion]]]];
    [swap.objectB.sprite runAction:[SKAction sequence:@[moveB, moveA]]];
}

- (void)animateSwap:(iAKSwap *)swap completion:(dispatch_block_t)completion {
    swap.objectA.sprite.zPosition = LayerObject1;
    swap.objectB.sprite.zPosition = LayerObject;
    
    const NSTimeInterval Duration = 0.3;
    
    SKAction *moveA = [SKAction moveTo:swap.objectB.sprite.position duration:Duration];
    moveA.timingMode = SKActionTimingEaseOut;
    [swap.objectA.sprite runAction:[SKAction sequence:@[moveA, [SKAction runBlock:completion]]]];
    
    SKAction *moveB = [SKAction moveTo:swap.objectA.sprite.position duration:Duration];
    moveB.timingMode = SKActionTimingEaseOut;
    [swap.objectB.sprite runAction:moveB];
}

- (SKAction *)animationObject:(NSString *)object fromAtlas:(SKTextureAtlas *)atlas start:(int)start finish:(int)finish withFrameRate:(float)framesOverOneSecond {
    
    NSMutableArray *animFrames = [NSMutableArray array];
    
    for (int x = start; x <= finish; x++)
        [animFrames addObject:[atlas textureNamed:[NSString stringWithFormat:@"anim_%@_%d.png", object, x]]];
    
    if (framesOverOneSecond == 0)
        framesOverOneSecond = 1.0 / (float)animFrames.count;
    else
        framesOverOneSecond = framesOverOneSecond / (float)animFrames.count;
    
    return [SKAction animateWithTextures:animFrames timePerFrame:framesOverOneSecond resize:YES restore:YES];
}

#pragma mark - Level methods

- (void)levelSelected:(NSInteger)level {
    
    NSDictionary *tempLevel = [gameModel.levels valueForKey:[NSString stringWithFormat:@"%02d", level]];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userLevelData = [[NSMutableDictionary alloc] initWithDictionary:[defaults dictionaryForKey:[tempLevel objectForKey:@"LevelTitle"]]];
    
    BOOL levelLocked = (level == 1 ? NO : ![[userLevelData objectForKey:@"unlocked"] boolValue]);
    
    //    self.levelNumber = [[tempLevel objectForKey:@"levelNumber"] intValue];
    //    self.levelType = [[tempLevel objectForKey:@"levelType"] intValue];
    //    self.levelRows = [[tempLevel objectForKey:@"levelRows"] intValue];
    //    self.levelCols = [[tempLevel objectForKey:@"levelCols"] intValue];
    
    [self switchToLevelPlay:level];
}

#pragma mark - play methods
-(void)addSpritesForObjects:(NSSet *)objects{
    for (iAKObject *object in objects) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[object spriteName]];
        sprite.position = [self pointForColumn:object.column row:object.row];
        sprite.zPosition = LayerObject;
        [_worldNode addChild:sprite];
        object.sprite = sprite;
    }
}

-(void)addTiles{
    for (NSInteger row = 0; row < NumRows; row ++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            if ([self.levelObject tileAtColumn:column row:row]!= nil) {
                SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithImageNamed:@"Tile@2x.png"];
                tileNode.position = [self pointForColumn:column row:row];
                tileNode.zPosition = LayerGame;
                [_worldNode addChild:tileNode];
            }
        }
    }
}

-(CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row{
    return CGPointMake((column-4) * TileWidth + self.size.width/2, (row-4) * TileHeight  +self.size.height/2);
}

-(void)beginGame{
    [self shuffle];
}

-(void)shuffle{
    newObjects = [self.levelObject shuffle];
    [self addSpritesForObjects:newObjects];
}

- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row {
    NSParameterAssert(column);
    NSParameterAssert(row);
    
    // Is this a valid location within the cookies layer? If yes,
    // calculate the corresponding row and column numbers.
    if (point.x >= self.size.width/2-4.5*TileWidth && point.x <  self.size.width/2+4.5*TileWidth &&
        point.y >=  self.size.height/2-4.5*TileHeight && point.y < self.size.height/2+4.5*TileHeight) {
        *column = (point.x - self.size.width/2 + 4.5*TileWidth)/TileWidth;
        *row = (point.y -self.size.height/2 + 4.5*TileHeight)/TileHeight;
        return YES;
        
    } else {
        *column = NSNotFound;  // invalid location
        *row = NSNotFound;
        return NO;
    }
}

- (void)handleMatches {
    NSSet *chains = [self.levelObject removeMatches];
    [self animateMatchedObjects:chains completion:^{
        NSArray *columns = [self.levelObject fillHoles];
        [self animateFallingObjects:columns completion:^{
            NSArray *columns = [self.levelObject topUpObjects];
            [self animateNewObjects:columns completion:^{
                self.view.userInteractionEnabled = YES;
            }];
        }];
    }];
}

@end
