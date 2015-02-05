//
//  ZCZombieSprite.m
//  ZombiConga_Cocoa2d
//
//  Created by Voronok Vitaliy on 2/4/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "ZCZombieSprite.h"

@interface ZCZombieSprite ()

@end

@implementation ZCZombieSprite

+ (id)spriteWithSize:(CGSize)size {
    ZCZombieSprite *zombie = [self spriteWithImageNamed:@"zombie1.png"];
    [zombie setPosition:CGPointMake(100, 100)];

    CGFloat scaleX = size.width / zombie.contentSize.width;
    CGFloat scaleY = size.height / zombie.contentSize.height;
    
    CGFloat scale = scaleX < scaleY ? scaleX : scaleY;
    
    zombie.scaleY = scale;
    zombie.scaleX = scale;
    
    NSMutableArray *animationFramesRun = [NSMutableArray array];
    
    for(int i = 1; i <= 4; ++i)
    {
        NSString *spriteName = [NSString stringWithFormat:@"zombie%lu.png", (unsigned long)i];
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:spriteName];
        
        [animationFramesRun addObject:frame] ;
    }
    
    [animationFramesRun addObject:animationFramesRun[3]];
    [animationFramesRun addObject:animationFramesRun[2]];
    
    CCAnimation *running = [CCAnimation animationWithSpriteFrames: animationFramesRun delay:0.1f];
    zombie.animation = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:running]];
    
    return zombie;
}

- (void)startAnimation {
    if (self.animation) {
        [self stopAnimation];
    }
    
    [self runAction:self.animation];
}

- (void)stopAnimation {
    [self stopAction:self.animation];
}

@end
