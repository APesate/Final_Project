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

//@synthesize body = _body;
@synthesize session = _session;
@synthesize myID = _myID;
@synthesize friendID = _friendID;

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
    _body->SetFixedRotation(YES);
    _body->SetAngularDamping(0.1* _body->GetMass());
    _body->SetLinearDamping(0.5 * _body->GetMass());
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

    if(!self.enabled) return NO;
    if (state != kPaddleStateUngrabbed) return NO;
    if(!CGRectContainsPoint(self.boundingBox, touchLocation))return NO;
    
    if(self.session != nil){
        NSDictionary* coordinates = @{@"DataType": @"DataForPaddleStartMoving"};
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:coordinates];
        NSError* error = nil;
        
        if(![_session sendData:data toPeers:_friendID withDataMode:GKSendDataReliable error:&error]){
            NSLog(@"Error sending Start Moving data to clients: %@", error);
        }
    }
    [self paddleWillStartMoving];
    
   

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
    if(_mouseJoint){
        NSAssert(state == kPaddleStateGrabbed, @"Paddle - Unexpected state!");
        
        CGPoint touchLocation = [touch locationInView:[touch view]];
        touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
        
        NSNumber* xCoordinate = [NSNumber numberWithFloat:(touchLocation.x / PTM_RATIO)];
        NSNumber* yCoordinate = [NSNumber numberWithFloat:(touchLocation.y / PTM_RATIO)];
        
        if(self.session != nil){
            NSNumber* xCoordinateToSend = @(((winSize.width / PTM_RATIO) - xCoordinate.floatValue) / winSize.width);
            NSNumber* yCoordinateToSend = @(((winSize.height / PTM_RATIO) - yCoordinate.floatValue) / winSize.height);
            
            NSDictionary* coordinates = @{@"x": xCoordinateToSend, @"y": yCoordinateToSend, @"DataType": @"DataForPaddleIsMoving"};
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:coordinates];
            NSError* error = nil;
            
            if(![_session sendData:data toPeers:_friendID withDataMode:GKSendDataReliable error:&error]){
                NSLog(@"Error sending Is Moving data to clients: %@", error);
            }
        }
        
        [self movePaddleToX:xCoordinate.floatValue andY:yCoordinate.floatValue];
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSAssert(state == kPaddleStateGrabbed, @"Paddle - Unexpected state!");

    if(self.session != nil){
        NSNumber* xSpeed = @((-1) * (self.body->GetLinearVelocity()).x);
        NSNumber* ySpeed = @((-1) * (self.body->GetLinearVelocity()).y);
        
        NSDictionary* coordinates = @{@"x": xSpeed, @"y": ySpeed,  @"DataType": @"DataForPaddleStopMoving"};
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:coordinates];
        NSError* error = nil;
        
        if(![_session sendData:data toPeers:_friendID withDataMode:GKSendDataReliable error:&error]){
            NSLog(@"Error sending End Movement data to clients: %@", error);
        }
    }
    
    [self paddleWillStopMoving];
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    NSAssert(state == kPaddleStateGrabbed, @"Paddle - Unexpected state!");
    
    if(self.session != nil){
        NSDictionary* coordinates = @{@"DataType": @"DataForPaddleStopMoving"};
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:coordinates];
        NSError* error = nil;
        
        if(![_session sendData:data toPeers:_friendID withDataMode:GKSendDataReliable error:&error]){
            NSLog(@"Error sending data to clients: %@", error);
        }
    }
    [self paddleWillStopMoving];
}

-(void)paddleWillStartMoving{
    
    b2MouseJointDef md;
    md.bodyA = world->GetBodyList();
    md.bodyB = _body;
    md.target = b2Vec2((_body->GetPosition()).x, (_body->GetPosition()).y);
    md.collideConnected = true;
    md.dampingRatio = 10.0f;
    md.frequencyHz =  500.0f;
    md.maxForce = 8000.0f * _body->GetMass();
    
    _mouseJoint = (b2MouseJoint *)world->CreateJoint(&md);
    _body->SetAwake(true);
    
    state = kPaddleStateGrabbed;
}

-(void)movePaddleToX:(CGFloat)xCoordinate andY:(CGFloat)yCoordinate{
    _mouseJoint->SetTarget(b2Vec2(xCoordinate, yCoordinate));
}

-(void)destroyLink
{
    if (_mouseJoint != NULL) {
        world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
}

-(void)createLink
{
    CCDirector *director = [CCDirector sharedDirector];
    
    [[director touchDispatcher] setDispatchEvents:YES];
}

-(void)paddleWillStopMoving{
    if (_mouseJoint) {
    world->DestroyJoint(_mouseJoint);   
    }

    _mouseJoint = NULL;
    
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

-(void)dealloc{
    [super dealloc];
    
}

@end
