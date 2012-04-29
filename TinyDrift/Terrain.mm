//
//  Terrain.m
//  TinyDrift
//
//  Created by Steven Gallagher on 12/1/11.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#import "Terrain.h"
#import "GameplayLayer.h"

@implementation Terrain
@synthesize batchNode = _batchNode;
@synthesize roadTexture = _roadTexture;
@synthesize targetRoadIndex = _targetRoadIndex;

int _lastRoadPoint = 100;


//Map the texture to the road points
//Alternate left and right of road
- (void)resetRoadVertices {
    
    _nRoadVertices = 0;
    CGPoint p0, p1, roadSegment, perpSegment;
    CGPoint l0, r0;
    CGFloat roadDistance = 0;
    
    int half_road_width = 128 * CC_CONTENT_SCALE_FACTOR(); 
    
    _targetRoadIndex= 1;
    p0 = _pathPoints[0];
    for (int i=0; i<_lastRoadPoint-1; i++) {
        p1 = _pathPoints[i+1];
        roadSegment = ccpSub(p1, p0);
        roadSegment = ccpNormalize(roadSegment);
        perpSegment = ccpRPerp(roadSegment);
        l0 = ccpMult(perpSegment, -half_road_width);
        r0 = ccpMult(perpSegment, half_road_width);
        
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

- (void)addGate {
    CCSprite *grid = [CCSprite spriteWithFile:@"grid.png"];
    CGPoint driveEndPoint = _pathPoints[_lastRoadPoint-kPointsToEnd];
    driveEndPoint = ccpMult(driveEndPoint, 1/CC_CONTENT_SCALE_FACTOR());
    grid.position = driveEndPoint;
    [self addChild:grid];
}

- (id)initWithWorld:(b2World *)world {
    if ((self = [super init])) {
        _world = world;
        [self setupDebugDraw];
        _path = [[[HermitePath alloc] createPath:_pathPoints] autorelease];
        _lastRoadPoint = _path.getNumPathPoints;
        _targetRoadIndex = 1;
        
        [self resetRoadVertices];
        
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"driftCar.png"];
        [self addChild:_batchNode z:1]; //z=1 above emitter
        //plist puts the targetfilename under a target node not expected by this call
        //May be fixed in future Zwoptex release
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"driftCar.plist"];
        
        [self addGate];
    }
    return self;
}

- (void) draw {
        //SJG Disable the hill drawing
//    CCLOG(@"drift:  from:%i to:%i ", _fromKeyPointI, _toKeyPointI);

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
    //Draw the box2d bodies
//    _world->DrawDebugData();
    
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
}


//Return the next road point past the look ahead distance
//return 0,0 if end of path
- (CGPoint)nextTargetPoint:(CGPoint)position {
    //scale position in points to actual pixels
    position.x *= CC_CONTENT_SCALE_FACTOR();
    position.y *= CC_CONTENT_SCALE_FACTOR();
    
    CGPoint testPoint = _pathPoints[_targetRoadIndex];

    for (; _targetRoadIndex<_lastRoadPoint; _targetRoadIndex++) {
        testPoint = _pathPoints[_targetRoadIndex];
        int dx =  (int)(position.x - testPoint.x);
        int dy =  (int)(position.y - testPoint.y);
        
        CGPoint tangent = self.targetTangent;
        float angleTangent = atan2f(tangent.x, tangent.y);
        float angleCar = atan2f(dx, dy);
        float angleDiff = angleTangent - angleCar;
        //test if behind this point
        if (angleDiff > 1.5 || angleDiff < -1.5) {
            //Scale back to position in points
            testPoint.x *= 1/CC_CONTENT_SCALE_FACTOR();
            testPoint.y *= 1/CC_CONTENT_SCALE_FACTOR();
//            CCLOG(@"target=%i",_targetRoadIndex);
            return testPoint;
        }
    }
    
    testPoint.x = 0;
    testPoint.y = 0;
    return testPoint;
}

//-(float)viewAngle:(int)pathIndex {
//    //linear fit to path points around target
//    //Fit jumps 90 degrees at apex of corner
//    int numPrePoints = 0;
//    int numPostPoints = 1;
//    double sumX = 0;
//    double sumY = 0;
//    for (int i=pathIndex-numPrePoints; i<= pathIndex+numPostPoints; i++) {
//        sumX += _pathPoints[i].x;
//        sumY += _pathPoints[i].y;
//    }
//
//    double sumXMean = sumX/(numPrePoints+numPostPoints+1);
//    double sumT2 = 0;
//    double slope = 0;
//    double diff = 0;
//    for (int i=pathIndex-numPrePoints; i<= pathIndex+numPostPoints; i++) {
//        diff = _pathPoints[i].x - sumXMean;
//        sumT2 += (diff*diff);
//        slope += (diff*_pathPoints[i].y);
//    }    
//    
//    float angle = M_PI/2.0f;
//    if (sumT2 != 0) {
//        slope = slope / sumT2;    
//        angle = atanf(slope);
//    }
//    
//    //determine direction along slope line
//    CGPoint startPoint  = _pathPoints[pathIndex-numPrePoints];
//    CGPoint endPoint  = _pathPoints[pathIndex+numPostPoints];
//    if (ABS(angle)<0.7) { //left or right
//        if ((endPoint.x - startPoint.x)< 0) {
//            angle = M_PI - ABS(angle);
//        }
//    } else { //up or down
//        if ((endPoint.y - startPoint.y)> 0 && angle < 0) {
//            angle = M_PI + angle;
//        } else if ((endPoint.y - startPoint.y)< 0 && angle > 0) {
//            angle = M_PI - angle;
//        }
//    }
//   return CC_RADIANS_TO_DEGREES(angle) - 90;
//    
//}

//True if at end of path drive section
- (BOOL)atRaceEnd {
    return _targetRoadIndex >= _lastRoadPoint-kPointsToEnd;
}

//True if at end of road
- (BOOL)atRoadEnd {
    return _targetRoadIndex >= _lastRoadPoint;
}

//Returns path curve at the target point
//positive for curves to the right, negative to the left
-(float)targetCurve {
    CGPoint prevPoint = _pathPoints[_targetRoadIndex-1];
    CGPoint targetPoint = _pathPoints[_targetRoadIndex];
    CGPoint nextPoint = _pathPoints[_targetRoadIndex+1];
    CGPoint tangent = ccpSub(targetPoint, prevPoint);
    CGPoint nextTangent = ccpSub(nextPoint, targetPoint);
    
    float angleTangent = atan2f(tangent.x, tangent.y);
    float angleNextTangent = atan2f(nextTangent.x, nextTangent.y);
    float curve = angleTangent - angleNextTangent;
//    CCLOG(@"curve=%4.4f",curve);
    return curve;
}

- (CGPoint)targetTangent {
    CGPoint prevPoint = _pathPoints[_targetRoadIndex-1];
    CGPoint nextPoint = _pathPoints[_targetRoadIndex];
    CGPoint tangent = ccpSub(nextPoint, prevPoint);
    return tangent;
}

//To keep the car in the same screen location at all scales
//The scale factor zooms about the screen center
//Calc the pixel distance from the bottom of the screen to original screen bottom (at scale 1.0)
//Subtract the constant pixel offset desired
//Divide by scale to converFt pixels to scaled units
-(void) setOffset:(CGPoint)newOffset {
    const float kBaseOffset = 200;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float scale = self.parent.scale;
    float viewOffset  = (winSize.height/2 * (1 - scale) - kBaseOffset) / scale;
    
    _offsetX = newOffset.x;
    _offsetY = newOffset.y;
    
    self.position = CGPointMake(winSize.width/2-_offsetX*self.scale, -viewOffset -_offsetY*self.scale);
//    [self resetRoadVertices];
}

-(CGPoint *)getPath {
    return _pathPoints;
}

- (void)resetTargetPoint {
    _targetRoadIndex= 1;
}


- (void)dealloc {
    [_roadTexture release];
    _roadTexture = NULL;
    [super dealloc];
}


@end