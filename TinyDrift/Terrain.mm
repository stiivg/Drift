//
//  Terrain.m
//  TinyDrift
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "Terrain.h"
#import "GameplayLayer.h"

@implementation Terrain
@synthesize batchNode = _batchNode;
@synthesize roadTexture = _roadTexture;

int _lastRoadPoint = 100;
static int targetRoadIndex= 0;

- (void) resetBox2DBody {
    
    if(_body) {
        _world->DestroyBody(_body);
    }
    
    b2BodyDef bd;
    bd.position.Set(0, 0);
    
    _body = _world->CreateBody(&bd);
    
    b2PolygonShape shape;
    
//    b2Vec2 p1, p2;
//    for (int i=0; i<_nBorderVertices-1; i++) {
//        p1 = b2Vec2(_borderVertices[i].x/PTM_RATIO,_borderVertices[i].y/PTM_RATIO);
//        p2 = b2Vec2(_borderVertices[i+1].x/PTM_RATIO,_borderVertices[i+1].y/PTM_RATIO);
//        shape.SetAsEdge(p1, p2);
//        _body->CreateFixture(&shape, 0);
//    }
}

- (void) generateRoad {

    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float x = winSize.width/2;
    float y = 0;
    int i = 0;
    
#define kStraightKeyPoints 20
#define kCornerRadius 1000

    //first straight section
    for (i=0; i<kStraightKeyPoints; i++) {
        _roadKeyPoints[i] = CGPointMake(x, y);
        y += 160;
    }
    //top curve includes last point of straight
    float curveCenterX = x - kCornerRadius;
    float curveCenterY = y;
    for (float theta=0; theta<M_PI_2; theta+=0.1) {
        x = curveCenterX + kCornerRadius * cosf(theta);
        y = curveCenterY + kCornerRadius * sinf(theta);
        _roadKeyPoints[i++] = CGPointMake(x, y);
    }
    //set new curve center
    curveCenterY += 2 * kCornerRadius;
    
    for (float theta=0; theta<M_PI; theta+=0.1) {
        x = curveCenterX - kCornerRadius * sinf(theta);
        y = curveCenterY - kCornerRadius * cosf(theta);
        _roadKeyPoints[i++] = CGPointMake(x, y);
    }
    
    //set new curve center
    curveCenterY += 2 * kCornerRadius;
    
    for (float theta=0; theta<M_PI_2; theta+=0.1) {
        x = curveCenterX + kCornerRadius * sinf(theta);
        y = curveCenterY - kCornerRadius * cosf(theta);
        _roadKeyPoints[i++] = CGPointMake(x, y);
    }
    
    
    //middle straight section
    for (int j=0; j<kStraightKeyPoints; j++) {
        y += 160;
        _roadKeyPoints[i++] = CGPointMake(x, y);
    }
    y += 160;

    //top curve includes last point of straight
    curveCenterX = x + kCornerRadius;
    curveCenterY = y;
    for (float theta=0; theta<M_PI_2; theta+=0.1) {
        x = curveCenterX - kCornerRadius * cosf(theta);
        y = curveCenterY + kCornerRadius * sinf(theta);
        _roadKeyPoints[i++] = CGPointMake(x, y);
    }
    //set new curve center
    curveCenterY += 2 * kCornerRadius;
    
    for (float theta=0; theta<M_PI; theta+=0.1) {
        x = curveCenterX + kCornerRadius * sinf(theta);
        y = curveCenterY - kCornerRadius * cosf(theta);
        _roadKeyPoints[i++] = CGPointMake(x, y);
    }
    
    //set new curve center
    curveCenterY += 2 * kCornerRadius;
    
    for (float theta=0; theta<M_PI_2; theta+=0.1) {
        x = curveCenterX - kCornerRadius * sinf(theta);
        y = curveCenterY - kCornerRadius * cosf(theta);
        _roadKeyPoints[i++] = CGPointMake(x, y);
    }

    
    //final straight
    x = curveCenterX - kCornerRadius;
    y = curveCenterY;
    
    for (int j=0; j<kStraightKeyPoints; j++) {
        _roadKeyPoints[i++] = CGPointMake(x, y);
        y += 160;
    }
    _lastRoadPoint = i - 1;
    
}

- (void)resetRoadVertices {
    
    _nRoadVertices = 0;
    CGPoint p0, p1, roadSegment, perpSegment;
    CGPoint l0, r0;
    CGFloat roadDistance = 0;
    
    p0 = _roadKeyPoints[0];
    for (int i=0; i<_lastRoadPoint; i++) {
        p1 = _roadKeyPoints[i+1];
        roadSegment = ccpSub(p1, p0);
        roadSegment = ccpNormalize(roadSegment);
        perpSegment = ccpRPerp(roadSegment);
        l0 = ccpMult(perpSegment, -128);
        r0 = ccpMult(perpSegment, 128);
        
        _roadVertices[_nRoadVertices]  = ccpAdd(p0, l0);
        _roadTexCoords[_nRoadVertices++] = CGPointMake(0, roadDistance/512);
        
        _roadVertices[_nRoadVertices]  = ccpAdd(p0, r0);
        _roadTexCoords[_nRoadVertices++] = CGPointMake(1.0f, roadDistance/512);
        
        
        roadDistance += ccpDistance(p0, p1);
        p0 = p1;
        
    }
        
}



- (void)setupDebugDraw {    
    _debugDraw = new GLESDebugDraw(PTM_RATIO*[[CCDirector sharedDirector] contentScaleFactor]);
    _world->SetDebugDraw(_debugDraw);
    _debugDraw->SetFlags(b2DebugDraw::e_shapeBit | b2DebugDraw::e_jointBit);
}

- (id)initWithWorld:(b2World *)world {
    if ((self = [super init])) {
        _world = world;
        [self setupDebugDraw];
        [self generateRoad];
        
        [self resetRoadVertices];
        
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"smallCar.png"];
        [self addChild:_batchNode z:1]; //z=1 above emitter
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"smallCar.plist"];
    }
    return self;
}

- (void) draw {
        //SJG Disable the hill drawing
//    CCLOG(@"drift:  from:%i to:%i ", _fromKeyPointI, _toKeyPointI);

    CGSize winSize = [CCDirector sharedDirector].winSize;

    glBindTexture(GL_TEXTURE_2D, _roadTexture.texture.name);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glColor4f(1, 1, 1, 1);
    glVertexPointer(2, GL_FLOAT, 0, _roadVertices);
    glTexCoordPointer(2, GL_FLOAT, 0, _roadTexCoords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)_nRoadVertices);
    
    //SJG debug draw path
//    for(int i = MAX(_fromKeyPointI, 1); i <= _toKeyPointI; ++i) {
//        glColor4f(0, 1.0, 0, 1.0); 
//        ccDrawLine(_roadKeyPoints[i-1], _roadKeyPoints[i]);     
        

//    }
    
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    //_world->DrawDebugData();
    
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
}

//Return the next road point past the look ahead distance
- (CGPoint)nextTargetPoint:(CGPoint)position {
#define kLookAheadSq 40000
    CGPoint testPoint = _roadKeyPoints[targetRoadIndex];
   
    for (; targetRoadIndex<_lastRoadPoint; targetRoadIndex++) {
        testPoint = _roadKeyPoints[targetRoadIndex];
        int dx =  (int)(position.x - testPoint.x);
        int dy =  (int)(position.y - testPoint.y);        
        if ((dx*dx + dy*dy) > kLookAheadSq) {
            return testPoint;
        }
    }
    
    return testPoint;
}

- (CGPoint)targetTangent {
    CGPoint prevPoint = _roadKeyPoints[targetRoadIndex-1];
    CGPoint nextPoint = _roadKeyPoints[targetRoadIndex+1];
    CGPoint tangent = ccpSub(nextPoint, prevPoint);
    return tangent;
}

-(void) setOffset:(CGPoint)newOffset {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _offsetX = newOffset.x;
    _offsetY = newOffset.y;
    
    self.position = CGPointMake(winSize.width/2-_offsetX*self.scale, winSize.height/4-_offsetY*self.scale);
//    [self resetRoadVertices];
}

- (void) updateRotation:(float)newRotation {
    self.rotation = newRotation;
//    self.rotation = 60;
    float rotationRadians = CC_DEGREES_TO_RADIANS(self.rotation);
    
    //update offset to maintain the car in the same position
    _offsetX = _offsetX * (1 - sinf(rotationRadians));
    _offsetY = _offsetY * (1 - cosf(rotationRadians));
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    self.position = CGPointMake(winSize.width/2-_offsetX*self.scale, winSize.height/4-_offsetY*self.scale);
    
    //SJG TODO draw the new terrain revealed here
    //[self resetHillVertices];
}


- (void)dealloc {
    [_roadTexture release];
    _roadTexture = NULL;
    [super dealloc];
}


@end