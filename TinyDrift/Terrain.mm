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

int _lastRoadPoint = 100;

- (void) createEdges {
    
    if(_body) {
        _world->DestroyBody(_body);
    }
    
    b2BodyDef bd;
    bd.position.Set(0, 0);
    
    _body = _world->CreateBody(&bd);
    
    b2PolygonShape shape;
    //Takes alternate edge points and makes
    //edge lines for alternating sides of the road
    b2Vec2 p1, p2;
    for (int i=0; i<_nRoadVertices-2; i++) {
        p1 = b2Vec2(_roadVertices[i].x/PTM_RATIO,_roadVertices[i].y/PTM_RATIO);
        p2 = b2Vec2(_roadVertices[i+2].x/PTM_RATIO,_roadVertices[i+2].y/PTM_RATIO);
        shape.SetAsEdge(p1, p2);
        _body->CreateFixture(&shape, 0);
    }
}


- (void) writeRoadFile {
    NSString *filePath = @"/Users/stevengallagher/Documents/DriftGithub/roadPoints.tsv";
    FILE *file;
    file = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "w");
    
    for (int i=0; i<_lastRoadPoint; i++) {
        fprintf(file, "%f\t%f\n",_roadKeyPoints[i].x,_roadKeyPoints[i].y);
    }
    fclose(file);
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
    //uncomment to write file of road points
    [self writeRoadFile];
    
}


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
//        [self generateRoad];
        
        [self resetRoadVertices];
//        [self createEdges];
        
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"driftCar.png"];
        [self addChild:_batchNode z:1]; //z=1 above emitter
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
    
    //_world->DrawDebugData();
    
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

//True if at end of path drive section
- (BOOL)atDriveEnd {
    return _targetRoadIndex >= _lastRoadPoint-kPointsToEnd;
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
//Divide by scale to convert pixels to scaled units
-(void) setOffset:(CGPoint)newOffset {
    const float kBaseOffset = 100;
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float scale = self.parent.scale;
    float viewOffset  = (winSize.height/2 * (1 - scale) - kBaseOffset) / scale;
    
    
    _offsetX = newOffset.x;
    _offsetY = newOffset.y;
    
    self.position = CGPointMake(winSize.width/2-_offsetX*self.scale, -viewOffset -_offsetY*self.scale);
//    [self resetRoadVertices];
}

- (void) updateRotation:(float)newRotation {
    self.anchorPoint = ccp(0.5, 0.5);
    self.rotation = newRotation;
//    self.rotation = -20;
//    float rotationRadians = CC_DEGREES_TO_RADIANS(self.rotation);
//    
//    //update offset to maintain the car in the same position
//    _offsetX = _offsetX * (1 - sinf(rotationRadians));
//    _offsetY = _offsetY * (1 - cosf(rotationRadians));
//    
//    CGSize winSize = [CCDirector sharedDirector].winSize;
//    
//    self.position = CGPointMake(winSize.width/2-_offsetX*self.scale, winSize.height/4-_offsetY*self.scale);
    
    //SJG TODO draw the new terrain revealed here
    //[self resetHillVertices];
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