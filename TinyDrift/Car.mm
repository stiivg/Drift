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
@synthesize driftAngle = _driftAngle;

- (void)createBody {
    
    
    float radius = 16.0f;
    CGSize size = [[CCDirector sharedDirector] winSize];
    int screenW = size.width;
    
    CGPoint startPosition = ccp(screenW/2, 60);
    
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
        
        _normalAnim = [[CCAnimation alloc] init];
        [_normalAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"car.png"]];
        [_normalAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"car_right.png"]];
        _normalAnim.delay = 0.1;
    }
    return self;
    
}

- (void)_applyForceOld {
    //calc target vector
    CGPoint targetVector = ccpSub(target, self.position);
    
    //calc velocity
    b2Vec2 vel2b = _body->GetLinearVelocity();
    CGPoint vel = ccp(vel2b.x, vel2b.y);
    if (vel.y == 0) {
        vel.y = 1;
    }

    //calc velocity to target angle
    float targetAngle = ccpAngleSigned(targetVector, vel);
    
    //Calc normalized tangent vector
    vel = ccpNormalize(vel);
    CGPoint tangent = ccpPerp(vel);
    
    //Calc direction to target
    CGPoint targetDir = ccpSub(target, self.position);

    //calc tangential force to turn towards target
    float forceScale = 1 * targetAngle * targetAngle;
    CGPoint tangentForce = ccpMult(tangent,forceScale);
    
    CGPoint force = tangentForce;
    float minVal = 4;
    //if velocity too low add force in target direction
    if (ccpLengthSQ(vel) < minVal) {
        targetDir = ccpNormalize(targetDir);
        targetDir = ccpMult(targetDir,2);
        CGPoint targetForce = targetDir;
        //Add tangential and target force vectors
        force = ccpAdd(tangentForce, targetForce);
    }
    _body->ApplyForce( b2Vec2(force.x,force.y), _body->GetPosition() );
    
//    int forceScale = 2;
//    _body->ApplyForce( b2Vec2(forceScale*targetDir.x,forceScale*targetDir.y), _body->GetPosition() );
    
}

- (void)_applyForceTest {
    float highLimit = 56;
    float lowLimit = 8;
    static float limit = highLimit;
    float endX = 160;
    
    float posX = _body->GetPosition().x*PTM_RATIO;
    b2Vec2 vel2b = _body->GetLinearVelocity();
    float velX = vel2b.x;
    
    //acceleration = v^2 / 2*d
    float distance = (endX - posX) / PTM_RATIO;
    float acc = (velX * velX) / (2 * distance);
    
    float accX = 40;
    //accelerate towards the road
    if (distance < 0) {
        accX = -1 * accX;
    }
    
    //moving towards road d and v have same sign
    if (distance*velX > 0) {
        //test for de-acceleration point
        if (ABS(acc) > limit) {
            accX = -1 * accX;
            limit = lowLimit;   //de-bounce 
        } else {
            limit = highLimit;
        }
    }
    
    // CCLOG(@"drift:  d=%4.2f v=%4.2f  a=%4.2f acc=%4.2f", distance, velX, acc, accX);
    
    _body->ApplyForce( b2Vec2(accX,0), _body->GetPosition() );
    
}

- (CGPoint) toPixels:(b2Vec2)vec {
    return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

- (void)_applyForce {
    static float last_distance = 0;
    
    //calc distance = radial distance to target
    CGPoint targetVector = ccpSub(target, self.position);

    float thetaT = atan2f(targetVector.x, targetVector.y);
    float thetaR = atan2f(pathTangent.x, pathTangent.y);
    float theta = thetaT - thetaR;
    float sinTheta = sinf(theta);
    float targetDistance = hypotf(targetVector.x, targetVector.y);
    float distance = targetDistance * sinTheta;
    
    //calc velR = radial velocity to target
    b2Vec2 vel2b = _body->GetLinearVelocity();
    CGPoint velocity = CGPointMake(vel2b.x, vel2b.y);
    CGPoint pathRadial = ccpRPerp(pathTangent);
    
    
    //Derivative term
    float Dterm = (distance - last_distance)*10;
    last_distance = distance;
    float Pterm = distance;
    
    float accR = Pterm+Dterm;
//    //accelerate towards the road
//    if (distance < 0) {
//        accR = -1 * accR;
//    }
    
    CCLOG(@"drift:      %4.2f   %4.2f", Pterm,Dterm);
    
//    //moving towards road d and v have same sign
//    if (distance*velR.x > 0) {
//        //test for de-acceleration point
//        if (ABS(acc) > limit) {
//            accR = -1 * accR;
//            limit = lowLimit;   //de-bounce 
//        } else {
//            limit = highLimit;
//        }
//    }
    
    CGPoint accTangential = CGPointMake(0,0);
    
    //calc radial acceleration
    CGPoint accRadial = ccpNormalize(pathRadial);
    //uncomment for force proportional to radial distance
//    accRadial = ccpMult(accRadial, accR*ABS(distance));
    accRadial = ccpMult(accRadial, accR);
    
    //Add force along path if needed
    CGPoint velT = ccpProject(velocity, pathTangent);
    float speedT = ccpLength(velT);
    if (speedT < 20.0) {
        accTangential = ccpNormalize(pathTangent);
        accTangential = ccpMult(accTangential, 10);
    }
    
    CGPoint accTotal = ccpAdd(accRadial, accTangential);
    CGPoint accDrift = ccp(0,0);
    
    //Add drift force
    if (_driftAngle != 0 && speedT < 30.0) {
        float posRadians = CC_DEGREES_TO_RADIANS(90 - self.rotation);
        //ccpForAngle zero along x axis, CCW positive
        accDrift = ccpForAngle(posRadians);
        accDrift= ccpMult(accDrift, 40);
        //CCLOG(@"drift:  angle=%4.2f accX=%4.2f accY=%4.2f", 
//              self.rotation, accTotal.x, accTotal.y);
        accTotal = ccpAdd(accTotal, accDrift);
    }
    

//    CCLOG(@"drift:  d=%4.2f v=%4.2f  a=%4.2f accX=%4.2f accY=%4.2f", 
//          distance, velR.x, acc, accTotal.x, accTotal.y);
    
    BOOL followRoad = true;
    if (followRoad) {
        _body->ApplyForce( b2Vec2(accTotal.x,accTotal.y), _body->GetPosition() );
    } else 
    {
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
        //SJG disable rotation here
        angle += _driftAngle;
        self.rotation = CC_RADIANS_TO_DEGREES(angle);
        
        //Apply force to stay  on road
        [self _applyForce];
        
    }
    

}

- (void)drive {
    _driving = YES;
    _driftAngle = 0;
    _body->SetActive(true);
}

-(void)push {
    _body->ApplyLinearImpulse(b2Vec2(-5,0), _body->GetPosition() );
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

- (void) setDriftAngle:(float)driftAngle {
    _driftAngle = driftAngle;
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
