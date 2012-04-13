//
//  GameBtnLayer.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 12/10/11.
//  Copyright (c) 2011 Steve Gallagher. All rights reserved.
//



#import "GameBtnLayer.h"
#import "GameManager.h"


@implementation GameBtnLayer

CCMenuItem *pauseMenuItem;
CCMenuItemLabel *raceAgainMenuItem;
CCMenuItemLabel *resumeMenuItem;
CCMenuItemLabel *menuMenuItem;

#define TITLE_LENGTH 80
#define LINE_SPACING 40
#define TOP_LINE 300
#define FONT_SIZE 20


-(void)initResults {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    ccColor3B resultsColor =ccBLACK; // ccc3(255,215,76);
    
    // Create result labels   
    scoreLabel = [CCLabelTTF labelWithString:@"Score: " dimensions:CGSizeMake(TITLE_LENGTH, LINE_SPACING) alignment:UITextAlignmentRight fontName:@"Arial" fontSize:FONT_SIZE];
    scoreLabel.color = resultsColor;
    [self addChild:scoreLabel];
    scoreLabel.position = ccp(winSize.width/2 - TITLE_LENGTH/2, winSize.height - TOP_LINE);

    rankLabel = [CCLabelTTF labelWithString:@"Rank No.: " dimensions:CGSizeMake(TITLE_LENGTH, LINE_SPACING) alignment:UITextAlignmentRight fontName:@"Arial" fontSize:12];
    rankLabel.color = resultsColor;
    [self addChild:rankLabel];
    rankLabel.position = ccp(winSize.width/2+10, winSize.height - TOP_LINE - 22);
    
    timeLabel = [CCLabelTTF labelWithString:@"Time: " dimensions:CGSizeMake(TITLE_LENGTH, LINE_SPACING) alignment:UITextAlignmentRight fontName:@"Arial" fontSize:FONT_SIZE];
    timeLabel.color = resultsColor;
    [self addChild:timeLabel];
    timeLabel.position = ccp(winSize.width/2 - TITLE_LENGTH/2, winSize.height - TOP_LINE - LINE_SPACING);
    
    leadLabel = [CCLabelTTF labelWithString:@"Lead: " dimensions:CGSizeMake(TITLE_LENGTH, LINE_SPACING) alignment:UITextAlignmentRight fontName:@"Arial" fontSize:12];
    leadLabel.color = resultsColor;
    [self addChild:leadLabel];
    leadLabel.position = ccp(winSize.width/2+10, winSize.height - TOP_LINE - LINE_SPACING - 22);
    
    driftsLabel = [CCLabelTTF labelWithString:@"Drifts: " dimensions:CGSizeMake(TITLE_LENGTH, LINE_SPACING) alignment:UITextAlignmentRight fontName:@"Arial" fontSize:FONT_SIZE];
    driftsLabel.color = resultsColor;
    [self addChild:driftsLabel];
    driftsLabel.position = ccp(winSize.width/2 - TITLE_LENGTH/2, winSize.height - TOP_LINE - 2*LINE_SPACING);  

    
    
    
    //Create result values
    scoreValue = [CCLabelTTF labelWithString:@"4126" dimensions:CGSizeMake(TITLE_LENGTH, LINE_SPACING) alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:FONT_SIZE];
    scoreValue.color = resultsColor;
    [self addChild:scoreValue];
    scoreValue.position = ccp(winSize.width/2 + TITLE_LENGTH/2, winSize.height - TOP_LINE);
    
    rankValue = [CCLabelTTF labelWithString:@"1" dimensions:CGSizeMake(TITLE_LENGTH, LINE_SPACING) alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:12];
    rankValue.color = resultsColor;
    [self addChild:rankValue];
    rankValue.position = ccp(winSize.width/2+TITLE_LENGTH+10, winSize.height - TOP_LINE - 22);
    
    timeValue = [CCLabelTTF labelWithString:@"43.6s" dimensions:CGSizeMake(TITLE_LENGTH, LINE_SPACING) alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:FONT_SIZE];
    timeValue.color = resultsColor;
    [self addChild:timeValue];
    timeValue.position = ccp(winSize.width/2 + TITLE_LENGTH/2, winSize.height - TOP_LINE - LINE_SPACING);
    
    leadValue = [CCLabelTTF labelWithString:@"5.2s" dimensions:CGSizeMake(TITLE_LENGTH, LINE_SPACING) alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:12];
    leadValue.color = resultsColor;
    [self addChild:leadValue];
    leadValue.position = ccp(winSize.width/2+TITLE_LENGTH+10, winSize.height - TOP_LINE - LINE_SPACING - 22);
    
    driftsValue = [CCLabelTTF labelWithString:@"4" dimensions:CGSizeMake(TITLE_LENGTH, LINE_SPACING) alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:FONT_SIZE];
    driftsValue.color = resultsColor;
    [self addChild:driftsValue];
    driftsValue.position = ccp(winSize.width/2 + TITLE_LENGTH/2, winSize.height - TOP_LINE - 2*LINE_SPACING);  
    
}

-(id) init {
    if((self=[super init])) {
        
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // Create pause button
        pauseMenuItem = [CCMenuItemImage 
                                    itemFromNormalImage:@"pause.png" selectedImage:@"pause_selected.png" 
                                    target:self selector:@selector(pauseAction:)];
        pauseMenuItem.position = ccp(winSize.width - 30, winSize.height - 30);
        CCMenu *pauseMenu = [CCMenu menuWithItems:pauseMenuItem, nil];
        pauseMenu.position = CGPointZero;
        [self addChild:pauseMenu];
        [pauseMenuItem setVisible:false];
        
        // Create Race Again button        
        CCLabelBMFont *raceAgainLabel = [CCLabelTTF labelWithString:@"Race Again" dimensions:CGSizeMake(240, 40) alignment:UITextAlignmentCenter fontName:@"Quasart" fontSize:32];
        raceAgainMenuItem = [CCMenuItemLabel itemWithLabel:raceAgainLabel target:self selector:@selector(raceAgainAction:)];
        raceAgainMenuItem.position = ccp(winSize.width / 2, 60);
        CCMenu *raceMenu = [CCMenu menuWithItems:raceAgainMenuItem, nil];
        raceMenu.position = CGPointZero;
        [self addChild:raceMenu];
        [raceAgainMenuItem setVisible:false];
        
        // Create menu button
        CCLabelBMFont *menuLabel = [CCLabelTTF labelWithString:@"Menu" fontName:@"Quasart" fontSize:20];
        menuMenuItem = [CCMenuItemLabel itemWithLabel:menuLabel target:self selector:@selector(menuAction:)];
        menuMenuItem.position = ccp(60, winSize.height - 30);
        CCMenu *menuMenu = [CCMenu menuWithItems:menuMenuItem, nil];
        menuMenu.position = CGPointZero;
        [self addChild:menuMenu];
        [menuMenuItem setVisible:false];
        
        // Create resume button
        CCLabelBMFont *resumeLabel = [CCLabelTTF labelWithString:@"Resume" fontName:@"Quasart" fontSize:20];
        resumeMenuItem = [CCMenuItemLabel itemWithLabel:resumeLabel target:self selector:@selector(resumeAction:)];
        resumeMenuItem.position = ccp(winSize.width - 60, winSize.height - 30);
        CCMenu *resumeMenu = [CCMenu menuWithItems:resumeMenuItem, nil];
        resumeMenu.position = CGPointZero;
        [self addChild:resumeMenu];
        [resumeMenuItem setVisible:false];

        winlabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(300, 100) alignment:UITextAlignmentCenter  fontName:@"Quasart" fontSize:48];
        winlabel.color = ccc3(0,0,0);
        winlabel.position = ccp(winSize.width/2, winSize.height*0.75);
        [self addChild:winlabel];
        winlabel.visible = false;
        
        [self initResults];
        [self hideResults];

    }
    return self;
}

- (void)pauseAction:(id)sender {
    [pauseMenuItem setVisible:false];
    [resumeMenuItem setVisible:true];
    [raceAgainMenuItem setString:@"New Race"];
    [raceAgainMenuItem setVisible:true];
    [menuMenuItem setVisible:true];
    [[GameManager sharedGameManager] pauseGame ];
    
    
}

- (void)raceAgainAction:(id)sender {
    [pauseMenuItem setVisible:false];
    [resumeMenuItem setVisible:false];
    [raceAgainMenuItem setVisible:false];
    [menuMenuItem setVisible:false];
    [[GameManager sharedGameManager] playGame];
    winlabel.visible = false;
    [self hideResults];
}

- (void)resumeAction:(id)sender {
    [pauseMenuItem setVisible:true];
    [resumeMenuItem setVisible:false];
    [raceAgainMenuItem setVisible:false];
    [menuMenuItem setVisible:false];
    [[GameManager sharedGameManager] resumeGame];
}

- (void)menuAction:(id)sender {
    [pauseMenuItem setVisible:false];
    [resumeMenuItem setVisible:false];
    [raceAgainMenuItem setVisible:false];
    [menuMenuItem setVisible:false];
    [[GameManager sharedGameManager] runSceneWithID:kMainScene];
    winlabel.visible = false;
    [self hideResults];
}

-(void)setResults {
    Statistics *stats = [GameManager sharedGameManager].getStatistics;
       
    [scoreValue setString: [NSString stringWithFormat:@"%d", stats.score]];
    [rankValue setString: [NSString stringWithFormat:@"%d", stats.rank]]; 
    [timeValue setString: [NSString stringWithFormat:@"%4.2fs", stats.time]]; 
    [leadValue setString: [NSString stringWithFormat:@"%4.2f", stats.lead]]; 
    [driftsValue setString: [NSString stringWithFormat:@"%d", stats.drifts]]; 
    
}

-(void)showResults {
    [self setResults];
    
    Statistics *stats = [GameManager sharedGameManager].getStatistics;

    scoreLabel.visible = true;
    //only show rank if on leaderboard
    rankLabel.visible = (stats.rank > 0);
    timeLabel.visible = true;
    leadLabel.visible = true;
    driftsLabel.visible = true;
    
    scoreValue.visible = true;
    rankValue.visible = (stats.rank > 0);
    timeValue.visible = true;
    leadValue.visible = true;
    driftsValue.visible = true;
}

-(void)hideResults {
    scoreLabel.visible = false;
    rankLabel.visible = false;
    timeLabel.visible = false;
    leadLabel.visible = false;
    driftsLabel.visible = false;
    
    scoreValue.visible = false;
    rankValue.visible = false;
    timeValue.visible = false;
    leadValue.visible = false;
    driftsValue.visible = false;
}

- (void)showWinLoss {
    NSString *userName = [[GameManager sharedGameManager] userName];
    [winlabel setScale:0.8];
    BOOL raceWon = [[GameManager sharedGameManager] raceWon];
    if (raceWon) {
        [winlabel setString:[userName stringByAppendingString:@" Won!"]];
        winlabel.rotation = -10;
        [self showResults];

    } else {
        [winlabel setString:[userName stringByAppendingString:@" Lost"]];
        winlabel.rotation = 0;

    }
    winlabel.opacity = 0;
    winlabel.visible = true;
    CCAction *scaleAction = [CCScaleTo  actionWithDuration:0.8 scale:1.0];
    CCAction *fadeInAction = [CCFadeIn actionWithDuration:1.0];
    [winlabel runAction:scaleAction];
    [winlabel runAction:fadeInAction];  

    
}

-(void)startRace {
    [pauseMenuItem setVisible:true];
}


-(void)endRace {
    [pauseMenuItem setVisible:false];
    [resumeMenuItem setVisible:false];
    [raceAgainMenuItem setString:@"Race Again"];
    [raceAgainMenuItem setVisible:true];
    [menuMenuItem setVisible:true];
    
    [self showWinLoss];
}


@end











