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
    CCSprite* selectionShadowLeft;
    CCSprite* selectionShadowRight;
    CCSprite* paddleOne;
    CCSprite* paddleTwo;
    CCSprite* paddleThree;
    CCSprite* paddleFour;
    CCSprite* paddleFive;
    CCSprite* paddleSix;
    CCSprite* paddleSeven;
    CCSprite* paddleEight;
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
    static CGFloat paddleWidth;
    static CGFloat paddleHeight;
    static CGFloat paddleScaleRate;
    static CGFloat selectionShadowWidth;
    static CGFloat selectionShadowHeight;
    static CGFloat selectionShadowScaleRate;
    static CGFloat puckWidth;
    static CGFloat puckHeight;
    static CGFloat puckScaleRate;
    static CGFloat speakerScaleRate;
    static CGFloat backgroundScaleRate;
    
    if(IS_RETINA){
        paddleWidth = 120;
        paddleHeight = 120;
        paddleScaleRate = 0.50;
        selectionShadowWidth = 145;
        selectionShadowHeight = 145;
        selectionShadowScaleRate = 0.60;
        puckWidth = 215;
        puckHeight = 215;
        puckScaleRate = 0.20;
        speakerScaleRate = 1.0;
        backgroundScaleRate = 1.0;
    }else{
        paddleWidth = 240;
        paddleHeight = 240;
        paddleScaleRate = 0.50;
        selectionShadowWidth = 290;
        selectionShadowHeight = 290;
        selectionShadowScaleRate = 0.30;
        puckWidth = 430;
        puckHeight = 430;
        puckScaleRate = 0.10;
        speakerScaleRate = 0.50;
        backgroundScaleRate = 0.50;
    }
    
    self.touchEnabled = TRUE;
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    
    if( winSize.width == 568 )
    {
        backgroundSprite = [CCSprite spriteWithFile:@"AirHockey_iPhone5.jpg"];
    }
    else
    {
        backgroundSprite = [CCSprite spriteWithFile:@"air_hockey_tabletop.jpg"];
        backgroundImage.scale = backgroundScaleRate;
    }
    
    backgroundSprite.position = ccp(winSize.width / 2,winSize.height / 2);
    [backgroundImage addChild:backgroundSprite];
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
    
    selectionShadowLeft = [CCSprite spriteWithFile:@"Selection_Shadow.png" rect:CGRectMake(0, 0, selectionShadowWidth, selectionShadowHeight)];
    selectionShadowLeft.scale = selectionShadowScaleRate;
    [backgroundImage addChild:selectionShadowLeft];
    
    NSString* paddleOneSelection = [[NSUserDefaults standardUserDefaults] objectForKey:@"Paddle_One_Color"];
    
    //Left Side
    
    paddleOne = [[CCSprite alloc] initWithFile:@"Paddle_red.png" rect:CGRectMake(0, 0, 240, 240)];
    paddleOne.position = ccp(90, winSize.height / 3);
    paddleOne.scale = paddleScaleRate;
    [backgroundImage addChild:paddleOne];
    [paddleOne release];
    
    paddleSeven = [[CCSprite alloc] initWithFile:@"Paddle_yellow.png" rect:CGRectMake(0, 0, paddleWidth, paddleHeight)];
    paddleSeven.position = ccp(90, 2*winSize.height / 3);
    paddleSeven.scale = paddleScaleRate;
    [backgroundImage addChild:paddleSeven];
    [paddleSeven release];
    
    paddleFive = [[CCSprite alloc] initWithFile:@"Paddle_green.png" rect:CGRectMake(0, 0, paddleWidth, paddleHeight)];
    paddleFive.position = ccp(180, 2*winSize.height / 3);
    paddleFive.scale = paddleScaleRate;
    [backgroundImage addChild:paddleFive];
    [paddleFive release];
    
    paddleThree = [[CCSprite alloc] initWithFile:@"Paddle_blue.png" rect:CGRectMake(0, 0, paddleWidth, paddleHeight)];
    paddleThree.position = ccp(180, winSize.height / 3);
    paddleThree.scale = paddleScaleRate;
    [backgroundImage addChild:paddleThree];
    [paddleThree release];
    
    if ([paddleOneSelection isEqualToString:@"red"]) {
        selectionShadowLeft.position = paddleOne.position;
    }else if([paddleOneSelection isEqualToString:@"blue"]){
        selectionShadowLeft.position = paddleThree.position;
    }else if([paddleOneSelection isEqualToString:@"green"]){
        selectionShadowLeft.position = paddleFive.position;
    }else if([paddleOneSelection isEqualToString:@"yellow"]){
        selectionShadowLeft.position = paddleSeven.position;
    }

    //Right Side
    
    selectionShadowRight = [CCSprite spriteWithFile:@"Selection_Shadow.png" rect:CGRectMake(0, 0, selectionShadowWidth, selectionShadowHeight)];
    selectionShadowRight.scale = selectionShadowScaleRate;
    [backgroundImage addChild:selectionShadowRight];
    
    paddleFour = [[CCSprite alloc] initWithFile:@"Paddle_red.png" rect:CGRectMake(0, 0, paddleWidth, paddleHeight)];
    paddleFour.position = ccp(winSize.width - 180, winSize.height / 3);
    paddleFour.scale = paddleScaleRate;
    [backgroundImage addChild:paddleFour];
    [paddleFour release];
    
    paddleTwo = [[CCSprite alloc] initWithFile:@"Paddle_blue.png" rect:CGRectMake(0, 0, paddleWidth, paddleHeight)];
    paddleTwo.position = ccp(winSize.width - 90, winSize.height / 3);
    paddleTwo.scale = paddleScaleRate;
    [backgroundImage addChild:paddleTwo];
    [paddleTwo release];
    
    paddleSix = [[CCSprite alloc] initWithFile:@"Paddle_green.png" rect:CGRectMake(0, 0, paddleWidth, paddleHeight)];
    paddleSix.position = ccp(winSize.width - 180, 2*winSize.height / 3);
    paddleSix.scale = paddleScaleRate;
    [backgroundImage addChild:paddleSix];
    [paddleSix release];
    
    paddleEight = [[CCSprite alloc] initWithFile:@"Paddle_yellow.png" rect:CGRectMake(0, 0, paddleWidth, paddleHeight)];
    paddleEight.position = ccp(winSize.width - 90, 2*winSize.height / 3);
    paddleEight.scale = paddleScaleRate;
    [backgroundImage addChild:paddleEight];
    [paddleEight release];
    
    
    CCSprite* puckSprite = [[CCSprite alloc] initWithFile:@"Puck.gif" rect:CGRectMake(0, 0, puckWidth, puckHeight)];
    puckSprite.position = ccp(winSize.width / 2, winSize.height / 2);
    puckSprite.scale = puckScaleRate;
    [backgroundImage addChild:puckSprite];
    [puckSprite release];
    
    NSString* paddleTwoSelection = [[NSUserDefaults standardUserDefaults] objectForKey:@"Paddle_Two_Color"];
    
    if ([paddleTwoSelection isEqualToString:@"red"]) {
        selectionShadowRight.position = paddleFour.position;
    }else if([paddleTwoSelection isEqualToString:@"blue"]){
        selectionShadowRight.position = paddleTwo.position;
    }else if([paddleTwoSelection isEqualToString:@"green"]){
        selectionShadowRight.position = paddleSix.position;
    }else if([paddleTwoSelection isEqualToString:@"yellow"]){
        selectionShadowRight.position = paddleEight.position;
    }
    
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
    speakerIcon.scale = speakerScaleRate;
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
    }else if (CGRectContainsPoint(paddleOne.boundingBox, coord)){ //Left Side
        [selectionShadowLeft stopAllActions];
        [selectionShadowLeft runAction:[CCMoveTo actionWithDuration:0.5 position:paddleOne.position]];
        [[NSUserDefaults standardUserDefaults] setValue:@"red" forKey:@"Paddle_One_Color"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else if (CGRectContainsPoint(paddleSeven.boundingBox, coord)){
        [selectionShadowLeft stopAllActions];
        [selectionShadowLeft runAction:[CCMoveTo actionWithDuration:0.5 position:paddleSeven.position]];
        [[NSUserDefaults standardUserDefaults] setValue:@"yellow" forKey:@"Paddle_One_Color"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else if (CGRectContainsPoint(paddleFive.boundingBox, coord)){
        [selectionShadowLeft stopAllActions];
        [selectionShadowLeft runAction:[CCMoveTo actionWithDuration:0.5 position:paddleFive.position]];
        [[NSUserDefaults standardUserDefaults] setValue:@"green" forKey:@"Paddle_One_Color"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else if (CGRectContainsPoint(paddleThree.boundingBox, coord)){
        [selectionShadowLeft stopAllActions];
        [selectionShadowLeft runAction:[CCMoveTo actionWithDuration:0.5 position:paddleThree.position]];
        [[NSUserDefaults standardUserDefaults] setValue:@"blue" forKey:@"Paddle_One_Color"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else if (CGRectContainsPoint(paddleTwo.boundingBox, coord)){ // Right Side
        [selectionShadowRight stopAllActions];
        [selectionShadowRight runAction:[CCMoveTo actionWithDuration:0.5 position:paddleTwo.position]];
        [[NSUserDefaults standardUserDefaults] setValue:@"blue" forKey:@"Paddle_Two_Color"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else if (CGRectContainsPoint(paddleFour.boundingBox, coord)){
        [selectionShadowRight stopAllActions];
        [selectionShadowRight runAction:[CCMoveTo actionWithDuration:0.5 position:paddleFour.position]];
        [[NSUserDefaults standardUserDefaults] setValue:@"red" forKey:@"Paddle_Two_Color"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else if (CGRectContainsPoint(paddleSix.boundingBox, coord)){
        [selectionShadowRight stopAllActions];
        [selectionShadowRight runAction:[CCMoveTo actionWithDuration:0.5 position:paddleSix.position]];
        [[NSUserDefaults standardUserDefaults] setValue:@"green" forKey:@"Paddle_Two_Color"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else if (CGRectContainsPoint(paddleEight.boundingBox, coord)){
        [selectionShadowRight stopAllActions];
        [selectionShadowRight runAction:[CCMoveTo actionWithDuration:0.5 position:paddleEight.position]];
        [[NSUserDefaults standardUserDefaults] setValue:@"yellow" forKey:@"Paddle_Two_Color"];
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
