//
//  GameBtnLayer.h
//  TinyDrift
//
//  Created by Steven Gallagher on 12/10/11.
//  Copyright (c) 2011 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_GameBtnLayer_h
#define TinyDrift_GameBtnLayer_h

#import "cocos2d.h"


@interface GameBtnLayer : CCLayer
{    
    CCLabelTTF *winlabel;
    //Results
    CCLabelBMFont *scoreLabel;
    CCLabelBMFont *rankLabel;
    CCLabelBMFont *timeLabel;
    CCLabelBMFont *driftsLabel;
    
    CCLabelBMFont *scoreValue;
    CCLabelBMFont *rankValue;
    CCLabelBMFont *timeValue;
    CCLabelBMFont *driftsValue;
    
}

-(void)startRace;
-(void)endRace;

@end


#endif
