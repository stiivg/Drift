//
//  GameScene.m
//  TinyDrift
//
//  Created by Steven Gallagher on 12/10/11.
//  Copyright (c) 2011 Steve Gallagher. All rights reserved.
//


#import "GameScene.h"

@implementation GameScene

-(id)init {
    self = [super init];
    if (self != nil) {
        //Gameplay layer
        GameplayLayer *gamePlayLayer = [GameplayLayer node];
        [self addChild:gamePlayLayer];
    }
    return self;
}

@end