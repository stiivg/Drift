//
//  OptionsLayer.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 3/29/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#import "OptionsLayer.h"
#import "GameManager.h"
#import "MainScene.h"

@implementation OptionsLayer

#define CONTROL_TOP 180
#define CONTROL_OFFSET 60


-(void)initMusicSlider {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float height = winSize.height - CONTROL_TOP;
    
    CCLabelBMFont *musicTitle = [CCLabelTTF labelWithString:@"Music" fontName:@"Arial" fontSize:20];
    musicTitle.color = ccWHITE;
    musicTitle.position = ccp(winSize.width/2 - 46, height);
    [self addChild:musicTitle];
    
    musicSlider = [[ UISlider alloc ] initWithFrame: CGRectMake(0, 0, 125, 50) ];
    musicSlider.backgroundColor = [UIColor clearColor]; 

    float soundVolume = [[GameManager sharedGameManager] backgroundVolume];
    musicSlider.value = soundVolume;
    
    musicSlider.center =  CGPointMake(winSize.width/2 + 60, winSize.height - height);
    
    [musicSlider addTarget:self action:@selector(musicAction:) forControlEvents:UIControlEventValueChanged];
    [[[CCDirector sharedDirector] openGLView] addSubview:musicSlider];
    [musicSlider release];   // don't forget to release memory
}

-(void)initSoundSlider {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float height = winSize.height - CONTROL_TOP - CONTROL_OFFSET;
    
    CCLabelBMFont *soundTitle = [CCLabelTTF labelWithString:@"Sound" fontName:@"Arial" fontSize:20];
    soundTitle.color = ccWHITE;
    soundTitle.position = ccp(winSize.width/2 - 46, height);
    [self addChild:soundTitle];
    
    soundSlider = [[ UISlider alloc ] initWithFrame: CGRectMake(0, 0, 125, 50) ];
    soundSlider.backgroundColor = [UIColor clearColor]; 
    
    float effectsVolume = [[GameManager sharedGameManager] effectsVolume];
    soundSlider.value = effectsVolume;
    
    soundSlider.center =  CGPointMake(winSize.width/2 + 60, winSize.height - height);
    
    [soundSlider addTarget:self action:@selector(soundAction:) forControlEvents:UIControlEventValueChanged];
    [[[CCDirector sharedDirector] openGLView] addSubview:soundSlider];
    [soundSlider release];   // don't forget to release memory
}

-(void)initTutorialSwitch {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float height = winSize.height - CONTROL_TOP - 2 * CONTROL_OFFSET;
    
    CCLabelBMFont *tutorialtitle = [CCLabelTTF labelWithString:@"Tutorial" fontName:@"Arial" fontSize:20];
    tutorialtitle.color = ccWHITE;
    tutorialtitle.position = ccp(winSize.width/2 - 54, height);
    [self addChild:tutorialtitle];
    
    tutorialSwitch = [[ UISwitch alloc ] initWithFrame: CGRectZero ];
    tutorialSwitch.center =  CGPointMake(winSize.width/2 + 60, winSize.height - height);
    
    BOOL tutorialOn = [[GameManager sharedGameManager] isTutorialOn];

    tutorialSwitch.on = tutorialOn;  
    [tutorialSwitch addTarget:self action:@selector(tutorialAction:) forControlEvents:UIControlEventValueChanged];
    [[[CCDirector sharedDirector] openGLView] addSubview:tutorialSwitch];
    [tutorialSwitch release];   // don't forget to release memory
}

- (id)initWithMain:(CCScene *)mainScene {
    if ((self = [super init])) {
        _mainScene = mainScene;
        
        //Play background first to ensure the soundEngine is initialized
        //So the volume levels are available for the slider defaults
        [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_RACE];
        
        [self initMusicSlider];
        [self initSoundSlider];
        [self initTutorialSwitch];
        
        
        if (engineSound == nil) {
            engineSound = [[GameManager sharedGameManager] createSoundSource:@"ENGINE_TEST"];
        }
        engineSound.looping = YES;
        engineSound.gain = 0.1;   //Typical value when driving
        [self soundAction:soundSlider];
        [engineSound play];

        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // Create Options title label        
        title = [CCLabelTTF labelWithString:@"Options" fontName:@"Quasart" fontSize:32];
        title.color = ccc3(0,0,0);
        title.position = ccp(winSize.width/2, winSize.height - 60);
        [self addChild:title];
        
        // Create Back button        
        CCLabelBMFont *backLabel = [CCLabelTTF labelWithString:@"Back" fontName:@"Quasart" fontSize:20];
        backMenuItem = [CCMenuItemLabel itemWithLabel:backLabel target:self selector:@selector(backAction:)];
        backMenuItem.position = ccp(winSize.width * 0.8, 60);
        CCMenu *backMenu = [CCMenu menuWithItems:backMenuItem, nil];
        backMenu.position = CGPointZero;
        [self addChild:backMenu];
        
    }
    return self;
}

- (void)tutorialAction:(id)sender
{
    [[GameManager sharedGameManager] setIsTutorialOn:[sender isOn]];
}

-(void)musicAction:(id)sender {
    [[GameManager sharedGameManager] setBackgroundVolume:[(UISlider *)sender value]];    
}

-(void)soundAction:(id)sender {
    [[GameManager sharedGameManager] setEffectsVolume:[(UISlider *)sender value]];    
}

- (void)backAction:(id)sender {
    [(MainScene *)_mainScene backToMain ];    
    
}

-(void) dealloc {
    
    //Release all our retained objects
    [musicSlider removeFromSuperview];
    [soundSlider removeFromSuperview];
    [tutorialSwitch removeFromSuperview];
    
    [engineSound stop];
    [engineSound release];

    [super dealloc];
}

@end







