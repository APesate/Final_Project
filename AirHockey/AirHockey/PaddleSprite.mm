//
//  PaddleSprite.m
//  AirHockey
//
//  Created by Andrés Pesate on 8/13/13.
//  Copyright 2013 Andrés Pesate. All rights reserved.
//

#import "PaddleSprite.h"

@implementation PaddleSprite{
    CGSize winSize;
}

@synthesize body = _body;

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
    _body = world->CreateBody(&bodyDef);
    
    b2CircleShape paddle;
    paddle.m_radius = 31.0/PTM_RATIO;
    
    b2FixtureDef bodyTextureDef;
    bodyTextureDef.shape = &paddle;
    bodyTextureDef.density = 5.0f;
    bodyTextureDef.friction = (0.5 * bodyTextureDef.density);
    bodyTextureDef.restitution = 0.8f;
    bodyTextureDef.filter.groupIndex = 1;
    
    _body->CreateFixture(&bodyTextureDef);
    _body->SetAngularDamping(0.05* _body->GetMass());
    _body->SetLinearDamping(0.05 * _body->GetMass());

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
    md.bodyB = _body;
    md.target = b2Vec2((_body->GetPosition()).x, (_body->GetPosition()).y);
    md.collideConnected = true;
    md.dampingRatio = 2.0f;
    md.frequencyHz =  100.0f;
    md.maxForce = 8000.0f * _body->GetMass();
    
    mouseJoint = (b2MouseJoint *)world->CreateJoint(&md);
    _body->SetAwake(true);
    
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

@end
