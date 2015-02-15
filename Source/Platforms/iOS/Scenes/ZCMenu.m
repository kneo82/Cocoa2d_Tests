//
//  ZCMenu.m
//  ZombiConga_Cocoa2d
//
//  Created by Admin on 14.02.15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "ZCMenu.h"

#import "ZCMaineScene.h"

@implementation ZCMenu

#pragma mark -
#pragma mark Initialization and Dealocation

- (id)init {
    self = [super init];
    
    if (self) {
        self.userInteractionEnabled = YES;
        
        CGSize size = [[CCDirector sharedDirector] viewSize];
        
        CCSprite *background = [CCSprite spriteWithImageNamed:@"MainMenu.png"];
        [background setPosition:CGPointMake(size.width / 2, size.height / 2)];

        CGSize imageSize = background.contentSize;
        background.scaleX = size.width / imageSize.width;
        background.scaleY = size.height / imageSize.height;
        
        [self addChild:background z:-1];
    }
    
    return self;
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CCTransition *transition = [CCTransition transitionCrossFadeWithDuration:1];
    
    [[CCDirector sharedDirector] replaceScene:[ZCMaineScene node]
                               withTransition:transition];
}

@end
