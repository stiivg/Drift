//
//  Car.mm
//  TinyDrift
//
//  Created by Ray Wenderlich on 6/17/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "Car.h"

@implementation Car
@synthesize driving = _driving;
@synthesize fixedDrift;

bool curvetoright = false;

- (void)createBody {
    //Destroy any body if exists
    b2Body* body_list =  _world->GetBodyList();
    if (body_list != NULL) {
        _world->DestroyBody(body_list);
    }
    
    float radius = 16.0f;
    CGSize size = [[CCDirector sharedDirector] winSize];
    int screenW = size.width;
    
    CGPoint startPosition = ccp(screenW/2, 100);
    
    b2BodyDef bd;
    bd.type = b2_dynamicBody;
    bd.linearDamping = 0.4f;
    bd.fixedRotation = true;
//    bd.angularDamping = 0.8f;
    bd.position.Set(startPosition.x/PTM_RATIO, startPosition.y/PTM_RATIO);
    _body = _world->CreateBody(&bd);
    
    b2CircleShape shape;
    shape.m_radius = radius/PTM_RATIO;
    
    b2FixtureDef fd;
    fd.shape = &shape;
    fd.density = 1.0f;
    fd.restitution = 0.0f;
    fd.friction = 0.2;
    
    _body->CreateFixture(&fd);
    
}

- (id)initWithWorld:(b2World *)world {
    
    if ((self = [super initWithSpriteFrameName:@"car.png"])) {
        _world = world;
        [self createBody];
        self.scale = 1.0;
        
        _normalAnim = [[CCAnimation alloc] init];
        [_normalAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"car.png"]];
        [_normalAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"car_right.png"]];
        _normalAnim.delay = 0.1;
    }
    return self;
    
}


- (CGPoint) toPixels:(b2Vec2)vec {
    return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}
static float last_distance = 0;
const float k_max_speed = 40;
const float k_drift_acc = 10;

- (void)_applyForce {
    //The force is calculated as two perpendicular components
    //Along the path tangent at the target and perpendicular to the tangent
    //The perpendicular distance to the tangent is the error term for the PID
    //control, the tangential direction is for velocity.
    
    const float k_default_road_speed = 7;
    const float k_default_road_acc = 10;
        
    
    //calc distance to target
    CGPoint targetVector = ccpSub(target, self.position);

    float thetaT = atan2f(targetVector.x, targetVector.y);
    float thetaR = atan2f(pathTangent.x, pathTangent.y);
    float theta = thetaT - thetaR;
    float sinTheta = sinf(theta);
    float targetDistance = hypotf(targetVector.x, targetVector.y);
    float distance = targetDistance * sinTheta;
    
//    CCLOG(@"distance=%4.2f", distance);
    
    //calc velR = radial velocity to target
    b2Vec2 vel2b = _body->GetLinearVelocity();
    CGPoint velocity = CGPointMake(vel2b.x, vel2b.y);
    CGPoint pathRadial = ccpRPerp(pathTangent);
    
    
    //Derivative term
    float Dterm = (distance - last_distance)*6;
    last_distance = distance;
    float Pterm = distance;
    
    float accR = Pterm+Dterm;
    
//    CCLOG(@"p=%4.2f  d=%4.2f", Pterm,Dterm);
    
    
    CGPoint accTangential = CGPointMake(0,0);
    
    //calc radial acceleration
    CGPoint accRadial = ccpNormalize(pathRadial);
    //uncomment for force proportional to radial distance
//    accRadial = ccpMult(accRadial, accR*ABS(distance));
    accRadial = ccpMult(accRadial, accR);
    
    //Add force along path if needed
    CGPoint velT = ccpProject(velocity, pathTangent);
    float speedT = ccpLength(velT);
    if (speedT < k_default_road_speed) {
        accTangential = ccpNormalize(pathTangent);
        accTangential = ccpMult(accTangential, k_default_road_acc);
    }
    CGPoint accTotal;
    if (speedT < 5) {
        //at slow speeds just accelerate along the tangent
        accTotal = accTangential;
    } else {
        accTotal = ccpAdd(accRadial, accTangential);
    }

    BOOL followRoad = true;
    if (followRoad) {
        _body->ApplyForce( b2Vec2(accTotal.x,accTotal.y), _body->GetPosition() );
    }
    
    //    CCLOG(@"drift:  d=%4.2f v=%4.2f  a=%4.2f accX=%4.2f accY=%4.2f", 
    //          distance, velR.x, acc, accTotal.x, accTotal.y);
    
    
}

-(void)_applyDriftForce {
    CGPoint accDrift = ccp(0,0);
    
    //Add drift force
    if (_driftAngle != 0) {
        float posRadians = CC_DEGREES_TO_RADIANS(90 - self.rotation);
        //ccpForAngle zero along x axis, CCW positive
        accDrift = ccpForAngle(posRadians);
        accDrift= ccpMult(accDrift, k_drift_acc);
        
        _body->ApplyForce( b2Vec2(accDrift.x,accDrift.y), _body->GetPosition() );
    }
    
}

- (void)update {
   
    self.position = [self toPixels:_body->GetPosition()];
    b2Vec2 vel = _body->GetLinearVelocity();
    b2Vec2 weightedVel = vel;
    
    for(int i = 0; i < NUM_PREV_VELS; ++i) {
        weightedVel += _prevVels[i];
    }
    weightedVel = b2Vec2(weightedVel.x/NUM_PREV_VELS, weightedVel.y/NUM_PREV_VELS);    
    _prevVels[_nextVel++] = vel;
    if (_nextVel >= NUM_PREV_VELS) _nextVel = 0;
    //SJG angle from vertical
    float angle = ccpToAngle(ccp(weightedVel.y, weightedVel.x));     
    if (_driving) { 
        //Apply force to stay  on road
        [self _applyForce];
        
        angle += _driftAngle;
        self.rotation = CC_RADIANS_TO_DEGREES(angle);
        
        
        [self _applyDriftForce];
        
    }    

}

- (void)drive {
    _driving = YES;
    _driftAngle = 0;
    _body->SetActive(true);
    [self runNormalAnimation];
}

- (void)stopDrive {
    _driving = NO;
    _driftAngle = 0;
    for(int i = 0; i < NUM_PREV_VELS; ++i) {
        _prevVels[i].SetZero();
    }
    self.rotation = 0;
    last_distance = 0;
    
    [_normalAnimate stop];
    _normalAnimate = nil;
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"car.png"]];
    
    //    _body->SetActive(false);
    [self createBody];
}

- (void)turboBoost {
    const BOOL kVelocityDirection = true;
    
    if(kVelocityDirection) {
        b2Vec2 vel2b = _body->GetLinearVelocity();
        vel2b.Normalize();
        vel2b *= 20;
        _body->ApplyLinearImpulse(vel2b, _body->GetPosition() );  
    } else {
        float posRadians = CC_DEGREES_TO_RADIANS(90 - self.rotation);
        float32 c = cosf(posRadians), s = sinf(posRadians);
        
        b2Vec2 vel2b(c,s);
        vel2b*=10;
        _body->ApplyLinearImpulse(vel2b, _body->GetPosition() );  
    }
    
}

- (void)runNormalAnimation {
    if (_normalAnimate || !_driving) return;
    _normalAnimate = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_normalAnim]];
    [self runAction:_normalAnimate];
}

- (void)runRightDriftAnimation {
    [_normalAnimate stop];
    _normalAnimate = nil;
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"car_left.png"]];
}

- (void)runLeftDriftAnimation {
    [_normalAnimate stop];
    _normalAnimate = nil;
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"car_right.png"]];
}

- (void)setTarget : (CGPoint)newTarget {
    target = newTarget;
}

- (void)setPathTangent : (CGPoint)newTangent {
    pathTangent = newTangent;
}

- (void)setPathCurve : (float)newCurve {
    pathCurve = newCurve;
}

//Property getter
-(float)driftAngle {
    return _driftAngle;
}

//Property setter
- (void) setDriftAngle:(float)driftAngle {
    _driftAngle = driftAngle;
    if (fixedDrift) {
        if (pathCurve > 0 && _driftAngle > 0) {
            _driftAngle = -1 * _driftAngle;
        }
    }
    if (_driftAngle > 0) {
        [self runRightDriftAnimation];
    } else if (_driftAngle < 0) {
        [self runLeftDriftAnimation];
    } else {
        [self runNormalAnimation];
    }
}   
- (void)nodive {
    [self runNormalAnimation];
}

@end
