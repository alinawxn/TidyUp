//
//  iAKGameModel.h
//  TidyUp
//
//  Created by Xiaonan Wang on 8/3/14.
//  Copyright (c) 2014 iAKTU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iAKGameModel : NSObject{
    
    UIViewController *parent;
}

@property (strong, nonatomic) NSMutableDictionary *levels;
@property (strong, nonatomic) NSArray *worlds;
@property (strong, nonatomic) NSArray *worldKeys;
@property (nonatomic) int tileSize;
@property (nonatomic) int squareSize;

+ (iAKGameModel *)sharedManager;

- (void)loadLevels;



@end
