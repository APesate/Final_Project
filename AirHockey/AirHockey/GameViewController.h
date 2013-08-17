//
//  GameViewController.h
//  AirHockey
//
//  Created by Andrés Pesate on 8/16/13.
//  Copyright (c) 2013 Andrés Pesate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"

@class GameViewController;

@protocol GameViewControllerDelegate <NSObject>

- (void)gameViewController:(GameViewController *)controller didQuitWithReason:(QuitReason)reason;

@end

@interface GameViewController : UIViewController <UIAlertViewDelegate, GameDelegate>

@property (nonatomic, strong) id <GameViewControllerDelegate> delegate;
@property (nonatomic, strong) Game *game;

@end
