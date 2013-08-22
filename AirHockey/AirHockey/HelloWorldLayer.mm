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
    NSDate* creationDate;
    NSTimer* timer;
    CCLabelBMFont* centerLabel;
    int playerOneScore;
    int playerTwoScore;
    
    BOOL isServer;
    GKPeerPickerController* picker;
}
@property HelloWorldLayer* layer;

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

+(id)nodeWithLayer:(id)layer andDelegate:(id)aDelegate{
    return [[[self alloc] initWithLayer:layer andDelegate:aDelegate] autorelease];
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
    
    centerLabel = [CCLabelTTF labelWithString:@"Host Name" fontName:@"Champagne & Limousines.ttf" fontSize:18];
    centerLabel.position = ccp(winSize.width / 2, (winSize.height / 2) - 50);
    centerLabel.color = ccc3(0.0, 0.0, 0.0);
    [self addChild:centerLabel];
    
    // init physics
    [self initPhysics];

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
    bodyFixtureDef.density = 10.0f;
    bodyFixtureDef.friction = (0.5 * bodyFixtureDef.density);
    bodyFixtureDef.restitution = 0.8f;
    bodyFixtureDef.filter.groupIndex = -1;
    puckBody->CreateFixture(&bodyFixtureDef);
    puckBody->SetLinearDamping(0.01 * puckBody->GetMass());
    
}

-(void)puckMovement{
    if(self.session != nil && isServer){
        NSNumber* xCoordinateToSend = @(((winSize.width / PTM_RATIO) - (puckBody->GetPosition()).x) / winSize.width);
        NSNumber* yCoordinateToSend = @(((winSize.height / PTM_RATIO) - (puckBody->GetPosition()).y) / winSize.height);
        
        NSDictionary* coordinates = @{@"x": xCoordinateToSend, @"y": yCoordinateToSend, @"DataType": @"DataForPuck"};
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:coordinates];
        NSError* error = nil;
        
        
        if(![_session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error]){
            NSLog(@"Error sending data to clients: %@", error);
        }
    }
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

#pragma mark - GKSessionDataHandler

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context{
    
    NSLog(@"Data Size: %i", [data length]);
    NSDictionary *dataDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString* dataType = [dataDictionary objectForKey:@"DataType"];
        
    if ([dataType isEqualToString:@"DataForPuck"]) {
        CGFloat xCoodinate = ((NSNumber *)[dataDictionary objectForKey:@"x"]).floatValue * winSize.width;
        CGFloat yCoodinate = ((NSNumber *)[dataDictionary objectForKey:@"y"]).floatValue * winSize.height;
        
        puckBody->SetTransform(b2Vec2(xCoodinate, yCoodinate), 0.0);
        
    }else if([dataType isEqualToString:@"DataForPaddleStartMoving"]){

        [paddleTwo paddleWillStartMoving];
        
    }else if([dataType isEqualToString:@"DataForPaddleIsMoving"]){
        CGPoint coord;
        [(NSValue*)[dataDictionary objectForKey:@"Coord"] getValue:&coord];
        
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
    paddleOne.session = session;
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
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(puckMovement) userInfo:nil repeats:YES];
    
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
            // Record the peerID of the other peer.
            // Inform your game that a peer has connected.
            NSLog(@"Connected");
            NSLog(@"isServer: %c", isServer);
            break;
        case GKPeerStateDisconnected:
            // Inform your game that a peer has left.
            NSLog(@"Disconnected");
            [self.delegate goToMenuLayer];
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

@end
