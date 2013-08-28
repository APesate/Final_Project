//
//  SettingsLayer.m
//  AirHockey
//
//  Created by Grimi on 8/28/13.
//  Copyright (c) 2013 Andrés Pesate. All rights reserved.
//

#import "SettingsLayer.h"

@implementation SettingsLayer
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
    SettingsLayer* layer = [SettingsLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

- (id)init
{
    self = [super init];
    if (self) {
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
        
        CCMenuItemFont* selectColorButton = [CCMenuItemFont itemWithString:@"Choose color:"
                                                                     target:self
                                                                   selector:@selector(selectColor)];
        [selectColorButton setColor:ccc3(71, 209, 248)];
        
        
        CCMenuItemFont* soundsButton = [CCMenuItemFont itemWithString:@"Game Sounds"
                                                                     target:self
                                                                   selector:@selector(gameSoundsState)];
        [soundsButton setColor:ccc3(71, 209, 248)];

    }
    return self;
}

-(void)selectColor{
    
}

-(void)gameSoundsState{
    
}

@end
