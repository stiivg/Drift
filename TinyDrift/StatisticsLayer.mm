//
//  StatisticsLayer.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 4/8/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#import "StatisticsLayer.h"
#import "GameManager.h"
#import "MainScene.h"


@implementation StatisticsLayer


- (id)initWithMain:(CCScene *)mainScene {
    if ((self = [super init])) {
        _mainScene = mainScene;
        
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // Create Options title label        
        title = [CCLabelTTF labelWithString:@"Statistics" fontName:@"Quasart" fontSize:32];
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
