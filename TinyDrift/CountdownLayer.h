//
//  CountdownLayer.h
//  TinyDrift
//
//  Created by Steven Gallagher on 3/8/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_CountdownLayer_h
#define TinyDrift_CountdownLayer_h

#import "cocos2d.h"
#import "SimpleAudioEngine.h"

#define START_COUNT 3

@interface CountdownLayer : CCLayer
{
    CCLabelTTF *_label;
    int _count;
    id callbackObject;
    SEL callbackSelector;
    
    CDSoundSource* beepLSound;
    CDSoundSource* beepHSound;

}

-(void)startCountdown:(id)object withSelector:(SEL)selector;

@end


#endif
