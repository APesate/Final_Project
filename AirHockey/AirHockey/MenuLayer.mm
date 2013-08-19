//
//  MenuLayer.mm
//  AirHockey
//
//  Created by Andrés Pesate on 8/15/13.
//  Copyright 2013 Andrés Pesate. All rights reserved.
//

#import "MenuLayer.h"
#import "HelloWorldLayer.h"
#import "Game.h"

@implementation MenuLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];

	// 'layer' is an autorelease object.
	MenuLayer *layer = [MenuLayer node];
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)testDelegate{
    NSLog(@"Funciona");
}

-(id)init{
    self = [super init];
    
    if(self){
        CCMenuItemImage *singlePlayerButton = [CCMenuItemImage itemWithNormalImage:@"myfirstbutton.png"
                                                            selectedImage: @"myfirstbutton_selected.png"
                                                                   target:self
                                                                 selector:@selector(playSinglePlayerMode:)];
        
        CCMenuItemImage *multiplayerButton = [CCMenuItemImage itemWithNormalImage:@"mysecondbutton.png"
                                                            selectedImage: @"mysecondbutton_selected.png"
                                                                   target:self
                                                                 selector:@selector(playMultiplayerMode:)];
        
        CCMenuItemImage *hostGameButton = [CCMenuItemImage itemWithNormalImage:@"mythirdbutton.png"
                                                            selectedImage: @"mythirdbutton_selected.png"
                                                                   target:self
                                                                 selector:@selector(hostGameMode:)];
        
        CCMenuItemImage *joinGameButton= [CCMenuItemImage itemWithNormalImage:@"mythirdbutton.png"
                                                                 selectedImage: @"mythirdbutton_selected.png"
                                                                        target:self
                                                                      selector:@selector(joinGameMode:)];
        
        CCMenu *myMenu = [CCMenu menuWithItems:singlePlayerButton, multiplayerButton, hostGameButton, joinGameButton, nil];
        
        [myMenu alignItemsVertically];

        [self addChild:myMenu];
    }
    
    return self;
}

- (void) playSinglePlayerMode: (CCMenuItem  *) menuItem
{
    NSLog(@"First Button");
}

- (void) playMultiplayerMode: (CCMenuItem  *) menuItem
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelloWorldLayer scene] ]];
}

- (void) hostGameMode: (CCMenuItem  *) menuItem
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HostGameLayer sceneWithDelegate:self]]];
}

- (void) joinGameMode: (CCMenuItem  *) menuItem
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[JoinGameLayer sceneWithDelegate:self]]];
}

#pragma mark - HostViewControllerDelegate

- (void)hostViewControllerDidCancel:(HostGameLayer *)controller
{
    [[CCDirector sharedDirector] popScene];
}

- (void)hostViewController:(HostGameLayer *)controller didEndSessionWithReason:(QuitReason)reason
{
	if (reason == QuitReasonNoNetwork)
	{
		[self showNoNetworkAlert];
	}
}

- (void)hostViewController:(HostGameLayer *)controller startGameWithSession:(GKSession *)session clients:(NSArray *)clients
{
    //[[CCDirector sharedDirector] popScene];
    
    [self startGameWithBlock:^(Game *game)
     {
         [game startServerGameWithSession:session clients:clients];
     }];
    
}

#pragma mark - JoinViewControllerDelegate

- (void)joinViewControllerDidCancel:(JoinGameLayer *)controller
{
    [[CCDirector sharedDirector] popScene];
}

- (void)joinViewController:(JoinGameLayer *)controller didDisconnectWithReason:(QuitReason)reason
{
	if (reason == QuitReasonNoNetwork)
	{
		[self showNoNetworkAlert];
	}
	else if (reason == QuitReasonConnectionDropped)
	{
        [[CCDirector sharedDirector] popScene];
        [self showDisconnectedAlert];
	}
}

- (void)joinViewController:(JoinGameLayer *)controller startGameWithSession:(GKSession *)session server:(NSString *)peerID
{
    //[[CCDirector sharedDirector] popScene];
    
    [self startGameWithBlock:^(Game *game)
     {
         [game startClientGameWithSession:session server:peerID];
     }];
}

#pragma mark - GameHelloWorldDelegate

- (void)gameHelloWorld:(HelloWorldLayer *)layer didQuitWithReason:(QuitReason)reason
{
	[[CCDirector sharedDirector] popScene];
    
    if (reason == QuitReasonConnectionDropped)
    {
        [self showDisconnectedAlert];
    }
}

#pragma mark - Alerts

- (void)showNoNetworkAlert
{
	UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"No Network", @"No network alert title")
                              message:NSLocalizedString(@"To use multiplayer, please enable Bluetooth or Wi-Fi in your device's Settings.", @"No network alert message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                              otherButtonTitles:nil];
    
	[alertView show];
}

- (void)showDisconnectedAlert
{
	UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Disconnected", @"Client disconnected alert title")
                              message:NSLocalizedString(@"You were disconnected from the game.", @"Client disconnected alert message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                              otherButtonTitles:nil];
    
	[alertView show];
}

#pragma mark - Misc

- (void)startGameWithBlock:(void (^)(Game *))block
{
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer sceneWithDelegate:self]];
    
    Game *game = [[Game alloc] init];
    [HelloWorldLayer setHelloGame:game];
    block(game);
}

@end
