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

#import "SMStateMachine.h"


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer(){
    CGSize winSize;
    PaddleSprite* paddleOne;
    PaddleSprite* paddleTwo;
    CCSprite* playerOneScoreSprite;
    CCSprite* playerTwoScoreSprite;
    CCSprite* backgroundSprite;
    CCSprite* puckSprite;
    b2Body* puckBody;
    b2FixtureDef bodyFixtureDef;
    b2ContactFilter *contactFilter;
    b2EdgeShape leftBarrier;
    b2ContactFilter *filterbarrier;

    NSArray *scoreImagesArray;
    int playerOneScore;
    int playerTwoScore;
    
    // State Machine
    SMStateMachine *sm;
    SMState *attack;
    SMState *deffend;
    
}

-(void)defending;

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

#pragma mark - Initialize Instances

-(id) init
{
	if( (self=[super init])) {
		
        winSize = [[CCDirector sharedDirector] winSize];
		// enable events
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
        
        playerOneScore = 0;
        playerTwoScore = 0;
        
#warning Change this array with the actual images of the score.
        scoreImagesArray = [NSArray arrayWithObjects:@"Icon.png", @"Puck.png", @"Icon.png", @"Puck.png", @"Icon.png", @"Puck.png", @"Icon.png", nil];
        [scoreImagesArray retain]; //Because it's no ARC
                
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        backgroundSprite = [CCSprite spriteWithFile:@"TableBackground.png"];
        backgroundSprite.position = ccp(winSize.width / 2,winSize.height / 2);
        backgroundSprite.rotation = 90;
        backgroundSprite.scale = 2;
        backgroundSprite.scaleY = 2.37;
        [self addChild:backgroundSprite];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        playerOneScoreSprite = [CCSprite spriteWithFile:[scoreImagesArray objectAtIndex:playerOneScore] rect:CGRectMake(0, 0, 50, 50)];
        playerOneScoreSprite.position = ccp((winSize.width / 2) - 28, winSize.height - 34.5);
        [self addChild:playerOneScoreSprite];
        
        playerTwoScoreSprite = [CCSprite spriteWithFile:[scoreImagesArray objectAtIndex:playerTwoScore] rect:CGRectMake(0, 0, 50, 50)];
        playerTwoScoreSprite.position = ccp(winSize.width / 2 + 28, winSize.height - 34.5);
        playerTwoScoreSprite.rotation = 180;
        [self addChild:playerTwoScoreSprite];
        
        paddleOne = [[PaddleSprite alloc] initWithFile:@"Paddle.png" rect:CGRectMake(0, 0, 85, 85)];
        paddleOne.position = ccp(90, winSize.height / 2);
        paddleOne.scale = 0.75;
        paddleOne.tag = 1;
        [self addChild:paddleOne];
        
        paddleTwo = [[PaddleSprite alloc] initWithFile:@"Paddle.png" rect:CGRectMake(0, 0, 85, 85)];
        paddleTwo.position = ccp(winSize.width - 90, winSize.height / 2);
        paddleTwo.scale = 0.75;
        paddleTwo.tag = 2;
        [self addChild:paddleTwo];
        
        puckSprite = [[CCSprite alloc] initWithFile:@"Puck.png" rect:CGRectMake(0, 0, 150, 150)];
        puckSprite.position = ccp(winSize.width / 2, winSize.height / 2);
        puckSprite.scale = 0.48;
        [self addChild:puckSprite];
        
		// init physics
		[self initPhysics];
        [self initStateMachine];
        
	}
	return self;
}

-(void)initStateMachine{
    //Create structure
    sm = [[SMStateMachine alloc] init];
    sm.globalExecuteIn = self; //execute all selectors on self object
    attack = [sm createState:@"open"];
    deffend = [sm createState:@"closed"];
    sm.initialState = deffend;
    
    [attack setEntrySelector:@selector(attackMode)];
    [attack setExitSelector:@selector(returnToDefense)];
    [deffend setEntrySelector:@selector(deffendMode)];
    
    [sm transitionFrom:deffend to:attack forEvent:@"toAttack"];
    [sm transitionFrom:attack to:deffend forEvent:@"toDeffend"];
    
    [sm transitionFrom:deffend to:deffend forEvent:@"deffending" withSel:@selector(defending)];
    
    /*
    [sm transitionFrom:deffend to:opened forEvent:@"coin"];
    [sm transitionFrom:opened to:closed forEvent:@"pass"];
    [sm transitionFrom:opened to:closed forEvent:@"timeout"];
    [sm transitionFrom:opened to:opened forEvent:@"coin" withSel:@selector(returnCoin)];
    */
    
    //Usage
      [sm validate];  
   
}

-(void)defending
{
    CCLOG(@"Im defending");
}

-(void)deffendMode
{

    paddleOne.body->SetTransform(b2Vec2(90/PTM_RATIO, puckSprite.position.y/PTM_RATIO), 0);
    CCLOG(@"im defending");
    
}

-(void)attackMode
{
    CCLOG(@"Im Attacking");
}

-(void)returnToDefense
{
    
}

-(void) dealloc
{
	delete world;
	world = NULL;
    puckBody = NULL;
    scoreImagesArray = nil;
    [scoreImagesArray release];
    paddleOne = nil;
    [paddleOne release];
    paddleTwo = nil;
    [paddleTwo release];
    playerOneScoreSprite = nil;
    [playerOneScoreSprite release];
    playerTwoScoreSprite = nil;
    [playerTwoScoreSprite release];
    backgroundSprite = nil;
    [backgroundSprite release];
    puckSprite = nil;
    [puckSprite release];
    	
	[super dealloc];
}	

-(void) initPhysics
{
	[self createWorld];
    [paddleOne createBody];
    [paddleTwo createBody];
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
   // world->SetContactFilter(filterbarrier);

   // filterbarrier->ShouldCollide(bodyFixtureDef, );
    
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
    
    
    groundBox.Set(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(0, 0));
	groundBody->CreateMyFixture(&groundBox,0); //CreateMyFixture method created in b2Body class
	
    
	// right
	groundBox.Set(b2Vec2(winSize.width/ PTM_RATIO, winSize.height/(3 * PTM_RATIO)), b2Vec2(winSize.width/PTM_RATIO, 0));
	groundBody->CreateFixture(&groundBox,0);
    
	groundBox.Set(b2Vec2(winSize.width/ PTM_RATIO, 2 * winSize.height/(3 * PTM_RATIO)), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
    
    
    //http://www.iforce2d.net/b2dtut/collision-filtering
    groundBox.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
	groundBody->CreateMyFixture(&groundBox,0); //CreateMyFixture method created in b2Body class
}


-(void)createPuck{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    
    bodyDef.position.Set(winSize.width / (2 * PTM_RATIO), winSize.height /(2 * PTM_RATIO));
    bodyDef.userData = puckSprite;
    puckBody = world->CreateBody(&bodyDef);
    
    b2CircleShape paddleTwoShape;
    paddleTwoShape.m_radius = 27.0/PTM_RATIO;
    

    bodyFixtureDef.shape = &paddleTwoShape;
    bodyFixtureDef.density = 0.5f;
    bodyFixtureDef.friction = (0.5 * bodyFixtureDef.density);
    bodyFixtureDef.restitution = 0.8f;
    bodyFixtureDef.filter.groupIndex = -1;
    puckBody->CreateFixture(&bodyFixtureDef);
    puckBody->SetLinearDamping(0.05 * puckBody->GetMass());
    puckBody->SetAngularDamping(0.05 * puckBody->GetMass());
    
}


#pragma mark - Update Time Step

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
    
    //Analyse the position of the puck on the screen and replaced if neccesary
    if((puckBody->GetPosition()).x > winSize.width / PTM_RATIO){
        //playerTwoScore++;
        [playerTwoScoreSprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[scoreImagesArray objectAtIndex:playerTwoScore]]];
        puckBody->SetTransform(b2Vec2(winSize.width / (2 * PTM_RATIO), winSize.height / (2 * PTM_RATIO)), 0.0);
        puckBody->SetLinearVelocity(b2Vec2(0, 0));
        puckBody->SetAngularVelocity(0);
    }else if((puckBody->GetPosition()).x < 0){
        //playerOneScore++;
        [playerOneScoreSprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[scoreImagesArray objectAtIndex:playerOneScore]]];
        puckBody->SetTransform(b2Vec2(winSize.width / (2 * PTM_RATIO), winSize.height / (2 * PTM_RATIO)), 0.0);
        puckBody->SetLinearVelocity(b2Vec2(0, 0));
        puckBody->SetAngularVelocity(0);
    }
    
    if ((puckBody->GetPosition()).x>winSize.width/(2*PTM_RATIO)) {
        [sm post:@"deffending"];
        //[self defending];
        //CCLOG(@"im here");
    }
    else if ((puckBody->GetPosition()).x>winSize.width/(2*PTM_RATIO)) {
        [sm post:@"toAttack"];
    }
    

#warning In case that we want to allow to throw the paddle
//    if((paddleOne.position.x > (winSize.width / 2)) && (paddleTwo.position.x < (winSize.width / 2))){
//        [paddleOne setPosition:ccp(90, winSize.height / 2)];
//        paddleOne->body->SetTransform(b2Vec2(90 / PTM_RATIO, winSize.height / (2 * PTM_RATIO)), 0.0);
//        paddleOne->body->SetLinearVelocity(b2Vec2(0, 0));
//        paddleOne->body->SetAngularVelocity(0);
//        
//        [paddleTwo setPosition:ccp(winSize.width - 90, winSize.height / 2)];
//        paddleTwo->body->SetTransform(b2Vec2((winSize.width - 90) / PTM_RATIO, winSize.height / (2 * PTM_RATIO)), 0.0);
//        paddleTwo->body->SetLinearVelocity(b2Vec2(0, 0));
//        paddleTwo->body->SetAngularVelocity(0);
//    }
    
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, 10, 10);
}

@end
