//
//  MainScene.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 1/21/12.
//  Copyright (c) 2012 Steven Gallagher. All rights reserved.
//


#import "MainScene.h"


@implementation MainScene

MainLayer *mainLayer = nil;

-(id)init {
    self = [super init];
    if (self != nil) {
        //Main button layer
        mainLayer = [MainLayer node];
        [self addChild:mainLayer z:0 tag:1];
    }
    return self;
}


@end