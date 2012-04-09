//
//  StatisticsLayer.h
//  TinyDrift
//
//  Created by Steven Gallagher on 4/8/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_StatisticsLayer_h
#define TinyDrift_StatisticsLayer_h

#import "cocos2d.h"
#import "SimpleAudioEngine.h"


@interface StatisticsLayer : CCLayer
{
    CCScene *_mainScene;
    
    CCMenuItemLabel *backMenuItem;
    CCLabelBMFont *title;
    
    UISwitch *tutorialSwitch;
    UISlider *musicSlider;
    UISlider *soundSlider;
    
    CDSoundSource* engineSound;
    
}

- (id)initWithMain:(CCScene *)mainScene;

@end



#endif
