//
//  GameOverScene.m
//  ZombiConga_Cocoa2d
//
//  Created by Admin on 11.02.15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameOverScene.h"
#import "ZCMaineScene.h"

static NSString * const kZCWinScenImage     = @"YouWin.png";
static NSString * const kZCLoseScenImage    = @"YouLose.png";
static NSString * const kZCWinScenSound     = @"win.wav";
static NSString * const kZCLoseScenSound    = @"lose.wav";

@interface GameOverScene ()

- (void)setBacgroundWithName:(NSString *)name;
- (id)initWinScene;
- (id)initLoseScene;
- (void)playSoundWithName:(NSString *)name;
- (void)gameOveActions;

@end

@implementation GameOverScene

#pragma mark -
#pragma mark Class Methods

+ (id)nodeWithIsWin:(BOOL)isWin {
    return isWin ? [[self alloc] initWinScene] : [[self alloc] initLoseScene];
}

#pragma mark -
#pragma mark Initialization and Dealocation

- (id)initLoseScene {
    self = [super init];
    
    if (self) {
        [self setBacgroundWithName:kZCLoseScenImage];
        
        [self playSoundWithName:kZCLoseScenSound];
        
        [self gameOveActions];
    }
    
    return self;
}

- (id)initWinScene {
    self = [super init];
    
    if (self) {
        [self setBacgroundWithName:kZCWinScenImage];
        
        [self playSoundWithName:kZCWinScenSound];
        
        [self gameOveActions];
    }
    
    return self;
}

#pragma mark -
#pragma mark Private

- (void)gameOveActions {
    CCActionDelay *delayAction = [CCActionDelay actionWithDuration:3];
    CCActionCallBlock *blockAction = [CCActionCallBlock actionWithBlock:^{
        CCTransition *transition = [CCTransition transitionRevealWithDirection:CCTransitionDirectionDown duration:1];

        transition.outgoingDownScale = 5;

        
        [[CCDirector sharedDirector] replaceScene:[ZCMaineScene node]
                                   withTransition:transition];
//         [CCTransition transitionPushWithDirection:CCTransitionDirectionDown
//                                                                                   duration:1]];
    }];
    
    CCActionSequence *sequence = [CCActionSequence actionWithArray:@[delayAction, blockAction]];
    
    [self runAction:sequence];
}

- (void)playSoundWithName:(NSString *)name {
    CCActionDelay *delayAction = [CCActionDelay actionWithDuration:0.1];
    CCActionSoundEffect *soundEffect = [CCActionSoundEffect actionWithSoundFile:name pitch:1 pan:0 gain:1];
    
    CCActionSequence *sequence = [CCActionSequence actionWithArray:@[delayAction, soundEffect]];
    
    [self runAction:sequence];
}

- (void)setBacgroundWithName:(NSString *)name {
    CGSize size = [[CCDirector sharedDirector] viewSize];
    
    CCSprite *background = [CCSprite spriteWithImageNamed:name];
    [background setPosition:CGPointMake(size.width / 2, size.height / 2)];
    
    CGSize imageSize = background.contentSize;
    background.scaleX = size.width / imageSize.width;
    background.scaleY = size.height / imageSize.height;
    
    [self addChild:background z:-1];
}

@end
