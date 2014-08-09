//
//  iAKChain.h
//  tidyUp
//
//  Created by Xiaonan Wang on 7/31/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iAKObject.h"

typedef NS_ENUM(NSUInteger, ChainType) {
    ChainTypeHorizontal,
    ChainTypeVertical,
};

@interface iAKChain : NSObject

@property (strong, nonatomic, readonly) NSArray *objects;

@property (assign, nonatomic) ChainType chainType;

- (void)addObject:(iAKObject *)object;

@end
