//
//  OptionsLayer.h
//  TinyDrift
//
//  Created by Steven Gallagher on 3/29/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_OptionsLayer_h
#define TinyDrift_OptionsLayer_h

#import "cocos2d.h"

#define CONTROL_TOP 180
#define CONTROL_OFFSET 60

@interface OptionsLayer : CCLayer
{
    CCScene *_mainScene;
    
    CCMenuItemLabel *backMenuItem;
    CCLabelBMFont *title;
    
    UISwitch *tutorialSwitch;
    UISlider *musicSlider;
    UISlider *soundSlider;
}

- (id)initWithMain:(CCScene *)mainScene;

@end

#endif
