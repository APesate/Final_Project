//
//  MatchMakingServer.m
//  AirHockey
//
//  Created by Andrés Pesate on 8/15/13.
//  Copyright (c) 2013 Andrés Pesate. All rights reserved.
//

#import "MatchMakingServer.h"
//
//typedef enum
//{
//	ServerStateIdle,
//	ServerStateAcceptingConnections,
//	ServerStateIgnoringNewConnections,
//}
//ServerState;
//
//@implementation MatchMakingServer{
//    NSMutableArray *connectedClients;
//    ServerState serverState;
//}
//
//@synthesize maxClients, session, connectedClients, delegate;
//
//- (id)init
//{
//	if ((self = [super init]))
//	{
//		serverState = ServerStateIdle;
//	}
//	return self;
//}
//
//- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID
//{
//    if (serverState == ServerStateIdle)
//	{
//		serverState = ServerStateAcceptingConnections;
//        connectedClients = [[NSMutableArray arrayWithCapacity:self.maxClients] retain];
//        
//        session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeServer];
//        session.delegate = self;
//        session.available = YES;
//    }
//}
//
//- (NSArray *)connectedClients
//{
//	return connectedClients;
//}
//
//- (NSUInteger)connectedClientCount
//{
//	return [connectedClients count];
//}
//
//- (NSString *)peerIDForConnectedClientAtIndex:(NSUInteger)index
//{
//	return [connectedClients objectAtIndex:index];
//}
//
//- (NSString *)displayNameForPeerID:(NSString *)peerID
//{
//	return [session displayNameForPeer:peerID];
//}
//
//#pragma mark - GKSessionDelegate
//
//- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
//{
//#ifdef DEBUG
//	NSLog(@"MatchmakingServer: peer %@ changed state %d", peerID, state);
//#endif
//    
//	switch (state)
//	{
//		case GKPeerStateAvailable:
//			break;
//            
//		case GKPeerStateUnavailable:
//			break;
//            
//            // A new client has connected to the server.
//		case GKPeerStateConnected:
//			if (serverState == ServerStateAcceptingConnections)
//			{
//				if (![connectedClients containsObject:peerID])
//				{
//					[connectedClients addObject:peerID];
//					[self.delegate matchmakingServer:self clientDidConnect:peerID];
//				}
//			}
//			break;
//            
//            // A client has disconnected from the server.
//		case GKPeerStateDisconnected:
//			if (serverState != ServerStateIdle)
//			{
//				if ([connectedClients containsObject:peerID])
//				{
//					[connectedClients removeObject:peerID];
//					[self.delegate matchmakingServer:self clientDidDisconnect:peerID];
//				}
//			}
//			break;
//            
//		case GKPeerStateConnecting:
//			break;
//	}
//}
//
//- (void)session:(GKSession *)_session didReceiveConnectionRequestFromPeer:(NSString *)peerID
//{
//#ifdef DEBUG
//	NSLog(@"MatchmakingServer: connection request from peer %@", peerID);
//#endif
//    
//	if (serverState == ServerStateAcceptingConnections && [self connectedClientCount] < self.maxClients)
//	{
//		NSError *error;
//		if ([_session acceptConnectionFromPeer:peerID error:&error])
//			NSLog(@"MatchmakingServer: Connection accepted from peer %@", peerID);
//		else
//			NSLog(@"MatchmakingServer: Error accepting connection from peer %@, %@", peerID, error);
//	}
//	else  // not accepting connections or too many clients
//	{
//		[_session denyConnectionFromPeer:peerID];
//	}
//}
//
//- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
//{
//#ifdef DEBUG
//	NSLog(@"MatchmakingServer: connection with peer %@ failed %@", peerID, error);
//#endif
//}
//
//- (void)session:(GKSession *)session didFailWithError:(NSError *)error
//{
//#ifdef DEBUG
//	NSLog(@"MatchmakingServer: session failed %@", error);
//#endif
//    
//	if ([[error domain] isEqualToString:GKSessionErrorDomain])
//	{
//		if ([error code] == GKSessionCannotEnableError)
//		{
//			[self.delegate matchmakingServerNoNetwork:self];
//			[self endSession];
//		}
//	}
//}
//
//- (void)endSession
//{
//	NSAssert(serverState != ServerStateIdle, @"Wrong state");
//    
//	serverState = ServerStateIdle;
//    
//	[session disconnectFromAllPeers];
//	session.available = NO;
//	session.delegate = nil;
//	session = nil;
//    
//	connectedClients = nil;
//    
//	[self.delegate matchmakingServerSessionDidEnd:self];
//}
//
//- (void)stopAcceptingConnections
//{
//	NSAssert(serverState == ServerStateAcceptingConnections, @"Wrong state");
//    
//	serverState = ServerStateIgnoringNewConnections;
//	session.available = NO;
//}
//@end

typedef enum
{
	ServerStateIdle,
	ServerStateAcceptingConnections,
	ServerStateIgnoringNewConnections,
}
ServerState;

@implementation MatchMakingServer
{
	NSMutableArray *_connectedClients;
    ServerState _serverState;
}

@synthesize maxClients = _maxClients;
@synthesize session = _session;
@synthesize delegate = _delegate;

- (id)init
{
	if ((self = [super init]))
	{
		_serverState = ServerStateIdle;
	}
	return self;
}

- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID
{
    if (_serverState == ServerStateIdle)
	{
		_serverState = ServerStateAcceptingConnections;
        _connectedClients = [NSMutableArray arrayWithCapacity:self.maxClients];
        
        _session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeServer];
        _session.delegate = self;
        _session.available = YES;
    }
}

- (NSArray *)connectedClients
{
	return _connectedClients;
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
#ifdef DEBUG
	NSLog(@"MatchmakingServer: peer %@ changed state %d", peerID, state);
#endif
    
	switch (state)
	{
		case GKPeerStateAvailable:
			break;
            
		case GKPeerStateUnavailable:
			break;
            
            // A new client has connected to the server.
		case GKPeerStateConnected:
			if (_serverState == ServerStateAcceptingConnections)
			{
				if (![_connectedClients containsObject:peerID])
				{
					[_connectedClients addObject:peerID];
					[self.delegate matchmakingServer:self clientDidConnect:peerID];
				}
			}
			break;
            
            // A client has disconnected from the server.
		case GKPeerStateDisconnected:
			if (_serverState != ServerStateIdle)
			{
				if ([_connectedClients containsObject:peerID])
				{
					[_connectedClients removeObject:peerID];
					[self.delegate matchmakingServer:self clientDidDisconnect:peerID];
				}
			}
			break;
            
		case GKPeerStateConnecting:
			break;
	}
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
#ifdef DEBUG
	NSLog(@"MatchmakingServer: connection request from peer %@", peerID);
#endif
    
	if (_serverState == ServerStateAcceptingConnections && [self connectedClientCount] < self.maxClients)
	{
		NSError *error;
		if ([session acceptConnectionFromPeer:peerID error:&error])
			NSLog(@"MatchmakingServer: Connection accepted from peer %@", peerID);
		else
			NSLog(@"MatchmakingServer: Error accepting connection from peer %@, %@", peerID, error);
	}
	else  // not accepting connections or too many clients
	{
		[session denyConnectionFromPeer:peerID];
	}
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"MatchmakingServer: connection with peer %@ failed %@", peerID, error);
#endif
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"MatchmakingServer: session failed %@", error);
#endif
    
	if ([[error domain] isEqualToString:GKSessionErrorDomain])
	{
		if ([error code] == GKSessionCannotEnableError)
		{
			[self.delegate matchmakingServerNoNetwork:self];
			[self endSession];
		}
	}
}

- (NSUInteger)connectedClientCount
{
	return [_connectedClients count];
}

- (NSString *)peerIDForConnectedClientAtIndex:(NSUInteger)index
{
	return [_connectedClients objectAtIndex:index];
}

- (NSString *)displayNameForPeerID:(NSString *)peerID
{
	return [_session displayNameForPeer:peerID];
}

- (void)stopAcceptingConnections
{
	NSAssert(_serverState == ServerStateAcceptingConnections, @"Wrong state");
    
	_serverState = ServerStateIgnoringNewConnections;
	_session.available = NO;
}

- (void)endSession
{
	NSAssert(_serverState != ServerStateIdle, @"Wrong state");
    
	_serverState = ServerStateIdle;
    
	[_session disconnectFromAllPeers];
	_session.available = NO;
	_session.delegate = nil;
	_session = nil;
    
	_connectedClients = nil;
    
	[self.delegate matchmakingServerSessionDidEnd:self];
}

@end