//
//  GameManager.m
//  TinyDrift
//
//  Created by Steven Gallagher on 12/16/11.
//  Copyright (c) 2011 Steve Gallagher. All rights reserved.
//

#import "GameManager.h"
#import "ccMacros.h"
#import "GameScene.h"
#import "MainScene.h"

@implementation GameManager
static GameManager* _sharedGameManager = nil;
@synthesize isGamePaused = _paused;

+(GameManager*)sharedGameManager {
    @synchronized([GameManager class])
    {
        if(!_sharedGameManager)
            [[self alloc] init];
        return _sharedGameManager;
    }
    return nil;
}

+(id)alloc
{
    @synchronized ([GameManager class])
    {
        NSAssert(_sharedGameManager == nil,
                 @"Attempted to allocate a second instance");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
    return nil;
}

-(id)init {
    self = [super init];
    if (self != nil) {
        //Game manager initialized
        CCLOG(@"Game Manager Singleton, init");
        currentScene = kNoSceneUnininitalized;
        isGamePaused = NO;
    }
    return self;
}

-(void)runSceneWithID:(SceneTypes)sceneID {
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    id sceneToRun = nil;
    switch (sceneID) {
        case kGameScene:
            _paused = NO;
            sceneToRun  = [GameScene node];
            break;
            
        case kMainScene:
            sceneToRun  = [MainScene node];
            break;
            
        default:
            return;
            break;
    }
    if (sceneToRun == nil) {
        //revert back as no new scene found
        currentScene = oldScene;
        return;
    }
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];
    } else {
        [[CCDirector sharedDirector] replaceScene:sceneToRun];
    }
}

-(void)pauseGame {
    _paused = YES;
}

-(void)resumeGame {
    _paused = NO;
}

-(void)playGame {
    //stop this game and start next game
    [((GameScene*)[[CCDirector sharedDirector] runningScene]) startGame];
    _paused = NO;
}


@end












