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


@end

@implementation ZCMaineScene

#pragma mark -
#pragma mark Initialization and Dealocation

- (id)init {
    self = [super init];
    
    if (self) {
        self.userInteractionEnabled = YES;
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

@end
