//
//  MenuLayer.m
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
        
        CCMenuItemImage *singlePlayerButton = [CCMenuItemImage itemWithNormalImage:@"myfirstbutton.png"
                                                            selectedImage: @"myfirstbutton_selected.png"
                                                                   target:self
                                                                 selector:@selector(playSinglePlayerMode:)];
        
        CCMenuItemImage *multiplayerButton = [CCMenuItemImage itemWithNormalImage:@"mysecondbutton.png"
                                                            selectedImage: @"mysecondbutton_selected.png"
                                                                   target:self
                                                                 selector:@selector(playMultiplayerMode:)];
        
        CCMenuItemImage *settingsButton = [CCMenuItemImage itemWithNormalImage:@"mythirdbutton.png"
                                                            selectedImage: @"mythirdbutton_selected.png"
                                                                   target:self
                                                                 selector:@selector(connectionSettings:)];
        
        CCMenu *myMenu = [CCMenu menuWithItems:singlePlayerButton, multiplayerButton, settingsButton, nil];
        
        [myMenu alignItemsVertically];

        [self addChild:myMenu];
    }
    
    return self;
}

- (void) playSinglePlayerMode: (CCMenuItem  *) menuItem
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelloWorldLayer scene] ]];
}
- (void) playMultiplayerMode: (CCMenuItem  *) menuItem
{
	NSLog(@"The second menu was called");
}
- (void) connectionSettings: (CCMenuItem  *) menuItem
{
	NSLog(@"The third menu was called");
}

@end
