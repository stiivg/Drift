//
//  Statistics.h
//  TinyDrift
//
//  Created by Steven Gallagher on 4/11/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_Statistics_h
#define TinyDrift_Statistics_h

#import "HighScores.h"
#import "HighScoreRecord.h"

@interface Statistics : NSObject {
    
    
}

@property (readwrite) int score;
@property (readwrite) double time;
@property (readwrite) double lead;
@property (readwrite) int rank;
@property (readwrite) int drifts;

-(void)clearStatistics;
-(void)calcScore;

@end

#endif
