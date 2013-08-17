//
//  JoinGameLayer.m
//  AirHockey
//
//  Created by Andrés Pesate on 8/15/13.
//  Copyright 2013 Andrés Pesate. All rights reserved.
//

#import "JoinGameLayer.h"
#import "MatchMakingClient.h"
#import "HostGameLayer.h"
#import "GameViewController.h"

//#warning Implement the tableview for servers
//@implementation JoinGameLayer{
//    CGSize winSize;
//    CCLabelTTF* playerName;
//    CCLabelTTF* serverName;
//    MatchMakingClient *_matchmakingClient;
//    QuitReason _quitReason;
//    
//    NSNotificationCenter* alertNotifications;
//}
//@synthesize delegate;
//
//+(CCScene *) scene
//{
//	// 'scene' is an autorelease object.
//	CCScene *scene = [CCScene node];
//	
//	// 'layer' is an autorelease object.
//	JoinGameLayer *layer = [JoinGameLayer node];
//	
//	// add layer as a child to scene
//	[scene addChild: layer];
//	
//	// return the scene
//	return scene;
//}
//
//+(CCScene *) sceneWithDelegate:(id)_delegate
//{
//	// 'scene' is an autorelease object.
//	CCScene *scene = [CCScene node];
//	
//	// 'layer' is an autorelease object.
//	JoinGameLayer *layer = [JoinGameLayer nodeWithDelegate:_delegate];
//	
//	// add layer as a child to scene
//	[scene addChild: layer];
//	
//	// return the scene
//	return scene;
//}
//
//+(id)nodeWithDelegate:(id)aDelegate{
//    return  [[[self alloc]  initWithDelegate:aDelegate] autorelease];
//}
//
//-(id)initWithDelegate:(id)aDelegate{
//    self = [super initWithColor:ccc4(255, 255, 255, 255)];
//    
//    
//    if(self){
//        self.delegate = aDelegate;
//        [self initialize];
//    }
//    
//    return self;
//}
//
//-(id)init{
//    self = [super initWithColor:ccc4(255, 255, 255, 255)];
//
//    if(self){
//        [self initialize];
//    }
//    
//    return self;
//}
//
//-(void)initialize{
//    alertNotifications = [NSNotificationCenter defaultCenter];
//    
//    winSize = [[CCDirector sharedDirector] winSize];
//    
//    playerName = [CCLabelTTF labelWithString:@"Host Name" fontName:@"Champagne & Limousines.ttf" fontSize:18];
//    playerName.position = ccp(winSize.width / 2, winSize.height / 2 + 50);
//    playerName.color = ccc3(0.0, 0.0, 0.0);
//    
//    serverName = [CCLabelTTF labelWithString:@"Host Name" fontName:@"Champagne & Limousines.ttf" fontSize:18];
//    serverName.position = ccp(winSize.width / 2, (winSize.height / 2) - 50);
//    serverName.color = ccc3(0.0, 0.0, 0.0);
//    
//    CCMenuItemImage *joinGameButton= [CCMenuItemImage itemWithNormalImage:@"mythirdbutton.png"
//                                                            selectedImage: @"mythirdbutton_selected.png"
//                                                                   target:self
//                                                                 selector:@selector(joinGame:)];
//    
//    CCMenu *myMenu = [CCMenu menuWithItems:joinGameButton, nil];
//    
//    [myMenu alignItemsVertically];
//    
//    [self addChild:myMenu];
//    
//    [self addChild:playerName];
//    [self addChild:serverName];
//    
//    if (_matchmakingClient == nil)
//    {
//        _quitReason = QuitReasonConnectionDropped;
//        
//        _matchmakingClient = [[MatchMakingClient alloc] init];
//        _matchmakingClient.delegate = self;
//        [_matchmakingClient startSearchingForServersWithSessionID:SESSION_ID];
//        
//        playerName.string = _matchmakingClient.session.displayName;
//    }
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
//}
//
//#pragma mark - UITableViewDataSource
//
////- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
////{
////	if (_matchmakingClient != nil)
////		return [_matchmakingClient availableServerCount];
////	else
////		return 0;
////}
////
////- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
////{
////	static NSString *CellIdentifier = @"CellIdentifier";
////    
////	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
////	if (cell == nil)
////		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
////    
////	NSString *peerID = [_matchmakingClient peerIDForAvailableServerAtIndex:indexPath.row];
////	cell.textLabel.text = [_matchmakingClient displayNameForPeerID:peerID];
////    
////	return cell;
////}
//
//#pragma mark - MatchmakingClientDelegate
//
//- (void)matchMakingClient:(MatchMakingClient *)client serverBecameAvailable:(NSString *)peerID
//{
//    serverName.string = peerID;
//    if(peerID)NSLog(@"Found One");
//   // [self.tableView reloadData];
//}
//
//- (void)matchMakingClient:(MatchMakingClient *)client serverBecameUnavailable:(NSString *)peerID
//{
//    serverName.string = @"No Available";
//    //[self.tableView reloadData];
//}
//
//- (void)matchMakingClient:(MatchMakingClient *)client didDisconnectFromServer:(NSString *)peerID
//{
//    NSString* reason;
//        
//    switch (_quitReason) {
//        case QuitReasonNoNetwork: // no Wi-Fi or Bluetooth
//            reason = @"QuitReasonNoNetwork";
//            break;
//        case QuitReasonConnectionDropped:// communication failure with server
//            reason = @"QuitReasonConnectionDropped";
//            break;
//        case QuitReasonUserQuit:// the user terminated the connection
//            reason = @"QuitReasonUserQuit";
//            break;
//        case QuitReasonServerQuit:// the server quit the game (on purpose)
//            reason = @"QuitReasonServerQuit";
//            break;
//            
//        default:
//            break;
//    }
//	_matchmakingClient.delegate = nil;
//	_matchmakingClient = nil;
//	//[self.tableView reloadData];
//    [self.delegate joinGameLayer:self didDisconnectWithReason:_quitReason];
//}
//
//- (void)matchMakingClientNoNetwork:(MatchMakingClient *)client
//{
//	_quitReason = QuitReasonNoNetwork;
//}
//
//- (void)matchMakingClient:(MatchMakingClient *)client didConnectToServer:(NSString *)peerID
//{
//	//NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
////	if ([name length] == 0)
////		name = _matchmakingClient.session.displayName;
////    
//	[self.delegate joinGameLayer:self startGameWithSession:_matchmakingClient.session server:peerID];
//}
//
//#pragma mark - Menu
//
//-(void)joinGame:(CCMenuItem  *) menuItem{
//    
//    if (_matchmakingClient != nil)
//	{
//		NSString *peerID = [_matchmakingClient peerIDForAvailableServerAtIndex:0];
//		[_matchmakingClient connectToServerWithPeerID:peerID];
//	}
//}
//
//@end

@implementation JoinGameLayer
{
	MatchMakingClient *_matchMakingClient;
    QuitReason _quitReason;
    CGSize winSize;
    CCLabelTTF* playerName;
    CCLabelTTF* serverName;
}

@synthesize waitView = _waitView;
@synthesize waitLabel = _waitLabel;
@synthesize delegate = _delegate;

//- (void)dealloc
//{
//#ifdef DEBUG
//	NSLog(@"dealloc %@", self);
//#endif
//    self.waitView = nil;
//    [super dealloc];
//}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];

	// 'layer' is an autorelease object.
	JoinGameLayer *layer = [JoinGameLayer node];

	// add layer as a child to scene
	[scene addChild: layer];

	// return the scene
	return scene;
}

+(CCScene *) sceneWithDelegate:(id)_delegate
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];

	// 'layer' is an autorelease object.
	JoinGameLayer *layer = [JoinGameLayer nodeWithDelegate:_delegate];

	// add layer as a child to scene
	[scene addChild: layer];

	// return the scene
	return scene;
}

+(id)nodeWithDelegate:(id)aDelegate{
    return  [[self alloc]  initWithDelegate:aDelegate];
}

-(id)initWithDelegate:(id)aDelegate{
    self = [super initWithColor:ccc4(255, 255, 255, 255)];


    if(self){
        self.delegate = aDelegate;
        [self initialize];
    }

    return self;
}

-(id)init{
    self = [super initWithColor:ccc4(255, 255, 255, 255)];

    if(self){
        [self initialize];
    }

    return self;
}

-(void)initialize{

    winSize = [[CCDirector sharedDirector] winSize];

    playerName = [CCLabelTTF labelWithString:@"Host Name" fontName:@"Champagne & Limousines.ttf" fontSize:18];
    playerName.position = ccp(winSize.width / 2, winSize.height / 2 + 50);
    playerName.color = ccc3(0.0, 0.0, 0.0);

    serverName = [CCLabelTTF labelWithString:@"Host Name" fontName:@"Champagne & Limousines.ttf" fontSize:18];
    serverName.position = ccp(winSize.width / 2, (winSize.height / 2) - 50);
    serverName.color = ccc3(0.0, 0.0, 0.0);

    CCMenuItemImage *joinGameButton= [CCMenuItemImage itemWithNormalImage:@"mythirdbutton.png"
                                                            selectedImage: @"mythirdbutton_selected.png"
                                                                   target:self
                                                                 selector:@selector(joinGame:)];

    CCMenu *myMenu = [CCMenu menuWithItems:joinGameButton, nil];

    [myMenu alignItemsVertically];

    [self addChild:myMenu];

    [self addChild:playerName];
    [self addChild:serverName];

    if (_matchMakingClient == nil)
    {
        _quitReason = QuitReasonConnectionDropped;

        _matchMakingClient = [[MatchMakingClient alloc] init];
        _matchMakingClient.delegate = self;
        [_matchMakingClient startSearchingForServersWithSessionID:SESSION_ID];

        playerName.string = _matchMakingClient.session.displayName;
    }
}

-(void)joinGame:(id)sender{
    	//[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    	if (_matchMakingClient != nil)
    	{
            [[[CCDirector sharedDirector] view] addSubview:self.waitView];

    		NSString *peerID = [_matchMakingClient peerIDForAvailableServerAtIndex:0];
    		[_matchMakingClient connectToServerWithPeerID:peerID];
    	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)exitAction:(id)sender
{
	_quitReason = QuitReasonUserQuit;
	[_matchMakingClient disconnectFromServer];
	[self.delegate joinViewControllerDidCancel:self];
}

//#pragma mark - UITableViewDataSource
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//	if (_matchMakingClient != nil)
//		return [_matchMakingClient availableServerCount];
//	else
//		return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	static NSString *CellIdentifier = @"CellIdentifier";
//    
//	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//	if (cell == nil)
//		cell = [[PeerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    
//	NSString *peerID = [_matchMakingClient peerIDForAvailableServerAtIndex:indexPath.row];
//	cell.textLabel.text = [_matchMakingClient displayNameForPeerID:peerID];
//    
//	return cell;
//}
//
//#pragma mark - UITableViewDelegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//	if (_matchMakingClient != nil)
//	{
//		[self.view addSubview:self.waitView];
//        
//		NSString *peerID = [_matchMakingClient peerIDForAvailableServerAtIndex:indexPath.row];
//		[_matchMakingClient connectToServerWithPeerID:peerID];
//	}
//}

//#pragma mark - UITextFieldDelegate
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//	[textField resignFirstResponder];
//	return NO;
//}

#pragma mark - MatchmakingClientDelegate

- (void)matchmakingClient:(MatchMakingClient *)client serverBecameAvailable:(NSString *)peerID
{
	serverName.string = peerID;
    //[self.tableView reloadData];
}

- (void)matchmakingClient:(MatchMakingClient *)client serverBecameUnavailable:(NSString *)peerID
{
    serverName.string = @"Server Disconnected";
	//[self.tableView reloadData];
}

- (void)matchmakingClient:(MatchMakingClient *)client didDisconnectFromServer:(NSString *)peerID
{
	_matchMakingClient.delegate = nil;
	_matchMakingClient = nil;
	//[self.tableView reloadData];
	[self.delegate joinViewController:self didDisconnectWithReason:_quitReason];
}

- (void)matchmakingClient:(MatchMakingClient *)client didConnectToServer:(NSString *)peerID
{
	[self.delegate joinViewController:self startGameWithSession:_matchMakingClient.session server:peerID];
}

- (void)matchmakingClientNoNetwork:(MatchMakingClient *)client
{
	_quitReason = QuitReasonNoNetwork;
}

@end
