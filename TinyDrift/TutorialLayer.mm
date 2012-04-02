//
//  TutorialLayer.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 4/1/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#import "TutorialLayer.h"
#import "GameManager.h"


@implementation TutorialLayer


-(id) init {
    if((self=[super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        ccColor3B tutorialColor = ccc3(255,215,76);
        
        // Create tutorial help label        
        helpLabel1 = [CCLabelTTF labelWithString:@"" fontName:@"Quasart" fontSize:FONT_SIZE];
        helpLabel1.color = tutorialColor;
        helpLabel1.position = ccp(winSize.width/2, winSize.height - TOP_LINE);
        [self addChild:helpLabel1];
        
        helpLabel2 = [CCLabelTTF labelWithString:@"" fontName:@"Quasart" fontSize:FONT_SIZE];
        helpLabel2.color = tutorialColor;
        helpLabel2.position = ccp(winSize.width/2, winSize.height - TOP_LINE - LINE_SPACING);
        [self addChild:helpLabel2];
        
        helpLabel3 = [CCLabelTTF labelWithString:@"" fontName:@"Quasart" fontSize:FONT_SIZE];
        helpLabel3.color = tutorialColor;
        helpLabel3.position = ccp(winSize.width/2, winSize.height - TOP_LINE - LINE_SPACING - LINE_SPACING);
        [self addChild:helpLabel3];
        
    }
    return self;
}

-(void)touchOffMessage {
    [helpLabel1 setString:@"PRESS AND HOLD"];
    [helpLabel2 setString:@"TO DRIVE"];

    [helpLabel1 setVisible:YES];
    [helpLabel2 setVisible:YES];
    [helpLabel3 setVisible:NO];
    
}

-(void)touchOnMessage {
    [helpLabel1 setString:@"SLIDE"];
    [helpLabel2 setString:@"LEFT AND RIGHT"];
    [helpLabel3 setString:@"TO TURN"];
    
    [helpLabel1 setVisible:YES];
    [helpLabel2 setVisible:YES];
    [helpLabel3 setVisible:YES];    
}

-(void)turboMessage {
    [helpLabel1 setString:@"LIFT OFF FOR"];
    [helpLabel2 setString:@"TURBO BOOST"];
    
    [helpLabel1 setVisible:YES];
    [helpLabel2 setVisible:YES];
    [helpLabel3 setVisible:NO];    
}



@end