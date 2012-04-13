//
//  StatisticsLayer.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 4/8/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#import "StatisticsLayer.h"
#import "GameManager.h"
#import "MainScene.h"

#define SCROLL_CONTENT_HEIGHT 760

@implementation StatisticsLayer


- (id)initWithMain:(CCScene *)mainScene {
    if ((self = [super init])) {
        _mainScene = mainScene;
        
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // Create Options title label        
        title = [CCLabelTTF labelWithString:@"Statistics" fontName:@"Quasart" fontSize:32];
        title.color = ccc3(0,0,0);
        title.position = ccp(winSize.width/2, winSize.height - 60);
        [self addChild:title];
        
        // Create Back button        
        CCLabelBMFont *backLabel = [CCLabelTTF labelWithString:@"Back" fontName:@"Quasart" fontSize:20];
        backMenuItem = [CCMenuItemLabel itemWithLabel:backLabel target:self selector:@selector(backAction:)];
        backMenuItem.position = ccp(winSize.width * 0.8, 60);
        CCMenu *backMenu = [CCMenu menuWithItems:backMenuItem, nil];
        backMenu.position = CGPointZero;
        [self addChild:backMenu];
        
        scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(5,100, 300, 254)];
        UIFont *statsFont = [UIFont fontWithName:@"arial" size:18];
        
        rankScroll = [[UITextView alloc] initWithFrame:CGRectZero];
        rankScroll.font = statsFont;
        rankScroll.backgroundColor = [UIColor clearColor];
        rankScroll.textColor = [UIColor whiteColor];
        rankScroll.userInteractionEnabled=NO;
        rankScroll.textAlignment = UITextAlignmentRight;
        
        [scroll addSubview:rankScroll];
        
        nameScroll = [[UITextView alloc] initWithFrame:CGRectZero];
        nameScroll.font = statsFont;
        nameScroll.backgroundColor = [UIColor clearColor];
        nameScroll.textColor = [UIColor whiteColor];
        nameScroll.userInteractionEnabled=NO;
        
        [scroll addSubview:nameScroll];
        
        scoreScroll = [[UITextView alloc] initWithFrame:CGRectZero];
        scoreScroll.font = statsFont;
        scoreScroll.backgroundColor = [UIColor clearColor];
        scoreScroll.textColor = [UIColor whiteColor];
        scoreScroll.userInteractionEnabled=NO;
        scoreScroll.textAlignment = UITextAlignmentRight;
        
        [scroll addSubview:scoreScroll];
        
        
        
        [[[CCDirector sharedDirector]openGLView]addSubview:scroll]; 
        [scroll setContentSize:CGSizeMake(200, SCROLL_CONTENT_HEIGHT)];
        
        
        rankScroll.frame =  CGRectMake(0, 0, 45, SCROLL_CONTENT_HEIGHT);
        nameScroll.frame =  CGRectMake(45, 0, 170, SCROLL_CONTENT_HEIGHT);
        scoreScroll.frame =  CGRectMake(215, 0, 90, SCROLL_CONTENT_HEIGHT);
        
        NSMutableString *ranks = [[NSMutableString alloc] init];
        for (int i=1; i<=32; i++) {
            [ranks appendFormat:@"%d.\n",i];
        }
        rankScroll.text = ranks;
        
        NSArray *highScoreData = [[HighScores getLocalHighScores] retain];
        
        NSMutableString *names = [[NSMutableString alloc] init];
        NSMutableString *scores = [[NSMutableString alloc] init];
        
        int count = [highScoreData count];
        for (int row = 0; row < count; row++) {
            HighScoreRecord *record = (HighScoreRecord *)[highScoreData objectAtIndex:row];
            
            [names appendFormat:@"%@\n",record.name];
            [scores appendFormat:@"%d\n",[record.totalScore intValue]];
            
//            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//            [dateFormat setDateFormat:@"yyyy-MM-dd"];
//            
//            cell.dateLabel.text = [dateFormat stringFromDate:record.dateRecorded];
        }
        nameScroll.text = names; //@"Stiiv\nKai\nHanako\nKailarious\nmmmmmmmmmm\n";
        scoreScroll.text = scores; //@"321453\n320692\n280232\n438\n5\n";
        
    }
    return self;
}

- (void)backAction:(id)sender {
    [(MainScene *)_mainScene backToMain ];    
    
}

-(void) dealloc {
    
    //Release all our retained objects   
    [scroll removeFromSuperview];

    [rankScroll release];
    [nameScroll release];
    [scoreScroll release];
    [super dealloc];
}

@end
