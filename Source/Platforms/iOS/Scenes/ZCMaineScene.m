//
//  ZCMaineScene.m
//  ZombiConga_Cocoa2d
//
//  Created by Voronok Vitaliy on 2/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "ZCMaineScene.h"
#import "CGGeometry+ZCExtension.h"

#import "ZCZombieSprite.h"

static const float ZOMBIE_MOVE_POINTS_PER_SEC = 120.0;
static const float CAT_MOVE_POINTS_PER_SEC = 120.0;

static const CGFloat zombieRotateRadiansPerSec  = 4.0 * M_PI;
static NSString * const kZCAnimationKey         = @"animation";
static NSString * const kZCCatSpriteName        = @"cat.png";
static NSString * const kZCCatTrainSpriteName   = @"train";
static NSString * const kZCEnemySpriteName      = @"enemy.png";

static const CGFloat radiusDebugLine            = 2.0;

@interface ZCMaineScene ()
@property (nonatomic, strong)   ZCZombieSprite  *zombie;
@property (nonatomic, assign)   NSTimeInterval  lastUpdateTime;
@property (nonatomic, assign)   NSTimeInterval  dt;
@property (nonatomic, assign)   CGPoint         velocity;
@property (nonatomic, assign)   CGPoint         lastTouchLocation;
@property (nonatomic, strong)   CCAction        *zombieAnimation;
@property (nonatomic, assign)   CGSize          spriteSize;
@property (nonatomic, assign)   CGFloat         scaleCat;

@property (nonatomic, assign, getter = isInvincible)    BOOL    invincible;

@end

@implementation ZCMaineScene

//@synthesize catCollisionSound = _catCollisionSound;
//@synthesize enemyCollisionSound = _enemyCollisionSound;

#pragma mark -
#pragma mark Initialization and Dealocation

- (id)init {
    self = [super init];
    
    if (self) {
        self.userInteractionEnabled = YES;
        CGSize size = [[CCDirector sharedDirector] viewSize];

        CCSprite *background = [CCSprite spriteWithImageNamed:@"background1.png"];
        [background setPosition:CGPointMake(size.width / 2, size.height / 2)];
        
        CGSize imageSize = background.contentSize;
        background.scaleX = size.width / imageSize.width;
        background.scaleY = size.height / imageSize.height;
        
        self.spriteSize = CGSizeMake(background.contentSize.width * 0.04, background.contentSize.height * 0.04);
        NSLog(@"Sprite size : %@", NSStringFromCGSize(self.spriteSize));
        [self addChild:background z:-1];
        
        ZCZombieSprite *zombie = [ZCZombieSprite spriteWithSize:self.spriteSize];
     
        zombie.zOrder = 100;
        [self addChild:zombie];
        self.zombie = zombie;
        
        [self createScene];
    }
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)playCatColision {
    [[OALSimpleAudio sharedInstance] playEffect:@"hitCat.wav"];
}

- (void)playEnemyColision {
    [[OALSimpleAudio sharedInstance] playEffect:@"hitCatLady.wav"];
}

#pragma mark -
#pragma mark Life Cycle

- (void)createScene {
    self.velocity = CGPointZero;
    
    // Spawn enemy
    [self runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actionWithArray:@[
                                                                                                [CCActionCallBlock actionWithBlock:^{
                                                                                                    [self spawnEnemy];
                                                                                                }],
                                                                                                [CCActionDelay actionWithDuration:4]
                                                                                                ]]]];
    
    
    // Spawn cats
    [self runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actionWithArray:@[
                                                                                                [CCActionCallBlock actionWithBlock:^{
                                                                                                    [self spawnCat];
                                                                                                }],
                                                                                                [CCActionDelay actionWithDuration:1]
                                                                                                ]]]];

    [self debugDrawPlayableArea];
}

- (void) update:(CCTime)delta {
    self.dt = delta;
    
    ZCZombieSprite *zombie = self.zombie;
    
    CGPoint lastTouch = self.lastTouchLocation;
    
    if (!CGPointEqualToPoint(lastTouch, CGPointZero)) {
        CGPoint diff = CGSubtractionVectors(lastTouch, zombie.position);
        
        if (CGLengthVector(diff) <= ZOMBIE_MOVE_POINTS_PER_SEC * self.dt) {
            zombie.position = lastTouch;
            self.velocity = CGPointZero;
            
            [self.zombie stopAnimation];
        } else {
            [self moveSprite:zombie velocity:self.velocity];
            [self rotateSprite:zombie direction:self.velocity rotateRadiansPerSec:zombieRotateRadiansPerSec];
        }
    }
    
    [self boundsCheckZombie];
    
    [self checkCollisions];
    [self moveTrain];
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint touchLocation = [touch locationInNode:self];

    self.lastTouchLocation = touchLocation;
    [self sceneTouched:touchLocation];
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint touchLocation = [touch locationInNode:self];
    
    self.lastTouchLocation = touchLocation;
    [self sceneTouched:touchLocation];
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint touchLocation = [touch locationInNode:self];
    
    self.lastTouchLocation = touchLocation;
    [self sceneTouched:touchLocation];
}

#pragma mark -
#pragma mark Private

- (void)zombieHitCat:(CCSprite *)cat {
    [self playCatColision];

    cat.name = kZCCatTrainSpriteName;
    [cat stopAllActions];
    cat.scale = self.scaleCat;
    cat.rotation = 0;
    
    CCActionDelay *actionDelay = [CCActionDelay actionWithDuration:0.2];
    CCActionCallBlock *colorizeAction = [CCActionCallBlock actionWithBlock:^{
        cat.color = [CCColor colorWithRed:0 green:200 blue:0];
    }];
    
    CCActionSequence *sequenceAction = [CCActionSequence actionWithArray:@[actionDelay, colorizeAction]];
    [cat runAction:sequenceAction];
}

- (void)moveTrain {
    __block CGPoint targetPosition = self.zombie.position;
    
    NSMutableArray *trainCats = [NSMutableArray array];
    
    for (CCSprite *sprite in self.children) {
        if ([sprite.name isEqualToString:kZCCatTrainSpriteName]) {
            [trainCats addObject:sprite];
        }
    }
    
    for (CCSprite *cat in trainCats) {
        if (!cat.numberOfRunningActions) {
            float actionDuration = 0.31;
            CGPoint offset = CGSubtractionVectors(targetPosition, cat.position);
            CGPoint direction = CGNormalizedVector(offset);
            CGPoint amountToMovePerSec = CGMultiplicationVectorOnScalar(direction, CAT_MOVE_POINTS_PER_SEC);
            CGPoint amountToMove = CGMultiplicationVectorOnScalar(amountToMovePerSec, actionDuration);
            CCActionMoveBy *moveAction = [CCActionMoveBy actionWithDuration:actionDuration position:amountToMove];
            
            [cat runAction:moveAction];
        }

        targetPosition = cat.position;
    }
}

- (void)zombieHitEnemy:(CCSprite *)enemy {
    self.invincible = YES;
    
    [self playEnemyColision];
    
    float blinkTimes = 10;
    float blinkDuration = 3.0;
    CCActionBlink *blinkAction = [CCActionBlink actionWithDuration:blinkDuration blinks:blinkTimes];
    CCActionCallBlock *blockAction = [CCActionCallBlock actionWithBlock:^{
        self.invincible = NO;
    }];
    
    CCActionSequence *sequenceAction = [CCActionSequence actionWithArray:@[blinkAction, blockAction]];
    
    [self.zombie runAction:sequenceAction];
}

- (void)checkCollisions {
    NSMutableArray *hitCats = [NSMutableArray array];
    
    for (CCSprite *sprite in self.children) {
        if ([sprite.name isEqualToString:kZCCatSpriteName]) {
            if (CGRectIntersectsRect([sprite boundingBox], [self.zombie boundingBox])) {
                [hitCats addObject:sprite];
            }
        }
    }
    
    for (CCSprite *cat in hitCats) {
        [self zombieHitCat:cat];
    }
    
    if (self.isInvincible) {
        return;
    }

    NSMutableArray *hitEnemies = [NSMutableArray array];
    
    for (CCSprite *sprite in self.children) {
        if ([sprite.name isEqualToString:kZCEnemySpriteName]) {
            if (CGRectIntersectsRect(CGRectInset([sprite boundingBox], 20, 20), [self.zombie boundingBox])) {
                [hitEnemies addObject:sprite];
            }
        }
    }
    
    for (CCSprite *enemy in hitEnemies) {
        [self zombieHitEnemy:enemy];
    }
}

- (void)spawnCat {
    CCSprite *cat = [CCSprite spriteWithImageNamed:kZCCatSpriteName];
    CGFloat scaleX = self.spriteSize.width / cat.contentSize.width;
    CGFloat scaleY = self.spriteSize.height / cat.contentSize.height;
    
    self.scaleCat = scaleX < scaleY ? scaleX : scaleY;

    cat.scale = self.scaleCat + self.scaleCat * 0.1;
    
    CGRect rect = [self boundingBox];
    
    CGFloat x = CGFloatRandomInRange(CGRectGetMinX(rect), CGRectGetMaxX(rect));
    CGFloat y = CGFloatRandomInRange(CGRectGetMinY(rect), CGRectGetMaxY(rect));
    
    cat.position = CGPointMake(x, y);
    [cat setScale:0];
    
    cat.name = kZCCatSpriteName;
    
    [self addChild:cat];
    
    cat.rotation = CC_RADIANS_TO_DEGREES(- M_PI / 16.0);
    
    CCActionScaleBy *scaleUp = [CCActionScaleBy actionWithDuration:0.25 scale:self.scaleCat + 0.03];
    CCAction *scaleDown = scaleUp.reverse;//[CCActionReverse actionWithAction:scaleUp];
    CCActionSequence *fullScale = [CCActionSequence actionWithArray:@[scaleUp, scaleDown, scaleUp, scaleDown]];
    
    CCActionRotateBy *leftWiggle = [CCActionRotateBy actionWithDuration:0.5 angle:CC_RADIANS_TO_DEGREES(M_PI / 8)];
    CCAction *rightWiggle = leftWiggle.reverse;//[CCActionReverse actionWithAction:leftWiggle];
    CCActionSequence *fullWiggle = [CCActionSequence actionWithArray:@[leftWiggle, rightWiggle]];
    
    CCActionSpawn *group = [CCActionSpawn actionWithArray:@[fullScale, fullWiggle]];
    CCActionRepeat *groupWait = [CCActionRepeat actionWithAction:group times:10];
    
    CCActionScaleTo *appear = [CCActionScaleTo actionWithDuration:0.5 scale:self.scaleCat];
    CCActionScaleTo *disappear = [CCActionScaleTo actionWithDuration:0.5 scale:0];
    CCActionRemove *removeFromParent = [CCActionRemove action];// removeFromParent];
    
    NSArray *actions = @[appear, groupWait, disappear, removeFromParent];

    [cat runAction:[CCActionSequence actionWithArray:actions]];
}

- (void)spawnEnemy {
    CCSprite *enemy = [CCSprite spriteWithImageNamed:@"enemy.png"];
    CGFloat scaleX = self.spriteSize.width / enemy.contentSize.width;
    CGFloat scaleY = self.spriteSize.height / enemy.contentSize.height;
    
    CGFloat scale = scaleX < scaleY ? scaleX : scaleY;
    
    enemy.scale = scale;
    
    CGSize size = self.contentSize;
    CGSize enemySize = enemy.contentSize;
    
    CGFloat min = CGRectGetMinY([self boundingBox]) + enemySize.height / 2;
    CGFloat max = CGRectGetMaxY([self boundingBox]) - enemySize.height / 2;
    
    enemy.position = CGPointMake(size.width - enemySize.width / 2, CGFloatRandomInRange(min, max));
    
    enemy.name = kZCEnemySpriteName;
    
    [self addChild:enemy];
    
    CCAction *actionMove = [CCActionMoveTo actionWithDuration:4
                                                     position:ccp((-enemySize.width / 2), enemy.position.y)];
    
    CCAction *actionRemove = [CCActionRemove action];
    [enemy runAction:[CCActionSequence actionWithArray:@[actionMove, actionRemove]]];
}

- (void)sceneTouched:(CGPoint)touchLocation {
    [self moveZombieToward:touchLocation];
}

- (void)moveSprite:(CCSprite *)sprite velocity:(CGPoint)velocity {
    CGPoint amountToMove = CGMultiplicationVectorOnScalar(velocity, self.dt);
    
    sprite.position = CGAddVectors(sprite.position, amountToMove);
}

- (void)moveZombieToward:(CGPoint)location {
    [self.zombie startAnimation];
    
    CCSprite *zombie = self.zombie;
    
    CGPoint offset = CGSubtractionVectors(location, zombie.position);
    
    CGPoint direction = CGNormalizedVector(offset);
    self.velocity = CGMultiplicationVectorOnScalar(direction, ZOMBIE_MOVE_POINTS_PER_SEC);
}

- (void)rotateSprite:(CCSprite *)sprite
           direction:(CGPoint)direction
 rotateRadiansPerSec:(CGFloat)radiansPerSec
{
    CGFloat angle = CGShortestAngleBetween(CC_DEGREES_TO_RADIANS(-sprite.rotation), CGAngleVector(direction));
    CGFloat amountToRotate = fmin(radiansPerSec * self.dt, fabs(angle));
    sprite.rotation -= CGScalarSign(angle) * CC_RADIANS_TO_DEGREES( amountToRotate);
}

- (void)boundsCheckZombie {
    CGPoint bottomLeft = CGPointMake(0, CGRectGetMinY([self boundingBox]));
    CGPoint topRight = CGPointMake(self.contentSize.width, CGRectGetMaxY([self boundingBox]));
    
    CCSprite *zombie = self.zombie;
    
    if (zombie.position.x <= bottomLeft.x) {
        zombie.position = CGPointMake(bottomLeft.x, zombie.position.y);
        self.velocity = CGPointMake(-self.velocity.x, self.velocity.y);
    }
    
    if (zombie.position.x >= topRight.x) {
        zombie.position = CGPointMake(topRight.x, zombie.position.y);
        self.velocity = CGPointMake(-self.velocity.x, self.velocity.y);
    }
    
    if (zombie.position.y <= bottomLeft.y) {
        zombie.position = CGPointMake(zombie.position.x, bottomLeft.y);
        self.velocity = CGPointMake(self.velocity.x, -self.velocity.y);
    }
    
    if (zombie.position.y >= topRight.y) {
        zombie.position = CGPointMake(zombie.position.x, topRight.y);
        self.velocity = CGPointMake(self.velocity.x, -self.velocity.y);
    }
}

- (void)rotateSprite:(CCSprite *)sprite direction:(CGPoint)direction {
    sprite.rotation = CC_RADIANS_TO_DEGREES(CGAngleVector(direction));
}

- (void)debugDrawPlayableArea {
    CCDrawNode *shape = [CCDrawNode node];
    [shape clear];
    
    CGRect rect = [self boundingBox];
    CCColor *color = [CCColor colorWithCcColor4b:ccc4(255, 0, 0, 255)];
    CGPoint startPoint = rect.origin;
    CGSize size = rect.size;
    CGPoint rightBottom = CGPointMake(startPoint.x + size.width, startPoint.y);
    CGPoint leftUp = CGPointMake(startPoint.x, startPoint.y + size.height);
    CGPoint rightUp = CGPointMake(startPoint.x + size.width, startPoint.y + size.height);
    
    [shape drawSegmentFrom:startPoint to:rightBottom radius:radiusDebugLine color:color];
    [shape drawSegmentFrom:startPoint to:leftUp radius:radiusDebugLine color:color];
    [shape drawSegmentFrom:rightBottom to:rightUp radius:radiusDebugLine color:color];
    [shape drawSegmentFrom:leftUp to:rightUp radius:radiusDebugLine color:color];
  
    [self addChild:shape];
}

@end
