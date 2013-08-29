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
#import "SettingsLayer.h"


@interface MenuLayer : CCLayer <HelloWorldLayerDelegate, SettingsLayerDelegate>
+(CCScene *) scene;

@end
