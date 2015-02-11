//
//  ZCZombieSprite.h
//  ZombiConga_Cocoa2d
//
//  Created by Voronok Vitaliy on 2/4/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface ZCZombieSprite : CCSprite
@property (nonatomic, strong)   CCAction    *animation;

+ (id)spriteWithSize:(CGSize)size;

- (void)startAnimation;
- (void)stopAnimation;

@end
