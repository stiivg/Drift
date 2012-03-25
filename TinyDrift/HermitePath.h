//
//  HermitePath.h
//  TinyDrift
//
//  Created by Steven Gallagher on 11/13/11.
//  Copyright 2011 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_Path_h
#define TinyDrift_Path_h

#import "cocos2d.h"

#define MAX_ROAD_KEY_POINTS 1000
//normal race 16
#define SEGMENT_COUNT 16

@interface HermitePath : NSObject {
    CGPoint _roadControlPoints[MAX_ROAD_KEY_POINTS];
    int _numControlPoints;
    CGPoint _keyPoints[MAX_ROAD_KEY_POINTS];
    int _numKeyPoints;
    CGPoint * _pathPoints;
    int _numPathPoints;
}

- (id)createPath:(CGPoint *) pathPoints;

-(int)getNumPathPoints;

@end


#endif
