//
//  HelloWorldLayer.mm
//  AirHockey
//
//  Created by Andrés Pesate on 8/13/13.
//  Copyright Andrés Pesate 2013. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

// Not included in "cocos2d.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer(){
    CGSize winSize;
    PaddleSprite* paddleOne;
    CCSprite* backgroundSprite;
    CCSprite* puckSprite;
    b2Body* puckBody;
    PaddleSprite* paddleTwo;
}
-(void) initPhysics;
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
		
        winSize = [[CCDirector sharedDirector] winSize];
		// enable events
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        backgroundSprite = [CCSprite spriteWithFile:@"TableBackground.png"];
        backgroundSprite.position = ccp(winSize.width / 2,winSize.height / 2);
        backgroundSprite.rotation = 90;
        backgroundSprite.scale = 2;
        backgroundSprite.scaleY = 2.37
        ;
        [self addChild:backgroundSprite];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        paddleOne = [[PaddleSprite alloc] initWithFile:@"Paddle.png" rect:CGRectMake(0, 0, 85, 85)];
        paddleOne.position = ccp(90, winSize.height / 2);
        paddleOne.scale = 0.75;
        [self addChild:paddleOne];
        
        paddleTwo = [[PaddleSprite alloc] initWithFile:@"Paddle.png" rect:CGRectMake(0, 0, 85, 85)];
        paddleTwo.position = ccp(winSize.width - 90, winSize.height / 2);
        paddleTwo.scale = 0.75;
        [self addChild:paddleTwo];
        
        puckSprite = [[CCSprite alloc] initWithFile:@"Puck.png" rect:CGRectMake(0, 0, 85, 85)];
        puckSprite.position = ccp(winSize.width / 2, winSize.height / 2);
        puckSprite.scale = 0.75;
        [self addChild:puckSprite];
        
		// init physics
		[self initPhysics];
	}
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	[super dealloc];
}	

-(void) initPhysics
{
	[self createWorld];
    [paddleOne createBodyWithCoordinateType:1];
    [paddleTwo createBodyWithCoordinateType:2];
    [self createPuck];
    [self createGround];
    [self schedule:@selector(update:)];
}

-(void)createWorld{
    b2Vec2 gravity;
	gravity.Set(0.0f, 0.0f);
	world = new b2World(gravity);
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
    
    
    paddleOne->world = world;
    paddleTwo->world = world;
}

-(void)createGround{

    // Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	paddleOne->world->CreateBody(&groundBodyDef);
    paddleTwo->world->CreateBody(&groundBodyDef);
    
	// Define the ground box shape.
	b2EdgeShape groundBox;
	
	// bottom
	
	groundBox.Set(b2Vec2(0, 0), b2Vec2(winSize.width/PTM_RATIO, 0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0, winSize.height/(3 * PTM_RATIO)), b2Vec2(0, 0));
	groundBody->CreateFixture(&groundBox,0);
    
    groundBox.Set(b2Vec2(0, 2 * winSize.height/(3 * PTM_RATIO)), b2Vec2(0, winSize.height / PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(winSize.width/ PTM_RATIO, winSize.height/(3 * PTM_RATIO)), b2Vec2(winSize.width/PTM_RATIO, 0));
	groundBody->CreateFixture(&groundBox,0);
    
	groundBox.Set(b2Vec2(winSize.width/ PTM_RATIO, 2 * winSize.height/(3 * PTM_RATIO)), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
}

-(void)createPuck{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    
    bodyDef.position.Set(winSize.width / (2 * PTM_RATIO), winSize.height /(2 * PTM_RATIO));
    bodyDef.userData = puckSprite;
    puckBody = world->CreateBody(&bodyDef);
    
    b2CircleShape paddleTwoShape;
    paddleTwoShape.m_radius = 31.0/PTM_RATIO;
    
    b2FixtureDef bodyTextureDef;
    bodyTextureDef.shape = &paddleTwoShape;
    bodyTextureDef.density = 10.0f;
    bodyTextureDef.friction = (0.5 * bodyTextureDef.density);
    bodyTextureDef.restitution = 0.8f;
    puckBody->CreateFixture(&bodyTextureDef);
    puckBody->SetLinearDamping(0.01 * puckBody->GetMass());
}

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
    {
        if (b->GetUserData() != NULL) {
            //Synchronize the AtlasSprites position and rotation with the corresponding body
            CCSprite *myActor = (CCSprite*)b->GetUserData();
            myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
    
    if((puckBody->GetPosition()).x > winSize.width / PTM_RATIO|| (puckBody->GetPosition()).x < 0){
        puckBody->SetTransform(b2Vec2(winSize.width / (2 * PTM_RATIO), winSize.height / (2 * PTM_RATIO)), 0.0);
        puckBody->SetLinearVelocity(b2Vec2(0, 0));
        puckBody->SetAngularVelocity(0);
    }
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, 10, 10);

}

@end
