//
//  iAKLevelButton.h
//  TidyUp
//
//  Created by Xiaonan Wang on 8/3/14.
//  Copyright (c) 2014 iAKTU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface iAKLevelButton : SKSpriteNode

@property (nonatomic, retain) SKSpriteNode *lockSprite;
@property (nonatomic, retain) SKSpriteNode *bgImage;
@property (nonatomic, retain) SKLabelNode *textLabel;
@property (nonatomic, retain) NSArray *starSprites;
@property (nonatomic, assign) BOOL isLocked;

- (void)setBackgroundImage:(NSString *)image;
- (void)setLocked:(BOOL)locked;
- (void)setLevelText:(NSString *)text;
- (void)setLevelStars:(NSInteger)life;

@property (nonatomic, readonly) SEL actionTouchDown;
@property (nonatomic, readonly) SEL actionTouchMoved;
@property (nonatomic, readonly, weak) id targetTouchDown;
@property (nonatomic, readonly, weak) id targetTouchMoved;

- (id)initWithImageNamed:(NSString *)image;
- (id)initWithSize:(CGSize)size;

- (void)setTouchDownTarget:(id)target action:(SEL)action;

@end
