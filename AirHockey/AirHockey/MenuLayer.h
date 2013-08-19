//
//  MenuLayer.h
//  AirHockey
//
//  Created by Andrés Pesate on 8/15/13.
//  Copyright 2013 Andrés Pesate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "HelloWorldLayer.h"
#import "HostGameLayer.h"
#import "JoinGameLayer.h"

@interface MenuLayer : CCLayer <HostViewControllerDelegate, JoinViewControllerDelegate, HelloWorldDelegate>
+(CCScene *) scene;

@end
