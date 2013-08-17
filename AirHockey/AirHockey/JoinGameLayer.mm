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

#warning Implement the tableview for servers
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
