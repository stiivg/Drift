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

#define kMaxRoadKeyPoints 1000

@interface HermitePath : NSObject {
    CGPoint _roadControlPoints[kMaxRoadKeyPoints];
    int _numControlPoints;
    CGPoint _keyPoints[kMaxRoadKeyPoints];
    int _numKeyPoints;
    CGPoint * _pathPoints;
    int _numPathPoints;
}

- (id)createPath:(CGPoint *) pathPoints;

-(int)getNumPathPoints;

@end


#endif
