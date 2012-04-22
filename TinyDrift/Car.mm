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
@synthesize followRoad;
@synthesize fixedDrift;
@synthesize roadSpeed;
@synthesize startPosition;
@synthesize speedT;
@synthesize lastOffCenter;
@synthesize drifting;

const float kDriftAcc = 40;

const float kDefaultRoadSpeed = 7;
const float kDefaultRoadAcc = 40;
const float kCorrectionAcc = 4;

const float kTurboImpulse = 80;

bool curvetoright = false;

- (CGPoint) toPixels:(b2Vec2)vec {
    return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

- (void)createBody {    
    
    //Destroy any body if exists
    if (_body != NULL) {
        _world->DestroyBody(_body);
    }
            
    b2BodyDef bd;
    bd.type = b2_dynamicBody;
    bd.linearDamping = 0.3f;
    bd.fixedRotation = false;
//    bd.angularDamping = 0.8f;
    bd.position.Set(startPosition.x/PTM_RATIO, startPosition.y/PTM_RATIO);
    _body = _world->CreateBody(&bd);
    
    b2PolygonShape carShape;
    carShape.SetAsBox(CAR_WIDTH/2/PTM_RATIO, CAR_HEIGHT/2/PTM_RATIO);
    
    b2FixtureDef fd;
    fd.shape = &carShape;
    fd.density = CAR_MASS / (CAR_WIDTH/PTM_RATIO * CAR_HEIGHT/PTM_RATIO);
    fd.restitution = 0.0f;
//    fd.friction = 0.2;
    
    _body->CreateFixture(&fd);
    
}

-(void)positionShadow: (float)angle {
    CGPoint shadowOffset = ccpForAngle(angle);
    shadowOffset = ccpMult(shadowOffset, SHADOW_OFFSET);
    shadow.position = ccp(15+shadowOffset.y, 24-shadowOffset.x);  
}

- (id)initWithWorld:(b2World *)world spriteFrameName:(NSString*)name {
    
    if ((self = [super initWithSpriteFrameName:name])) {
        _world = world;
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        int screenW = size.width;
        self.startPosition = ccp(screenW/2, START_DOWN_ROAD);
        
        self.scale = 1.0;
        
        lastOffCenter = 0;
                
        shadow = [CCSprite spriteWithSpriteFrameName:@"shadow.png"];
        [self positionShadow:0];
        [self addChild:shadow z:-1];
        
        leftWheel = [CCSprite spriteWithSpriteFrameName:@"wheel.png"];
        leftWheel.position = ccp(2, 40);
        [self addChild:leftWheel z:-1];
        
        rightWheel = [CCSprite spriteWithSpriteFrameName:@"wheel.png"];
        rightWheel.position = ccp(27.5, 40);
        [self addChild:rightWheel z:-1];
        
        roadSpeed = kDefaultRoadSpeed;
        self.drifting = false;
    }
    return self;
    
}


- (void)_applyForce {
    //The force is calculated as two perpendicular components
    //Along the path tangent at the target and perpendicular to the tangent
    //The perpendicular distance to the tangent is the error term for the PID
    //control, the tangential direction is for velocity.
    
    //calc distance to target
    CGPoint targetVector = ccpSub(target, self.position);

    float thetaT = atan2f(targetVector.x, targetVector.y);
    float thetaR = atan2f(pathTangent.x, pathTangent.y);
    float theta = thetaT - thetaR;
    float sinTheta = sinf(theta);
    float targetDistance = hypotf(targetVector.x, targetVector.y);
    float offCenter = targetDistance * sinTheta;
    
//    CCLOG(@"distance=%4.2f", distance);
    
    //calc velR = radial velocity to target
    b2Vec2 vel2b = _body->GetLinearVelocity();
    CGPoint velocity = CGPointMake(vel2b.x, vel2b.y);
    CGPoint pathRadial = ccpRPerp(pathTangent);
    
    
    //Derivative term
    float Dterm = (offCenter - lastOffCenter)*6;
    lastOffCenter = offCenter;
    float Pterm = offCenter;
    
    float accR = Pterm+Dterm * kCorrectionAcc;
    
//    CCLOG(@"p=%4.2f  d=%4.2f", Pterm,Dterm);
    
    
    CGPoint accTangential = CGPointMake(0,0);
    
    //calc radial acceleration
    CGPoint accRadial = ccpNormalize(pathRadial);
    //uncomment for force proportional to radial distance
//    accRadial = ccpMult(accRadial, accR*ABS(distance));
    //Reduce the radial force when still on road
    //Allows the car to move about the road without being
    //forced to center
    float absOffCenter = ABS(offCenter);
    if (absOffCenter < 100) {
        accR*=0.5;
    }
    accRadial = ccpMult(accRadial, accR);
    
    //Add force along path if needed
    CGPoint velT = ccpProject(velocity, pathTangent);
    speedT = ccpLength(velT);
    if (speedT < roadSpeed) {
        accTangential = ccpNormalize(pathTangent);
        accTangential = ccpMult(accTangential, kDefaultRoadAcc);
    }
    CGPoint accTotal;
    if (speedT < 5) {
        //at slow speeds just accelerate along the tangent
        accTotal = accTangential;
    } else {
        accTotal = ccpAdd(accRadial, accTangential);
    }

    if (followRoad) {
        _body->ApplyForce( b2Vec2(accTotal.x,accTotal.y), _body->GetPosition() );
    }
    
    //    CCLOG(@"drift:  d=%4.2f v=%4.2f  a=%4.2f accX=%4.2f accY=%4.2f", 
    //          distance, velR.x, acc, accTotal.x, accTotal.y);
    
    
}

-(void)_applyDriftForce {
    CGPoint accDrift = ccp(0,0);
    
    //Add drift force
    if (self.drifting) {
        float posRadians = CC_DEGREES_TO_RADIANS(90 - self.rotation);
        //ccpForAngle zero along x axis, CCW positive
        accDrift = ccpForAngle(posRadians);
        float absRotation = ABS(self.rotation);
        float driftAccel = kDriftAcc + absRotation/2;
        accDrift= ccpMult(accDrift, driftAccel);
        
        _body->ApplyForce( b2Vec2(accDrift.x,accDrift.y), _body->GetPosition() );
    }
    
}

-(void)setDamping {
    float damping = 0.3;
    if (self.drifting) {
        //This may not be needed intended to help keep car on tight turns
        //Increase damping with drift angle
        float absRotation = ABS(self.rotation);
        damping += absRotation/400;
    }
    
    //Add damping if off road
    float absOffCenter = ABS(lastOffCenter);
    if (absOffCenter > 120) {
        damping += absOffCenter/200;
    }
    
    _body->SetLinearDamping(damping);
    
//    CCLOG(@"off=%4.2f", absOffCenter);
    
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
        
        _body->SetTransform(_body->GetPosition(), -angle);
        
        [self positionShadow:angle];

        [self _applyDriftForce];
        
        [self setDamping];
    }    

}

- (void)drive {
    _driving = YES;
    followRoad = YES;
    _driftAngle = 0;
    _body->SetActive(true);
    [self runNormalAnimation];
}

- (void)resetDrive {
    _driving = NO;
    _driftAngle = 0;
    speedT = 0;
    for(int i = 0; i < NUM_PREV_VELS; ++i) {
        _prevVels[i].SetZero();
    }
    self.rotation = 0;
    lastOffCenter = 0;
    
    [_normalAnimate stop];
    _normalAnimate = nil;
    
    //    _body->SetActive(false);
    [self createBody];
    //Reset the car position to the starting body position
    self.position = [self toPixels:_body->GetPosition()];
    self.roadSpeed = kDefaultRoadSpeed;
    [self positionShadow:0];


}

- (void)turboBoost {
    const BOOL kVelocityDirection = false;
    
    if(kVelocityDirection) {
        b2Vec2 vel2b = _body->GetLinearVelocity();
        vel2b.Normalize();
        vel2b *= kTurboImpulse;
        _body->ApplyLinearImpulse(vel2b, _body->GetPosition() );  
    } else {
        float posRadians = CC_DEGREES_TO_RADIANS(90 - self.rotation);
        float32 c = cosf(posRadians), s = sinf(posRadians);
        
        b2Vec2 vel2b(c,s);
        vel2b *= kTurboImpulse;
        _body->ApplyLinearImpulse(vel2b, _body->GetPosition() );  
    }
    
}

- (void)runNormalAnimation {
    leftWheel.rotation = 0;
    rightWheel.rotation = 0;
}

- (void)runRightDriftAnimation {
    float wheelTurn = -0.5 * CC_RADIANS_TO_DEGREES(_driftAngle);
    wheelTurn = MAX(wheelTurn, -30);
    leftWheel.rotation = wheelTurn;
    rightWheel.rotation = wheelTurn;

}

- (void)runLeftDriftAnimation {
    float wheelTurn = -1.5 * CC_RADIANS_TO_DEGREES(_driftAngle);
    wheelTurn = MIN(wheelTurn, 30);
    leftWheel.rotation = wheelTurn;
    rightWheel.rotation = wheelTurn;
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

- (void)setStartPosition:(CGPoint)newStartPosition {
    startPosition = newStartPosition;
    [self createBody];
    self.position = [self toPixels:_body->GetPosition()];

}

- (CGPoint)startPosition {
    return startPosition;
}

- (float)getSpeed {
    b2Vec2 vel2b = _body->GetLinearVelocity();
    return vel2b.Length();
}

- (void)nodive {
    [self runNormalAnimation];
}

@end
