//
//  HighScores.m
//  TinyDrift
//
//  Created by Steven Gallagher on 4/11/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//  Based on http://www.travisdunn.com/managing-local-high-scores-and-online-leaderboard-for-your-iphone-games-part-1

#import "HighScores.h"

@implementation HighScores

const int HIGH_SCORE_COUNT = 32;

+ (int)addNewHighScore:(HighScoreRecord *)score {
	NSMutableArray *locals = [HighScores getLocalHighScores];
    
    int rank=0;
	int totalScore = [score.totalScore intValue];
	if (locals.count < HIGH_SCORE_COUNT){
		[locals addObject:score];
		NSMutableArray *sortedLocals = [HighScores sortHighScoreDictionaryArray:locals];
		[HighScores saveLocalHighScores:sortedLocals];
        rank = [sortedLocals indexOfObject:score] + 1;
		[sortedLocals release];
	} else {
		NSUInteger lastIdx = HIGH_SCORE_COUNT-1;
		HighScoreRecord *lastRecord = [locals objectAtIndex:lastIdx];
		if (totalScore > [lastRecord.totalScore intValue]){
			[locals addObject:score];
			NSMutableArray *sortedLocals = [HighScores sortHighScoreDictionaryArray:locals];
			[sortedLocals removeLastObject];
            
			[HighScores saveLocalHighScores:sortedLocals];
            
            rank = [sortedLocals indexOfObject:score] + 1;
			[sortedLocals release];
		}
	}
    return rank;
}

+ (NSString *)highScoresFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"HighScoresFile"];
}

+ (NSMutableArray *)getLocalHighScores {
	NSData *data = [[NSMutableData alloc] initWithContentsOfFile:[HighScores highScoresFilePath]];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
	NSArray *highScores = [unarchiver decodeObjectForKey:@"HighScores"];
    
	return [[[NSMutableArray alloc] initWithArray:highScores copyItems:NO] autorelease];
}

+ (void)saveLocalHighScores:(NSArray *)highScoreArray {
    
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
	[archiver encodeObject:highScoreArray forKey:@"HighScores"];
	[archiver finishEncoding];
    
	[data writeToFile:[HighScores highScoresFilePath] atomically:YES];
	[archiver release];
	[data release];
}

+ (NSMutableArray *)sortHighScoreDictionaryArray:(NSMutableArray *)highScoreArray {
    
	NSString *SORT_KEY = @"totalScore";
	NSSortDescriptor *scoreDescriptor = [[[NSSortDescriptor alloc] initWithKey:SORT_KEY ascending:NO selector:@selector(compare:)] autorelease];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:scoreDescriptor, nil];
    
	NSArray *sortedArray = [highScoreArray sortedArrayUsingDescriptors:sortDescriptors];
    
	return [[NSMutableArray alloc] initWithArray:sortedArray copyItems:NO];
}

@end