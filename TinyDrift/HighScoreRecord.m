//
//  HighScoreRecord.m
//  TinyDrift
//
//  Created by Steven Gallagher on 4/11/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//
//  Based on http://www.travisdunn.com/managing-local-high-scores-and-online-leaderboard-for-your-iphone-games-part-1

#import "HighScoreRecord.h"

@implementation HighScoreRecord

@synthesize name;
@synthesize totalScore;
@synthesize dateRecorded;

- (id) initWithScore:(NSString *)playerName TotalScore:(NSNumber *)score {
    if (self = [super init])
	{
		name = playerName;
		totalScore = score;
        
		dateRecorded = [NSDate date];
	}
    return self;
}

- (NSComparisonResult) compare:(id)other {
	return [self.totalScore compare:other];
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:name forKey:@"Name"];
	[encoder encodeObject:totalScore forKey:@"TotalScore"];
	[encoder encodeObject:dateRecorded forKey:@"DateRecorded"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if(self = [super init]) {
		self.name = [decoder decodeObjectForKey:@"Name"];
		self.totalScore = [decoder decodeObjectForKey:@"TotalScore"];
		self.dateRecorded = [decoder decodeObjectForKey:@"DateRecorded"];
	}
	return self;
}

#pragma mark -
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	HighScoreRecord *copy = [[[self class] allocWithZone:zone] init];
	name = [self.name copy];
	totalScore = [self.totalScore copy];
	dateRecorded = [self.dateRecorded copy];
    
	return copy;
}
#pragma mark -

- (void)dealloc {
	[name release];
	[totalScore release];
	[dateRecorded release];
    
    [super dealloc];
}

@end