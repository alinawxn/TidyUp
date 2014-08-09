//
//  iAKLevelObject.h
//  tidyUp
//
//  Created by Xiaonan Wang on 8/3/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "iAKObject.h"
#import "iAKTile.h"
#import "iAKSwap.h"
#import "iAKChain.h"


static const NSInteger NumColumns = 9;
static const NSInteger NumRows = 9;

@interface iAKLevelObject : NSObject

@property NSMutableSet *set;

- (NSSet *)shuffle;
- (iAKObject *)objectAtColumn:(NSInteger)column row:(NSInteger)row;
- (instancetype)initWithFile:(NSString *)filename;
- (iAKTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row;

- (void)performSwap:(iAKSwap *)swap;
- (BOOL)isPossibleSwap:(iAKSwap *)swap;
- (void)detectPossibleSwaps;

- (NSSet *)removeMatches;
- (NSArray *)fillHoles;
- (NSArray *)topUpObjects;

@end

