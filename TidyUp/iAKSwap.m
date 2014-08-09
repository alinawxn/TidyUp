//
//  iAKSwap.m
//  tidyUp
//
//  Created by Xiaonan Wang on 7/30/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import "iAKSwap.h"

@implementation iAKSwap

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ swap %@ with %@", [super description], self.objectA, self.objectB];
}

- (BOOL)isEqual:(id)object {
    // You can only compare this object against other RWTSwap objects.
    if (![object isKindOfClass:[iAKSwap class]]) return NO;
    
    // Two swaps are equal if they contain the same cookie, but it doesn't
    // matter whether they're called A in one and B in the other.
    iAKSwap *other = (iAKSwap *)object;
    return (other.objectA == self.objectA && other.objectB == self.objectB) ||
    (other.objectB == self.objectA && other.objectA == self.objectB);
}

- (NSUInteger)hash {
    return [self.objectA hash] ^ [self.objectB hash];
}

@end
