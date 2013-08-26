//
//  MenuLayer.mm
//  AirHockey
//
//  Created by Andrés Pesate on 8/15/13.
//  Copyright 2013 Andrés Pesate. All rights reserved.
//

#import "MenuLayer.h"
#import "HelloWorldLayer.h"

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

-(id)init{
    self = [super init];
    
    if(self){
        CCMenuItemFont* singlePlayerButton = [CCMenuItemFont itemWithString:@"Single Player"
                                                       target:self
                                                     selector:@selector(playSinglePlayerMode:)];
        [singlePlayerButton setColor:ccc3(135,206,235)];
        
        CCMenuItemFont* twoPlayersButton = [CCMenuItemFont itemWithString:@"Two Players"
                                                       target:self
                                                     selector:@selector(playMultiplayerMode:)];
        [twoPlayersButton setColor:ccc3(135,206,235)];
        
        CCMenuItemFont* multiplayerButton = [CCMenuItemFont itemWithString:@"Multiplayer"
                                                       target:self
                                                     selector:@selector(hostGameMode:)];
        [multiplayerButton setColor:ccc3(135,206,235)];
        
        
        CCMenu *myMenu = [CCMenu menuWithItems: singlePlayerButton, twoPlayersButton, multiplayerButton, nil];
        
        [myMenu alignItemsVerticallyWithPadding:10];

        [self addChild:myMenu];
    }
    
    return self;
}

- (void) playSinglePlayerMode: (CCMenuItem  *) menuItem
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSplitRows transitionWithDuration:1.0 scene:[HelloWorldLayer sceneWithGameMode:SinglePlayerMode andDelegate:self]]];
}

- (void) playMultiplayerMode: (CCMenuItem  *) menuItem
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelloWorldLayer sceneWithGameMode:MultiplayerMode andDelegate:self]]];
}

- (void) hostGameMode: (CCMenuItem  *) menuItem
{
    HelloWorldLayer* layer = [HelloWorldLayer nodeWithLayer:layer gameMode:BluetoothMode andDelegate:self];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelloWorldLayer sceneForLayer:layer]]];
}

- (void) joinGameMode: (CCMenuItem  *) menuItem
{

}

#pragma mark HelloWorldLayerDelegate

-(void)goToMenuLayer{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSplitCols transitionWithDuration:1.0 scene:[MenuLayer scene]]];
}

@end
