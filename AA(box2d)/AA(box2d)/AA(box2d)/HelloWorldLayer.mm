//
//  HelloWorldLayer.mm
//  AA(box2d)
//
//  Created by Grimi on 8/12/13.
//  Copyright MobileMakers 2013. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

// Not included in "cocos2d.h"
#import "CCPhysicsSprite.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"


enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
{
    BOOL touchInSprite;
}

-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) createMenu;
- (void)tick:(ccTime) dt;
@end

@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {

		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
        _ball = [CCSprite spriteWithFile:@"ball-hd.png" rect:CGRectMake(0, 0, 52, 52)];
        _ball.position = ccp(100, 300);
        [self addChild:_ball];
        
        _paddleSprite = [CCSprite spriteWithFile:@"hockey.png" rect:CGRectMake(0, 0, 85, 85)];
        _paddleSprite.position = ccp(200, 300);
        [self addChild:_paddleSprite];
        
        // Create a world
        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
        _world = new b2World(gravity);
        
        // Create ball body and shape
        b2BodyDef ballBodyDef;
        ballBodyDef.type = b2_dynamicBody;
        ballBodyDef.position.Set(100/PTM_RATIO, 300/PTM_RATIO);
        ballBodyDef.userData = _ball;
        _body = _world->CreateBody(&ballBodyDef);
        
        
        // Create paddle body and shape
        
        b2BodyDef paddleBodyDef;
        paddleBodyDef.type = b2_dynamicBody;
        paddleBodyDef.position.Set(100/PTM_RATIO, 300/PTM_RATIO);
        paddleBodyDef.userData = _paddleSprite;
        _body = _world->CreateBody(&paddleBodyDef);

        b2CircleShape circle;
        circle.m_radius = 26.0/PTM_RATIO;
        
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &circle;
        ballShapeDef.density = 1.0f;
        ballShapeDef.friction = 0.2f;
        ballShapeDef.restitution = 0.8f;
        _body->CreateFixture(&ballShapeDef);

        b2FixtureDef paddleShapeDef;
        paddleShapeDef.shape = &circle;
        paddleShapeDef.density = 5.0f;
        paddleShapeDef.friction = 0.2f;
        paddleShapeDef.restitution = 0.1f;
        _body->CreateFixture(&paddleShapeDef);
        
        

        
        [self schedule:@selector(tick:)];
        
        // Create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        
        groundBody = _world->CreateBody(&groundBodyDef);
        b2EdgeShape groundEdge;
        b2FixtureDef boxShapeDef;
        boxShapeDef.shape = &groundEdge;
        
        _body->SetLinearDamping(0.01*ballShapeDef.density);
        
        //wall definitions
        groundEdge.Set(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);
    
        groundEdge.Set(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
        groundBody->CreateFixture(&boxShapeDef);
        
        groundEdge.Set(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO,
                                                                  winSize.height/PTM_RATIO));
        groundBody->CreateFixture(&boxShapeDef);
        
        groundEdge.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO),
                      b2Vec2(winSize.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);

     /*   b2PrismaticJointDef jointDef;
        b2Vec2 worldAxis(1.0f, 0.0f);
        jointDef.collideConnected = true;
        jointDef.Initialize(_paddle, groundBody,
                            _paddle->GetWorldCenter(), worldAxis);
        _world->CreateJoint(&jointDef);*/

        
    }
	return self;
}


- (void)tick:(ccTime) dt {
    
    _world->Step(dt, 10, 10);
    
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *)b->GetUserData();
            
            // if ball is going too fast, turn on damping
            if (sprite.tag == 1) {
                static int maxSpeed = 10;
                
                b2Vec2 velocity = b->GetLinearVelocity();
                float32 speed = velocity.Length();
                
                if (speed > maxSpeed) {
                    b->SetLinearDamping(0.5);
                } else if (speed < maxSpeed) {
                    b->SetLinearDamping(0.0);
                }
                
            }
            
            sprite.position = ccp(b->GetPosition().x * PTM_RATIO,
                                  b->GetPosition().y * PTM_RATIO);
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }

    
}


-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    UITouch * touch  = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    if(CGRectContainsPoint(_ball.boundingBox, location))
    {
        touchInSprite = YES;
        
        b2MouseJointDef md;
        md.bodyA = groundBody;
        md.bodyB = _body;
        md.target = locationWorld;
        md.collideConnected = true;
        md.maxForce = 1000.0f * _body->GetMass();
        
        _mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
        _body->SetAwake(true);
        
    }
    if (CGRectContainsPoint(_paddleSprite.boundingBox, location)) {
        
        b2MouseJointDef md;
        md.bodyA = groundBody;
        md.bodyB = _paddle;
        md.target = locationWorld;
        md.collideConnected = true;
        md.maxForce = 1000.0f * _paddle->GetMass();
        
        _mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
        _paddle->SetAwake(true);
        
    }
}


-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!_mouseJoint) {
        return;
    }
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    _mouseJoint->SetTarget(locationWorld);
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
}


-(void) dealloc
{
	delete _world;
    
	_world = NULL;
	_body = NULL;
	
	[super dealloc];
}



@end
