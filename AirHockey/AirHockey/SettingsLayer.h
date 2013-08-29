//
//  SettingsLayer.h
//  AirHockey
//
//  Created by Grimi on 8/28/13.
//  Copyright (c) 2013 Andrés Pesate. All rights reserved.
//

#import "CCLayer.h"
#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class SettingsLayer;

@protocol SettingsLayerDelegate <NSObject>

-(void)goToMenuLayer;

@end

@interface SettingsLayer : CCLayer

@property (nonatomic, retain) id <SettingsLayerDelegate> delegate;

+(CCScene *) scene;
+(CCScene *) sceneWithDelegate:(id)aDelegate;

@end
