//
//  MainScene.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 1/21/12.
//  Copyright (c) 2012 Steven Gallagher. All rights reserved.
//


#import "MainScene.h"
#import "MainLayer.h"
#import "LoopLayer.h"
#import "OptionsLayer.h"
#import "StatisticsLayer.h"

@implementation MainScene

MainLayer *mainLayer = nil;
LoopLayer *loopLayer = nil;
OptionsLayer *optionsLayer = nil;
StatisticsLayer  *statisticsLayer = nil;

-(id)init {
    self = [super init];
    if (self != nil) {
        //Main button layer
        mainLayer = [[[MainLayer alloc] initWithMain:self] autorelease];
        [self addChild:mainLayer z:2 tag:1];

        //Background loop layer
        loopLayer = [LoopLayer node];
        [self addChild:loopLayer z:0 tag:3];
    }
    return self;
}

-(void)showOptions {
    mainLayer.visible = false;
    
    optionsLayer = [[[OptionsLayer alloc] initWithMain:self] autorelease];
    [self addChild:optionsLayer z:1 tag:2];
}

-(void)showStatistics {
    mainLayer.visible = false;
    
    statisticsLayer = [[[StatisticsLayer alloc] initWithMain:self] autorelease];
    [self addChild:statisticsLayer z:1 tag:2];
}

-(void)backToMain {
    mainLayer.visible = true;
    
	[self removeChild:optionsLayer cleanup:YES];    
	[self removeChild:statisticsLayer cleanup:YES];    
}

@end