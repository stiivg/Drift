//
//  GameplayLayer.mm
//  TinyDrift
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//


#import "GameplayLayer.h"
#import "SimpleAudioEngine.h"

@implementation GameplayLayer


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
    ccColor4B roadColor = ccc4(209, 133, 34, 255);
    ccColor4F bgColor = ccc4FFromccc4B(roadColor);
    
    _background = [self spriteWithColor:bgColor textureSize:512];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _background.position = ccp(winSize.width/2, winSize.height/2);        
    ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [_background.texture setTexParameters:&tp];
    [_background setTextureRect:CGRectMake(0, 0, winSize.width/self.scale, winSize.height/self.scale)];
    
    [self addChild:_background];
        
}

- (void)setupWorld {    
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    bool doSleep = true;
    _world = new b2World(gravity, doSleep);            
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
        self.scale = 0.5;
        
        _terrain = [[[Terrain alloc] initWithWorld:_world] autorelease];
        [self addChild:_terrain z:1];
        CCSprite *road = [CCSprite spriteWithFile:@"road_pattern.png"];
        ccTexParams tp2 = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
        [road.texture setTexParameters:&tp2];
        _terrain.roadTexture = road;

       
       
        [self genBackground];
        self.isTouchEnabled = YES;  
        [self scheduleUpdate];
        
        _car = [[[Car alloc] initWithWorld:_world] autorelease];
        [_terrain.batchNode addChild:_car];
        
        _emitter = [CCParticleSmoke node];
        [_terrain addChild: _emitter];
        //[self addChild: _emitter];
        _emitter.scale = 1.0;
        _emitter.gravity = ccp(0,-200);
        _emitter.positionType = kCCPositionTypeFree;
        
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        //copied from terrain offset
//        [_emitter setPosition:ccp(winSize.width/2, winSize.height/4)];
        [_emitter setPosition:ccp(_car.position.x, _car.position.y)];


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
        
        if (_tapDown) {
            if (!_car.driving) {
                [_car drive];
            }
        }
        _car.driftAngle = _driftControl;
        
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
    //Particles when drifting only
    if (_driftControl == 0) {
        _emitter.emissionRate = 0.0;
    } else {
        _emitter.emissionRate = 50.0;
    
        float posRadians = CC_DEGREES_TO_RADIANS(90 - _car.rotation);
        CGPoint particleDrift;
        //ccpForAngle zero along x axis, CCW positive
        particleDrift = ccpForAngle(posRadians);
        particleDrift= ccpMult(particleDrift, -20);

        _emitter.gravity = particleDrift;
    
        [_emitter setSourcePosition:ccp(_car.position.x / _emitter.scale, _car.position.y / _emitter.scale)];
    }
  
    [_terrain setOffset:ccp(_car.position.x, _car.position.y)];
    //[_emitter setPosition:ccp(_car.position.x, _car.position.y)];

    //uncomment to rotate view with car
//    [_terrain updateRotation:_car.rotation];
    
}

//remember the touch start location for relative slides
static CGPoint startLoc;

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _tapDown = YES;    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    startLoc = [[CCDirector sharedDirector] convertToGL:location];
    
   // CCLOG(@"drift:  touches began x=%4.2f y=%4.2f  ", cLoc.x, cLoc.y);

    
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    CGPoint cLoc = [[CCDirector sharedDirector] convertToGL:location];
    
    _driftControl = (startLoc.x - cLoc.x) / 50;

    
   // CCLOG(@"drift:  touches moved drift=%4.2f", _driftControl);
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _tapDown = NO;
    _driftControl = 0;
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _tapDown = NO;
    _driftControl = 0;
}

@end
