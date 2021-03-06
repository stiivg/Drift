//
//  Terrain.h
//  TinyDrift
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#ifndef drift_Terrain_h
#define drift_Terrain_h


#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "HermitePath.h"

@class GameplayLayer;

#define kMaxRoadKeyPoints 1000
#define kRoadSegmentWidth 5
#define kMaxRoadVertices 4000
#define kMaxBorderVertices 800
#define kPointsToEnd 20

@interface Terrain : CCNode {
    int _offsetX;
    int _offsetY;
    CGPoint _roadKeyPoints[kMaxRoadKeyPoints];
    CGPoint _pathPoints[kMaxRoadKeyPoints];
    CCSprite *_roadTexture;
    HermitePath * _path;

    
    int _nRoadVertices;
    CGPoint _roadVertices[kMaxRoadVertices];
    CGPoint _roadTexCoords[kMaxRoadVertices];
    int _nBorderVertices;
    CGPoint _borderVertices[kMaxBorderVertices];
    int _targetRoadIndex;
    
    b2World *_world;
    b2Body *_body;
    GLESDebugDraw * _debugDraw;
    
    CCSpriteBatchNode * _batchNode;
    CCSprite *oilDrum;
}

@property (retain) CCSpriteBatchNode * batchNode;
@property (retain) CCSprite * roadTexture;
@property int targetRoadIndex;

- (void)resetTargetPoint;
- (CGPoint)nextTargetPoint:(CGPoint)position;
- (CGPoint)targetTangent;
- (float)targetCurve;
- (BOOL)atRaceEnd;
- (BOOL)atRoadEnd;
- (void) setOffset:(CGPoint)newOffset;
- (id)initWithWorld:(b2World *)world;
- (CGPoint*)getPath;

@end

#endif