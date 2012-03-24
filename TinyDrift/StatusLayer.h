//
//  StatusLayer.h
//  TinyDrift
//
//  Created by Steven Gallagher on 3/17/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_StatusLayer_h
#define TinyDrift_StatusLayer_h

#import "cocos2d.h"

#define BAR_WIDTH 8

@interface StatusLayer : CCLayer
{
	CCSprite * _carBar;
    int car;
}

//-(void)startCountdown:(id)object withSelector:(SEL)selector;

@end



#endif
