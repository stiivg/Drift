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
#define START_DOWN_ROAD 400
#define SHADOW_OFFSET 8
#define CAR_MASS 3.1416
#define CAR_WIDTH 32
#define CAR_HEIGHT 48

@interface Car : CCSprite {
    b2World *_world;
    b2Body *_body;
    
    CCSprite *leftWheel;
    CCSprite *rightWheel;
    
    CCSprite *shadow;
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

@property BOOL chaseCar;
@property (readonly) BOOL driving;
@property BOOL drifting;
@property BOOL followRoad;
@property float driftAngle;
@property BOOL fixedDrift;
@property float roadSpeed;
@property CGPoint startPosition;
@property float speedT;
@property float lastOffCenter;

- (void)runNormalAnimation;
- (void)drive;
- (void)resetDrive;
- (void)turboBoost;
- (void)setTarget: (CGPoint) newTarget;
- (void)setPathTangent: (CGPoint) newTangent;
- (void)setPathCurve: (float) newCurve;
- (id)initWithWorld:(b2World *)world spriteFrameName:(NSString*)name;
- (void)update;
- (float)getSpeed;

@end
