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
#import "SimpleAudioEngine.h"

@interface OptionsLayer : CCLayer
{
    CCScene *_mainScene;
    
    CCMenuItemLabel *backMenuItem;
    CCLabelBMFont *title;
    
    UISwitch *tutorialSwitch;
    UISlider *musicSlider;
    UISlider *soundSlider;
    
    UIScrollView *scroll;
    UITextView *titleMeScroll;
    UITextView *meScroll;
    UITextView *thanksTitleScroll;
    UITextView *thanksScroll;

    CDSoundSource* engineSound;

}

- (id)initWithMain:(CCScene *)mainScene;

@end

#endif
