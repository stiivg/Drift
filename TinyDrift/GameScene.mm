//
//  GameScene.m
//  TinyDrift
//
//  Created by Steven Gallagher on 12/10/11.
//  Copyright (c) 2011 Steve Gallagher. All rights reserved.
//


#import "GameScene.h"


@implementation GameScene

GameplayLayer *gamePlayLayer = nil;
CountdownLayer *countdownLayer = nil;

-(id)init {
    self = [super init];
    if (self != nil) {
        //Gameplay layer
        gamePlayLayer = [GameplayLayer node];
        [self addChild:gamePlayLayer z:0 tag:1];
        //Game button layer
        GameBtnLayer *gameBtnLayer = [GameBtnLayer node];
        [self addChild:gameBtnLayer];
        
        countdownLayer = [CountdownLayer node];
        [self addChild:countdownLayer];
        
        [self startGame];
    }
    return self;
}

-(void)startGame {
    [gamePlayLayer resetStart];
    [countdownLayer startCountdown:self withSelector:@selector(startRace)];
}

-(void)startRace {
    [gamePlayLayer startRace];
}

@end