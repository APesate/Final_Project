//
//  HelloWorldLayer.h
//  AirHockey
//
//  Created by Andrés Pesate on 8/13/13.
//  Copyright Andrés Pesate 2013. All rights reserved.
//



// When you import this file, you import all the cocos2d classes
//#import "cocos2d.h"
//#import "Box2D.h"
//#import "GLES-Render.h"
#import "PaddleSprite.h"
#import "Game.h"


//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

@class HelloWorldLayer;

@protocol HelloWorldDelegate <NSObject>

- (void)gameHelloWorld:(HelloWorldLayer *)layer didQuitWithReason:(QuitReason)reason;

@end

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <UIAlertViewDelegate, GameDelegate>
{
	b2World* world;					// strong ref
}


@property (nonatomic, strong) id <HelloWorldDelegate> delegate;
@property (nonatomic, strong) Game *game;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
+(CCScene *) sceneWithDelegate:(id)_delegate;
+(void)setHelloGame:(Game *)menuGame;
@end




