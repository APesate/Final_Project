//
//  Paddle.h
//  AA(box2d)
//
//  Created by Grimi on 8/13/13.
//  Copyright (c) 2013 MobileMakers. All rights reserved.
//

#import "CCSprite.h"
#import "CCDirector.h"
#import "CCDirectorIOS.h"
#import "CCTouchDispatcher.h"

typedef enum tagPaddleState {
	kPaddleStateGrabbed,
	kPaddleStateUngrabbed
} PaddleState;

@interface Paddle : CCSprite <CCTouchOneByOneDelegate>
{
@private
PaddleState state;
}

@property(nonatomic, readonly) CGRect rect;
@property(nonatomic, readonly) CGRect rectInPixels;
@end
