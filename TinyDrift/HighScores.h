//
//  HighScores.h
//  TinyDrift
//
//  Created by Steven Gallagher on 4/11/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_HighScores_h
#define TinyDrift_HighScores_h

#import <Foundation/Foundation.h>
#import "HighScoreRecord.h"

@interface HighScores : NSObject {}

+ (int)addNewHighScore:(HighScoreRecord *)score;
+ (void)saveLocalHighScores:(NSArray *)highScoreArray;

+ (NSString *)highScoresFilePath;
+ (NSMutableArray *)getLocalHighScores;
+ (NSMutableArray *)sortHighScoreDictionaryArray:(NSMutableArray *)highScoreArray;
@end

#endif
