//
//  Car.h
//  TinyDrift
//
//  Created by Ray Wenderlich on 6/17/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "Constants.h"


#define NUM_PREV_VELS   5
#define PTM_RATIO   32.0
#define START_DOWN_ROAD 200

@interface Car : CCSprite {
    b2World *_world;
    b2Body *_body;
    
    CCSprite *leftWheel;
    CCSprite *rightWheel;
    BOOL _driving;
    float _driftAngle;
    CGPoint target;
    CGPoint pathTangent;
    float pathCurve;
    
    b2Vec2 _prevVels[NUM_PREV_VELS];
    int _nextVel;
    
    CCAnimation *_normalAnim;
    CCAnimate *_normalAnimate;
    
}

@property (readonly) BOOL driving;
@property BOOL followRoad;
@property float driftAngle;
@property BOOL fixedDrift;

- (void)runNormalAnimation;
- (void)drive;
- (void)resetDrive;
- (void)turboBoost;
- (void)setTarget: (CGPoint) newTarget;
- (void)setPathTangent: (CGPoint) newTangent;
- (void)setPathCurve: (float) newCurve;
- (id)initWithWorld:(b2World *)world;
- (void)update;
- (float)getSpeed;

@end
