//
//  Race2Layer.h
//  TinyDrift
//
//  Created by Steven Gallagher on 2/5/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_Race2Layer_h
#define TinyDrift_Race2Layer_h

#import "cocos2d.h"
#import "Terrain.h"
#import "Car.h"

#define PTM_RATIO   32.0
#define NUM_PREV_SPEEDS   60
#define MIN_SCALE 0.5



@interface Race2Layer : CCLayer
{
	CCSprite * _background;
    Terrain * _terrain;
    
    b2World * _world;
    
    Car * _car;
    CCParticleSystem * _emitter;
    
    float _prevSpeeds[NUM_PREV_SPEEDS];
    int _nextSpeed;
    
    float targetScale;
    
}

@end


#endif
