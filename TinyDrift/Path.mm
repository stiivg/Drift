//
//  Path.mm
//  TinyDrift
//
//  Created by Steve Gallagher on 11/13/11.
//  Copyright 2011 Steve Gallagher. All rights reserved.
//

#import "Path.h"

@implementation Path


// Reference: http://www.cubic.org/docs/bezier.htm


// simple linear interpolation between two points
-(CGPoint)interpolate:(CGPoint)a endPoint:(CGPoint)b fraction:(float)t {
    CGPoint retVal;
    retVal.x = a.x + (b.x-a.x)*t;
    retVal.y = a.y + (b.y-a.y)*t;
    return retVal;
}

// evaluate a point on a bezier-curve. t goes from 0 to 1.0
-(CGPoint)cgbezier:(CGPoint)a b:(CGPoint)b c:(CGPoint)c d:(CGPoint)d t:(float)t {
    CGPoint bezierPoint;
    CGPoint ab,bc,cd,abbc,bccd;
    ab = [self interpolate:a endPoint:b fraction:t];
    bc = [self interpolate:b endPoint:c fraction:t];
    cd = [self interpolate:c endPoint:d fraction:t];
    abbc = [self interpolate:ab endPoint:bc fraction:t];
    bccd = [self interpolate:bc endPoint:cd fraction:t];
    bezierPoint = [self interpolate:abbc endPoint:bccd fraction:t];
    return bezierPoint;
}

// small test program.. just prints the points
-(void) cgtest {
    // 4 points define the bezier-curve. These are the points used
    // for the example-images on this page.
    CGPoint a = CGPointMake(40, 100);
    CGPoint b = CGPointMake(80, 20);
    CGPoint c = CGPointMake(150, 180);
    CGPoint d = CGPointMake(260, 100);
    
    NSString *filePath = @"/Users/stevengallagher/Documents/DriftGithub/roadPoints2.tsv";
    FILE *file;
    file = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "w");
    
    for (int i=0; i<100; ++i)
    {
        CGPoint p;
        float t = i/99.0;
        p = [self cgbezier:a b:b c:c d:d t:t];
        fprintf(file, "%f\t%f\n", p.x, p.y);
    }
    fclose(file);
    
}

//generate the path from the control points array
-(void)generatePath {
    _numPathPoints = 0;
    for (int i=0; i<_numControlPoints-3; i+=3)
    {
        CGPoint a = _roadControlPoints[i];
        CGPoint b = _roadControlPoints[i+1];
        CGPoint c = _roadControlPoints[i+2];
        CGPoint d = _roadControlPoints[i+3];
        //Try to make point distance similar for all segments
        float distance = ccpDistance(a, d);
        int pointCount = distance *2;
        for (int j=0; j<pointCount; ++j) {
            float t = j/(float)(pointCount);
            _pathPoints[_numPathPoints++] = [self cgbezier:a b:b c:c d:d t:t];
        }
    }
    
}

-(void)scalePath {
    for (int i=0; i<_numPathPoints; i++) {
        CGPoint scaledPoint = ccpMult(_pathPoints[i], 80);
        scaledPoint.x += 160;
        _pathPoints[i] = scaledPoint;
    }
    
}

-(void) saveControlPoints {    
    NSString *filePath = @"/Users/stevengallagher/Documents/DriftGithub/controlpoints.tsv";
    FILE *file;
    file = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "w");
    
    for (int i=0; i<_numControlPoints; ++i)
    {
        fprintf(file, "%f\t%f\n", _roadControlPoints[i].x, _roadControlPoints[i].y);
    }
    fclose(file);
    
}
-(void) savePathPoints {    
    NSString *filePath = @"/Users/stevengallagher/Documents/DriftGithub/pathpoints.tsv";
    FILE *file;
    file = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "w");
    
    for (int i=0; i<_numPathPoints; ++i)
    {
        fprintf(file, "%f\t%f\n", _pathPoints[i].x, _pathPoints[i].y);
    }
    fclose(file);
    
}


//Generate random vector to next point in positive y
-(CGPoint)randVector {
    int maxDistance = 20;
    int minSum = 4;
    int randx = 0, randy = 0;
    do {
      randx = arc4random() % (2*maxDistance) - maxDistance;
      randy = arc4random() % maxDistance;
    } while (abs(randx + randy) < minSum);
    return CGPointMake(randx, randy);
}

//Control points with road, slope, slope, road for each segment
-(void) generateControlPoints {
    
    float startx = 0;
    float starty = 0;
    int segmentCount = 8;
    int i = 0;
    
    CGPoint nextPathPoint = CGPointMake(startx, starty);
    //slope in direction of straight line
    CGPoint nextVector = CGPointMake(0, 20);
    CGPoint slope = ccpMult(nextVector, .3);
    
    //straight line at start
    _roadControlPoints[i++] = nextPathPoint; //road point
    _roadControlPoints[i++] = ccpAdd(nextPathPoint,slope); //control a
    nextPathPoint = ccpAdd(nextPathPoint, nextVector);
    _roadControlPoints[i++] = ccpSub(nextPathPoint,slope); //control b

    _roadControlPoints[i++] = nextPathPoint; //road point
    
    for (int j=0; j<segmentCount; j++) {
       _roadControlPoints[i++] = ccpAdd(nextPathPoint,slope); //control a
        
        //vector to next road point
        nextVector = [self randVector];
        //slope in same direction as next vector
        slope = ccpMult(nextVector, .3);
        
        nextPathPoint = ccpAdd(nextPathPoint, nextVector);
        _roadControlPoints[i++] = ccpSub(nextPathPoint,slope); //control b
        _roadControlPoints[i++] = nextPathPoint; //road point
        
    }
    _numControlPoints = i;
    
}


-(id) createPath:(CGPoint *)pathPoints {
    _pathPoints = pathPoints;
    
    [self generateControlPoints];
    [self saveControlPoints];
    [self generatePath];
    [self scalePath];
    [self savePathPoints];
    return self;
}

-(int)getNumPathPoints {
    return _numPathPoints;
}

@end









