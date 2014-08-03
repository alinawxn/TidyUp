//
//  iAKLevelScroller.m
//  TidyUp
//
//  Created by Xiaonan Wang on 8/3/14.
//  Copyright (c) 2014 iAKTU. All rights reserved.
//

#import "iAKLevelScroller.h"

@implementation iAKLevelScroller

- (iAKLevelScroller *)initWithSize:(CGSize)size {
    
    if (self = [super initWithColor:[SKColor clearColor] size:size]) {
        
        self.size = size;
        self.name = @"levelsScroller";
        
    }
    
    return self;
}

@end

