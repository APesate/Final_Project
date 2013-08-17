//
//  HostGameLayer.h
//  AirHockey
//
//  Created by Andrés Pesate on 8/15/13.
//  Copyright (c) 2013 Andrés Pesate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLayer.h"
#import "MatchMakingServer.h"

//@class HostGameLayer;
//
//@protocol HostGameLayerDelegate<NSObject>
//
//- (void)hostGameLayerDidCancel:(HostGameLayer *)controller;
//- (void)hostGameLayer:(HostGameLayer *)controller didEndSessionWithReason:(QuitReason)reason;
//- (void)hostGameLayer:(HostGameLayer *)controller startGameWithSession:(GKSession *)session clients:(NSArray *)clients;
//
//@end
//
//
//@interface HostGameLayer : CCLayerColor <MatchmakingServerDelegate>
//
//@property (nonatomic, strong) id <HostGameLayerDelegate> delegate;
//
//+(CCScene *) scene;
//+(CCScene *) sceneWithDelegate:(id)_delegate;
//
//@end

@class HostGameLayer;

@protocol HostViewControllerDelegate <NSObject>

- (void)hostViewControllerDidCancel:(HostGameLayer *)controller;
- (void)hostViewController:(HostGameLayer *)controller didEndSessionWithReason:(QuitReason)reason;
- (void)hostViewController:(HostGameLayer *)controller startGameWithSession:(GKSession *)session clients:(NSArray *)clients;

@end

@interface HostGameLayer : CCLayerColor <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MatchmakingServerDelegate>

@property (nonatomic, strong) id <HostViewControllerDelegate> delegate;
+(CCScene *) scene;
+(CCScene *) sceneWithDelegate:(id)_delegate;

@end
