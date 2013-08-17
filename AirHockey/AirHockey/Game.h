//
//  Game.h
//  AirHockey
//
//  Created by Andrés Pesate on 8/16/13.
//  Copyright (c) 2013 Andrés Pesate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@class Game;

@protocol GameDelegate <NSObject>

- (void)game:(Game *)game didQuitWithReason:(QuitReason)reason;
- (void)gameWaitingForServerReady:(Game *)game;
- (void)gameWaitingForClientsReady:(Game *)game;

@end

@interface Game : NSObject <GKSessionDelegate>

@property (nonatomic, assign) id <GameDelegate> delegate;
@property (nonatomic, assign) BOOL isServer;

- (void)startClientGameWithSession:(GKSession *)session server:(NSString *)peerID;
- (void)startServerGameWithSession:(GKSession *)session clients:(NSArray *)clients;
- (void)quitGameWithReason:(QuitReason)reason;

@end