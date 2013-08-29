//
//  MenuLayer.mm
//  AirHockey
//
//  Created by Andrés Pesate on 8/15/13.
//  Copyright 2013 Andrés Pesate. All rights reserved.
//

#import "MenuLayer.h"
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.width - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )

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
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCLayer* backgroundImage = [[CCLayer alloc] init];
        CCSprite* backgroundSprite;
        
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
        [backgroundImage addChild:backgroundSprite];
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        CCSprite* paddleOne = [[CCSprite alloc] initWithFile:@"Paddle_blue.gif" rect:CGRectMake(0, 0, 120, 120)];
        paddleOne.position = ccp(90, winSize.height / 2);
        paddleOne.scale = 0.50;
        [backgroundImage addChild:paddleOne];
        
        CCSprite* paddleTwo = [[CCSprite alloc] initWithFile:@"Paddle_red.gif" rect:CGRectMake(0, 0, 120, 120)];
        paddleTwo.position = ccp(winSize.width - 90, winSize.height / 2);
        paddleTwo.scale = 0.50;
        [backgroundImage addChild:paddleTwo];
        
        CCSprite* puckSprite = [[CCSprite alloc] initWithFile:@"Puck.gif" rect:CGRectMake(0, 0, 215, 215)];
        puckSprite.position = ccp(winSize.width / 2, winSize.height / 2);
        puckSprite.scale = 0.20;
        [backgroundImage addChild:puckSprite];
        
        [self addChild:backgroundImage];
        
        CCLayerColor* fogLayer = [[CCLayerColor alloc] initWithColor:ccc4(100, 100, 100, 190)];
        [self addChild:fogLayer];
        
        CCMenuItemFont* singlePlayerButton = [CCMenuItemFont itemWithString:@"Single Player"
                                                       target:self
                                                     selector:@selector(playSinglePlayerMode:)];
        [singlePlayerButton setColor:ccc3(241, 196, 15)];
        
        CCMenuItemFont* twoPlayersButton = [CCMenuItemFont itemWithString:@"Two Players"
                                                       target:self
                                                     selector:@selector(playMultiplayerMode:)];
        [twoPlayersButton setColor:ccc3(241, 196, 15)];
        
        CCMenuItemFont* multiplayerButton = [CCMenuItemFont itemWithString:@"Multiplayer"
                                                       target:self
                                                     selector:@selector(hostGameMode:)];
        [multiplayerButton setColor:ccc3(241, 196, 15)];
        
        CCMenuItemFont* settingsButton = [CCMenuItemFont itemWithString:@"Settings"
                                                                    target:self
                                                                  selector:@selector(settingsMenu:)];
        [settingsButton setColor:ccc3(241, 196, 15)];
        
        CCMenu *myMenu = [CCMenu menuWithItems: singlePlayerButton, twoPlayersButton, multiplayerButton, settingsButton, nil];
        
        [myMenu alignItemsVerticallyWithPadding:10];
        myMenu.position = ccp(winSize.width / 2, (winSize.height / 2) - 35);

        [self addChild:myMenu];
        
        CCSprite* logo = [CCSprite spriteWithFile:@"AirHockeyLogo.png"];
        logo.position = ccp(winSize.width / 2, winSize.height - 50);

        [self addChild: logo];
    }
    
    return self;
}

- (void) playSinglePlayerMode: (CCMenuItem  *) menuItem
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[HelloWorldLayer sceneWithGameMode:SinglePlayerMode andDelegate:self]]];
}

- (void) playMultiplayerMode: (CCMenuItem  *) menuItem
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[HelloWorldLayer sceneWithGameMode:MultiplayerMode andDelegate:self]]];
}

- (void) hostGameMode: (CCMenuItem  *) menuItem
{
    HelloWorldLayer* layer = [HelloWorldLayer nodeWithLayer:layer gameMode:BluetoothMode andDelegate:self];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[HelloWorldLayer sceneForLayer:layer]]];
}

- (void) settingsMenu: (CCMenuItem  *) menuItem
{
    
}

#pragma mark HelloWorldLayerDelegate

-(void)goToMenuLayer{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[MenuLayer scene]]];
}

@end
