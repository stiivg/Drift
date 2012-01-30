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

#define PTM_RATIO   32.0
#define NUM_PREV_SPEEDS   60
#define MIN_SCALE 0.5


@interface GameplayLayer : CCLayer
{
	CCSprite * _background;
    Terrain * _terrain;
    
    b2World * _world;
    
    Car * _car;
    CCParticleSystem * _emitter;
    
    float _prevSpeeds[NUM_PREV_SPEEDS];
    int _nextSpeed;
    
    float targetScale;
    
    BOOL _tapDown;
    float _driftControlAngle;
    BOOL turboDrifting;
    BOOL drifting;
    
    CDSoundSource* driftingSound;
}
-(void)startGame;

@end
