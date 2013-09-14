//
//  MyContactListener.m
//  Box2DPong
//
//  Created by Ray Wenderlich on 2/18/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "MyContactListener.h"
#import "SimpleAudioEngine.h"
#import "cocos2d.h"

static float32 sMaxForce = 0;
static float32 sWallForce = 0;

MyContactListener::MyContactListener() : _contacts() {
}

MyContactListener::~MyContactListener() {
}

void MyContactListener::BeginContact(b2Contact* contact) {
    // We need to copy out the data because the b2Contact passed in
    // is reused.
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"soundsActivated"] boolValue]) {
        MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
        _contacts.push_back(myContact);
        
        b2Body *bodyA = contact->GetFixtureA()->GetBody();
        b2Body *bodyB = contact->GetFixtureB()->GetBody();
        
        CCSprite* spriteA = (CCSprite *)bodyA->GetUserData();
        CCSprite* spriteB = (CCSprite *)bodyB->GetUserData();
        
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            if ((spriteA.tag == 1 || spriteA.tag == 2) && spriteB.tag == 3) {
                float32 soundPan;
                float32 halfScreenWidth = [[CCDirector sharedDirector] winSize].width / 2;
                float32 volume = bodyB->GetLinearVelocity().Normalize() + bodyA->GetLinearVelocity().Normalize();
                
                if (sMaxForce < volume) {
                    
                    sMaxForce = volume;
                }
                
                if (bodyA->GetLinearVelocity().Normalize() < 5) {
                        sMaxForce = bodyB->GetLinearVelocity().Normalize();
                }
                
                if (spriteB.position.x < halfScreenWidth) {
                    soundPan = (spriteB.position.x / halfScreenWidth) * (-1);
                }else{
                    soundPan = (spriteB.position.x * 2) / halfScreenWidth;
                }
                                
                [[SimpleAudioEngine sharedEngine] playEffect:@"Air Hockey Paddle Hit.mp3" pitch:1.0f pan:soundPan gain:(volume / sMaxForce)];
            }
        }else if (spriteB.tag != 1 && spriteB.tag != 2){
            float32 volume = bodyB->GetLinearVelocity().Normalize();
            if (sWallForce < volume) {
                sWallForce = volume;
            }
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"Air_hockey_wall_hit.mp3" pitch:1.0f pan:0.0f gain:(volume / sWallForce)];
        }
        
    }

    
}

void MyContactListener::EndContact(b2Contact* contact) {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"soundsActivated"] boolValue]) {
        MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
        std::vector<MyContact>::iterator pos;
        pos = std::find(_contacts.begin(), _contacts.end(), myContact);
        if (pos != _contacts.end()) {
            _contacts.erase(pos);
        }
    }
}

void MyContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
}

void MyContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
}

