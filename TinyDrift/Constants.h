//
//  Constants.h
//  TinyDrift
//
//  Created by Steven Gallagher on 12/16/11.
//  Copyright (c) 2011 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_Constants_h
#define TinyDrift_Constants_h

#define AUDIO_MAX_WAITTIME 150
#define PTM_RATIO   32.0

typedef enum {
    kAudioManagerUninitialized=0,
    kAudioManagerFailed=1,
    kAudioManagerInitializing=2,
    kAudioManagerInitialized=100,
    kAudioManagerLoading=200,
    kAudioManagerReady=300
} GameManagerSoundState;

//Audio constants pg199
#define SFX_NOTLOADED NO
#define SFX_LOADED YES

#define PLAYSOUNDEFFECT(...) \
[[GameManager sharedGameManager] playSoundEffect:@#__VA_ARGS__]

#define STOPSOUNDEFFECT(...) \
[[GameManager sharedGameManager] stopSoundEffect:__VA_ARGS__]

//Background music for scenes
#define BACKGROUND_TRACK_RACE @"TinySeal.caf"


typedef enum {
    kNoSceneUninitialized=0,
    kGameScene=1,
    kMainScene=2,
    kRace2Scene=3
} SceneTypes;

#endif
