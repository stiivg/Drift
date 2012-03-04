//
//  LoopLayer.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 1/22/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//


#import "LoopLayer.h"
#import "GameManager.h"
#import "emitters.h"

@implementation LoopLayer

//SJG TODO link failed when same name as GameplayLayer
CCParticleSystem * _drift2_emitter;
CCParticleSystem * _turbo2_emitter;


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


- (void)genBackground {
    
    [_background removeFromParentAndCleanup:YES];
    //Use fixed road color
    ccColor4B roadColor = ccc4(209, 133, 34, 255);
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

-(void)setupEmitters {
    //Normal Drift
    _drift2_emitter = [CCParticleDrift node];
    _drift2_emitter.emissionRate = 0.0;
    [_terrain addChild: _drift2_emitter];
    [_drift2_emitter setPosition:ccp(_car.position.x, _car.position.y)];
    
    //Turbo drift
    _turbo2_emitter = [CCParticleTurbo node];
    _turbo2_emitter.emissionRate = 0.0;
    [_terrain addChild: _turbo2_emitter];
    [_turbo2_emitter setPosition:ccp(_car.position.x, _car.position.y)];
}


-(id) init {
    if((self=[super init])) {
        
        [self setupWorld];
        //set to 0.5 to zoom out
        self.scale = 1.0;
        
        targetScale = 1.0;
        
        _terrain = [[[Terrain alloc] initWithWorld:_world] autorelease];
        [self addChild:_terrain z:1];
        CCSprite *road = [CCSprite spriteWithFile:@"road_pattern.png"];
        ccTexParams tp2 = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
        [road.texture setTexParameters:&tp2];
        _terrain.roadTexture = road;
        
        [self genBackground];
        self.isTouchEnabled = YES;  
        [self scheduleUpdate];
        
        _car = [[[Car alloc] initWithWorld:_world spriteFrameName:@"car_body.png"] autorelease];
        [_terrain.batchNode addChild:_car];
        
        [self setupEmitters];
        _emitter = _drift2_emitter;        
//        [_car drive];
        
        
        //SJG continuous background music off
        //      [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"TinyDrift.caf" loop:YES];
        
    }
    return self;
}


- (void)update:(ccTime)dt {
        
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
    
    CGPoint target = [_terrain nextTargetPoint:_car.position];
    [_car setTarget:target];
    
    // CCLOG(@"drift:  target x=%4.2f y=%4.2f  ", target.x, target.y);
    CGPoint tangent = [_terrain targetTangent];
    [_car setPathTangent:tangent];
    
    [_car update];
    float offsetX = _car.position.x;
    float offsetY = _car.position.y;
    
    
    CGSize textureSize = _background.textureRect.size;
    [_background setTextureRect:CGRectMake(offsetX, -offsetY, textureSize.width, textureSize.height)];
    
    [_terrain setOffset:ccp(_car.position.x, _car.position.y)];
    
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
    //Zoom out at kZoomOutSpeed zoom in to 1.0 at kZoomInSpeed
    if (weightedSpeed > kZoomOutSpeed && targetScale == 1.0) {
        targetScale = MIN_SCALE;
    } else if (weightedSpeed < kZoomInSpeed && targetScale < 1.0){
        targetScale = 1.0;
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
    
    
    //uncomment to rotate view with car
    //    [_terrain updateRotation:_car.rotation];
    
}

@end
