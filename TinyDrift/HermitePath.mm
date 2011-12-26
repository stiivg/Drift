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


//generate the path from the control points array
-(void)generatePath {
    CGPoint bezierPoint;
    CGPoint slope;
    static float t = 0;
    _numPathPoints = 0;
    for (int i=0; i<_numControlPoints-3; i+=3)
    {
        CGPoint a = _roadControlPoints[i];
        CGPoint b = _roadControlPoints[i+1];
        CGPoint c = _roadControlPoints[i+2];
        CGPoint d = _roadControlPoints[i+3];
        //Try to make point distance similar for all segments
        float speed = 0;
        
        while (t < 1.0) {
            float tb = 1-t;
            bezierPoint.x = a.x*tb*tb*tb + 3*b.x*tb*tb*t + 3*c.x*tb*t*t + d.x*t*t*t;
            bezierPoint.y = a.y*tb*tb*tb + 3*b.y*tb*tb*t + 3*c.y*tb*t*t + d.y*t*t*t;
            _pathPoints[_numPathPoints++] = bezierPoint;
            
            //calculate speed of curve at this point
            slope.x = -3*a.x*tb*tb + 3*b.x*tb*(tb-2*t) + 3*c.x*t*(2*tb-t) + d.x*3*t*t;
            slope.y = -3*a.y*tb*tb + 3*b.y*tb*(tb-2*t) + 3*c.y*t*(2*tb-t) + d.y*3*t*t;
            speed = 5 / ccpLength(slope);
            t += speed;
        }
        t = t - 1;  //Start next segment at this t for equal spacing
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
    int maxDistance = 200;
    int minY = 10;
    int minSquare = 10000;
    int randx = 0, randy = 0;
    do {
        randx = arc4random() % (2*maxDistance) - maxDistance;
        randy = arc4random() % (maxDistance-minY) + minY;
    } while ( (randx*randx + randy*randy) < minSquare);
    return CGPointMake(randx, randy);
}

//Points on road only
-(void) generateKeyPoints {
    float startx = 0;
    float starty = 0;
    int segmentCount = 8;
    int i = 0;
        
    //straight line at start
    _keyPoints[i++] = CGPointMake(startx, starty-100); //point before first point used
    CGPoint nextPathPoint = CGPointMake(startx, starty);
    _keyPoints[i++] = nextPathPoint; //first key point used
    CGPoint nextVector = CGPointMake(0, 100);
    
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
    
    [self generateKeyPoints];
    [self saveKeyPoints];
//    [self restoreKeyPoints];
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








