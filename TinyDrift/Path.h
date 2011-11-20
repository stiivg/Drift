//
//  Path.h
//  TinyDrift
//
//  Created by Steven Gallagher on 11/13/11.
//  Copyright 2011 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_Path_h
#define TinyDrift_Path_h

#import "cocos2d.h"

#define kMaxRoadKeyPoints 1000

@interface Path : NSObject {
    CGPoint _roadControlPoints[kMaxRoadKeyPoints];
    CGPoint _pathPoints[kMaxRoadKeyPoints];
}

- (id)createPath;


@end


#endif
