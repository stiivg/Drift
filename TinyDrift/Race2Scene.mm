//
//  Race2Scene.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 2/5/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#import "Race2Scene.h"
#import "Race2Layer.h"


@implementation Race2Scene

Race2Layer *race2Layer = nil;

-(id)init {
    self = [super init];
    if (self != nil) {
        //race layer
        race2Layer = [Race2Layer node];
        [self addChild:race2Layer z:1 tag:1];
    }
    return self;
}


@end