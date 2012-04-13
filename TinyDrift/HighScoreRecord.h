//
//  HighScoreRecord.h
//  TinyDrift
//
//  Created by Steven Gallagher on 4/11/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_HighScoreRecord_h
#define TinyDrift_HighScoreRecord_h

#import <Foundation/Foundation.h>

@interface HighScoreRecord : NSObject <NSCoding, NSCopying> {
	NSString *name;
	NSNumber *totalScore;
    
	NSDate *dateRecorded;
}

- (id) initWithScore:(NSString *)name TotalScore:(NSNumber *)totalScore;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *totalScore;

@property (nonatomic, retain) NSDate *dateRecorded;
- (NSComparisonResult) compare:(id)other;


@end

#endif
