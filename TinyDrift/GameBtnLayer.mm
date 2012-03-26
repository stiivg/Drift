//
//  GameBtnLayer.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 12/10/11.
//  Copyright (c) 2011 Steve Gallagher. All rights reserved.
//



#import "GameBtnLayer.h"
#import "GameManager.h"


@implementation GameBtnLayer

CCMenuItem *pauseMenuItem;
CCMenuItemLabel *raceAgainMenuItem;
CCMenuItemLabel *resumeMenuItem;
CCMenuItemLabel *menuMenuItem;

-(id) init {
    if((self=[super init])) {
        
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // Create pause button
        pauseMenuItem = [CCMenuItemImage 
                                    itemFromNormalImage:@"pause.png" selectedImage:@"pause_selected.png" 
                                    target:self selector:@selector(pauseAction:)];
        pauseMenuItem.position = ccp(winSize.width - 30, winSize.height - 30);
        CCMenu *pauseMenu = [CCMenu menuWithItems:pauseMenuItem, nil];
        pauseMenu.position = CGPointZero;
        [self addChild:pauseMenu];
        [pauseMenuItem setVisible:true];
        
        // Create Race Again button        
        CCLabelBMFont *raceAgainLabel = [CCLabelTTF labelWithString:@"Race Again" fontName:@"Arial" fontSize:32];
        raceAgainMenuItem = [CCMenuItemLabel itemWithLabel:raceAgainLabel target:self selector:@selector(stopAction:)];
        raceAgainMenuItem.position = ccp(winSize.width / 2, 60);
        CCMenu *stopMenu = [CCMenu menuWithItems:raceAgainMenuItem, nil];
        stopMenu.position = CGPointZero;
        [self addChild:stopMenu];
        [raceAgainMenuItem setVisible:false];
        
        // Create menu button
        CCLabelBMFont *menuLabel = [CCLabelTTF labelWithString:@"Menu" fontName:@"Arial" fontSize:20];
        menuMenuItem = [CCMenuItemLabel itemWithLabel:menuLabel target:self selector:@selector(menuAction:)];
        menuMenuItem.position = ccp(60, winSize.height - 30);
        CCMenu *menuMenu = [CCMenu menuWithItems:menuMenuItem, nil];
        menuMenu.position = CGPointZero;
        [self addChild:menuMenu];
        [menuMenuItem setVisible:false];
        
        // Create resume button
        CCLabelBMFont *resumeLabel = [CCLabelTTF labelWithString:@"Resume" fontName:@"Arial" fontSize:20];
        resumeMenuItem = [CCMenuItemLabel itemWithLabel:resumeLabel target:self selector:@selector(resumeAction:)];
        resumeMenuItem.position = ccp(winSize.width - 60, winSize.height - 30);
        CCMenu *resumeMenu = [CCMenu menuWithItems:resumeMenuItem, nil];
        resumeMenu.position = CGPointZero;
        [self addChild:resumeMenu];
        [resumeMenuItem setVisible:false];

        winlabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:48];
        winlabel.color = ccc3(0,0,0);
        winlabel.position = ccp(winSize.width/2, winSize.height*2/3);
        [self addChild:winlabel];
        winlabel.visible = false;

    }
    return self;
}

- (void)pauseAction:(id)sender {
    [pauseMenuItem setVisible:false];
    [resumeMenuItem setVisible:true];
    [raceAgainMenuItem setString:@"New Race"];
    [raceAgainMenuItem setVisible:true];
    [menuMenuItem setVisible:true];
    [[GameManager sharedGameManager] pauseGame ];
    
    
}

- (void)stopAction:(id)sender {
    [pauseMenuItem setVisible:true];
    [resumeMenuItem setVisible:false];
    [raceAgainMenuItem setVisible:false];
    [menuMenuItem setVisible:false];
    [[GameManager sharedGameManager] playGame];
    winlabel.visible = false;
    
}

- (void)resumeAction:(id)sender {
    [pauseMenuItem setVisible:true];
    [resumeMenuItem setVisible:false];
    [raceAgainMenuItem setVisible:false];
    [menuMenuItem setVisible:false];
    [[GameManager sharedGameManager] resumeGame];
}

- (void)menuAction:(id)sender {
    [pauseMenuItem setVisible:true];
    [resumeMenuItem setVisible:false];
    [raceAgainMenuItem setVisible:false];
    [menuMenuItem setVisible:false];
    [[GameManager sharedGameManager] runSceneWithID:kMainScene];
    winlabel.visible = false;
}

- (void)showWinLoss {
    [winlabel setScale:0.8];
    BOOL raceWon = [[GameManager sharedGameManager] raceWon];
    if (raceWon) {
        [winlabel setString:@"You Won!"];
    } else {
        [winlabel setString:@"You Lost"];
    }
    winlabel.opacity = 0;
    winlabel.visible = true;
    CCAction *scaleAction = [CCScaleTo  actionWithDuration:0.8 scale:1.0];
    CCAction *fadeInAction = [CCFadeIn actionWithDuration:1.0];
    [winlabel runAction:scaleAction];
    [winlabel runAction:fadeInAction];    
    
    [winlabel runAction:[CCSequence actions:
                       [CCDelayTime actionWithDuration:1], nil]];
    
}

-(void)endRace {
    [pauseMenuItem setVisible:false];
    [resumeMenuItem setVisible:false];
    [raceAgainMenuItem setString:@"Race Again"];
    [raceAgainMenuItem setVisible:true];
    [menuMenuItem setVisible:true];
    
    [self showWinLoss];
}


@end











