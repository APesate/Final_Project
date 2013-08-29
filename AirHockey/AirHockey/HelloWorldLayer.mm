//
//  HelloWorldLayer.mm
//  AirHockey
//
//  Created by Andrés Pesate on 8/13/13.
//  Copyright Andrés Pesate 2013. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "SMStateMachine.h"
#import "SimpleAudioEngine.h"
#import "MyContactListener.h"
#import "GLES-Render.h"

#define MAX_PUCK_SPEED 25.0

static GameMode sGameMode;

typedef enum{
    ScoreAlert,
    DisconnectAlert
}AlertType;


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer(){
    PaddleSprite* paddleOne;
    PaddleSprite* paddleTwo;
    CCLayerColor* pauseLayer;
    CCSprite* playerOneScoreSprite;
    CCSprite* playerTwoScoreSprite;
    CCSprite* backgroundSprite;
    CCSprite* puckSprite;
    CCSprite* pauseButton;
    CCSprite* speakerIcon;
    CCLabelTTF* playerOneScoreLabel;
    CCLabelTTF* playerTwoScoreLabel;
    b2Body* puckBody;
    b2Body* groundBody;
    b2FixtureDef bodyFixtureDef;
    b2ContactFilter *contactFilter;
    b2ContactFilter *filterbarrier;
    b2EdgeShape leftBarrier;
    MyContactListener* _contactListener;
    
    GKPeerPickerController* picker;
    NSMutableArray* coordinatesArray;
    NSArray *scoreImagesArray;
    NSDate* creationDate;
    NSTimeInterval ping;
    NSString* soundState;
    CGSize winSize;
    CGPoint predictionDistance;
    CGPoint puckSpeedBeforePause;
    CGFloat lastXCoordinate;
    CGFloat lastYCoordinate;
    int playerOneScore;
    int playerTwoScore;
    BOOL isServer;
    BOOL isInGolArea;
    BOOL updateComputer;
    BOOL isInPauseScreen;
    BOOL soundActivated;
    
    // State Machine
    SMStateMachine *sm;
    SMState *attack;
    SMState *deffend;
    
}

@property HelloWorldLayer* layer;

-(void)defending;
-(void)attacking;

@end


@implementation HelloWorldLayer

@synthesize peerID = _peerID;
@synthesize session = _session;
@synthesize layer = _layer;
@synthesize delegate = _delegate;

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

+(CCScene *) sceneWithGameMode:(GameMode)mode andDelegate:(id)aDelegate
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer nodeWithGameMode:mode andDelegate:aDelegate];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

+(CCScene *) sceneForLayer:(id)layer
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

#pragma mark - Initialize Instances

+(id)nodeWithLayer:(id)layer gameMode:(GameMode)mode andDelegate:(id)aDelegate{
    sGameMode = mode;
    return [[[self alloc] initWithLayer:layer andDelegate:aDelegate] autorelease];
}

+(id)nodeWithGameMode:(GameMode)mode andDelegate:(id)aDelegate{
    return [[[self alloc] initWithGameMode:mode andDelegate:aDelegate] autorelease];
}

-(id) initWithGameMode:(GameMode)mode andDelegate:(id)aDelegate
{
	if( (self=[super init])) {
        sGameMode = mode;
        self.delegate = aDelegate;
        
        [self initialize];
	}
	return self;
}

-(id) init
{
	if( (self=[super init])) {
        [self initialize];
	}
	return self;
}

-(id) initWithLayer:(id)layer andDelegate:(id)aDelegate{
	if( (self=[super init])) {
        picker = [[GKPeerPickerController alloc] init];
        picker.delegate = self;
        picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
        _layer = layer;
        _delegate = aDelegate;
        
        [self.delegate retain];
        [self initialize];
        [picker show];
        
	}
	return self;
}

-(void)initialize{
    
    winSize = [[CCDirector sharedDirector] winSize];
    isServer = NO;
    isInPauseScreen = NO;
    creationDate = [[[NSDate alloc] init] retain];
    
    _peerID = [[NSMutableArray arrayWithCapacity:2] retain];
    coordinatesArray = [[NSMutableArray arrayWithCapacity:25] retain];
    
    // enable events
    self.touchEnabled = YES;
    //self.accelerometerEnabled = YES;
    
    playerOneScore = 0;
    playerTwoScore = 0;
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    
    if( winSize.width == 568 )
    {
        backgroundSprite = [CCSprite spriteWithFile:@"AirHockey_iPhone5.jpg"];
    }
    else
    {
        backgroundSprite = [CCSprite spriteWithFile:@"air_hockey_tabletop.jpg"];
    }
    
    backgroundSprite.position = ccp(winSize.width / 2,winSize.height / 2);
    
    [self addChild:backgroundSprite];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
    
    playerOneScoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Let's go Digital" fontSize:35];
    playerOneScoreLabel.position = ccp(winSize.width / 2 - 28, winSize.height - 34.5);
    [playerOneScoreLabel setColor:ccc3(255, 0, 0)];
    [self addChild:playerOneScoreLabel];
    
    playerTwoScoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Let's go Digital" fontSize:35];
    playerTwoScoreLabel.position = ccp(winSize.width / 2 + 28, winSize.height - 34.5);
    [playerTwoScoreLabel setColor:ccc3(255, 0, 0)];
    [self addChild:playerTwoScoreLabel];
    
    pauseButton = [[CCSprite alloc] initWithFile:@"Pause_Button.gif" rect:CGRectMake(0, 0, 164, 164)];
    pauseButton.position = ccp(winSize.width - 20, winSize.height - 50);
    pauseButton.scale = 0.40;
    [self addChild:pauseButton];
    
    paddleOne = [[PaddleSprite alloc] initWithFile:[NSString stringWithFormat:@"Paddle_%@.png", [[NSUserDefaults standardUserDefaults] objectForKey:@"Paddle_One_Color"]] rect:CGRectMake(0, 0, 120, 120)];
    paddleOne.position = ccp(90, winSize.height / 2);
    paddleOne.scale = 0.50;
    paddleOne.tag = 1;
    paddleOne.enabled = YES;
    [self addChild:paddleOne];
    
    paddleTwo = [[PaddleSprite alloc] initWithFile:[NSString stringWithFormat:@"Paddle_%@.png", [[NSUserDefaults standardUserDefaults] objectForKey:@"Paddle_Two_Color"]] rect:CGRectMake(0, 0, 120, 120)];
    paddleTwo.position = ccp(winSize.width - 90, winSize.height / 2);
    paddleTwo.scale = 0.50;
    paddleTwo.tag = 2;
    
    switch (sGameMode) {
        case SinglePlayerMode:
            paddleTwo.enabled = NO;
            [self performSelector:@selector(initStateMachine) withObject:nil afterDelay:3];
            break;
        case MultiplayerMode:
            paddleTwo.enabled = YES;
            break;
        case BluetoothMode:
            paddleTwo.enabled = NO;
            break;
            
        default:
            break;
    }
    
    [self addChild:paddleTwo];
    
    puckSprite = [[CCSprite alloc] initWithFile:@"Puck.gif" rect:CGRectMake(0, 0, 215, 215)];
    puckSprite.position = ccp(winSize.width / 2, winSize.height / 2);
    puckSprite.scale = 0.20;
    puckSprite.tag = 3;
    [self addChild:puckSprite];
    
    [self initPhysics];
    
}

#pragma mark StateMachine Compiler

-(void)initStateMachine{
    //Create structure
    updateComputer = YES;
    sm = [[SMStateMachine alloc] init];
    sm.globalExecuteIn = self; //execute all selectors on self object
    attack = [sm createState:@"open"];
    deffend = [sm createState:@"closed"];
    sm.initialState = deffend;
    
    
    [attack setEntrySelector:@selector(attackMode)];
    [deffend setEntrySelector:@selector(deffendMode)];
    //[deffend setExitSelector:@selector(exitAttack)];
    
    [sm transitionFrom:deffend to:attack forEvent:@"toAttack" ];
    [sm transitionFrom:attack to:deffend forEvent:@"toDeffend" withSel:@selector(exitAttack)];
    
    [sm transitionFrom:deffend to:deffend forEvent:@"deffending" withSel:@selector(defending)];
    [sm transitionFrom:attack to:attack forEvent:@"attacking" withSel:@selector(attacking)];
    //Usage
    // [sm validate];
    
}

-(void)defending
{
    //    CCLOG(@"Im defending");
}

-(void)deffendMode
{
    b2Vec2 linearVel = paddleTwo.body->GetLinearVelocity();
    linearVel.x *= .4;
    linearVel.y *= .4;
    
    b2Vec2 currentPosition = paddleTwo.body->GetPosition() + linearVel;
    float puckRatio = (puckBody->GetPosition().y/10);
    
    float windowSizeY = winSize.height/PTM_RATIO;
    float windowSizeX = winSize.width/PTM_RATIO;
    
    float positionPaddleY = (puckRatio*5.26)+2.364;
    float positionPaddleX = windowSizeX - sqrtf(powf((windowSizeY/6+40/PTM_RATIO),2)-powf((positionPaddleY-windowSizeY/2),2))-.5;
    
    //CCLOG(@"X: %f Y: %f",positionPaddleX,positionPaddleY);
    
    // CCLOG(@"%")
    
    b2Vec2 desiredPosition = b2Vec2((positionPaddleX>0)? positionPaddleX:0, positionPaddleY );
    b2Vec2 necessaryMovement = desiredPosition - currentPosition;
    float necessaryDistance = necessaryMovement.Length();
    
    necessaryMovement.Normalize();
    float forceMagnitude = (900>necessaryDistance)? 900:necessaryDistance;  //b2Min(, <#T b#>)  //b2Min(2000, necessaryDistance); //b2Min(2000, necessaryDistance);
    b2Vec2 force = forceMagnitude * necessaryMovement;
    
    paddleTwo.body->ApplyForce(force, paddleOne.body->GetWorldCenter() );
}

-(void)attacking
{
    //CCLOG(@"Im Attacking");
}

-(void)attackMode
{
    b2Vec2 linearVel = paddleTwo.body->GetLinearVelocity();
    linearVel.x *= 0.1;
    linearVel.y *= 0.1;
    b2Vec2 currentPosition = paddleTwo.body->GetPosition() + linearVel;
    b2Vec2 desiredPosition = b2Vec2(puckBody->GetPosition().x+20/PTM_RATIO, puckBody->GetPosition().y);
    b2Vec2 necessaryMovement = desiredPosition - currentPosition;
    //float necessaryDistance = necessaryMovement.Length();
    necessaryMovement.Normalize();
    float forceMagnitude = 2000;  //b2Min(, <#T b#>)  //b2Min(2000, necessaryDistance); //b2Min(2000, necessaryDistance);
    b2Vec2 force = forceMagnitude * necessaryMovement;
    paddleTwo.body->ApplyForce(force, paddleTwo.body->GetWorldCenter() );
    
}

-(void)exitAttack
{
    b2Vec2 linearVel = paddleTwo.body->GetLinearVelocity();
    linearVel.x *= 0.1;
    linearVel.y *= 0.1;
    b2Vec2 currentPosition = paddleTwo.body->GetPosition() + linearVel;
    b2Vec2 desiredPosition = b2Vec2(winSize.width/PTM_RATIO-winSize.width/(6*PTM_RATIO)-30/PTM_RATIO, puckBody->GetPosition().y);
    b2Vec2 necessaryMovement = desiredPosition - currentPosition;
    //float necessaryDistance = necessaryMovement.Length();
    necessaryMovement.Normalize();
    float forceMagnitude = 3000;  //b2Min(, <#T b#>)  //b2Min(2000, necessaryDistance); //b2Min(2000, necessaryDistance);
    b2Vec2 force = forceMagnitude * necessaryMovement;
    paddleTwo.body->ApplyForce(force, paddleTwo.body->GetWorldCenter() );
}


#pragma mark - Init Physics

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
    float32 timeStep = 1/60.0;      //the length of time passed to simulate (seconds)
    int32 velocityIterations = 8;   //how strongly to correct velocity
    int32 positionIterations = 3;   //how strongly to correct position
	
    gravity.Set(0.0f, 0.0f);
    
	world = new b2World(gravity);
    world->SetAllowSleeping(true);
	world->SetContinuousPhysics(true);
    world->Step(timeStep, velocityIterations, positionIterations);
    
    paddleOne->world = world;
    paddleTwo->world = world;
    
    // Create contact listener
    _contactListener = new MyContactListener();
    world->SetContactListener(_contactListener);
    
    // Preload effect
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Air Hockey Paddle Hit.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Air hockey Goal.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Air hockey puck set down wobble.mp3"];
}

-(void)createGround{
    
    // Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	groundBody = world->CreateBody(&groundBodyDef);
	paddleOne->world->CreateBody(&groundBodyDef);
    paddleTwo->world->CreateBody(&groundBodyDef);
    
	// Define the ground box shape.
	b2EdgeShape groundBox;
	
	// bottom
	
	groundBox.Set(b2Vec2(winSize.height/(PTM_RATIO * 20), winSize.height/(PTM_RATIO * 20)),
                  b2Vec2(winSize.width/PTM_RATIO, winSize.height/(PTM_RATIO * 20)));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(winSize.height/(PTM_RATIO * 20), (winSize.height/PTM_RATIO)-winSize.height/(PTM_RATIO * 20)),
                  b2Vec2((winSize.width/PTM_RATIO)-winSize.height/(PTM_RATIO * 20), (winSize.height/PTM_RATIO)-winSize.height/(PTM_RATIO * 20)));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(winSize.height/(PTM_RATIO * 20), winSize.height/(4 * PTM_RATIO)),
                  b2Vec2(winSize.height/(PTM_RATIO * 20), 0));
	groundBody->CreateFixture(&groundBox,0);
    
    groundBox.Set(b2Vec2(winSize.height/(PTM_RATIO * 20), 2.95 * winSize.height/(4 * PTM_RATIO)),
                  b2Vec2(winSize.height/(PTM_RATIO * 20), winSize.height / PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
    
    // left boundary for paddle
    b2EdgeShape paddleLeftBox;
    
    paddleLeftBox.Set(b2Vec2(0, 0),
                  b2Vec2(0, winSize.height/PTM_RATIO));
	groundBody->CreateMyFixture(&paddleLeftBox,0); //CreateMyFixture method created in b2Body class
	
    
	// right
	groundBox.Set(b2Vec2((winSize.width/ PTM_RATIO)-winSize.height/(PTM_RATIO * 20), winSize.height/(4 * PTM_RATIO)),
                  b2Vec2((winSize.width/PTM_RATIO)-winSize.height/PTM_RATIO/20, 0));
	groundBody->CreateFixture(&groundBox,0);
    
	groundBox.Set(b2Vec2((winSize.width/ PTM_RATIO)-winSize.height/(PTM_RATIO * 20), 2.95 * winSize.height/(4 * PTM_RATIO)),
                  b2Vec2((winSize.width/ PTM_RATIO)-winSize.height/(PTM_RATIO * 20), winSize.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
    
    
    // right boundary for paddle   http://www.iforce2d.net/b2dtut/collision-filtering
    b2EdgeShape paddleRightBox;
    
    paddleRightBox.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO),
                  b2Vec2(winSize.width/PTM_RATIO, 0));
	groundBody->CreateMyFixture(&paddleRightBox,0); //CreateMyFixture method created in b2Body class
    
    // Create rounded corner
    
    b2ChainShape roundedCorner;
    b2BodyDef roundedCornerDef;
    b2FixtureDef roundedCornerFixture;
    
    b2Vec2 vs[11];
    /*vs[0].Set(1.0f, 0.0f);
     vs[1].Set(0.05f, 0.01f);
     vs[2].Set(0.02f, 0.02f);
     vs[3].Set(0.01f, 0.05f);
     vs[4].Set(0.0f, 1.0f);*/
    
    for (float points = 0; points <= 1; points += 0.10f) {
        int index = points*10;
        float y = 1-sqrt(-(points-2)*points);
        vs[index].Set(points, y);
    }
    
    roundedCorner.CreateChain(vs, 11);
    roundedCornerDef.type = b2_staticBody;
    roundedCornerDef.position.Set(0.5, 0.5);
    
    b2Body* roundedCornerBody = world->CreateBody(&roundedCornerDef);
    roundedCornerBody->CreateFixture(&roundedCorner, 100);
    
    CCLOG(@"%f",roundedCornerDef.angle);
    
    roundedCornerDef.position.Set(winSize.width/PTM_RATIO-0.5, 0.5);
    roundedCornerDef.angle = 1.57f;
    roundedCornerBody = world->CreateBody(&roundedCornerDef);
    roundedCornerBody->CreateFixture(&roundedCorner, 100);
    
    roundedCornerDef.position.Set(winSize.width/PTM_RATIO-0.5, 9.5);
    roundedCornerDef.angle = 3.14f;
    roundedCornerBody = world->CreateBody(&roundedCornerDef);
    roundedCornerBody->CreateFixture(&roundedCorner, 100);
    
    roundedCornerDef.position.Set(0.5, 9.5);
    roundedCornerDef.angle = 4.71f;
    roundedCornerBody = world->CreateBody(&roundedCornerDef);
    roundedCornerBody->CreateFixture(&roundedCorner, 100);
    
    GLESDebugDraw *debugDraw = new GLESDebugDraw(PTM_RATIO);
    debugDraw->DrawPolygon(vs, 5, b2Color(100, 100, 100));
    world->SetDebugDraw(debugDraw);
    
    uint32 flags = 0;
    flags += 0x0001;
    flags += 0x0002;
    flags += 0x0010;
    
    //debugDraw->SetFlags(flags);
    //debugDraw = new GLESDebugDraw;
    // debugDraw->GLESDebugDraw(PTM_RATIO);
    //debugDraw->DrawPolygon(vs, 5,b2Color(30, 30, 30));
    //world->SetDebugDraw(debugDraw);
}


-(void)createPuck{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    
    bodyDef.position.Set(winSize.width / (2 * PTM_RATIO), winSize.height /(2 * PTM_RATIO));
    bodyDef.userData = puckSprite;
    puckBody = world->CreateBody(&bodyDef);
    
    b2CircleShape paddleTwoShape;
    paddleTwoShape.m_radius = 21.5/PTM_RATIO;
    
    
    bodyFixtureDef.shape = &paddleTwoShape;
    bodyFixtureDef.density = 0.8f;
    bodyFixtureDef.friction = (0.5 * bodyFixtureDef.density);
    bodyFixtureDef.restitution = 1.2f;
    bodyFixtureDef.filter.groupIndex = -2;
    puckBody->CreateFixture(&bodyFixtureDef);
    puckBody->SetLinearDamping(0.5 * puckBody->GetMass());
    puckBody->SetAngularDamping(0.5 * puckBody->GetMass());
    puckBody->SetFixedRotation(YES);
    
    lastXCoordinate = (puckBody->GetPosition()).x;
    lastYCoordinate = (puckBody->GetPosition()).y;
}

#pragma mark - Update Time Step

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
    
    
    
	world->Step(dt, 8, 3);
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
    {
        if (b->GetUserData()) {
            //Synchronize the AtlasSprites position and rotation with the corresponding body
            CCSprite *myActor = (CCSprite*)b->GetUserData();
            myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
    
    //Set Maxspeed for the puck
    CGFloat actualPuckSpeed = puckBody->GetLinearVelocity().Normalize();
    if (actualPuckSpeed > MAX_PUCK_SPEED) {
        CGFloat angle;
        CGFloat xSpeed;
        CGFloat ySpeed;
        
        angle = atan2f((puckBody->GetLinearVelocity()).y, (puckBody->GetLinearVelocity()).x);
        
        xSpeed = cosf(angle) * MAX_PUCK_SPEED;
        ySpeed = sinf(angle) * MAX_PUCK_SPEED;
        
        puckBody->SetLinearVelocity(b2Vec2(xSpeed, ySpeed));
    }
    
    //Analyse the position of the puck on the screen and replaced if neccesary
    if(!isInGolArea){
        if((puckBody->GetPosition()).x > winSize.width / PTM_RATIO){
            updateComputer = NO;
            isInGolArea = YES;
            playerOneScore++;
            playerOneScoreLabel.string = [NSString stringWithFormat:@"%i", playerOneScore];
            
            //[paddleOne destroyLink];
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"soundsActivated"]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"Air hockey Goal.mp3"];
            }
            
            [self performSelector:@selector(resetObjectsPositionAfterGoal:) withObject:@(1) afterDelay:1.0];
            [self updateScore:@(2)];
            
        }else if((puckBody->GetPosition()).x < 0){
            updateComputer = NO;
            isInGolArea = YES;
            playerTwoScore++;
            playerTwoScoreLabel.string = [NSString stringWithFormat:@"%i", playerTwoScore];
            
            //[paddleOne destroyLink];
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"soundsActivated"]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"Air hockey Goal.mp3"];
            }
            
            [self performSelector:@selector(resetObjectsPositionAfterGoal:) withObject:@(2) afterDelay:1.0];
            [self updateScore:@(1)];
        }
    }
    
    if ((puckBody->GetPosition()).x<winSize.width/(2*PTM_RATIO)&&updateComputer) {
        
        [sm post:@"toDeffend"];
        [sm post:@"deffending"];
        
    }
    if ((puckBody->GetPosition()).x>=winSize.width/(2*PTM_RATIO)&&updateComputer) {
        [sm post:@"toAttack"];
        [sm post:@"attacking"];
    }
}

#pragma mark - Data Send

-(void)puckSpeed{
    if(self.session != nil && isServer){
        CGFloat xPrediction = (predictionDistance.x / ping);
        CGFloat yPrediction = (predictionDistance.y / ping);
        
        CGFloat xCoordinate = (-1) * (puckBody->GetLinearVelocity()).x;
        CGFloat yCoordinate = (-1) * (puckBody->GetLinearVelocity()).y;
        
        if (lastXCoordinate < xCoordinate) {
            xCoordinate = xCoordinate + (xPrediction / winSize.width);
        }else{
            xCoordinate = xCoordinate - (xPrediction / winSize.width);
        }
        
        if (lastYCoordinate < yCoordinate) {
            yCoordinate = yCoordinate + (yPrediction / winSize.height);
        }else{
            yCoordinate = yCoordinate - (yPrediction / winSize.height);
        }
        
        CGPoint puckSpeed = CGPointMake(xCoordinate, yCoordinate);
        NSValue* valueToSend = [NSValue valueWithCGPoint:puckSpeed];
        
        NSDictionary* coordinates = @{@"Speed": valueToSend, @"DataType": @"DataForPuckSpeed"};
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:coordinates];
        NSError* error = nil;
        
        if(![_session sendData:data toPeers:_peerID withDataMode:GKSendDataReliable error:&error]){
            NSLog(@"Error sending Puck Speed data to clients: %@", error);
        }
    }
}

-(void)puckCoordinates{
    if(self.session != nil && isServer){
        CGFloat xPrediction = (puckBody->GetLinearVelocity()).x * ping * puckBody->GetLinearDamping();
        CGFloat yPrediction = (puckBody->GetLinearVelocity()).y * ping * puckBody->GetLinearDamping();
        predictionDistance = CGPointMake(xPrediction, yPrediction);
        
        CGFloat xCoordinate = ((winSize.width / PTM_RATIO) - (puckBody->GetPosition()).x) / winSize.width;
        CGFloat yCoordinate = ((winSize.height / PTM_RATIO) - (puckBody->GetPosition()).y) / winSize.height;
        
        if (lastXCoordinate < xCoordinate) {
            xCoordinate = xCoordinate + (xPrediction / winSize.width);
        }else{
            xCoordinate = xCoordinate - (xPrediction / winSize.width);
        }
        
        if (lastYCoordinate < yCoordinate) {
            yCoordinate = yCoordinate + (yPrediction / winSize.height);
        }else{
            yCoordinate = yCoordinate - (yPrediction / winSize.height);
        }
        
        lastXCoordinate = xCoordinate;
        lastYCoordinate = yCoordinate;
        
        CGPoint puckCoordinates = CGPointMake(xCoordinate, yCoordinate);
        NSValue* valueToSend = [NSValue valueWithCGPoint:puckCoordinates];
        
        NSDictionary* coordinates = @{@"Coord": valueToSend, @"DataType": @"DataForPuckCoordinates"};
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:coordinates];
        NSError* error = nil;
        
        if(![_session sendData:data toPeers:_peerID withDataMode:GKSendDataReliable error:&error]){
            NSLog(@"Error sending Puck Coordinates data to clients: %@", error);
        }
    }
}

-(void)lookingForPing{
    [creationDate release];
    creationDate = [[[NSDate alloc] init] retain];
    
    NSDictionary* pingData = @{@"DataType": @"DataAskingForPing"};
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:pingData];
    NSError* error;
    
    if(![_session sendData:data toPeers:_peerID withDataMode:GKSendDataReliable error:&error]){
        NSLog(@"Error sending Puck Coordinates data to clients: %@", error);
    }
}

-(void)updateScore:(NSNumber *)position{
    if(self.session != nil && isServer){
        NSNumber* playerTwo = @(playerOneScore);
        NSNumber* playerOne = @(playerTwoScore);
        
        NSDictionary* coordinates = @{@"One": playerOne, @"Two": playerTwo, @"Position": position, @"DataType": @"UpdateScore"};
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:coordinates];
        NSError* error = nil;
        
        if(![_session sendData:data toPeers:_peerID withDataMode:GKSendDataReliable error:&error]){
            NSLog(@"Error sending Score Update data to clients: %@", error);
        }
    }
}

#pragma mark - On Goal Actions

-(void)resetObjectsPositionAfterGoal:(NSNumber *)position{
    
    CGPoint puckNewPosition;
    CGPoint paddleOneNewPosition;
    CGPoint paddleTwoNewPosition;
    
    puckBody->SetLinearVelocity(b2Vec2(0, 0));
    puckBody->SetAngularVelocity(0);
    puckBody->SetUserData(nil);
    
    switch (position.integerValue) {
        case 1:{
            puckBody->SetTransform(b2Vec2((winSize.width / (2 * PTM_RATIO)) + (50 / PTM_RATIO), winSize.height / (2 * PTM_RATIO)), 0.0);
            puckNewPosition = CGPointMake((puckBody->GetPosition()).x * PTM_RATIO, (puckBody->GetPosition()).y * PTM_RATIO);
            puckNewPosition = [[CCDirector sharedDirector] convertToGL:puckNewPosition];
            [puckSprite stopAllActions];
            [puckSprite runAction:[CCSequence actionOne:[CCJumpTo actionWithDuration:0.7
                                                                            position:puckNewPosition
                                                                              height:100
                                                                               jumps:1]
                                                    two:[CCCallFunc actionWithTarget:self selector:@selector(playSound)]]];;
            [self showAlertFor:ScoreAlert];
            break;
        }
        case 2:{
            puckBody->SetTransform(b2Vec2((winSize.width / (2 * PTM_RATIO)) - (50 / PTM_RATIO), winSize.height / (2 * PTM_RATIO)), 0.0);
            puckNewPosition = CGPointMake((puckBody->GetPosition()).x * PTM_RATIO, (puckBody->GetPosition()).y * PTM_RATIO);
            puckNewPosition = [[CCDirector sharedDirector] convertToGL:puckNewPosition];
            
            [puckSprite stopAllActions];
            [puckSprite runAction:[CCSequence actionOne:[CCJumpTo actionWithDuration:0.7
                                                                            position:puckNewPosition
                                                                              height:100
                                                                               jumps:1]
                                                    two:[CCCallFunc actionWithTarget:self selector:@selector(playSound)]]];
            [self showAlertFor:ScoreAlert];
            break;
        }
        case 3:
            puckBody->SetTransform(b2Vec2(winSize.width / (2 * PTM_RATIO), winSize.height / (2 * PTM_RATIO)), 0.0);
            puckNewPosition = CGPointMake((puckBody->GetPosition()).x * PTM_RATIO, (puckBody->GetPosition()).y * PTM_RATIO);
            puckNewPosition = [[CCDirector sharedDirector] convertToGL:puckNewPosition];
            
            [puckSprite stopAllActions];
            [puckSprite runAction:[CCSequence actionOne:[CCJumpTo actionWithDuration:0.7
                                                                            position:puckNewPosition
                                                                              height:100
                                                                               jumps:1]
                                                    two:[CCCallFunc actionWithTarget:self selector:@selector(playSound)]]];
            
            paddleOne.body->SetLinearVelocity(b2Vec2(0, 0));
            paddleOne.body->SetUserData(nil);
            paddleOne.body->SetTransform(b2Vec2(90 / PTM_RATIO, winSize.height / (2 * PTM_RATIO)), 0.0);
            
            paddleTwo.body->SetLinearVelocity(b2Vec2(0, 0));
            paddleTwo.body->SetUserData(nil);
            paddleTwo.body->SetTransform(b2Vec2((winSize.width / PTM_RATIO) - (90 / PTM_RATIO),
                                                winSize.height / (2 * PTM_RATIO)), 0.0);
            
            [paddleOne stopAllActions];
            paddleOneNewPosition = CGPointMake((paddleOne.body->GetPosition()).x * PTM_RATIO, (paddleOne.body->GetPosition()).y * PTM_RATIO);
            paddleOneNewPosition = [[CCDirector sharedDirector] convertToGL:paddleOneNewPosition];
            [paddleOne runAction:[CCMoveTo actionWithDuration:1.0 position:paddleOneNewPosition]];
            paddleOne.enabled = NO;
            
            [paddleTwo stopAllActions];
            paddleTwoNewPosition = CGPointMake((paddleTwo.body->GetPosition()).x * PTM_RATIO, (paddleTwo.body->GetPosition()).y * PTM_RATIO);
            paddleTwoNewPosition = [[CCDirector sharedDirector] convertToGL:paddleTwoNewPosition];
            paddleTwo.enabled = NO;
            break;
        default:
            break;
    }
    
    [sm post:@"deffendMode"];
    [[CCDirector sharedDirector] touchDispatcher].dispatchEvents = YES;
    [paddleTwo runAction:[CCSequence actions:
                          [CCMoveTo actionWithDuration:1.0 position:paddleTwoNewPosition],
                          [CCCallFunc actionWithTarget:self selector:@selector(assignObjectsBodiesAgain)], nil]];
}

-(void)playSound{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"soundsActivated"]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"Air hockey puck set down wobble.mp3"];
    }
    puckBody->SetAngularVelocity(10);
}

-(void)updateComp
{
    updateComputer = YES;
}

-(void)assignObjectsBodiesAgain{
    paddleOne.body->SetUserData(paddleOne);
    paddleTwo.body->SetUserData(paddleTwo);
    puckBody->SetUserData(puckSprite);
    
    switch (sGameMode) {
        case SinglePlayerMode:
            [self performSelector:@selector(updateComp) withObject:nil afterDelay:1.0];
            paddleOne.enabled = YES;
            break;
        case MultiplayerMode:
            updateComputer = NO;
            paddleOne.enabled = YES;
            paddleTwo.enabled = YES;
            break;
        case BluetoothMode:
            paddleOne.enabled = YES;
            break;
        default:
            break;
    }
    
    if (_session == nil) {
        isInGolArea = NO;
    }else if (isServer){
        isInGolArea = NO;
    }
}

#pragma mark - GKSessionDataHandler

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context{
    
    NSDictionary *dataDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString* dataType = [dataDictionary objectForKey:@"DataType"];
    
    if([dataType isEqualToString:@"DataForPing"]){
        NSDate* pingDate = [NSDate date];
        ping = [pingDate timeIntervalSinceDate:creationDate];
        
    }else if([dataType isEqualToString:@"DataAskingForPing"]){
        NSDictionary* pingData = @{@"DataType": @"DataForPing"};
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:pingData];
        NSError* error;
        
        if(![_session sendData:data toPeers:_peerID withDataMode:GKSendDataReliable error:&error]){
            NSLog(@"Error sending Puck Coordinates data to clients: %@", error);
        }
        
    }else if ([dataType isEqualToString:@"DataForPuckSpeed"]) {
        
        NSValue* value = [dataDictionary objectForKey:@"Speed"];
        CGPoint newSpeed;
        [value getValue:&newSpeed];
        
        puckBody->SetLinearVelocity(b2Vec2(newSpeed.x, newSpeed.y));
        
    }else if ([dataType isEqualToString:@"DataForPuckCoordinates"]){
        NSValue* value = [dataDictionary objectForKey:@"Coord"];
        CGPoint newCoord;
        [value getValue:&newCoord];
        
        puckBody->SetLinearVelocity(b2Vec2(0, 0));
        puckBody->SetTransform(b2Vec2(newCoord.x * winSize.width, newCoord.y * winSize.height), 0.0);
        
    }else if([dataType isEqualToString:@"DataForPaddleStartMoving"]){
        
        [paddleTwo paddleWillStartMoving];
        
    }else if([dataType isEqualToString:@"DataForPaddleIsMoving"]){
        CGFloat xCoodinate = ((NSNumber *)[dataDictionary objectForKey:@"x"]).floatValue * winSize.width;
        CGFloat yCoodinate = ((NSNumber *)[dataDictionary objectForKey:@"y"]).floatValue * winSize.height;
        
        paddleTwo.mouseJoint->SetTarget(b2Vec2(xCoodinate, yCoodinate));
        
    }else if([dataType isEqualToString:@"DataForPaddleStopMoving"]){
        CGFloat xCoodinate = ((NSNumber *)[dataDictionary objectForKey:@"x"]).floatValue;
        CGFloat yCoodinate = ((NSNumber *)[dataDictionary objectForKey:@"y"]).floatValue;
        
        paddleTwo.body->ApplyLinearImpulse(b2Vec2(xCoodinate, yCoodinate), paddleTwo.body->GetWorldCenter());
        
        [paddleTwo paddleWillStopMoving];
        
    }else if([dataType isEqualToString:@"CreationDateData"]){
        NSDate* peerDate = [dataDictionary objectForKey:@"Date"];
        if([creationDate compare:peerDate] == NSOrderedAscending){
            isServer = YES;
            paddleOne.myID = _session.sessionID;
            
            [self schedule:@selector(puckCoordinates) interval:0.025f];
            //[self schedule:@selector(puckSpeed) interval:0.10f];
            [self schedule:@selector(lookingForPing) interval:0.10f];
        }
    }else if([dataType isEqualToString:@"UpdateScore"]){
        playerOneScore = ((NSNumber *)[dataDictionary objectForKey:@"One"]).integerValue;
        playerTwoScore = ((NSNumber *)[dataDictionary objectForKey:@"Two"]).integerValue;
        NSNumber* position = ((NSNumber *)[dataDictionary objectForKey:@"Position"]);
        
        playerOneScoreLabel.string = [NSString stringWithFormat:@"%i", playerOneScore];
        playerTwoScoreLabel.string = [NSString stringWithFormat:@"%i", playerTwoScore];
        isInGolArea = YES;
        
        [self performSelector:@selector(resetObjectsPositionAfterGoal:) withObject:position afterDelay:1.0];
    }else if([dataType isEqualToString:@"PauseScreen"]){
        isInPauseScreen = YES;
        [self pauseScreen];
    }else if([dataType isEqualToString:@"ResumeGame"]){
        isInPauseScreen = NO;
        [self resume];
    }
    
}

#pragma mark - GKPeerPickerDelegate

- (void)peerPickerController:(GKPeerPickerController *)_picker didConnectPeer:(NSString *)peerID toSession: (GKSession *) session {
    [_peerID addObject:peerID];
    
    // Use a retaining property to take ownership of the session.
    self.session = session;
    // Assumes our object will also become the session's delegate.
    paddleOne.session = [[GKSession alloc] init];
    paddleOne.friendID = [[NSMutableArray arrayWithCapacity:1] retain];
    [paddleOne.friendID addObject:peerID];
    paddleOne.session = session;
    
    //    paddleTwo.session = [[GKSession alloc] init];
    //    paddleTwo.friendID = [[NSMutableArray arrayWithCapacity:1] retain];
    //    [paddleTwo.friendID addObject:peerID];
    //    paddleTwo.session = session;
    
    
    [paddleOne.session setDataReceiveHandler:self withContext:nil];
    //[paddleTwo.session setDataReceiveHandler:self withContext:nil];
    
    
    session.delegate = self;
    [session setDataReceiveHandler: self withContext:nil];
    
    // Remove the picker.
    [_picker dismiss];
    _picker.delegate = nil;
    [_picker autorelease];
    
    // Start your game.
    NSDictionary* dataDictionary = @{@"Date": creationDate, @"DataType": @"CreationDateData"};
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:dataDictionary];
    NSError* error = nil;
    
    if(![_session sendData:data toPeers:_peerID withDataMode:GKSendDataReliable error:&error]){
        NSLog(@"Error sending creationDate data to peer: %@", error);
    }
    
}


- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)_picker
{
    _picker.delegate = nil;
    // The controller dismisses the dialog automatically.
    [_picker autorelease];
    [self.delegate goToMenuLayer];
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    switch (state)
    {
        case GKPeerStateAvailable:
            NSLog(@"Available");
            break;
        case GKPeerStateConnecting:
            NSLog(@"Connecting");
            break;
        case GKPeerStateConnected:
            NSLog(@"Connected");
            break;
        case GKPeerStateDisconnected:
            NSLog(@"Disconnected");
            [self showAlertFor:DisconnectAlert];
            break;
        case GKPeerStateUnavailable:
            NSLog(@"Unavailable");
            break;
        default:
            NSLog(@"Wrong State");
    }
}

-(void) session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID{
    NSError* error;
    
    NSLog(@"Did receive connection request from peer %@", peerID);
    
    if(![session acceptConnectionFromPeer:peerID error:&error]){
        NSLog(@"Session receive connection request error: %@", error);
    }
}

-(void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error{
    NSLog(@"Connection Failed: %@", error);
}

-(void)session:(GKSession *)session didFailWithError:(NSError *)error{
    NSLog(@"Session Failed Error: %@", error);
}

#pragma mark UIAlerts

-(void)showAlertFor:(AlertType)type{
    switch (type) {
        case ScoreAlert:
            if(playerTwoScore == 7 || playerOneScore == 7){
                
                NSString* title = [NSString stringWithFormat:@"Player %@ Wins!", playerOneScore > playerTwoScore?@"One":@"Two"];
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Game Over!"
                                                                message:title
                                                               delegate:self
                                                      cancelButtonTitle:@"Exit"
                                                      otherButtonTitles:@"Rematch", nil];
                
                updateComputer = NO;
                
                [self performSelector:@selector(resetObjectsPositionAfterGoal:) withObject:@(3) afterDelay:1.5];
                [alert setAlertViewStyle:UIAlertViewStyleDefault];
                [alert show];
                [alert release];
            }else{
                [self performSelector:@selector(updateComp) withObject:nil afterDelay:2.0];
            }
            break;
        case DisconnectAlert:{
            
            NSString* message = [NSString stringWithFormat:@"The connection with the other device was lost."];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Connection Lost!"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Exit"
                                                  otherButtonTitles:nil];
            
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
            [alert release];
            break;
        }
        default:
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self.delegate goToMenuLayer];
            break;
        case 1:{
            if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Rematch"]) {
                playerOneScore = 0;
                playerTwoScore = 0;
                
                playerOneScoreLabel.string = @"0";
                playerTwoScoreLabel.string = @"0";
                
                switch (sGameMode) {
                    case SinglePlayerMode:
                        [self performSelector:@selector(updateComp) withObject:nil afterDelay:1.0];
                        paddleOne.enabled = YES;
                        break;
                    case MultiplayerMode:
                        updateComputer = NO;
                        paddleOne.enabled = YES;
                        paddleTwo.enabled = YES;
                        break;
                    case BluetoothMode:
                        paddleOne.enabled = YES;
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Pause Screen

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint coord = [touch locationInView:touch.view];
    coord = [[CCDirector sharedDirector] convertToGL:coord];
    
    if (CGRectContainsPoint(pauseButton.boundingBox, coord)) {
        if(!isInPauseScreen){
            [self pauseScreen];
        }
    }else if (CGRectContainsPoint(speakerIcon.boundingBox, coord)) {
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"soundsActivated"] integerValue]) {
            CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:@"Unmute_Speaker.png"];
            [speakerIcon setTexture: tex];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"soundsActivated"];
        }else{
            CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:@"Mute_Speaker.png"];
            [speakerIcon setTexture: tex];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"soundsActivated"];
        }
        
    [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)pauseScreen{
    pauseLayer = [[CCLayerColor alloc] initWithColor:ccc4(255, 255, 255, 120)];
    [self addChild:pauseLayer];
    
    paddleOne.body->SetLinearVelocity(b2Vec2(0, 0));
    paddleTwo.body->SetLinearVelocity(b2Vec2(0, 0));
    puckSpeedBeforePause = CGPointMake((puckBody->GetLinearVelocity()).x, (puckBody->GetLinearVelocity()).y);
    puckBody->SetLinearVelocity(b2Vec2(0, 0));
    
    if(isInGolArea){
        puckSpeedBeforePause = CGPointMake(0, 0);
    }else{
        isInGolArea = YES;
    }
    
    switch (sGameMode) {
        case SinglePlayerMode:
            updateComputer = NO;
            isInPauseScreen = YES;
            paddleOne.enabled = NO;
            [self createMenu];
            break;
        case MultiplayerMode:
            paddleOne.enabled = NO;
            isInPauseScreen = YES;
            paddleTwo.enabled = NO;
            [self createMenu];
            break;
        case BluetoothMode:{
            paddleOne.enabled = NO;
            
            if (!isInPauseScreen) {
                [self createMenu];
                isInPauseScreen = YES;
                NSDictionary* dataDictionary = @{@"DataType": @"PauseScreen"};
                NSData* data = [NSKeyedArchiver archivedDataWithRootObject:dataDictionary];
                NSError* error = nil;
                
                if(![_session sendData:data toPeers:_peerID withDataMode:GKSendDataReliable error:&error]){
                    NSLog(@"Error sending PauseScreen data to peer: %@", error);
                }
            }
            break;
        }
        default:
            break;
    }
    
    if((int)[[NSUserDefaults standardUserDefaults] objectForKey:@"soundsActivated"]){
        soundState = @"Mute";
    }else{
        soundState = @"Unmute";
    }
    
    speakerIcon = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_Speaker.png",  soundState] rect:CGRectMake(0, 0, 78, 78)];
    speakerIcon.position = ccp(winSize.width - 10, 10);
    [pauseLayer addChild:speakerIcon];
}

-(void)createMenu{
    CCMenuItemFont* resumeButton = [CCMenuItemFont itemWithString:@"Resume Game"
                                                           target:self
                                                         selector:@selector(resumeGame:)];
    [resumeButton setColor:ccc3(241, 196, 15)];
    
    CCMenuItemFont* exitButton = [CCMenuItemFont itemWithString:@"Quit Game"
                                                         target:self
                                                       selector:@selector(exitButton:)];
    [exitButton setColor:ccc3(241, 196, 15)];
    
    CCMenu *pauseMenu = [CCMenu menuWithItems: resumeButton, exitButton, nil];
    
    
    [pauseMenu alignItemsVerticallyWithPadding:30];
    
    [pauseLayer addChild:pauseMenu];
}

-(void)resumeGame: (CCMenuItem  *) menuItem{
    switch (sGameMode) {
        case SinglePlayerMode:
            updateComputer = YES;
            break;
        case MultiplayerMode:
            updateComputer = NO;
            paddleTwo.enabled = YES;
            break;
        case BluetoothMode:{
            NSDictionary* dataDictionary = @{@"DataType": @"ResumeGame"};
            NSData* data = [NSKeyedArchiver archivedDataWithRootObject:dataDictionary];
            NSError* error = nil;
            
            if(![_session sendData:data toPeers:_peerID withDataMode:GKSendDataReliable error:&error]){
                NSLog(@"Error sending PauseScreen data to peer: %@", error);
            }
            break;
        }
        default:
            break;
    }
    [self resume];
}

-(void)resume{
    isInPauseScreen = NO;
    isInGolArea = NO;
    paddleOne.enabled = YES;
    
    puckBody->SetLinearVelocity(b2Vec2(puckSpeedBeforePause.x, puckSpeedBeforePause.y));
    
    [self removeChild:pauseLayer];
}

-(void)exitButton: (CCMenuItem  *) menuItem{
    if(sGameMode == BluetoothMode){
        [_session disconnectFromAllPeers];
        _session.available = NO;
        [_session setDataReceiveHandler: nil withContext: nil];
        _session.delegate = nil;
        [_session release];
    }
    
    [self removeChild:pauseLayer];
    [self.delegate goToMenuLayer];
}

#pragma mark - Memory Management

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
    _delegate = nil;
    [_delegate release];
    _layer = nil;
    [_layer release];
    [_session disconnectFromAllPeers];
    _session.available = NO;
    [_session setDataReceiveHandler: nil withContext: nil];
    _session.delegate = nil;
    [_session release];
    creationDate = nil;
    [creationDate release];
    [self release];
    delete _contactListener;
	[super dealloc];
}

@end
