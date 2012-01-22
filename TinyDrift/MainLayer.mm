//
//  MainLayer.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 1/20/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//



#import "MainLayer.h"
#import "GameManager.h"

@implementation MainLayer

CCMenuItem *playMenuItem;
CCMenuItem *statsMenuItem;
CCMenuItem *optionsMenuItem;

-(id) init {
    if((self=[super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // Create play button
        playMenuItem = [CCMenuItemImage 
                         itemFromNormalImage:@"play.png" selectedImage:@"play_selected.png" 
                         target:self selector:@selector(playAction:)];
        playMenuItem.position = ccp(winSize.width / 2, winSize.height / 3);
        CCMenu *playMenu = [CCMenu menuWithItems:playMenuItem, nil];
        playMenu.position = CGPointZero;
        [self addChild:playMenu];
        
        // Create stats button
        statsMenuItem = [CCMenuItemImage 
                        itemFromNormalImage:@"stats.png" selectedImage:@"stats_selected.png" 
                        target:self selector:@selector(statsAction:)];
        statsMenuItem.position = ccp(winSize.width / 2, winSize.height / 2);
        CCMenu *statsMenu = [CCMenu menuWithItems:statsMenuItem, nil];
        statsMenu.position = CGPointZero;
        [self addChild:statsMenu];
        
        // Create options button
        optionsMenuItem = [CCMenuItemImage 
                          itemFromNormalImage:@"options.png" selectedImage:@"options_selected.png" 
                          target:self selector:@selector(optionsAction:)];
        optionsMenuItem.position = ccp(winSize.width / 2, winSize.height * 2 / 3);
        CCMenu *optionsMenu = [CCMenu menuWithItems:optionsMenuItem, nil];
        optionsMenu.position = CGPointZero;
        [self addChild:optionsMenu];
        
    }
    return self;
}

- (void)playAction:(id)sender {
    
    [[GameManager sharedGameManager] runSceneWithID:kGameScene];
    
}

- (void)statsAction:(id)sender {
    
}

- (void)optionsAction:(id)sender {
    
}


@end
