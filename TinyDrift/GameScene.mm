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
StatusLayer *statusLayer = nil;
GameBtnLayer *gameBtnLayer = nil;
TutorialLayer *tutorialLayer = nil;

-(id)init {
    self = [super init];
    if (self != nil) {
        tutorialLayer = [TutorialLayer node];
        [self addChild:tutorialLayer z:1];
        
        //Gameplay layer
        [gamePlayLayer = [[GameplayLayer alloc] init:tutorialLayer] autorelease];
        [self addChild:gamePlayLayer z:0 tag:1];
        
        //Game button layer
        gameBtnLayer = [GameBtnLayer node];
        [self addChild:gameBtnLayer];
        
        countdownLayer = [CountdownLayer node];
        [self addChild:countdownLayer];
                
        //Disable status for now
//        statusLayer = [StatusLayer node];
//        [self addChild:statusLayer];
//        
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
    [gameBtnLayer startRace];
}

-(void)pauseRace {
    [gamePlayLayer pauseRace];
}

-(void)resumeRace {
    [gamePlayLayer resumeRace];
}

-(void)endRace {
    [gamePlayLayer endrace];
    [gameBtnLayer endRace];
}

@end