//
//  IntroLayer.m
//  AirHockey
//
//  Created by Andrés Pesate on 8/13/13.
//  Copyright Andrés Pesate 2013. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "MenuLayer.h"
#import "SimpleAudioEngine.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer{
    ALuint soundEffectID;
}

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//
-(id) init
{
	if( (self=[super init])) {
		self.touchEnabled = YES;
        
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Air_hockey_Intro.mp3"];
        soundEffectID = [[SimpleAudioEngine sharedEngine] playEffect:@"Air_hockey_Intro.mp3"];

		CGSize size = [[CCDirector sharedDirector] winSize];
		
        CCSprite *background;
        
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
			background = [CCSprite spriteWithFile:@"AirHockeyLogo.png"];
		} else {
			background = [CCSprite spriteWithFile:@"AirHockeyLogo.png"];
		}
        
		background.position = ccp(size.width/2, size.height/2);
		
        background.opacity = 0;
        
		// add the label as a child to this Layer
		[self addChild: background];

        [background runAction:[CCSequence actions:[CCFadeIn actionWithDuration:4.0],
                               [CCCallFunc actionWithTarget:self selector:@selector(splashDidFinish)], nil]];
        
    }
	return self;
}

-(void)splashDidFinish{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:2.0 scene:[MenuLayer scene]]];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self stopAllActions];
    [[SimpleAudioEngine sharedEngine] stopEffect:soundEffectID];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MenuLayer scene]]];
}

-(void)dealloc{
    [super dealloc];
}

-(void) onEnter
{
	[super onEnter];
}
@end
