//
//  Statistics.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 4/11/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#include "Statistics.h"
#import "GameManager.h"

@implementation Statistics

@synthesize score;
@synthesize time;
@synthesize lead;
@synthesize rank;
@synthesize drifts;

//- (void)initialize{
//    NSDictionary *appDefaults = [NSDictionary
//                                 dictionaryWithObjects:[NSArray arrayWithObjects:
//                                                        [NSNumber numberWithFloat:0.1],
//                                                        [NSNumber numberWithFloat:0.5],
//                                                        [NSNumber numberWithBool:YES],
//                                                        [NSString stringWithString:@"You"],
//                                                        nil]
//                                 forKeys:[NSArray arrayWithObjects:
//                                          @"MusicLevel", // starts at score of 0.2
//                                          @"SoundLevel", // starts at level 0.8
//                                          @"Tutorial",   // starts with tutorial on
//                                          @"UserName",   // starts with "You"
//                                          nil]];
//    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
//} 


-(void)clearStatistics {
    score = 0;
    time = 0.0;
    lead = 0.0;
    rank = 1;
    drifts = 0;
}

-(void)calcScore {
    //Calc score and add to local leaderboard if ranked
    score = 100000 / time;
    NSString* name = [[GameManager sharedGameManager] userName];

    HighScoreRecord *highScore = [[HighScoreRecord alloc] initWithScore:name TotalScore:[NSNumber numberWithInt:score]];
	rank = [HighScores addNewHighScore:highScore];

//    NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserName"];
//    [[GameManager sharedGameManager] setUserName:user];    
    
}

//NSArray *getNames {
//    NSArray *namesArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"Names"]
//
//}



@end