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

-(id)initWithFile:(NSString *)filename rect:(CGRect)rect{
    self = [super initWithFile:filename rect:rect];
    
    if(self){
        state = kPaddleStateUngrabbed;
        winSize = [[CCDirector sharedDirector] winSize];
    }
    return self;
}

-(void)createBodyWithCoordinateType:(int)coordinateType{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    
    if(coordinateType == 1){
    bodyDef.position.Set(([[CCDirector sharedDirector] winSize].width - 90)/PTM_RATIO, [[CCDirector sharedDirector] winSize].height /(2 * PTM_RATIO));
    }else{
        bodyDef.position.Set(90/PTM_RATIO, [[CCDirector sharedDirector] winSize].height /(2 * PTM_RATIO));
    }
    
    
    bodyDef.userData = self;
    body = world->CreateBody(&bodyDef);
    
    b2CircleShape paddle;
    paddle.m_radius = 31.0/PTM_RATIO;
    
    b2FixtureDef bodyTextureDef;
    bodyTextureDef.shape = &paddle;
    bodyTextureDef.density = 10.0f;
    bodyTextureDef.friction = (0.5 * bodyTextureDef.density);
    bodyTextureDef.restitution = 0.8f;
    bodyTextureDef.filter.groupIndex = 1;
    body->CreateFixture(&bodyTextureDef);
    body->SetAngularDamping(0.01* body->GetMass());
    body->SetLinearDamping(0.01 * body->GetMass());

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
    
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    
    if(!(self.position.x < 0 || self.position.x > winSize.width)){
        mouseJoint->SetTarget(b2Vec2(touchLocation.x / PTM_RATIO, touchLocation.y / PTM_RATIO));
    }else{
        CGPoint previousTouch = [touch previousLocationInView:[touch view]];
        previousTouch = [[CCDirector sharedDirector] convertToGL:previousTouch];
        body->SetTransform(b2Vec2(previousTouch.x, previousTouch.y), 0.0);
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSAssert(state == kPaddleStateGrabbed, @"Paddle - Unexpected state!");
    
    /*b2MouseJointDef md;
    md.maxForce = 2000.0f * body->GetMass();
    mouseJoint = (b2MouseJoint *)world->CreateJoint(&md);*/
    
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
