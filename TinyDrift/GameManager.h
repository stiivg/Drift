//
//  GameManager.h
//  TinyDrift
//
//  Created by Steven Gallagher on 12/16/11.
//  Copyright (c) 2011 Steve Gallagher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface GameManager : NSObject {
    BOOL isGamePaused;
    SceneTypes currentScene;
}
@property (readwrite) BOOL isGamePaused;

+(GameManager*)sharedGameManager;
-(void)pauseGame;
-(void)resumeGame;
-(void)stopGame;
-(void)runSceneWithID:(SceneTypes)sceneID;

@end
