//
//  HostGameLayer.mm
//  AirHockey
//
//  Created by Andrés Pesate on 8/15/13.
//  Copyright (c) 2013 Andrés Pesate. All rights reserved.
//

#import "HostGameLayer.h"
#import "HelloWorldLayer.h"


@implementation HostGameLayer
{
	MatchMakingServer *_matchMakingServer;
    QuitReason _quitReason;
    CCLabelTTF*  hostName;
    CCLabelTTF* guestName;
    CGSize winSize;
}
@synthesize delegate = _delegate;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];

	// 'layer' is an autorelease object.
	HostGameLayer *layer = [HostGameLayer node];

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
	HostGameLayer *layer = [HostGameLayer nodeWithDelegate:_delegate];

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

- (void)initialize{
    winSize = [[CCDirector sharedDirector] winSize];

    hostName = [CCLabelTTF labelWithString:@"Host Name" fontName:@"Champagne & Limousines.ttf" fontSize:18];
    hostName.position = ccp(winSize.width / 2, (winSize.height / 2) - 50);
    hostName.color = ccc3(0.0, 0.0, 0.0);

    guestName = [CCLabelTTF labelWithString:@"Guest Name" fontName:@"Champagne & Limousines.ttf" fontSize:18];
    guestName.position = ccp(winSize.width / 2, (winSize.height / 2) + 50);
    guestName.color = ccc3(0.0, 0.0, 0.0);

    CCMenuItemImage *startGameButton= [CCMenuItemImage itemWithNormalImage:@"mythirdbutton.png"
                                                             selectedImage: @"mythirdbutton_selected.png"
                                                                    target:self
                                                                  selector:@selector(startAction:)];

    CCMenu *myMenu = [CCMenu menuWithItems:startGameButton, nil];

    [myMenu alignItemsVertically];

    [self addChild:myMenu];

    [self addChild:hostName];
    [self addChild:guestName];

    if (_matchMakingServer == nil)
    {
        _matchMakingServer = [[MatchMakingServer alloc] init];
        _matchMakingServer.delegate = self;
        _matchMakingServer.maxClients = 1;
        [_matchMakingServer startAcceptingConnectionsForSessionID:SESSION_ID];

        hostName.string = _matchMakingServer.session.displayName;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)startAction:(id)sender
{
	if (_matchMakingServer != nil && [_matchMakingServer connectedClientCount] > 0)
	{
		[_matchMakingServer stopAcceptingConnections];
        
		[self.delegate hostViewController:self startGameWithSession:_matchMakingServer.session clients:_matchMakingServer.connectedClients];
	}
}

- (IBAction)exitAction:(id)sender
{
	_quitReason = QuitReasonUserQuit;
	[_matchMakingServer endSession];
	[self.delegate hostViewControllerDidCancel:self];
}

//#pragma mark - UITableViewDataSource
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//	if (_matchMakingServer != nil)
//		return [_matchMakingServer connectedClientCount];
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
//	NSString *peerID = [_matchMakingServer peerIDForConnectedClientAtIndex:indexPath.row];
//	cell.textLabel.text = [_matchMakingServer displayNameForPeerID:peerID];
//    
//	return cell;
//}
//
//#pragma mark - UITableViewDelegate
//
//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	return nil;
//}
//
//#pragma mark - UITextFieldDelegate
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//	[textField resignFirstResponder];
//	return NO;
//}

#pragma mark - MatchmakingServerDelegate

- (void)matchmakingServer:(MatchMakingServer *)server clientDidConnect:(NSString *)peerID
{
    guestName.string = peerID;
	//[self.tableView reloadData];
}

- (void)matchmakingServer:(MatchMakingServer *)server clientDidDisconnect:(NSString *)peerID
{
    guestName.string = @"Guest Disconnected";
	//[self.tableView reloadData];
}

- (void)matchmakingServerSessionDidEnd:(MatchMakingServer *)server
{
	_matchMakingServer.delegate = nil;
	_matchMakingServer = nil;
	//[self.tableView reloadData];
	[self.delegate hostViewController:self didEndSessionWithReason:_quitReason];
}

- (void)matchmakingServerNoNetwork:(MatchMakingServer *)session
{
	_quitReason = QuitReasonNoNetwork;
}


@end
