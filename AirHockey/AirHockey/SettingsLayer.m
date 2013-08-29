//
//  SettingsLayer.m
//  AirHockey
//
//  Created by Grimi on 8/28/13.
//  Copyright (c) 2013 Andrés Pesate. All rights reserved.
//

#import "SettingsLayer.h"

@implementation SettingsLayer
{
    BOOL actualState;
}

@synthesize delegate = _delegate;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	SettingsLayer *layer = [SettingsLayer node];
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(CCScene *) sceneWithDelegate:(id)aDelegate
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	SettingsLayer *layer = [SettingsLayer nodeWithDelegate:aDelegate];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

+(id)nodeWithDelegate:(id)aDelegate{
    return [[[self alloc] initWithDelegate:aDelegate] autorelease];
}

-(id) initWithDelegate:(id)aDelegate
{
	if( (self=[super init])) {
        _delegate = aDelegate;
        [self.delegate retain];
        [self initialize];
	}
	return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)initialize{
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
    
    CCMenuItemFont* selectColorButton = [CCMenuItemFont itemWithString:@"Choose color:"
                                                                target:self
                                                              selector:@selector(selectColor)];
    [selectColorButton setColor:ccc3(71, 209, 248)];
    
    
    CCMenuItemFont* soundsButton = [CCMenuItemFont itemWithString:@"Game Sounds"
                                                           target:self
                                                         selector:@selector(gameSoundsState)];
    [soundsButton setColor:ccc3(71, 209, 248)];
    
    CCMenuItemFont* exitButton = [CCMenuItemFont itemWithString:@"Back"
                                                         target:self
                                                       selector:@selector(exitScreen:)];
    [exitButton setColor:ccc3(71, 209, 248)];
    
    CCMenu *myMenu = [CCMenu menuWithItems: selectColorButton, soundsButton, exitButton, nil];
    
    [myMenu alignItemsVerticallyWithPadding:10];
    
    actualState = [[[NSUserDefaults standardUserDefaults] objectForKey:@"soundsActivated"] boolValue];
    
    [self addChild:myMenu];
}

-(void)selectColor{
    
}

-(void)gameSoundsState{
    
    if(actualState){
        actualState = NO;
    }else{
        actualState = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:actualState forKey:@"soundsActivated"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)exitScreen: (CCMenuItem *) item{
    [self.delegate goToMenuLayer];
}

-(void)dealloc{
    
    [super dealloc];
    //[self release];

}

@end
