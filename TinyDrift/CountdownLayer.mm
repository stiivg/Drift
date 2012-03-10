//
//  CountdownLayer.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 3/8/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#import "CountdownLayer.h"
#import "GameManager.h"


@implementation CountdownLayer


-(id) init {
    if((self=[super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        _label = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:32];
        _label.color = ccc3(0,0,0);
        _label.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:_label];
        
    }
    return self;
}


- (void)fadeNumber {
    NSString* countString = [NSString stringWithFormat:@"%d", _count];
    [_label setScale:1.0];
    [_label setString:countString];
    
    CCAction *scaleAction = [CCScaleTo  actionWithDuration:1.0 scale:8];
    CCAction *fadeOutAction = [CCFadeOut actionWithDuration:1.0];
    [_label runAction:scaleAction];
    [_label runAction:fadeOutAction];    
    
    [_label runAction:[CCSequence actions:
                       [CCDelayTime actionWithDuration:1],
                       [CCCallFunc actionWithTarget:self selector:@selector(digitDone)], nil]];
    
}

- (void)digitDone {
    _count--;
    if (_count > 0) {
        [self fadeNumber];
    } else {
        [callbackObject performSelector:callbackSelector withObject:self];
    }
}

//Calls the selector at the end of the countdown
- (void)startCountdown:(id)object withSelector:(SEL)selector {
    _count = START_COUNT;
    
    callbackObject = object;
    callbackSelector = selector;
    
    //Delay before first number
    [_label runAction:[CCSequence actions:
                       [CCDelayTime actionWithDuration:1],
                       [CCCallFunc actionWithTarget:self selector:@selector(fadeNumber)], nil]];
    
}


@end