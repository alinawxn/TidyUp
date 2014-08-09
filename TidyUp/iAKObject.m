//
//  iAKObject.m
//  tidyUp
//
//  Created by Xiaonan Wang on 7/29/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import "iAKObject.h"

@implementation iAKObject

- (NSString *)spriteName {
    static NSString * const spriteNames[] = {
        @"Croissant@2x",
        @"Cupcake@2x",
        @"Danish@2x",
        @"Donut@2x",
        @"Macaroon@2x",
        @"SugarCookie@2x",
    };
    
    return spriteNames[self.objectType - 1];
}

- (NSString *)highlightedSpriteName {
    static NSString * const highlightedSpriteNames[] = {
        @"Croissant-Highlighted@2x",
        @"Cupcake-Highlighted@2x",
        @"Danish-Highlighted@2x",
        @"Donut-Highlighted@2x",
        @"Macaroon-Highlighted@2x",
        @"SugarCookie-Highlighted@2x",
    };
    
    return highlightedSpriteNames[self.objectType - 1];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld square:(%ld,%ld)", (long)self.objectType,
            (long)self.column, (long)self.row];
}

@end
