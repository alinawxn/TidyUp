//
//  iAKLevelGrid.m
//  TidyUp
//
//  Created by Xiaonan Wang on 8/3/14.
//  Copyright (c) 2014 iAKTU. All rights reserved.
//

#import "iAKLevelGrid.h"
#import "iAKLevelButton.h"
#import "iAKGameModel.h"
#import "iAKLevel.h"
#import "iAKGameConfig.h"

#pragma mark - MenuLevel private Interface
extern iAKGameModel *gameModel;

@interface iAKLevelGrid() {
    int iconWidth, iconheight, gridPadding, gridCols, gridRows;
}

@property (nonatomic, readonly) CGSize gridSize;

@end

@implementation iAKLevelGrid

@synthesize backgroundFileName, gridSize, size, levels;

- (instancetype)initWithWorld:(iAKWorld *)world  {
    
    if (self = [super init]) {
        
        gameModel = [iAKGameModel sharedManager];
        levels = [[NSMutableArray alloc] init];
        
        // default values
        backgroundFileName = @"button";
        iconWidth = 103.0f;
        iconheight = 120.0f;
        gridPadding = 10;
        gridCols = 4;
        
        self.anchorPoint = CGPointMake(0.5, 0.5);
        
        levels = [self filterLevelsByWorld:world];
        
        gridRows = abs(levels.count / gridCols);
        self.size = CGSizeMake(gridCols * (gridPadding + iconWidth) - gridPadding, gridRows * (gridPadding + iconheight) - gridPadding);
        
        [self createGrid];
        
        SKLabelNode *pageLabel = [SKLabelNode labelNodeWithFontNamed:kLevelFontName];
        pageLabel.position = CGPointMake(self.size.width / 2, self.size.height + 20);
        pageLabel.fontColor = [SKColor whiteColor];
        pageLabel.text = world.title;
        [self addChild:pageLabel];
    }
    
    return self;
}

- (NSArray *)filterLevelsByWorld:(iAKWorld *)world {
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    for (id levelKey in gameModel.levels) {
        
        NSDictionary *tempLevel = [gameModel.levels objectForKey:levelKey];
        
        int worldID = [[tempLevel objectForKey:@"WorldID"] intValue];
        
        if (worldID == world.worldID)
            [temp addObject:tempLevel];
    }
    
    //sort the worlds plist by worldID
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"LevelID" ascending:YES];
    return [temp sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}

- (void)createGrid  {
    
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
    int x = 0;
    
    for (int row = 0; row < gridRows; row++) {
        
        for (int col = 0; col < gridCols; col++) {
            
            int position = row * gridCols + col;
            
            NSDictionary *tempLevel = levels[position];
            //int menuItem = (col + 1 + (row * gridCols));
            
            NSString *levelTitle = [tempLevel objectForKey:@"LevelTitle"];
            int levelID = [[tempLevel objectForKey:@"LevelID"] intValue];
            
            NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            NSString *plistPath = [paths objectAtIndex:0];
            
            NSString *filename=[plistPath stringByAppendingPathComponent:@"LevelLocked.plist"];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithContentsOfFile:filename];
            
            if (!dic) {
                NSLog(@"dic not found");
            }
            
            
            BOOL levelLocked = [[dic objectForKey:[NSString stringWithFormat:@"%02d",levelID]]boolValue];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *userLevelData = [[NSMutableDictionary alloc] initWithDictionary:[defaults dictionaryForKey:levelTitle]];
            
            NSInteger starsCollected = [[userLevelData objectForKey:@"highStarsCollected"] integerValue];
            
            [self createMenuItem:levelID position:CGPointMake(col * (iconWidth + (col == 0 ? 0 : gridPadding)) + (iconWidth / 2), (gridRows - row) * iconheight + ((gridRows - row - 1) * gridPadding) - (iconheight / 2)) life:starsCollected locked:levelLocked];
            
            x++;
        }
    }
}

- (iAKLevelButton *)createMenuItem:(NSInteger)level position:(CGPoint)position life:(NSInteger)life locked:(BOOL)locked {
    
    // create button with background
    iAKLevelButton *item = [[iAKLevelButton alloc] initWithImageNamed:@"button"];
    // settings
    [self setMenuItem:item Level:level andImage:backgroundFileName position:position life:life locked:locked];
    
    return item;
}

#pragma mark MenuLevel Private Methods

- (void)setMenuItem:(iAKLevelButton *)item Level:(NSInteger)level andImage:(NSString *)bgImage position:(CGPoint)position life:(NSInteger)life locked:(BOOL)locked {
    
    item.position = position;
    item.name = @"level";
    [self addChild:item];
    
    item.name = [NSString stringWithFormat:@"%d", level];
    
    [item setBackgroundImage:bgImage];
    
    [item setLevelText:[NSString stringWithFormat:@"%d", level]];
    
    [item setLocked:locked];
    
    [item setLevelStars:life];
}

@end
