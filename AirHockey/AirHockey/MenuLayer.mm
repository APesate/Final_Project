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
        
        CGPoint coord = CGPointMake(2.0545, 1.4343);
        NSValue* value = [NSValue valueWithCGPoint:coord];
        NSNumber* number = @(3.4354);
        NSDictionary* dictionary = @{@"x": value, @"DataType":@"Datafadfad"};
        NSArray* array = @[value, @"afagfdggd"];
        NSSet* set = [NSSet setWithObjects:value, @"adfadfadfadgad", nil];
        
        NSLog(@"Value size %lu", sizeof(value));
        NSLog(@"CGpoint size %lu", sizeof(coord));
        NSLog(@"Number size %lu", sizeof(number));
        NSLog(@"Dictionary size %lu", sizeof(dictionary));
        NSLog(@"Array size %lu", sizeof(array));
        NSLog(@"Set size %lu", sizeof(set));


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
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelloWorldLayer scene]]];
}

- (void) hostGameMode: (CCMenuItem  *) menuItem
{
    HelloWorldLayer* layer = [HelloWorldLayer nodeWithLayer:layer andDelegate:self];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelloWorldLayer sceneForLayer:layer]]];
}

- (void) joinGameMode: (CCMenuItem  *) menuItem
{

}

#pragma mark HelloWorldLayerDelegate

-(void)goToMenuLayer{
    [[CCDirector sharedDirector] replaceScene:[MenuLayer scene]];
}

@end
