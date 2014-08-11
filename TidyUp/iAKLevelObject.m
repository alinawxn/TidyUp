//
//  iAKLevelObject.m
//  tidyUp
//
//  Created by Xiaonan Wang on 8/3/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import "iAKLevelObject.h"

extern NSInteger currentScore,levelTarget, levelTime, levelMove, levelLocked;

@interface iAKLevelObject ()

@property (strong, nonatomic) NSSet *possibleSwaps;

@end

@implementation iAKLevelObject{
    iAKObject *_objects[NumColumns][NumRows];
    iAKTile *_tiles[NumColumns][NumRows];
}
@synthesize set = _set;

#pragma mark - load
//load a JSON file
- (NSDictionary *)loadJSON:(NSString *)filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    if (path == nil) {
        NSLog(@"Could not find level file: %@", filename);
        return nil;
    }
    
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
    if (data == nil) {
        NSLog(@"Could not load level file: %@, error: %@", filename, error);
        return nil;
    }
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Level file '%@' is not valid JSON: %@", filename, error);
        return nil;
    }
    
    return dictionary;
}

- (instancetype)initWithFile:(NSString *)filename {
    self = [super init];
    if (self != nil) {
        NSDictionary *dictionary = [self loadJSON:filename];
        
        // Loop through the rows
        [dictionary[@"tiles"] enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger row, BOOL *stop) {
            
            // Loop through the columns in the current row
            [array enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger column, BOOL *stop) {
                
                // Note: In Sprite Kit (0,0) is at the bottom of the screen,
                // so we need to read this file upside down.
                NSInteger tileRow = NumRows - row - 1;
                
                // If the value is 1, create a tile object.
                if ([value integerValue] == 1) {
                    _tiles[column][tileRow] = [[iAKTile alloc] init];
                }
            }];
        }];
        levelTarget = [dictionary[@"targetScore"] integerValue];
        levelMove = [dictionary[@"moves"] integerValue];
        levelTime = [dictionary[@"time"] integerValue];
    }
    return self;
}

- (iAKTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row {
    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
    
    return _tiles[column][row];
}

#pragma mark - create new objects
//
- (iAKObject *)objectAtColumn:(NSInteger)column row:(NSInteger)row {
    return _objects[column][row];
}

- (NSSet *)createInitialObjects {
    NSMutableSet *set = [NSMutableSet set];
    
    // 1
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            
            if (_tiles[column][row] != nil) {
                
                // 2
                NSUInteger objectType;
                do {
                    objectType = arc4random_uniform(NumObjectTypes) + 1;
                }
                while ((column >= 2 &&
                        _objects[column - 1][row].objectType == objectType &&
                        _objects[column - 2][row].objectType == objectType)
                       ||
                       (row >= 2 &&
                        _objects[column][row - 1].objectType == objectType &&
                        _objects[column][row - 2].objectType == objectType));
                
                // 3
                iAKObject *object = [self createObjectAtColumn:column row:row withType:objectType];
                
                // 4
                [set addObject:object];
            }
            
        }
    }
    return set;
}

- (iAKObject *)createObjectAtColumn:(NSInteger)column row:(NSInteger)row withType:(NSUInteger)objectType {
    iAKObject *object = [[iAKObject alloc] init];
    object.objectType = objectType;
    object.column = column;
    object.row = row;
    _objects[column][row] = object;
    return object;
}

#pragma mark - detect possible swaps

- (NSSet *)shuffle {
    NSSet *set;
    do {
        set = [self createInitialObjects];
        
        [self detectPossibleSwaps];
        
        //NSLog(@"possible swaps: %@", self.possibleSwaps);
    }
    while ([self.possibleSwaps count] == 0);
    
    return set;
}

- (void)detectPossibleSwaps {
    self.set = [NSMutableSet set];
    
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            
            iAKObject *object = _objects[column][row];
            if (object != nil) {
                
                // TODO: detection logic goes here
                // Is it possible to swap this cookie with the one on the right?
                if (column < NumColumns - 1) {
                    // Have a cookie in this spot? If there is no tile, there is no cookie.
                    iAKObject *other = _objects[column + 1][row];
                    if (other != nil) {
                        // Swap them
                        _objects[column][row] = other;
                        _objects[column + 1][row] = object;
                        
                        // Is either cookie now part of a chain?
                        if ([self hasChainAtColumn:column + 1 row:row] ||
                            [self hasChainAtColumn:column row:row]) {
                            
                            iAKSwap *swap = [[iAKSwap alloc] init];
                            swap.objectA = object;
                            swap.objectB = other;
                            [self.set addObject:swap];
                        }
                        
                        // Swap them back
                        _objects[column][row] = object;
                        _objects[column + 1][row] = other;
                    }
                }
                
                
                if (row < NumRows - 1) {
                    
                    iAKObject *other = _objects[column][row + 1];
                    if (other != nil) {
                        // Swap them
                        _objects[column][row] = other;
                        _objects[column][row + 1] = object;
                        
                        if ([self hasChainAtColumn:column row:row + 1] ||
                            [self hasChainAtColumn:column row:row]) {
                            
                            iAKSwap *swap = [[iAKSwap alloc] init];
                            swap.objectA = object;
                            swap.objectB = other;
                            [self.set addObject:swap];
                        }
                        
                        _objects[column][row] = object;
                        _objects[column][row + 1] = other;
                    }
                }
            }
        }
    }
    
    self.possibleSwaps = self.set;
}

- (BOOL)hasChainAtColumn:(NSInteger)column row:(NSInteger)row {
    NSUInteger objectType = _objects[column][row].objectType;
    
    NSUInteger horzLength = 1;
    for (NSInteger i = column - 1; i >= 0 && _objects[i][row].objectType == objectType; i--, horzLength++) ;
    for (NSInteger i = column + 1; i < NumColumns && _objects[i][row].objectType == objectType; i++, horzLength++) ;
    if (horzLength >= 3) return YES;
    
    NSUInteger vertLength = 1;
    for (NSInteger i = row - 1; i >= 0 && _objects[column][i].objectType == objectType; i--, vertLength++) ;
    for (NSInteger i = row + 1; i < NumRows && _objects[column][i].objectType == objectType; i++, vertLength++) ;
    return (vertLength >= 3);
}


#pragma mark - Swap
- (BOOL)isPossibleSwap:(iAKSwap *)swap {
    return [self.possibleSwaps containsObject:swap];
}

- (void)performSwap:(iAKSwap *)swap {
    NSInteger columnA = swap.objectA.column;
    NSInteger rowA = swap.objectA.row;
    NSInteger columnB = swap.objectB.column;
    NSInteger rowB = swap.objectB.row;
    
    _objects[columnA][rowA] = swap.objectB;
    swap.objectB.column = columnA;
    swap.objectB.row = rowA;
    
    _objects[columnB][rowB] = swap.objectA;
    swap.objectA.column = columnB;
    swap.objectA.row = rowB;
}

#pragma mark - find chain

- (NSSet *)detectHorizontalMatches {
    // 1
    NSMutableSet *set = [NSMutableSet set];
    
    // 2
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns - 2; ) {
            
            // 3
            if (_objects[column][row] != nil) {
                NSUInteger matchType = _objects[column][row].objectType;
                
                // 4
                if (_objects[column + 1][row].objectType == matchType
                    && _objects[column + 2][row].objectType == matchType) {
                    // 5
                    iAKChain *chain = [[iAKChain alloc] init];
                    chain.chainType = ChainTypeHorizontal;
                    do {
                        [chain addObject:_objects[column][row]];
                        column += 1;
                    }
                    while (column < NumColumns && _objects[column][row].objectType == matchType);
                    
                    [set addObject:chain];
                    continue;
                }
            }
            
            // 6
            column += 1;
        }
    }
    return set;
}

- (NSSet *)detectVerticalMatches {
    NSMutableSet *set = [NSMutableSet set];
    
    for (NSInteger column = 0; column < NumColumns; column++) {
        for (NSInteger row = 0; row < NumRows - 2; ) {
            if (_objects[column][row] != nil) {
                NSUInteger matchType = _objects[column][row].objectType;
                
                if (_objects[column][row + 1].objectType == matchType
                    && _objects[column][row + 2].objectType == matchType) {
                    
                    iAKChain *chain = [[iAKChain alloc] init];
                    chain.chainType = ChainTypeVertical;
                    do {
                        [chain addObject:_objects[column][row]];
                        row += 1;
                    }
                    while (row < NumRows && _objects[column][row].objectType == matchType);
                    
                    [set addObject:chain];
                    continue;
                }
            }
            row += 1;
        }
    }
    return set;
}

- (NSSet *)removeMatches {
    NSSet *horizontalChains = [self detectHorizontalMatches];
    NSSet *verticalChains = [self detectVerticalMatches];
    
    [self removeObjects:horizontalChains];
    [self removeObjects:verticalChains];
    
    return [horizontalChains setByAddingObjectsFromSet:verticalChains];
}

- (void)removeObjects:(NSSet *)chains {
    int individualScore = 30;
    for (iAKChain *chain in chains) {
        for (iAKObject *object in chain.objects) {
            _objects[object.column][object.row] = nil;
            currentScore = currentScore + individualScore;
            individualScore = individualScore + 10;
        }
    }
}

- (NSArray *)fillHoles {
    NSMutableArray *columns = [NSMutableArray array];
    
    // 1
    for (NSInteger column = 0; column < NumColumns; column++) {
        
        NSMutableArray *array;
        for (NSInteger row = 0; row < NumRows; row++) {
            
            // 2
            if (_tiles[column][row] != nil && _objects[column][row] == nil) {
                
                // 3
                for (NSInteger lookup = row + 1; lookup < NumRows; lookup++) {
                    iAKObject *object = _objects[column][lookup];
                    if (object != nil) {
                        // 4
                        _objects[column][lookup] = nil;
                        _objects[column][row] = object;
                        object.row = row;
                        
                        // 5
                        if (array == nil) {
                            array = [NSMutableArray array];
                            [columns addObject:array];
                        }
                        [array addObject:object];
                        
                        // 6
                        break;
                    }
                }
            }
        }
    }
    return columns;
}

- (NSArray *)topUpObjects {
    NSMutableArray *columns = [NSMutableArray array];
    
    NSUInteger objectType = 0;
    
    for (NSInteger column = 0; column < NumColumns; column++) {
        
        NSMutableArray *array;
        
        // 1
        for (NSInteger row = NumRows - 1; row >= 0 && _objects[column][row] == nil; row--) {
            
            // 2
            if (_tiles[column][row] != nil) {
                
                // 3
                NSUInteger newObjectType;
                do {
                    newObjectType = arc4random_uniform(NumObjectTypes) + 1;
                } while (newObjectType == objectType);
                objectType = newObjectType;
                
                // 4
                iAKObject *object = [self createObjectAtColumn:column row:row withType:objectType];
                
                // 5
                if (array == nil) {
                    array = [NSMutableArray array];
                    [columns addObject:array];
                }
                [array addObject:object];
            }
        }
    }
    [self detectPossibleSwaps];
    return columns;
}

@end
