//
//  MenuLayer.mm
//  AirHockey
//
//  Created by Andrés Pesate on 8/15/13.
//  Copyright 2013 Andrés Pesate. All rights reserved.
//

#import "MenuLayer.h"
#import "SimpleAudioEngine.h"

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
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"] integerValue]) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstRun"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"soundsActivated"];
            [[NSUserDefaults standardUserDefaults] setValue:@"red" forKey:@"Paddle_One_Color"];
            [[NSUserDefaults standardUserDefaults] setValue:@"blue" forKey:@"Paddle_Two_Color"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        

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
        
        
        CCSprite* paddleOne = [[CCSprite alloc] initWithFile:[NSString stringWithFormat:@"Paddle_%@.png", [[NSUserDefaults standardUserDefaults] objectForKey:@"Paddle_One_Color"]] rect:CGRectMake(0, 0, 120, 120)];
        paddleOne.position = ccp(90, winSize.height / 2);
        paddleOne.scale = 0.50;
        [backgroundImage addChild:paddleOne];
        
        [paddleOne release];
        
        CCSprite* paddleTwo = [[CCSprite alloc] initWithFile:[NSString stringWithFormat:@"Paddle_%@.png", [[NSUserDefaults standardUserDefaults] objectForKey:@"Paddle_Two_Color"]] rect:CGRectMake(0, 0, 120, 120)];
        paddleTwo.position = ccp(winSize.width - 90, winSize.height / 2);
        paddleTwo.scale = 0.50;
        [backgroundImage addChild:paddleTwo];
        
        [paddleTwo release];
        
        CCSprite* puckSprite = [[CCSprite alloc] initWithFile:@"Puck.gif" rect:CGRectMake(0, 0, 215, 215)];
        puckSprite.position = ccp(winSize.width / 2, winSize.height / 2);
        puckSprite.scale = 0.20;
        [backgroundImage addChild:puckSprite];
        
        [puckSprite release];
        
        [self addChild:backgroundImage];
        [backgroundImage release];
        
        CCLayerColor* fogLayer = [[CCLayerColor alloc] initWithColor:ccc4(255, 255, 255, 120)];
        [self addChild:fogLayer];
        [fogLayer release];
        
        CCSprite* logo = [CCSprite spriteWithFile:@"AirHockeyLogo.png"];
        logo.position = ccp(winSize.width / 2, winSize.height - 50);
        //logo.scale = 0.75;
        [self addChild:logo];
        
        CCMenuItemFont* singlePlayerButton = [CCMenuItemFont itemWithString:@"Single Player"
                                                       target:self
                                                     selector:@selector(playSinglePlayerMode:)];
        [singlePlayerButton setColor:ccc3(24, 38, 176)];
        
        CCMenuItemFont* twoPlayersButton = [CCMenuItemFont itemWithString:@"Two Players"
                                                       target:self
                                                     selector:@selector(playMultiplayerMode:)];
        [twoPlayersButton setColor:ccc3(24, 38, 176)];
        
        CCMenuItemFont* multiplayerButton = [CCMenuItemFont itemWithString:@"Multiplayer"
                                                       target:self
                                                     selector:@selector(hostGameMode:)];
        [multiplayerButton setColor:ccc3(24, 38, 176)];
        
        CCMenuItemFont* settingsButton = [CCMenuItemFont itemWithString:@"Settings"
                                                                    target:self
                                                               selector:@selector(settingsMode:)];
        [settingsButton setColor:ccc3(24, 38, 176)];
        
        CCMenu *myMenu = [CCMenu menuWithItems: singlePlayerButton, twoPlayersButton, multiplayerButton, settingsButton, nil];
        
        [myMenu alignItemsVerticallyWithPadding:10];
        myMenu.position = ccp(winSize.width / 2, (winSize.height / 2) - 30);
        
        [self addChild:myMenu];
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

- (void) settingsMode: (CCMenuItem  *) menuItem
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[SettingsLayer sceneWithDelegate:self]]];
}

#pragma mark HelloWorldLayerDelegate

-(void)goToMenuLayer{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[MenuLayer scene]]];
}

- (void)dealloc
{
    [super dealloc];
}

@end
