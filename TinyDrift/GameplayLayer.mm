//
//  GameplayLayer.mm
//  TinyDrift
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//


#import "GameplayLayer.h"
#import "GameManager.h"
#import "SimpleAudioEngine.h"
#import "emitters.h"

@implementation GameplayLayer

double k_turbo_time = 2.0;
double driftStartTime; 

CCParticleSystem * _drift_emitter;
CCParticleSystem * _turbo_emitter;

const bool _fixedDrift = false;

-(CCSprite *)spriteWithColor:(ccColor4F)bgColor textureSize:(float)textureSize {
    
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize height:textureSize];
    
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:bgColor.r g:bgColor.g b:bgColor.b a:bgColor.a];
    
    // 3: Draw into the texture
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    //SJG 0.7 to 0.0 to remove top to bottom gradient
    float gradientAlpha = 0.0;    
    CGPoint vertices[4];
    ccColor4F colors[4];
    int nVertices = 0;
    
    vertices[nVertices] = CGPointMake(0, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0 };
    vertices[nVertices] = CGPointMake(textureSize, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    vertices[nVertices] = CGPointMake(0, textureSize);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    vertices[nVertices] = CGPointMake(textureSize, textureSize);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, colors);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
    
    CCSprite *noise = [CCSprite spriteWithFile:@"Noise.png"];
    [noise setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
    noise.position = ccp(textureSize/2, textureSize/2);
    [noise visit];
    
    // 4: Call CCRenderTexture:end
    [rt end];
    
    // 5: Create a new Sprite from the texture
    return [CCSprite spriteWithTexture:rt.sprite.texture];
    
}

- (ccColor4F)randomBrightColor {    
    while (true) {
        float requiredBrightness = 192;
        ccColor4B randomColor = 
        ccc4(arc4random() % 255,
             arc4random() % 255, 
             arc4random() % 255, 
             255);
        if (randomColor.r > requiredBrightness || 
            randomColor.g > requiredBrightness ||
            randomColor.b > requiredBrightness) {
            return ccc4FFromccc4B(randomColor);
        }        
    }
    
}

- (void)genBackground {
    
    [_background removeFromParentAndCleanup:YES];
    //Use fixed road color
    ccColor4B roadColor = ccc4(209, 133, 34, 255); // brown
//    ccColor4B roadColor = ccc4(20, 200, 30, 255); // green
    ccColor4F bgColor = ccc4FFromccc4B(roadColor);
    
    _background = [self spriteWithColor:bgColor textureSize:512/CC_CONTENT_SCALE_FACTOR()];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _background.position = ccp(winSize.width/2, winSize.height/2);        
    ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [_background.texture setTexParameters:&tp];
    [_background setTextureRect:CGRectMake(0, 0, winSize.width / MIN_SCALE, winSize.height / MIN_SCALE)];
    
    [self addChild:_background];
        
}

- (void)setupWorld {    
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    bool doSleep = true;
    _world = new b2World(gravity, doSleep);            
}

//Position at 0,0 then use source position to follow car
-(void)setupEmitters {
    //Normal Drift
    _drift_emitter = [CCParticleDrift node];
    _drift_emitter.emissionRate = 0.0;
    [_terrain addChild: _drift_emitter];
    [_drift_emitter setPosition:ccp(0,0)];

    //Turbo drift
    _turbo_emitter = [CCParticleTurbo node];
    _turbo_emitter.emissionRate = 0.0;
    [_terrain addChild: _turbo_emitter];
    [_turbo_emitter setPosition:ccp(0,0)];
}

-(void)freezeEmitters {
    [[CCScheduler sharedScheduler] pauseTarget:_drift_emitter];
    [[CCScheduler sharedScheduler] pauseTarget:_turbo_emitter];
}

-(void)resumeEmitters {
    [[CCScheduler sharedScheduler] resumeTarget:_drift_emitter];
    [[CCScheduler sharedScheduler] resumeTarget:_turbo_emitter];
}

- (void)createTestBodyAtPosition:(CGPoint)position {
    
    b2BodyDef testBodyDef;
    testBodyDef.type = b2_dynamicBody;
    testBodyDef.position.Set(position.x/PTM_RATIO, position.y/PTM_RATIO);
    b2Body * testBody = _world->CreateBody(&testBodyDef);
    
    b2CircleShape testBodyShape;
    b2FixtureDef testFixtureDef;
    testBodyShape.m_radius = 25.0/PTM_RATIO;
    testFixtureDef.shape = &testBodyShape;
    testFixtureDef.density = 1.0;
    testFixtureDef.friction = 0.2;
    testFixtureDef.restitution = 0.5;
    testBody->CreateFixture(&testFixtureDef);
    
}

-(id) init {
    if((self=[super init])) {
        
        [self setupWorld];
        //set to 0.5 to zoom out
        self.scale = 1.0;
        
        targetScale = 1.0;
        
        _carRoadIndex = 1;
        _chaseCarRoadIndex = 1;
        racing = NO;

        
        _terrain = [[[Terrain alloc] initWithWorld:_world] autorelease];
        [self addChild:_terrain z:1];
        CCSprite *road = [CCSprite spriteWithFile:@"road_pattern_inverted_fade.png"];
        ccTexParams tp2 = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
        [road.texture setTexParameters:&tp2];
        _terrain.roadTexture = road;
       
        [self genBackground];
        self.isTouchEnabled = YES;  
        [self scheduleUpdate];
        
        _car = [[[Car alloc] initWithWorld:_world spriteFrameName:@"car_body.png"] autorelease];
        [_terrain.batchNode addChild:_car];
        _car.fixedDrift = _fixedDrift;
        //Offset race car to left of path
        CGPoint startPos = _car.startPosition;
        startPos.x -= CAR_SIDE_OFFSET;
        _car.startPosition = startPos;
        
        _chaseCar = [[[Car alloc] initWithWorld:_world spriteFrameName:@"chase_car_body.png"] autorelease];
        [_terrain.batchNode addChild:_chaseCar];
        
        //Offset chase car to right of path
        startPos = _chaseCar.startPosition;
        startPos.x += CAR_SIDE_OFFSET;
        _chaseCar.startPosition = startPos;
        
        _chaseCar.roadSpeed = CHASE_CAR_SPEED;

        [self setupEmitters];
        _emitter = _drift_emitter;        
        
        driftEnabled = YES;
        [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_RACE];
        
        
    }
    return self;
}

- (void)clearWeightedSpeed {
    for(int i = 0; i < NUM_PREV_SPEEDS; ++i) {
        _prevSpeeds[i] = 0;
    }
   
}

-(void)scaleWithSpeed {
    
    float speed = _car.getSpeed;
    float weightedSpeed = speed;
    const float kZoomOutSpeed = 20;
    const float kZoomInSpeed = 10;
    
    for(int i = 0; i < NUM_PREV_SPEEDS; ++i) {
        weightedSpeed += _prevSpeeds[i];
    }
    weightedSpeed = weightedSpeed / NUM_PREV_SPEEDS;    
    _prevSpeeds[_nextSpeed++] = speed;
    if (_nextSpeed >= NUM_PREV_SPEEDS) _nextSpeed = 0;
    
    //set the target scale with hysteresis
    //Zoom out at kZoomOutSpeed zoom in at kZoomInSpeed
    if (weightedSpeed > kZoomOutSpeed && targetScale == MAX_SCALE) {
        targetScale = MIN_SCALE;
    } else if (weightedSpeed < kZoomInSpeed && targetScale < MAX_SCALE){
        targetScale = MAX_SCALE;
    }
    
    if (self.scale > targetScale) {
        self.scale *= 0.99;
        if (self.scale < targetScale) { //clamp to target
            self.scale = targetScale;
        }
    } else if (self.scale < targetScale){
        self.scale *= 1.01;
        if (self.scale > targetScale) { //clamp to target
            self.scale = targetScale;
        }
    }
//    CCLOG(@"speed=%4.2f scale=%4.2f ", weightedSpeed, self.scale);
    
    if (engineSound == nil) {
        engineSound = [[GameManager sharedGameManager] createSoundSource:@"ENGINE"];
    }
    engineSound.looping = YES;
    
    if (weightedSpeed == 0) {
        [engineSound stop];
    } else {
        if (engineSound.isPlaying == NO) {
            [engineSound play];
        }
    }
    
    float speedGain = 0.02 +  weightedSpeed / 100;
    speedGain = MIN(speedGain, 1.0);
    
    float speedPitch = 0.8 + weightedSpeed / 70;
    speedPitch = MIN(speedPitch, 1.6);
    
    if(drifting == NO) {
        engineSound.gain = speedGain;   
        engineSound.pitch = speedPitch;
    }
    
    
    
}

-(void)startDrift {
    //Only create the sound source when needed
    if (gravelSound == nil) {
        gravelSound = [[GameManager sharedGameManager] createSoundSource:@"GRAVEL"];
    }
    gravelSound.looping = YES;
    [gravelSound play];
    _turbo_emitter.emissionRate = 0.0;
    _emitter = _drift_emitter;
    _emitter.emissionRate = 50.0;
    drifting = YES;
}

-(void)endDrift {
    if (gravelSound != 0) {
//        [CDPropertyModifierAction fadeSoundEffect:0.1f finalVolume:0.0f curveType:kIT_Linear shouldStop:YES effect:driftingSound];

        [gravelSound stop];
    }
    //test if end of turbo drift
    if (turboDrifting) {
        turboDrifting = NO;
        [_car turboBoost];
    }
    drifting = NO;
    _emitter.emissionRate = 0.0;
}


-(void)updatePhysics:(ccTime)dt {
    static double UPDATE_INTERVAL = 1.0f/60.0f;
    static double MAX_CYCLES_PER_FRAME = 5;
    static double timeAccumulator = 0;
    
    timeAccumulator += dt;    
    if (timeAccumulator > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL)) {
        timeAccumulator = UPDATE_INTERVAL;
    }    
    
    int32 velocityIterations = 3;
    int32 positionIterations = 2;
    while (timeAccumulator >= UPDATE_INTERVAL) {        
        timeAccumulator -= UPDATE_INTERVAL;       
        
        _world->Step(UPDATE_INTERVAL, 
                     velocityIterations, positionIterations);        
        _world->ClearForces();
        
    }
   
}

-(void)raceEnded {
    [self endDrift];
    driftEnabled = NO;
    _car.driftAngle = 0;
    _car.roadSpeed = 0;
    
    //determine if won or lost
    float carY = _car.position.y;
    float chaseCarY = _chaseCar.position.y;
    
    [GameManager sharedGameManager].raceWon  = carY >= chaseCarY;
    [[GameManager sharedGameManager] endRace ];   
}

- (void)update:(ccTime)dt {
        
    
    [self updatePhysics:dt];
    
    if (_tapDown && racing) {
        if (!_car.driving) {
            [_car drive];
        } else if(driftEnabled && !drifting) {
            [self startDrift];
        }
    } else if(drifting) {
        [self endDrift];
    }
    
    if (driftEnabled) {
        _car.driftAngle = _driftControlAngle;
    }
    
    _terrain.targetRoadIndex = _carRoadIndex;
    CGPoint target = [_terrain nextTargetPoint:_car.position];
    if ([_terrain atDriveEnd]) {
//        //end of path drive section
        [self raceEnded];
        return;
    }
    [_car setTarget:target];
    
    float targetCurve = [_terrain targetCurve];
    [_car setPathCurve:targetCurve];
    
    // CCLOG(@"drift:  target x=%4.2f y=%4.2f  ", target.x, target.y);
    CGPoint tangent = [_terrain targetTangent];
    [_car setPathTangent:tangent];
    
    [_car update];
    float offsetX = _car.position.x;
    float offsetY = _car.position.y;
    
    _carRoadIndex = _terrain.targetRoadIndex;
    _terrain.targetRoadIndex = _chaseCarRoadIndex;
    
    target = [_terrain nextTargetPoint:_chaseCar.position];
    [_chaseCar setTarget:target];
    targetCurve = [_terrain targetCurve];
    [_chaseCar setPathCurve:targetCurve];
    
    // CCLOG(@"drift:  target x=%4.2f y=%4.2f  ", target.x, target.y);
    tangent = [_terrain targetTangent];
    [_chaseCar setPathTangent:tangent];
    
    [_chaseCar update];
    _chaseCarRoadIndex = _terrain.targetRoadIndex;
   

    
    CGSize textureSize = _background.textureRect.size;
    [_background setTextureRect:CGRectMake(offsetX, -offsetY, textureSize.width, textureSize.height)];
    
    //Particles when drifting only
    if (drifting) {
        //if turbo time change emitter
        double drift_time = CACurrentMediaTime() - driftStartTime; 
        if (drift_time > k_turbo_time) {
            turboDrifting = YES;
            _drift_emitter.emissionRate = 0.0;
            _emitter = _turbo_emitter;
            _emitter.emissionRate = 50.0;
        }
        

        float soundGain = 0.2 +  ABS(_driftControlAngle) / 4;
        soundGain = MIN(soundGain, 1.0);
        
        float soundPitch = 1.0 + ABS(_driftControlAngle) / 3;
        soundPitch = MIN(soundPitch, 2.0);
                           
        engineSound.gain = soundGain;    //0.2 - 1.0
        engineSound.pitch = soundPitch;  //1.0 - 2.0
        
        gravelSound.gain = soundGain+.5;    //0.2 - 1.0
        gravelSound.pitch = soundPitch;  //1.0 - 2.0
        
        
        
        float posRadians = CC_DEGREES_TO_RADIANS(90 - _car.rotation);
        CGPoint particleDrift;
        //ccpForAngle zero along x axis, CCW positive
        particleDrift = ccpForAngle(posRadians);
        particleDrift= ccpMult(particleDrift, 0);
        
        _emitter.gravity = particleDrift;
        
        [_emitter setSourcePosition:ccp(_car.position.x / _emitter.scale, _car.position.y / _emitter.scale)];        
    }
    
  
    [_terrain setOffset:ccp(_car.position.x, _car.position.y)];
    
    [self scaleWithSpeed];
    
    //uncomment to rotate view with car
//    [_terrain updateRotation:_car.rotation];
    
}

-(void)destroyBodies {
    //Destroy any body if exists
    b2Body* body_list =  _world->GetBodyList();
    if (body_list != NULL) {
        _world->DestroyBody(body_list);
    }
}


-(void)resetStart {
    racing = NO;
    
    [_car resetDrive];
    [_chaseCar resetDrive];
    _chaseCar.roadSpeed = CHASE_CAR_SPEED;

    driftEnabled = YES;
    //Reset the target point after the car has stopped
    _carRoadIndex = 1;
    _chaseCarRoadIndex = 1;
    [self clearWeightedSpeed];
    [self resumeEmitters];
    [self resumeSchedulerAndActions];    
}

-(void)startRace {
    [_chaseCar drive];
    _tapDown = NO; //force a new touch at start
    racing = YES;
    [self resumeEmitters];
    [self resumeSchedulerAndActions];
}

-(void)pauseRace {
    [gravelSound stop];
    [engineSound stop];
    
    //Freeze the particles
    [self freezeEmitters];
    [self pauseSchedulerAndActions]; 
}

-(void)resumeRace {
    [self resumeEmitters];
    [self resumeSchedulerAndActions];    
}

-(void)endrace {
    [self pauseRace];
}

//remember the touch start location for relative slides
static CGPoint startLoc;
//remember the touch start time

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _tapDown = YES;
    turboDrifting = NO;
    driftStartTime = CACurrentMediaTime();
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    startLoc = [[CCDirector sharedDirector] convertToGL:location];
    
    if (_car.driving && _fixedDrift) {
        _driftControlAngle = 0.7;
    }
    
   // CCLOG(@"drift:  touches began x=%4.2f y=%4.2f  ", cLoc.x, cLoc.y);

    
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    const float kMaxDrift = 2.0;    //Maximum drift angle in radians
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    CGPoint cLoc = [[CCDirector sharedDirector] convertToGL:location];
    
    if (!_fixedDrift) {
        _driftControlAngle = (startLoc.x - cLoc.x) / 50;
    }
    if (_driftControlAngle > kMaxDrift) {
        _driftControlAngle = kMaxDrift;
    } else {
        if (_driftControlAngle < -kMaxDrift) {
            _driftControlAngle = -kMaxDrift;
        }
    }

    
//    CCLOG(@"drift:  touches moved drift=%4.2f", _driftControl);
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _tapDown = NO;
    _driftControlAngle = 0;
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _tapDown = NO;
    _driftControlAngle = 0;
}

-(void) dealloc {
    
    //Release all our retained objects
    [engineSound release];
    [gravelSound release];
    [super dealloc];
}

@end
