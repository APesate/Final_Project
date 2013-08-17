//
//  MatchMakingServer.h
//  AirHockey
//
//  Created by Andrés Pesate on 8/15/13.
//  Copyright (c) 2013 Andrés Pesate. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class MatchMakingServer;
//
//@protocol MatchmakingServerDelegate <NSObject>
//
//- (void)matchmakingServer:(MatchMakingServer *)server clientDidConnect:(NSString *)peerID;
//- (void)matchmakingServer:(MatchMakingServer *)server clientDidDisconnect:(NSString *)peerID;
//- (void)matchmakingServerSessionDidEnd:(MatchMakingServer *)server;
//- (void)matchmakingServerNoNetwork:(MatchMakingServer *)server;
//
//@end
//
//@interface MatchMakingServer : NSObject <GKSessionDelegate>
//
//@property (nonatomic, assign) int maxClients;
//@property (nonatomic, strong, readonly) NSArray *connectedClients;
//@property (nonatomic, strong, readonly) GKSession *session;
//@property (nonatomic, retain) id <MatchmakingServerDelegate> delegate;
//
//- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID;
//- (NSString *)peerIDForConnectedClientAtIndex:(NSUInteger)index;
//- (NSString *)displayNameForPeerID:(NSString *)peerID;
//- (NSUInteger)connectedClientCount;
//- (NSString *)displayNameForPeerID:(NSString *)peerID;
//- (void)endSession;
//- (void)stopAcceptingConnections;
//
//@end

@class MatchMakingServer;

@protocol MatchmakingServerDelegate <NSObject>

- (void)matchmakingServer:(MatchMakingServer *)server clientDidConnect:(NSString *)peerID;
- (void)matchmakingServer:(MatchMakingServer *)server clientDidDisconnect:(NSString *)peerID;
- (void)matchmakingServerSessionDidEnd:(MatchMakingServer *)server;
- (void)matchmakingServerNoNetwork:(MatchMakingServer *)server;

@end

@interface MatchMakingServer : NSObject <GKSessionDelegate>

@property (nonatomic, assign) int maxClients;
@property (nonatomic, strong, readonly) NSArray *connectedClients;
@property (nonatomic, strong, readonly) GKSession *session;
@property (nonatomic, strong) id <MatchmakingServerDelegate> delegate;

- (void)endSession;
- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID;
- (NSUInteger)connectedClientCount;
- (NSString *)peerIDForConnectedClientAtIndex:(NSUInteger)index;
- (NSString *)displayNameForPeerID:(NSString *)peerID;
- (void)stopAcceptingConnections;

@end
