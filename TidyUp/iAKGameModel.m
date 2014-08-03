//
//  iAKGameModel.m
//  TidyUp
//
//  Created by Xiaonan Wang on 8/3/14.
//  Copyright (c) 2014 iAKTU. All rights reserved.
//

#import "iAKGameModel.h"

static iAKGameModel *sharedManager;

@implementation iAKGameModel

@synthesize levels, worlds;

+ (iAKGameModel *)sharedManager {
    
	static dispatch_once_t done;
	dispatch_once(&done, ^{ sharedManager = [[iAKGameModel alloc] init]; });
    
	return sharedManager;
}

- (id) init {
    
    self = [super init];
    
    if (self) {
        
        self.squareSize = 110.0f;
        self.tileSize = 100.0f;
        
        [self loadLevels];
    }
    
    return self;
}

- (void)loadLevels {
    
    NSString *levelsPath = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
    levels = [NSMutableDictionary dictionaryWithContentsOfFile:levelsPath];
    
    
    //sort the worlds plist by worldID
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"WorldID" ascending:YES];
    worlds = [[NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Worlds" ofType:@"plist"]] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}

@end
