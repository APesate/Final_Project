//
//  JoinGameLayer.h
//  AirHockey
//
//  Created by Andrés Pesate on 8/15/13.
//  Copyright 2013 Andrés Pesate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MatchMakingClient.h"

//@class JoinGameLayer;
//
//@protocol JoinGameLayerDelegate <NSObject>
//
//- (void)joinGameLayerDidCancel:(JoinGameLayer *)layer;
//- (void)joinGameLayer:(JoinGameLayer *)layer didDisconnectWithReason:(QuitReason)reason;
//- (void)joinGameLayer:(JoinGameLayer *)layer startGameWithSession:(GKSession *)session server:(NSString *)peerID;
//
//@end
//
//@interface JoinGameLayer : CCLayerColor <MatchmakingClientDelegate>
//
//@property (nonatomic, strong) id <JoinGameLayerDelegate> delegate;
//+(CCScene *) scene;
//+(CCScene *) sceneWithDelegate:(id)_delegate;
//
//@end

@class JoinGameLayer;

@protocol JoinViewControllerDelegate <NSObject>

- (void)joinViewControllerDidCancel:(JoinGameLayer *)controller;
- (void)joinViewController:(JoinGameLayer *)controller didDisconnectWithReason:(QuitReason)reason;
- (void)joinViewController:(JoinGameLayer *)controller startGameWithSession:(GKSession *)session server:(NSString *)peerID;

@end

@interface JoinGameLayer : CCLayerColor <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MatchmakingClientDelegate>

@property (nonatomic, strong) IBOutlet UIView *waitView;
@property (nonatomic, assign) IBOutlet UILabel *waitLabel;

@property (nonatomic, strong) id <JoinViewControllerDelegate> delegate;
+(CCScene *) scene;
+(CCScene *) sceneWithDelegate:(id)_delegate;

@end