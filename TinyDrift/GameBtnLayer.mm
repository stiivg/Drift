//
//  GameBtnLayer.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 12/10/11.
//  Copyright (c) 2011 Steve Gallagher. All rights reserved.
//



#import "GameBtnLayer.h"

@implementation GameBtnLayer

-(id) init {
    if((self=[super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // Standard method to create a button
        CCMenuItem *pauseMenuItem = [CCMenuItemImage 
                                    itemFromNormalImage:@"pause.png" selectedImage:@"pause_selected.png" 
                                    target:self selector:@selector(pauseAction:)];
        pauseMenuItem.position = ccp(winSize.width - 30, winSize.height - 30);
//        starMenuItem.position = ccp(10, 20);
        CCMenu *pauseMenu = [CCMenu menuWithItems:pauseMenuItem, nil];
        pauseMenu.position = CGPointZero;
        [self addChild:pauseMenu];
    }
    return self;
}

- (void)pauseAction:(id)sender {
    
}


@end


