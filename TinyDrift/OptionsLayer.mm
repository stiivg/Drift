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

CCMenuItemLabel *backMenuItem;
CCLabelTTF *title;

- (id)initWithMain:(CCScene *)mainScene {
    if ((self = [super init])) {
        _mainScene = mainScene;
        
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

- (void)backAction:(id)sender {
    [(MainScene *)_mainScene backToMain ];    
    
}
@end

