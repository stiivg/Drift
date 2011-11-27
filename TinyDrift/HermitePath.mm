//
//  Path.mm
//  TinyDrift
//
//  Created by Steve Gallagher on 11/13/11.
//  Copyright 2011 Steve Gallagher. All rights reserved.
//

#import "HermitePath.h"

@implementation HermitePath


// Reference: http://paulbourke.net/miscellaneous/interpolation/
// Equidistant points: http://www.blitzbasic.com/codearcs/codearcs.php?code=1523


// simple linear interpolation between two points
-(CGPoint)interpolate:(CGPoint)a endPoint:(CGPoint)b fraction:(float)t {
    CGPoint retVal;
    retVal.x = a.x + (b.x-a.x)*t;
    retVal.y = a.y + (b.y-a.y)*t;
    return retVal;
}

// evaluate a point on a hermite curve. t goes from 0 to 1.0
-(CGPoint)cgBezier:(CGPoint)a b:(CGPoint)b c:(CGPoint)c d:(CGPoint)d t:(float)t {
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
        int pointCount = distance /5;
        for (int j=0; j<pointCount; ++j) {
            float t = j/(float)(pointCount);
            _pathPoints[_numPathPoints++] = [self cgBezier:a b:b c:c d:d t:t];
        }
    }
    
}

-(void)scalePath {
    for (int i=0; i<_numPathPoints; i++) {
        CGPoint scaledPoint = ccpMult(_pathPoints[i], 8);
        scaledPoint.x += 160;
        _pathPoints[i] = scaledPoint;
    }
    
}

-(void) restoreKeyPoints {    
//    NSString* filePath = [[NSBundle mainBundle]  pathForResource:@"keypoints" ofType:@"tsv"];
//    NSArray* contentArray = [NSArray arrayWithContentsOfFile:filePath];
    _keyPoints[0] = CGPointMake(0, -200);
    _keyPoints[1] = CGPointMake(0, 0);
    _keyPoints[2] = CGPointMake(0, 200);
    _keyPoints[3] = CGPointMake(-30, 330);
    _keyPoints[4] = CGPointMake(-90, 340);
    _keyPoints[5] = CGPointMake(-40, 460);
    _keyPoints[6] = CGPointMake(150, 580);
    _keyPoints[7] = CGPointMake(210, 630);
    _keyPoints[8] = CGPointMake(220, 750);
    _keyPoints[9] = CGPointMake(370, 910);
    _numKeyPoints = 10;
        
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
-(void) saveKeyPoints {    
    NSString *filePath = @"/Users/stevengallagher/Documents/DriftGithub/keypoints.tsv";
    FILE *file;
    file = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "w");
    
    for (int i=0; i<_numKeyPoints; ++i)
    {
        fprintf(file, "%f\t%f\n", _keyPoints[i].x, _keyPoints[i].y);
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

//Points on road only
-(void) generateKeyPoints {
    float startx = 0;
    float starty = 0;
    int segmentCount = 8;
    int i = 0;
        
    //straight line at start
    _keyPoints[i++] = CGPointMake(startx, starty-20); //point before first point used
    CGPoint nextPathPoint = CGPointMake(startx, starty);
    _keyPoints[i++] = nextPathPoint; //first key point used
    CGPoint nextVector = CGPointMake(0, 20);
    
    for (int j=0; j<segmentCount; j++) {
        //vector to next road point
        nextPathPoint = ccpAdd(nextPathPoint, nextVector);
        _keyPoints[i++] = nextPathPoint; //key point
        nextVector = [self randVector];        
    }
    _numKeyPoints = i;
 
}

//Add the slope points between the key points
-(void) generateControlPoints {
    
    int i = 0;
    
    _roadControlPoints[i++] = _keyPoints[1]; //road point
    CGPoint slope = ccpSub(_keyPoints[2],_keyPoints[0]);
    slope = ccpMult(slope, .2); //scale the slope

    for (int j=0; j<_numKeyPoints-3; j++) {
        _roadControlPoints[i++] = ccpAdd(_keyPoints[j+1],slope); //control a

        //slope from previous to next point
        slope = ccpSub(_keyPoints[j+3],_keyPoints[j+1]);
        slope = ccpMult(slope, .2); //scale the slope

        _roadControlPoints[i++] = ccpSub(_keyPoints[j+2],slope); //control b
        
        _roadControlPoints[i++] = _keyPoints[j+2]; //road point
        
    }
    _numControlPoints = i;
    
}



-(id) createPath:(CGPoint *)pathPoints {
    _pathPoints = pathPoints;
    
//    [self generateKeyPoints];
//    [self saveKeyPoints];
    [self restoreKeyPoints];
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









