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
    
    SceneTypes currentScene;
    // Added for audio
    BOOL hasAudioBeenInitialized;
    GameManagerSoundState managerSoundState;
    SimpleAudioEngine  *soundEngine;
    NSMutableDictionary *listOfSoundEffectFiles;
    NSMutableDictionary *soundEffectsState;
    
    float backgroundVolumeDefault;
    float effectsVolumeDefault;
    
}
@property (readwrite) BOOL isGamePaused;
@property (readwrite) BOOL isMusicON;
@property (readwrite) BOOL isSoundEffectsON;
@property (readwrite) BOOL isTutorialOn;

@property (readwrite) float backgroundVolume;
@property (readwrite) float effectsVolume;

@property (readwrite) GameManagerSoundState managerSoundState;
@property (nonatomic, retain) NSMutableDictionary *listOfSoundEffectFiles;
@property (nonatomic, retain) NSMutableDictionary *soundEffectsState;

//Race properties
@property (readwrite) BOOL raceWon;
@property (readwrite) float raceTime;


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
