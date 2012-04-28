//
//  Box2DSprite.mm
//  drift
//
//  Created by Steven Gallagher on 4/24/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#include "Box2DSprite.h"

@implementation Box2DSprite
@synthesize body;

- (id)initWithWorld:(b2World *)world {
    if ((self = [super init])) {
        _world = world;
    }
    return self;
}

-(void) dealloc {
    //Release all our retained objects
    [super dealloc];
}


@end