//
//  GameBtnLayer.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 12/10/11.
//  Copyright (c) 2011 Steve Gallagher. All rights reserved.
//



#import "GameBtnLayer.h"

@implementation GameBtnLayer

CCMenuItem *pauseMenuItem;
CCMenuItem *stopMenuItem;
CCMenuItem *resumeMenuItem;

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
        
        // Create stop button
        stopMenuItem = [CCMenuItemImage 
                        itemFromNormalImage:@"stop.png" selectedImage:@"stop_selected.png" 
                        target:self selector:@selector(stopAction:)];
        stopMenuItem.position = ccp(30, winSize.height - 30);
        CCMenu *stopMenu = [CCMenu menuWithItems:stopMenuItem, nil];
        stopMenu.position = CGPointZero;
        [self addChild:stopMenu];
        [stopMenuItem setVisible:false];
  
        // Create resume button
        resumeMenuItem = [CCMenuItemImage 
                        itemFromNormalImage:@"resume.png" selectedImage:@"resume_selected.png" 
                        target:self selector:@selector(resumeAction:)];
        resumeMenuItem.position = ccp(winSize.width - 30, winSize.height - 30);
        CCMenu *resumeMenu = [CCMenu menuWithItems:resumeMenuItem, nil];
        resumeMenu.position = CGPointZero;
        [self addChild:resumeMenu];
        [resumeMenuItem setVisible:false];

    }
    return self;
}

- (void)pauseAction:(id)sender {
    [pauseMenuItem setVisible:false];
    [resumeMenuItem setVisible:true];
    [stopMenuItem setVisible:true];
//    [[GameManager sharedGameManager] pauseGame];
    
    
}

- (void)stopAction:(id)sender {
    [pauseMenuItem setVisible:true];
    [resumeMenuItem setVisible:false];
    [stopMenuItem setVisible:false];
//    [[GameManager sharedGameManager] stopGame];
    
}

- (void)resumeAction:(id)sender {
    [pauseMenuItem setVisible:true];
    [resumeMenuItem setVisible:false];
    [stopMenuItem setVisible:false];
//    [[GameManager sharedGameManager] resumeGame];
    
}


@end


