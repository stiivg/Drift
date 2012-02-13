//
//  GameManager.h
//  TinyDrift
//
//  Created by Steven Gallagher on 12/16/11.
//  Copyright (c) 2011 Steve Gallagher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "SimpleAudioEngine.h"

@interface GameManager : NSObject {
    BOOL isMusicON;
    BOOL isSoundEffectsON;
    
    BOOL isGamePaused;
    SceneTypes currentScene;
    // Added for audio
    BOOL hasAudioBeenInitialized;
    GameManagerSoundState managerSoundState;
    SimpleAudioEngine  *soundEngine;
    NSMutableDictionary *listOfSoundEffectFiles;
    NSMutableDictionary *soundEffectsState;
    
    
}
@property (readwrite) BOOL isGamePaused;
@property (readwrite) BOOL isMusicON;
@property (readwrite) BOOL isSoundEffectsON;
@property (readwrite) GameManagerSoundState managerSoundState;
@property (nonatomic, retain) NSMutableDictionary *listOfSoundEffectFiles;
@property (nonatomic, retain) NSMutableDictionary *soundEffectsState;


+(GameManager*)sharedGameManager;
-(void)pauseGame;
-(void)resumeGame;
-(void)playGame;
-(void)endRace;
-(void)runSceneWithID:(SceneTypes)sceneID;
-(void)setupAudioEngine;
-(CDSoundSource*)createSoundSource:(NSString*)soundEffectKey;
-(ALuint)playSoundEffect:(NSString*)soundEffectKey;
-(void)stopSoundEffect:(ALuint)soundEffectID;
-(void)playBackgroundTrack:(NSString*)trackFileName;

@end
