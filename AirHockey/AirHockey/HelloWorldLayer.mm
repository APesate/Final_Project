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

#define MAX_PUCK_SPEED 30.0

static GameMode sGameMode;

typedef enum{
    ScoreAlert,
    DisconnectAlert
}AlertType;


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer(){
    PaddleSprite* paddleOne;
    PaddleSprite* paddleTwo;
    CCSprite* playerOneScoreSprite;
    CCSprite* playerTwoScoreSprite;
    CCSprite* backgroundSprite;
    CCSprite* puckSprite;
    b2Body* puckBody;
    b2FixtureDef bodyFixtureDef;
    b2ContactFilter *contactFilter;
    b2ContactFilter *filterbarrier;
    b2EdgeShape leftBarrier;
    
    GKPeerPickerController* picker;
    NSMutableArray* coordinatesArray;
    NSArray *scoreImagesArray;
    NSDate* creationDate;
    NSTimer* timer;
    CGSize winSize;
    int playerOneScore;
    int playerTwoScore;
    BOOL isServer;
    BOOL isInGolArea;

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

@synthesize serverID = _serverID;
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
    creationDate = [[NSDate date] retain];
    
    coordinatesArray = [[NSMutableArray arrayWithCapacity:25] retain];
    
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
    paddleOne.enabled = YES;
    [self addChild:paddleOne];
    
    paddleTwo = [[PaddleSprite alloc] initWithFile:@"Paddle.png" rect:CGRectMake(0, 0, 85, 85)];
    paddleTwo.position = ccp(winSize.width - 90, winSize.height / 2);
    paddleTwo.scale = 0.75;
    paddleTwo.tag = 2;
    
    switch (sGameMode) {
        case SinglePlayerMode:
            paddleOne.enabled = NO;
            paddleTwo.enabled = YES;
            [self initStateMachine];
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
    
    puckSprite = [[CCSprite alloc] initWithFile:@"Puck.png" rect:CGRectMake(0, 0, 150, 150)];
    puckSprite.position = ccp(winSize.width / 2, winSize.height / 2);
    puckSprite.scale = 0.48;
    [self addChild:puckSprite];
    
    [self initPhysics];
    
}

#pragma mark StateMachine Compiler

-(void)initStateMachine{
    //Create structure
    sm = [[SMStateMachine alloc] init];
    sm.globalExecuteIn = self; //execute all selectors on self object
    attack = [sm createState:@"open"];
    deffend = [sm createState:@"closed"];
    sm.initialState = deffend;
    
    
    [attack setEntrySelector:@selector(attackMode)];
    [deffend setEntrySelector:@selector(deffendMode)];
    
    [sm transitionFrom:deffend to:attack forEvent:@"toAttack"];
    [sm transitionFrom:attack to:deffend forEvent:@"toDeffend"];
    
    [sm transitionFrom:deffend to:deffend forEvent:@"deffending" withSel:@selector(defending)];
    [sm transitionFrom:attack to:attack forEvent:@"attacking" withSel:@selector(attacking)];
    //Usage
      [sm validate];  
}

-(void)defending
{
//    CCLOG(@"Im defending");
}

-(void)deffendMode
{
    b2Vec2 linearVel = paddleOne.body->GetLinearVelocity();
    linearVel.x *= .2;
    linearVel.y *= .2;
    /*if (linearVel.y<.2) {
        linearVel.y = 0;
    }
    if (linearVel.x<.2) {
        linearVel.x = 0;
    }*/
    //CCLOG(@"X: %f Y: %f",linearVel.x,linearVel.y);
    
    b2Vec2 currentPosition = paddleOne.body->GetPosition() + linearVel;
    float puckRatio = (puckBody->GetPosition().y/10);
    
    
    float windowSizeY = winSize.height/PTM_RATIO;
    float windowSizeX = winSize.width/PTM_RATIO;
    
    float positionPaddleY = (puckRatio*5.26)+2.364;
    float positionPaddleX = sqrtf(powf((windowSizeY/6+60/PTM_RATIO),2)-powf((positionPaddleY-windowSizeY/2),2));
    
    //CCLOG(@"X: %f Y: %f",positionPaddleX,positionPaddleY);

   // CCLOG(@"%")
    
    b2Vec2 desiredPosition = b2Vec2((positionPaddleX>0)? positionPaddleX:0, positionPaddleY );
    b2Vec2 necessaryMovement = desiredPosition - currentPosition;
    float necessaryDistance = necessaryMovement.Length();
    
    necessaryMovement.Normalize();
    float forceMagnitude = (600>necessaryDistance)? 600:necessaryDistance;  //b2Min(, <#T b#>)  //b2Min(2000, necessaryDistance); //b2Min(2000, necessaryDistance);
    b2Vec2 force = forceMagnitude * necessaryMovement;
    
    paddleOne.body->ApplyForce(force, paddleOne.body->GetWorldCenter() );
}

-(void)attacking
{
    //CCLOG(@"Im Attacking");
}

-(void)attackMode
{
    b2Vec2 linearVel = paddleOne.body->GetLinearVelocity();
    linearVel.x *= 0.1;
    linearVel.y *= 0.1;
    b2Vec2 currentPosition = paddleOne.body->GetPosition() + linearVel;
    b2Vec2 desiredPosition = b2Vec2(puckBody->GetPosition().x-20/PTM_RATIO, puckBody->GetPosition().y);
    b2Vec2 necessaryMovement = desiredPosition - currentPosition;
    //float necessaryDistance = necessaryMovement.Length();
    necessaryMovement.Normalize();
    float forceMagnitude = 1500;  //b2Min(, <#T b#>)  //b2Min(2000, necessaryDistance); //b2Min(2000, necessaryDistance);
    b2Vec2 force = forceMagnitude * necessaryMovement;
    paddleOne.body->ApplyForce(force, paddleOne.body->GetWorldCenter() );
    
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
    _delegate = nil;
    [_delegate release];
    _layer = nil;
    [_layer release];
    [_session disconnectFromAllPeers];
    _session.available = NO;
    [_session setDataReceiveHandler: nil withContext: nil];
    _session.delegate = nil;
    [_session release];
    [timer invalidate];
    timer = nil;
	[super dealloc];
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
    
    // left boundary for paddle
    groundBox.Set(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(0, 0));
	groundBody->CreateMyFixture(&groundBox,0); //CreateMyFixture method created in b2Body class
	
    
	// right
	groundBox.Set(b2Vec2(winSize.width/ PTM_RATIO, winSize.height/(3 * PTM_RATIO)), b2Vec2(winSize.width/PTM_RATIO, 0));
	groundBody->CreateFixture(&groundBox,0);
    
	groundBox.Set(b2Vec2(winSize.width/ PTM_RATIO, 2 * winSize.height/(3 * PTM_RATIO)), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
    
    
    // right boundary for paddle   http://www.iforce2d.net/b2dtut/collision-filtering
    groundBox.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
	groundBody->CreateMyFixture(&groundBox,0); //CreateMyFixture method created in b2Body class
    
    // Create circle that restricts movement of paddle near the area
    
    b2BodyDef semiCircleDef;
    b2FixtureDef semiCircleFixture;
    b2CircleShape semiCircleShape;
    
    semiCircleDef.type = b2_staticBody;
    semiCircleDef.position.Set(0, winSize.height /(2 * PTM_RATIO));
    
    b2Body* semiCircleBody = world->CreateBody(&semiCircleDef);
    
    semiCircleShape.m_radius = ((winSize.height/6)/PTM_RATIO);
    semiCircleBody->CreateMyFixture(&semiCircleShape, 100);
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
    
	world->Step(dt, 10, 10);
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
    {
        if (b->GetUserData() != NULL) {
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
            isInGolArea = YES;
            playerOneScore++;
            NSLog(@"Score: %i - %i", playerOneScore, playerTwoScore);
            [self showAlertFor:ScoreAlert];
            // [playerTwoScoreSprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[scoreImagesArray objectAtIndex:playerTwoScore]]];
            [self performSelector:@selector(resetObjectsPositionAfterGoal:) withObject:@(1) afterDelay:1.0];
        }else if((puckBody->GetPosition()).x < 0){
            isInGolArea = YES;
            playerTwoScore++;
            NSLog(@"Score: %i - %i", playerOneScore, playerTwoScore);
            [self showAlertFor:ScoreAlert];
            //[playerOneScoreSprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[scoreImagesArray objectAtIndex:playerOneScore]]];
            [self performSelector:@selector(resetObjectsPositionAfterGoal:) withObject:@(2) afterDelay:1.0];
        }
    }
    
    //Change AI Behavior
    if ((puckBody->GetPosition()).x>winSize.width/(2*PTM_RATIO)) {
        [sm post:@"toDeffend"];
        [sm post:@"deffending"];
        //[self defending];
    }
    if ((puckBody->GetPosition()).x<=winSize.width/(2*PTM_RATIO)) {
        [sm post:@"toAttack"];
        [sm post:@"attacking"];
    }
}

//Send puck coordinates to the client side
-(void)puckMovement{
    if(self.session != nil && isServer){
        
        CGPoint puckSpeed = CGPointMake((puckBody->GetLinearVelocity()).x, (puckBody->GetLinearVelocity()).y);
        NSValue* valueToSend = [NSValue valueWithCGPoint:puckSpeed];
        
        NSDictionary* coordinates = @{@"Speed": valueToSend, @"DataType": @"DataForPuckSpeed"};
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:coordinates];
        NSError* error = nil;
        
        if(![_session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error]){
            NSLog(@"Error sending data to clients: %@", error);
        }
    }
}

-(void)puckCoordinates{
    if(self.session != nil && isServer){
        
        CGPoint puckCoordinates = CGPointMake((puckBody->GetPosition()).x, (puckBody->GetPosition()).y);
        NSValue* valueToSend = [NSValue valueWithCGPoint:puckCoordinates];
        
        NSDictionary* coordinates = @{@"Coord": valueToSend, @"DataType": @"DataForPuckCoordinates"};
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:coordinates];
        NSError* error = nil;
        
        if(![_session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error]){
            NSLog(@"Error sending data to clients: %@", error);
        }
    }
}

-(void)resetObjectsPositionAfterGoal:(NSNumber *)position{
    CGPoint puckNewPosition;
    CGPoint paddleOneNewPosition;
    CGPoint paddleTwoNewPosition;
    
    puckBody->SetLinearVelocity(b2Vec2(0, 0));
    puckBody->SetAngularVelocity(0);
    puckBody->SetUserData(nil);
    
    paddleOne.body->SetLinearVelocity(b2Vec2(0, 0));
    paddleOne.body->SetUserData(nil);
    paddleOne.body->SetTransform(b2Vec2(120 / PTM_RATIO, winSize.height / (2 * PTM_RATIO)), 0.0);

    paddleTwo.body->SetLinearVelocity(b2Vec2(0, 0));
    paddleTwo.body->SetUserData(nil);
    paddleTwo.body->SetTransform(b2Vec2((winSize.width - 120) / PTM_RATIO, winSize.height / (2 * PTM_RATIO)), 0.0);

    switch (position.integerValue) {
        case 1:{
            puckBody->SetTransform(b2Vec2((winSize.width / (2 * PTM_RATIO)) + (50 / PTM_RATIO), winSize.height / (2 * PTM_RATIO)), 0.0);
            puckNewPosition = CGPointMake((puckBody->GetPosition()).x * PTM_RATIO, (puckBody->GetPosition()).y * PTM_RATIO);
            puckNewPosition = [[CCDirector sharedDirector] convertToGL:puckNewPosition];
            [puckSprite stopAllActions];
            [puckSprite runAction:[CCJumpTo actionWithDuration:0.7 position:puckNewPosition height:100 jumps:1]];
            break;
        }
        case 2:{
            puckBody->SetTransform(b2Vec2((winSize.width / (2 * PTM_RATIO)) - (50 / PTM_RATIO), winSize.height / (2 * PTM_RATIO)), 0.0);
            puckNewPosition = CGPointMake((puckBody->GetPosition()).x * PTM_RATIO, (puckBody->GetPosition()).y * PTM_RATIO);
            puckNewPosition = [[CCDirector sharedDirector] convertToGL:puckNewPosition];
            [puckSprite stopAllActions];
            [puckSprite runAction:[CCJumpTo actionWithDuration:0.7 position:puckNewPosition height:100 jumps:1]];
            break;
        }
        default:
            break;
    }
    
    [paddleOne stopAllActions];
    paddleOneNewPosition = CGPointMake((paddleOne.body->GetPosition()).x * PTM_RATIO, (paddleOne.body->GetPosition()).y * PTM_RATIO);
    paddleOneNewPosition = [[CCDirector sharedDirector] convertToGL:paddleOneNewPosition];
    [paddleOne runAction:[CCMoveTo actionWithDuration:0.5 position:paddleOneNewPosition]];
    
    [paddleTwo stopAllActions];
    paddleTwoNewPosition = CGPointMake((paddleTwo.body->GetPosition()).x * PTM_RATIO, (paddleTwo.body->GetPosition()).y * PTM_RATIO);
    paddleTwoNewPosition = [[CCDirector sharedDirector] convertToGL:paddleTwoNewPosition];
    
    [paddleTwo runAction:[CCSequence actions:
                     [CCMoveTo actionWithDuration:0.5 position:paddleTwoNewPosition],
                     [CCCallFunc actionWithTarget:self selector:@selector(assignObjectsBodiesAgain)], nil]];
}

-(void)assignObjectsBodiesAgain{
    paddleOne.body->SetUserData(paddleOne);
    paddleTwo.body->SetUserData(paddleTwo);
    puckBody->SetUserData(puckSprite);
    isInGolArea = NO;
}

#pragma mark - GKSessionDataHandler

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context{
    
    NSDictionary *dataDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString* dataType = [dataDictionary objectForKey:@"DataType"];
        
    if ([dataType isEqualToString:@"DataForPuckSpeed"]) {
        
        NSValue* value = [dataDictionary objectForKey:@"Speed"];
        CGPoint newSpeed;
        [value getValue:&newSpeed];
        
        puckBody->SetLinearVelocity(b2Vec2(newSpeed.x, newSpeed.y));
        
    }else if ([dataType isEqualToString:@"DataForPuckCoordinates"]){
        NSValue* value = [dataDictionary objectForKey:@"Coord"];
        CGPoint newCoord;
        [value getValue:&newCoord];
        
        puckBody->SetTransform(b2Vec2(newCoord.x, newCoord.y), 0.0);
        
    }else if([dataType isEqualToString:@"DataForPaddleStartMoving"]){

        [paddleTwo paddleWillStartMoving];
        
    }else if([dataType isEqualToString:@"DataForPaddleIsMoving"]){
        CGFloat xCoodinate = ((NSNumber *)[dataDictionary objectForKey:@"x"]).floatValue * winSize.width;
        CGFloat yCoodinate = ((NSNumber *)[dataDictionary objectForKey:@"y"]).floatValue * winSize.height;
                
        paddleTwo.mouseJoint->SetTarget(b2Vec2(xCoodinate, yCoodinate));
        
    }else if([dataType isEqualToString:@"DataForPaddleStopMoving"]){
        [paddleTwo paddleWillStopMoving];
    
    }else if([dataType isEqualToString:@"CreationDateData"]){
        NSDate* peerDate = [dataDictionary objectForKey:@"Date"];
        if([creationDate compare:peerDate] == NSOrderedAscending){
            isServer = YES;
        }
        NSLog(@"Am I the Server: %i", isServer);
    }
    
}

#pragma mark - GKPeerPickerDelegate

- (void)peerPickerController:(GKPeerPickerController *)_picker didConnectPeer:(NSString *)peerID toSession: (GKSession *) session {
    // Use a retaining property to take ownership of the session.
    self.session = session;
    // Assumes our object will also become the session's delegate.
    paddleOne.session = [[GKSession alloc] init];
    paddleOne.session = session;

    paddleTwo.session = [[GKSession alloc] init];
    paddleTwo.session = session;
    
    
    [paddleOne.session setDataReceiveHandler:self withContext:nil];
    [paddleTwo.session setDataReceiveHandler:self withContext:nil];
    

    session.delegate = self;
    [session setDataReceiveHandler: self withContext:nil];
    // Remove the picker.
    _picker.delegate = nil;
    [_picker dismiss];
    [_picker autorelease];
    
    // Start your game.
#warning Here we start tracking the movement of the puck.
//    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(puckMovement) userInfo:nil repeats:YES];
    [self schedule:@selector(puckMovement) interval:0.25];
    [self schedule:@selector(puckCoordinates) interval:0.5f];
    
    NSDictionary* dataDictionary = @{@"Date": creationDate, @"DataType": @"CreationDateData"};
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:dataDictionary];
    NSError* error = nil;
    
    if(![_session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error]){
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
            NSLog(@"isServer: %c", isServer);
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
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Game Over!" message:title delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:@"Rematch", nil];
                [alert setAlertViewStyle:UIAlertViewStyleDefault];
                [alert show];
                [alert release];
            }else{
                
            }
            break;
        case DisconnectAlert:{
            NSString* message = [NSString stringWithFormat:@"The connection with the other device was lost."];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Connection Lost!" message:message delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:@"Reconnect", nil];
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
        case 1:
            if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Rematch"]) {
                playerOneScore = 0;
                playerTwoScore = 0;
                NSLog(@"%i - %i", playerOneScore, playerTwoScore);
            }else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Reconnect"]){
                [self reconnect];
            }
            break;
        default:
            break;
    }
}

-(void)reconnect{
    [_session disconnectFromAllPeers];
    _session.available = NO;
    [_session setDataReceiveHandler: nil withContext: nil];
    _session.delegate = nil;
    [_session release];
    
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [picker show];
}


//To be able to go back to main menu mean while.
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint coord = [touch locationInView:touch.view];
    coord = [[CCDirector sharedDirector] convertToGL:coord];
    
    if (CGRectContainsPoint(playerOneScoreSprite.boundingBox, coord)) {
        [self.delegate goToMenuLayer];
    }
}

@end
