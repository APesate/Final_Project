//
//  PaddleSprite.h
//  AirHockey
//
//  Created by Andrés Pesate on 8/13/13.
//  Copyright 2013 Andrés Pesate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "CCPhysicsSprite.h"

#define PTM_RATIO 32

typedef enum tagPaddleState{
    kPaddleStateGrabbed,
    kPaddleStateUngrabbed
} PaddleState;

@interface PaddleSprite : CCSprite <CCTouchOneByOneDelegate> {
    PaddleState state;
    @public
    b2World* world;


    b2MouseJoint* mouseJoint;
}




@property b2MouseJoint* mouseJoint;
@property b2Body* body;
@property BOOL enabled;
@property (nonatomic, strong) GKSession* session;
@property (nonatomic, strong) NSString* myID;
@property (nonatomic, strong) NSString* firendID;


-(void)createBody;
-(void)paddleWillStartMoving;
-(void)movePaddleToX:(CGFloat)xCoordinate andY:(CGFloat)yCoordinate;
-(void)paddleWillStopMoving;

@end
