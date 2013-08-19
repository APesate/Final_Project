//
//  PaddleSprite.m
//  AirHockey
//
//  Created by Andrés Pesate on 8/13/13.
//  Copyright 2013 Andrés Pesate. All rights reserved.
//

#import "PaddleSprite.h"
#import "HelloWorldLayer.h"
#import "PaddleSprite_sm.h"


@implementation PaddleSprite{
    CGSize winSize;
}

-(id)initWithFile:(NSString *)filename rect:(CGRect)rect{
    self = [super initWithFile:filename rect:rect];
    
    if(self){
        state = kPaddleStateUngrabbed;
        winSize = [[CCDirector sharedDirector] winSize];
    }
    return self;
}

-(void)createBody{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    
    if(self.tag == 1){
        bodyDef.position.Set(90/PTM_RATIO, [[CCDirector sharedDirector] winSize].height /(2 * PTM_RATIO));
    }else{
        bodyDef.position.Set(([[CCDirector sharedDirector] winSize].width - 90)/PTM_RATIO, [[CCDirector sharedDirector] winSize].height /(2 * PTM_RATIO));
    }
    
    
    bodyDef.userData = self;
    body = world->CreateBody(&bodyDef);
    
    b2CircleShape paddle;
    paddle.m_radius = 31.0/PTM_RATIO;
    
    b2FixtureDef bodyTextureDef;
    bodyTextureDef.shape = &paddle;
    bodyTextureDef.density = 5.0f;
    bodyTextureDef.friction = (0.5 * bodyTextureDef.density);
    bodyTextureDef.restitution = 0.8f;
    bodyTextureDef.filter.groupIndex = 1;
    body->CreateFixture(&bodyTextureDef);
    body->SetAngularDamping(0.05* body->GetMass());
    body->SetLinearDamping(0.05 * body->GetMass());
    

}

- (CGRect)rectInPixels
{
    CGSize s = [self.texture contentSizeInPixels];
    return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
}

- (CGRect)rect
{
    CGSize s = [self.texture contentSize];
    return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
    CGPoint p = [self convertTouchToNodeSpaceAR:touch];
    CGRect r = [self rectInPixels];
    return CGRectContainsPoint(r, p);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:touch.view];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];

    if (state != kPaddleStateUngrabbed) return NO;
    if(!CGRectContainsPoint(self.boundingBox, touchLocation))return NO;
    //if ( ![self containsTouchLocation:touch] ) return NO;
    
    
    b2MouseJointDef md;
    md.bodyA = world->GetBodyList();
    md.bodyB = body;
    md.target = b2Vec2((body->GetPosition()).x, (body->GetPosition()).y);
    md.collideConnected = true;
    md.dampingRatio = 2.0f;
    md.frequencyHz =  100.0f;
    md.maxForce = 8000.0f * body->GetMass();
    
    _fsm = [[PaddleSpriteContext alloc] initWithOwner:self];
    [_fsm setDebugFlag:YES];
    [_fsm enterStartState];
    
    mouseJoint = (b2MouseJoint *)world->CreateJoint(&md);
    body->SetAwake(true);
    
    state = kPaddleStateGrabbed;
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // If it weren't for the TouchDispatcher, you would need to keep a reference
    // to the touch from touchBegan and check that the current touch is the same
    // as that one.
    // Actually, it would be even more complicated since in the Cocos dispatcher
    // you get NSSets instead of 1 UITouch, so you'd need to loop through the set
    // in each touchXXX method.
    
    NSAssert(state == kPaddleStateGrabbed, @"Paddle - Unexpected state!");

#warning In case that we want to allow to throw the paddle
//    if(self.tag == 1 && self.position.x > winSize.width / 2){
//        return;
//    }
//    else if(self.tag == 2 && self.position.x < winSize.width / 2){
//        return;
//    }
    
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    mouseJoint->SetTarget(b2Vec2(touchLocation.x / PTM_RATIO, touchLocation.y / PTM_RATIO));
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSAssert(state == kPaddleStateGrabbed, @"Paddle - Unexpected state!");
    
    world->DestroyJoint(mouseJoint);
    mouseJoint = NULL;
    
    state = kPaddleStateUngrabbed;
}

- (void)onEnter
{
    CCDirector *director = [CCDirector sharedDirector];
    
    [[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    [super onEnter];
}

- (void)onExit
{
    CCDirector *director = [CCDirector sharedDirector];
    
    [[director touchDispatcher] removeDelegate:self];
    [super onExit];
}

#pragma marl SMC
//
// SMC AI
//


-(void)defend {
    [_fsm defend];
}

-(void)attack {
    [_fsm attack];
}

-(void)fallBack {
    [_fsm fallBack];
}

-(void) update:(ccTime)delta
{
    [_fsm update:delta];
    CCLOG(@"%f",delta);
}

-(void)runAnimation:(PaddleSpriteAnimation)anim{
    
    id callback = nil;
    id action = nil;
    
    switch (anim) {
        case pAttackingAnimation:
                //[self attack];
            break;
            
        case pDefendingAnimation:
            callback = [CCCallBlock actionWithBlock:^{
                [self defend];
            }];
            
            action = [CCSequence actions: callback, nil];
            
            break;
            
        case pFallBackAnimation:
                //[self fallBack];
            break;
            
        default:
            NSAssert( NO, @"Unknow PaddleSprite Action!!" );
            break;
    }
    if (action != nil) {
        [self stopAllActions];
        [self runAction:action];
    }

}

-(void)startAttackingTimer{
    CCLOG(@"CaveMan.startAttackingTimer");
    
    //ccTime nextPunchTime = ((MAX_NEXT_PUNCH_TIME - MIN_NEXT_PUNCH_TIME) * CCRANDOM_0_1() + MIN_NEXT_PUNCH_TIME);
    ccTime nextPunchTime = 1.0f;
    CCLOG(@"nextPunchTime: %f", nextPunchTime);
    [self schedule:@selector(attack) interval: nextPunchTime];
}

-(void)stopAttackingTimer{
    CCLOG(@"CaveMan.stopAttackingTimer");

    [self unschedule:@selector(attack)];
}

-(void)startDefendingTimer{
    CCLOG(@"CaveMan.startDefendingTimer");
    ccTime nextPunchTime = 10.0f;
    CCLOG(@"nextPunchTime: %f", nextPunchTime);
    [self schedule:@selector(defend) interval: nextPunchTime];

}

-(void)stopDefendingTimer{
    CCLOG(@"CaveMan.stopDefendingTimer");
    [self unschedule:@selector(defend)];
}

-(void)startFallingBackTimer{
    CCLOG(@"CaveMan.startFallingTimer");
    ccTime nextPunchTime = 10.0f;
    CCLOG(@"nextPunchTime: %f", nextPunchTime);
    [self schedule:@selector(fallBack) interval: nextPunchTime];
}

-(void)stopFallingBackTimer{
    CCLOG(@"CaveMan.stopFallingTimer");
    [self unschedule:@selector(fallBack)];
}

-(void)updateAttacking:(ccTime)dt{
    
}

-(void)updateDefending:(ccTime)dt{
    body->SetTransform(b2Vec2([HelloWorldLayer getPuckSprite].position.x/32, [HelloWorldLayer getPuckSprite].position.y/32), 0);
    CCLOG(@"Posicion!! %f",[HelloWorldLayer getPuckSprite].position.x/32);
}

@end
