//
//  ZCMaineScene.m
//  ZombiConga_Cocoa2d
//
//  Created by Voronok Vitaliy on 2/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "ZCMaineScene.h"
#import "CGGeometry+ZCExtension.h"

@interface ZCMaineScene ()
@property (nonatomic, assign)   CGSize  winSize;

@property (nonatomic, strong)   CCSprite    *square;
@property (nonatomic, strong)   CCSprite    *circle;
@property (nonatomic, strong)   CCSprite    *triangle;

- (void)setupSprites;

@end

@implementation ZCMaineScene

#pragma mark -
#pragma mark Initialization and Dealocation

- (id)init {
    self = [super init];
    
    if (self) {
        self.winSize = [CCDirector sharedDirector].viewSize;
        
        
        ccColor4B color = {50, 45, 30, 255};
        CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithCcColor4b:color]];

        [self addChild:background];
        
        self.userInteractionEnabled = YES;
        
        [self setupSprites];
    }
    
    return self;
}

#pragma mark -
#pragma mark Accessors

#pragma mark -
#pragma mark Life Cycle

- (void) update:(CCTime)delta {
    
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint touchLocation = [touch locationInNode:self];
    
    NSLog(@"Touch Began : (%@)", NSStringFromCGPoint(touchLocation));
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint touchLocation = [touch locationInNode:self];
    
    NSLog(@"Touch Ended : (%@)", NSStringFromCGPoint(touchLocation));
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint touchLocation = [touch locationInNode:self];
    
    NSLog(@"Touch Moved : (%@)", NSStringFromCGPoint(touchLocation));
}

#pragma mark -
#pragma mark Private

- (void)setupSprites {
    CCSprite *square = [CCSprite spriteWithImageNamed:@"square@1x.png"];
    square.position = ccp(self.winSize.width * 0.25, self.winSize.height * 0.50);
    self.square = square;
    
    [self addChild:square];
}

@end
