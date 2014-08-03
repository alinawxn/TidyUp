//
//  iAKLevel.h
//  TidyUp
//
//  Created by Xiaonan Wang on 8/3/14.
//  Copyright (c) 2014 iAKTU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iAKLevel : NSObject

@property (nonatomic, strong) NSString *levelTitle;
@property (nonatomic) int levelID;
@property (nonatomic) int levelType;
@property (nonatomic) int worldID;
@property (nonatomic, strong) NSArray *levelTargetScore;

- (id)initWithLevelID:(NSInteger)levelID;

@end