//
//  GameplayLayer.h
//  TinyDrift
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//

#import "cocos2d.h"
#import "Constants.h"
#import "Terrain.h"
#import "Box2D.h"
#import "Car.h"
#import "GameManager.h"
#import "TutorialLayer.h"
#import "Drums.h"

#define NUM_PREV_SPEEDS   60
#define MIN_SCALE 0.6
#define MAX_SCALE 1.0
#define END_SPEED 35
#define CAR_SIDE_OFFSET 30
#define CHASE_CAR_SPEED 30
#define MIN_DRIFT_ANGLE 0.0


@interface GameplayLayer : CCLayer
{
	CCSprite * _background;
    Terrain * _terrain;
    Drums * drums;
    
    CCLayerColor *flashLayer;
    TutorialLayer *tutorialLayer;

    
    float viewOffset;
    
    b2World * _world;
    
    Car * _car;
    CCParticleSystem * _emitter;
    int _carRoadIndex;
    
    Car * _chaseCar;
    int _chaseCarRoadIndex;
    
    float _prevSpeeds[NUM_PREV_SPEEDS];
    int _nextSpeed;
    
    float targetScale;
    
    BOOL _tapDown;
    float _driftControlAngle;
    BOOL turboDrifting;
    BOOL drifting;
    BOOL racing;
    
    double raceStartTime;
    
    CDSoundSource* engineSound;
    CDSoundSource* chaseEngineSound;
    CDSoundSource* gravelSound;
    CDSoundSource* cameraSound;
}

- (id)init:(TutorialLayer *)tLayer;


-(void)resetStart;
-(void)startRace;
-(void)pauseRace;
-(void)resumeRace;
-(void)endrace;

@end
