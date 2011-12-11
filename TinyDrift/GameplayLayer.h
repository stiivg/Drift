//
//  GameplayLayer.h
//  TinyDrift
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//

#import "cocos2d.h"
#import "Terrain.h"
#import "Box2D.h"
#import "Car.h"

#define PTM_RATIO   32.0

@interface GameplayLayer : CCLayer
{
	CCSprite * _background;
    Terrain * _terrain;
    
    b2World * _world;
    
    Car * _car;
    CCParticleSystem * _emitter;
    
    BOOL _tapDown;
    float _driftControl;
}

@end
