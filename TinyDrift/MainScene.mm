//
//  MainScene.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 1/21/12.
//  Copyright (c) 2012 Steven Gallagher. All rights reserved.
//


#import "MainScene.h"
#import "LoopLayer.h"


@implementation MainScene

MainLayer *mainLayer = nil;
LoopLayer *loopLayer = nil;

-(id)init {
    self = [super init];
    if (self != nil) {
        //Main button layer
        mainLayer = [MainLayer node];
        [self addChild:mainLayer z:1 tag:1];
        //Background loop layer
//        loopLayer = [LoopLayer node];
//        [self addChild:loopLayer z:0 tag:2];
    }
    return self;
}


@end