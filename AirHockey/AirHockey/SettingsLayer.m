//
//  SettingsLayer.m
//  AirHockey
//
//  Created by Grimi on 8/28/13.
//  Copyright (c) 2013 Andrés Pesate. All rights reserved.
//

#import "SettingsLayer.h"

@implementation SettingsLayer
{
    CCSprite* speakerIcon;
    BOOL actualState;
    NSString* soundState;
}

@synthesize delegate = _delegate;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	SettingsLayer *layer = [SettingsLayer node];
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(CCScene *) sceneWithDelegate:(id)aDelegate
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	SettingsLayer *layer = [SettingsLayer nodeWithDelegate:aDelegate];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

+(id)nodeWithDelegate:(id)aDelegate{
    return [[[self alloc] initWithDelegate:aDelegate] autorelease];
}

-(id) initWithDelegate:(id)aDelegate
{
	if( (self=[super init])) {
        _delegate = aDelegate;
        [self.delegate retain];
        [self initialize];
	}
	return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)initialize{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLayer* backgroundImage = [[CCLayer alloc] init];
    CCSprite* backgroundSprite;
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    
    if( winSize.width == 568 )
    {
        backgroundSprite = [CCSprite spriteWithFile:@"AirHockey_iPhone5.jpg"];
    }
    else
    {
        backgroundSprite = [CCSprite spriteWithFile:@"air_hockey_tabletop.jpg"];
    }
    
    backgroundSprite.position = ccp(winSize.width / 2,winSize.height / 2);
    [backgroundImage addChild:backgroundSprite];
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
    
    //
    
    CCSprite* paddleOne = [[CCSprite alloc] initWithFile:[NSString stringWithFormat:@"Paddle_%@.png", [[NSUserDefaults standardUserDefaults] objectForKey:@"Paddle_One_Color"]] rect:CGRectMake(0, 0, 120, 120)];
    paddleOne.position = ccp(90, winSize.height / 2);
    paddleOne.scale = 0.50;
    [backgroundImage addChild:paddleOne];
    [paddleOne release];
    
    CCSprite* paddleSeven = [[CCSprite alloc] initWithFile:@"Paddle_blue.gif" rect:CGRectMake(0, 0, 120, 120)];
    paddleSeven.position = ccp(90, 2*winSize.height / 3);
    paddleSeven.scale = 0.50;
    [backgroundImage addChild:paddleSeven];
    [paddleSeven release];
    
    CCSprite* paddleFive = [[CCSprite alloc] initWithFile:@"Paddle_blue.gif" rect:CGRectMake(0, 0, 120, 120)];
    paddleFive.position = ccp(180, 2*winSize.height / 3);
    paddleFive.scale = 0.50;
    [backgroundImage addChild:paddleFive];
    [paddleFive release];
    
    CCSprite* paddleThree = [[CCSprite alloc] initWithFile:@"Paddle_blue.gif" rect:CGRectMake(0, 0, 120, 120)];
    paddleThree.position = ccp(180, winSize.height / 3);
    paddleThree.scale = 0.50;
    [backgroundImage addChild:paddleThree];
    [paddleThree release];
    
    CCSprite* paddleFour = [[CCSprite alloc] initWithFile:@"Paddle_blue.gif" rect:CGRectMake(0, 0, 120, 120)];
    paddleFour.position = ccp(400, winSize.height / 3);
    paddleFour.scale = 0.50;
    [backgroundImage addChild:paddleFour];
    [paddleFour release];
    
    CCSprite* paddleTwo = [[CCSprite alloc] initWithFile:[NSString stringWithFormat:@"Paddle_%@.png", [[NSUserDefaults standardUserDefaults] objectForKey:@"Paddle_Two_Color"]] rect:CGRectMake(0, 0, 120, 120)];
    paddleTwo.position = ccp(winSize.width - 90, winSize.height / 2);
    paddleTwo.scale = 0.50;
    [backgroundImage addChild:paddleTwo];
    [paddleTwo release];
    
    CCSprite* paddleSix = [[CCSprite alloc] initWithFile:@"Paddle_blue.gif" rect:CGRectMake(0, 0, 120, 120)];
    paddleSix.position = ccp(400, 2*winSize.height / 3);
    paddleSix.scale = 0.50;
    [backgroundImage addChild:paddleSix];
    [paddleSix release];
    
    CCSprite* paddleEight = [[CCSprite alloc] initWithFile:@"Paddle_red.gif" rect:CGRectMake(0, 0, 120, 120)];
    paddleEight.position = ccp(winSize.width - 90, 2*winSize.height / 3);
    paddleEight.scale = 0.50;
    [backgroundImage addChild:paddleEight];
    [paddleEight release];
    
    
    CCSprite* puckSprite = [[CCSprite alloc] initWithFile:@"Puck.gif" rect:CGRectMake(0, 0, 215, 215)];
    puckSprite.position = ccp(winSize.width / 2, winSize.height / 2);
    puckSprite.scale = 0.20;
    [backgroundImage addChild:puckSprite];
    [puckSprite release];
    
    [self addChild:backgroundImage];
    [backgroundImage release];
    
    CCMenuItemFont* exitButton = [CCMenuItemFont itemWithString:@"Back"
                                                         target:self
                                                       selector:@selector(exitScreen:)];
    [exitButton setColor:ccc3(24, 38, 176)];
    
    CCMenu *myMenu = [CCMenu menuWithItems: exitButton, nil];
    [myMenu setPosition: CGPointMake(winSize.width/7, 3.4*winSize.height/4) ];
    
    actualState = [[[NSUserDefaults standardUserDefaults] objectForKey:@"soundsActivated"] boolValue];
    
    if(actualState){
        soundState = @"Unmute";
    }else{
        soundState = @"Mute";
    }
    
    speakerIcon = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_Speaker.png",  soundState] rect:CGRectMake(0, 0, 78, 78)];
    speakerIcon.position = ccp(winSize.width - 10, 10);
    [self addChild:speakerIcon];
    
    [self addChild:myMenu];
}

-(void)selectColor{
    
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint coord = [touch locationInView:touch.view];
    coord = [[CCDirector sharedDirector] convertToGL:coord];
    
    if (CGRectContainsPoint(speakerIcon.boundingBox, coord)) {
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"soundsActivated"] integerValue]) {
            CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:@"Unmute_Speaker.png"];
            [speakerIcon setTexture: tex];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"soundsActivated"];
        }else{
            CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:@"Mute_Speaker.png"];
            [speakerIcon setTexture: tex];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"soundsActivated"];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)exitScreen: (CCMenuItem *) item{
    [self.delegate goToMenuLayer];
}

-(void)dealloc{
    
    [super dealloc];
    //[self release];

}

@end
