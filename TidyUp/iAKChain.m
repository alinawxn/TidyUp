//
//  iAKChain.m
//  tidyUp
//
//  Created by Xiaonan Wang on 7/31/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import "iAKChain.h"

@implementation iAKChain {
    NSMutableArray *_objects;
}

- (void)addObject:(iAKObject *)object{
    if (_objects == nil) {
        _objects = [NSMutableArray array];
    }
    [_objects addObject:object];
}

- (NSArray *)objects{
    return _objects;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld objects:%@", (long)self.chainType, self.objects];
}

@end
