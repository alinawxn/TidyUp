//
//  iAKLevel.m
//  TidyUp
//
//  Created by Xiaonan Wang on 8/3/14.
//  Copyright (c) 2014 iAKTU. All rights reserved.
//


#import "iAKLevel.h"
#import "iAKGameModel.h"

extern iAKGameModel *gameModel;

@interface iAKLevel () {
}

@end

@implementation iAKLevel

@synthesize levelTitle, levelID, worldID, levelType;

- (id)initWithLevelID:(NSInteger)_levelID {
    
    self = [super init];
    
    if (self) {
        
        gameModel = [iAKGameModel sharedManager];
        
        levelTitle = [NSString stringWithFormat:@"Level %d", _levelID];
        
        NSDictionary *tempLevel = [gameModel.levels valueForKey:levelTitle];
        
        levelID = [[tempLevel objectForKey:@"levelID"] intValue];
        levelType = [[tempLevel objectForKey:@"levelType"] intValue];
        worldID = [[tempLevel objectForKey:@"LevelGroupNumber"] intValue];
        self.levelTargetScore = [tempLevel objectForKey:@"levelTargetScore"];
    }
    
    return self;
}

@end
