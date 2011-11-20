//
//  Terrain.h
//  TinyDrift
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "Path.h"

@class GameplayLayer;

#define kMaxRoadKeyPoints 1000
#define kRoadSegmentWidth 5
#define kMaxRoadVertices 4000
#define kMaxBorderVertices 800 

@interface Terrain : CCNode {
    int _offsetX;
    int _offsetY;
    CGPoint _roadKeyPoints[kMaxRoadKeyPoints];
    CCSprite *_roadTexture;
    Path * _path;

    
    int _nRoadVertices;
    CGPoint _roadVertices[kMaxRoadVertices];
    CGPoint _roadTexCoords[kMaxRoadVertices];
    int _nBorderVertices;
    CGPoint _borderVertices[kMaxBorderVertices];
    
    b2World *_world;
    b2Body *_body;
    GLESDebugDraw * _debugDraw;
    
    CCSpriteBatchNode * _batchNode;
}

@property (retain) CCSpriteBatchNode * batchNode;
@property (retain) CCSprite * roadTexture;

- (CGPoint)nextTargetPoint:(CGPoint)position;
- (CGPoint)targetTangent;
- (void) setOffset:(CGPoint)newOffset;
- (void) updateRotation:(float)rotation;
- (id)initWithWorld:(b2World *)world;

@end
