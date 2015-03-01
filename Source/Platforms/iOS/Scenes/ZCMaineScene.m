//
//  ZCMaineScene.m
//  ZombiConga_Cocoa2d
//
//  Created by Voronok Vitaliy on 2/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "ZCMaineScene.h"
#import "CGGeometry+ZCExtension.h"

static const CGFloat kZCBorderSize = 20;

@interface ZCMaineScene ()
@property (nonatomic, assign)   CGSize          winSize;

@property (nonatomic, strong)   CCPhysicsNode   *physicWorld;

@property (nonatomic, strong)   CCSprite        *square;
@property (nonatomic, strong)   CCSprite        *circle;
@property (nonatomic, strong)   CCSprite        *triangle;
@property (nonatomic, strong)   CCSprite        *octagon;

- (void)setupSprites;
- (void)spawnSand;

@end

@implementation ZCMaineScene

#pragma mark -
#pragma mark Initialization and Dealocation

- (id)init {
    self = [super init];
    
    if (self) {
        self.winSize = [CCDirector sharedDirector].viewSize;
        NSLog(@"---- %@", NSStringFromCGSize(self.winSize));
        
        CCPhysicsNode* physicsNode = [CCPhysicsNode node];
        [self addChild:physicsNode z:10];
        physicsNode.gravity = ccp(0,-1000);
        
        physicsNode.debugDraw = YES;
        
        self.physicWorld = physicsNode;
        
        CCPhysicsBody *body1 = [CCPhysicsBody bodyWithRect:CGRectMake(0,
                                                                      kZCBorderSize / 4 - kZCBorderSize,
                                                                      self.winSize.width,
                                                                      16)
                                              cornerRadius:0];
        
        CCPhysicsBody *body2 = [CCPhysicsBody bodyWithRect:CGRectMake(kZCBorderSize / 4 - kZCBorderSize,
                                                                      0,
                                                                      16,
                                                                      self.winSize.height)
                                              cornerRadius:0];
        
        CCPhysicsBody *body3 = [CCPhysicsBody bodyWithRect:CGRectMake(self.winSize.width - 1,
                                                                      0,
                                                                      16,
                                                                      self.winSize.height)
                                              cornerRadius:0];
        
        CCPhysicsBody *body4 = [CCPhysicsBody bodyWithRect:CGRectMake(1,
                                                                      self.winSize.height - 1,
                                                                      self.winSize.width,
                                                                      16)
                                              cornerRadius:0];
        
        body1.type = CCPhysicsBodyTypeStatic;
        body2.type = CCPhysicsBodyTypeStatic;
        body3.type = CCPhysicsBodyTypeStatic;
        body4.type = CCPhysicsBodyTypeStatic;
        
        CCNode *node1 = [CCNode node];
        node1.physicsBody = body1;
        [self.physicWorld addChild:node1];
        
        CCNode *node2 = [CCNode node];
        node2.physicsBody = body2;
        [self.physicWorld addChild:node2];
        
        CCNode *node3 = [CCNode node];
        node3.physicsBody = body3;
        [self.physicWorld addChild:node3];
        
        CCNode *node4 = [CCNode node];
        node4.physicsBody = body4;
        [self.physicWorld addChild:node4];
        
//        self.physicWorld.physicsBody.type = 
       

        ccColor4B color = {50, 45, 30, 255};
        CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithCcColor4b:color]];

        [self addChild:background z:-10];
        
        self.userInteractionEnabled = YES;
        
        [self setupSprites];
        
        CCAction *repeatAction = [CCActionRepeat actionWithAction:[CCActionCallFunc actionWithTarget:self
                                                                                selector:@selector(spawnSand)]
                                                      times:100];
        
        [self runAction:repeatAction];
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
    
    for (CCSprite *node in self.physicWorld.children) {
        if ([node.name isEqualToString: @"sand"]) {
            [node.physicsBody applyImpulse:ccp(0, arc4random_uniform(500))];
        }
    }
    
    CCActionMoveBy *shake = [CCActionMoveBy actionWithDuration:0.05 position:ccp(0, 10)];
    CCActionRepeat *repeart = [CCActionRepeat actionWithAction:[CCActionSequence actionWithArray:@[shake, shake.reverse]] times:5];
    
    [self runAction:repeart];
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
    
    CCSprite *square = [CCSprite spriteWithImageNamed:@"square.png"];
    square.position = ccp(self.winSize.width * 0.25, self.winSize.height * 0.50);
    CGSize squareSyze = square.contentSize;

    CGRect squareRect = CGRectMake(0, 0, squareSyze.width, squareSyze.height);
    square.physicsBody = [CCPhysicsBody bodyWithRect:squareRect cornerRadius:0];
    
    self.square = square;
    [self.physicWorld addChild:square];
    
    CCSprite *circle = [CCSprite spriteWithImageNamed:@"circle.png"];
    circle.position = ccp(self.winSize.width * 0.5, self.winSize.height * 0.50);
    CGFloat radius = (circle.contentSize.width / 2) ;
    circle.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:radius andCenter:ccp(radius, radius)];
    
    self.circle = circle;
    
    [self.physicWorld addChild:circle];
    
    CCSprite *triangle = [CCSprite spriteWithImageNamed:@"triangle.png"];
    triangle.position = ccp(self.winSize.width * 0.75, self.winSize.height * 0.50);
    self.triangle = triangle;
    
    [self.physicWorld addChild:triangle];
    CGPoint point1 = ccp(0, 0);
    CGPoint point2 = ccp(triangle.contentSize.width / 2, triangle.contentSize.height);
    CGPoint point3 = ccp( triangle.contentSize.width, 0);
    
    CGPoint points[] = {point1, point2, point3};
    
    triangle.physicsBody = [CCPhysicsBody bodyWithPolygonFromPoints:points count:3 cornerRadius:0];
    
    CCSprite *octagon = [CCSprite spriteWithImageNamed:@"octagon.png"];
    octagon.position = ccp(self.winSize.width * 0.5, self.winSize.height * 0.75);
    self.octagon = octagon;
    
    [self.physicWorld addChild:octagon];
    CGFloat width = octagon.contentSize.width;
    CGFloat height = octagon.contentSize.height;
    CGFloat w2 = width / 2;
    CGFloat h2 = height / 2;
    
    CGPoint point11 = ccp(-width / 4 + w2, -height / 2 + h2);
    CGPoint point21 = ccp(-width / 2 + w2, -height / 4 + h2);
    CGPoint point31 = ccp(-width / 2 + w2, height / 4 + h2);
    CGPoint point4 = ccp(-width / 4 + w2, height / 2 + h2);
    CGPoint point5 = ccp(width / 4 + w2, height / 2 + h2);
    CGPoint point6 = ccp(width / 2 + w2, height / 4 + h2);
    CGPoint point7 = ccp(width / 2 + w2, -height / 4 + h2);
    CGPoint point8 = ccp(width / 4 + w2, -height / 2 + h2);
    
    CGPoint points2[] = {point11, point21, point31, point4, point5, point6, point7, point8};
    
    octagon.physicsBody = [CCPhysicsBody bodyWithPolygonFromPoints:points2 count:8 cornerRadius:0];

}

- (void)spawnSand {
    CCSprite *sand = [CCSprite spriteWithImageNamed:@"sand.png"];
    
    sand.position = ccp((float)(arc4random()%(int)self.winSize.width),
                        self.winSize.height - sand.contentSize.height);
    
    CGFloat radius = (sand.contentSize.width / 2) ;
    sand.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:radius andCenter:ccp(radius, radius)];
    
    [self.physicWorld addChild:sand];
    sand.name = @"sand";
    sand.physicsBody.friction = 1.2;
}

@end
