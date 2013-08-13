//
//  Paddle.m
//  AA(box2d)
//
//  Created by Grimi on 8/13/13.
//  Copyright (c) 2013 MobileMakers. All rights reserved.
//

#import "Paddle.h"

@implementation Paddle
@synthesize rect,rectInPixels;

- (void)onEnter
{
	CCDirector *director =  [CCDirector sharedDirector];
    
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit
{
	CCDirector *director = [CCDirector sharedDirector];
    
	[[director touchDispatcher] removeDelegate:self];
	[super onExit];
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	CGPoint p = [self convertTouchToNodeSpaceAR:touch];
	CGRect r = [self rectInPixels];
	return CGRectContainsPoint(r, p);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (state != kPaddleStateUngrabbed) return NO;
	if ( ![self containsTouchLocation:touch] ) return NO;
    
	state = kPaddleStateGrabbed;
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	// If it weren't for the TouchDispatcher, you would need to keep a reference
	// to the touch from touchBegan and check that the current touch is the same
	// as that one.
	// Actually, it would be even more complicated since in the Cocos dispatcher
	// you get NSSets instead of 1 UITouch, so you'd need to loop through the set
	// in each touchXXX method.
    
	NSAssert(state == kPaddleStateGrabbed, @"Paddle - Unexpected state!");
    
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
	self.position = CGPointMake(touchPoint.x, self.position.y);
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state == kPaddleStateGrabbed, @"Paddle - Unexpected state!");
    
	state = kPaddleStateUngrabbed;
}

@end
