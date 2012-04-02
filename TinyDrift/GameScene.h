//
//  GameScene.h
//  TinyDrift
//
//  Created by Steven Gallagher on 12/10/11.
//  Copyright (c) 2011 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_GameScene_h
#define TinyDrift_GameScene_h

#import "cocos2d.h"
#import "GameplayLayer.h"
#import "GameBtnLayer.h"
#import "CountdownLayer.h"
#import "StatusLayer.h"
#import "TutorialLayer.h"

@interface GameScene : CCScene {
}

-(void)startGame;
-(void)startRace;
-(void)pauseRace;
-(void)resumeRace;
-(void)endRace;

@end

#endif
