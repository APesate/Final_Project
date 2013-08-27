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

MyContactListener::MyContactListener() : _contacts() {
}

MyContactListener::~MyContactListener() {
}

void MyContactListener::BeginContact(b2Contact* contact) {
    // We need to copy out the data because the b2Contact passed in
    // is reused.
    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    _contacts.push_back(myContact);
    
    b2Body *bodyA = contact->GetFixtureA()->GetBody();
    b2Body *bodyB = contact->GetFixtureB()->GetBody();
    
    CCSprite* spriteA = (CCSprite *)bodyA->GetUserData();
    CCSprite* spriteB = (CCSprite *)bodyB->GetUserData();
    
    if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
        if ((spriteA.tag == 1 || spriteA.tag == 2) && spriteB.tag == 3) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"Air Hockey Paddle Hit.mp3"];
        }
    }else if (spriteA.tag != 1 || spriteA.tag != 2){
        [[SimpleAudioEngine sharedEngine] playEffect:@"Air_hockey_wall_hit.mp3"];
    }
    
    
}

void MyContactListener::EndContact(b2Contact* contact) {
    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<MyContact>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), myContact);
    if (pos != _contacts.end()) {
        _contacts.erase(pos);
    }
}

void MyContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
}

void MyContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
}

