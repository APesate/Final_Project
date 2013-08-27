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

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32.0f

@class HelloWorldLayer;

@protocol HelloWorldLayerDelegate <NSObject>

-(void)goToMenuLayer;

@end

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <UIAlertViewDelegate, GKSessionDelegate, GKPeerPickerControllerDelegate, CCTouchOneByOneDelegate>
{
	b2World* world;					// strong ref
}

@property (nonatomic, strong) GKSession* session;
@property (nonatomic, strong) NSMutableArray* peerID;
@property (nonatomic, retain) id <HelloWorldLayerDelegate> delegate;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
+(CCScene *) sceneWithGameMode:(GameMode)mode andDelegate:(id)aDelegate;
+(CCScene *) sceneForLayer:(id)layer;
+(id)nodeWithLayer:(id)layer gameMode:(GameMode)mode andDelegate:(id)aDelegate;

@end




