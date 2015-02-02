//
//  ZCMaineScene.m
//  ZombiConga_Cocoa2d
//
//  Created by Voronok Vitaliy on 2/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "ZCMaineScene.h"

@interface ZCMaineScene ()

@end

@implementation ZCMaineScene

- (id)init {
    self = [super init];
    
    if (self) {
        CCSprite *background = [CCSprite spriteWithImageNamed:@"background1.png"];
        CGSize size = [[CCDirector sharedDirector] viewSize];
        
        [background setPosition:CGPointMake(size.width / 2, size.height / 2)];
        
        CGSize imageSize = background.contentSize;
        background.scaleX = size.width / imageSize.width;
        background.scaleY = size.height / imageSize.height;
        
        [self addChild:background z:-1];
        CCSprite *zombie = [CCSprite spriteWithImageNamed:@"zombie1.png"];
        [zombie setPosition:CGPointMake(100, 100)];
        zombie.scaleX = size.width / imageSize.width;
        zombie.scaleY = size.height / imageSize.height;
        
        [self addChild:zombie];
    }
    
    return self;
}


@end

/*
CGSize wSize=[[CCDirector sharedDirector] viewSize];
CGSize scrSize={640,1136};
CCSprite* background1 = [CCSprite spriteWithFile:@"1136.png"];
background1.anchorPoint=ccp(0, 0);
background1.scaleX=wSize.width/scrSize.width;
background1.scaleY=wSize.height/scrSize.height;
[self addChild:background1];
*/

/*
if ((self = [super init]))
{
    // create and initialize a label
    CCLabelTTF* label = [CCLabelTTF labelWithString:@"Hello World"
                                           fontName:@"Verdana-Bold"//@"Marker Felt"
                                           fontSize:64];
    
    // get the window (screen) size from CCDirector
    CGSize size = [[CCDirector sharedDirector] viewSize];
    // position the label at the center of the screen
    label.position = CGPointMake(size.width / 2, size.height / 2);
    //add the label as a child to this Layer
    [self addChild:label];
}
return self;
*/