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
    b2Body* body;
    b2MouseJoint* mouseJoint;
}

-(void)createBodyWithCoordinateType:(int)coordinateType;

@end
