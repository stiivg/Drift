//
//  Box2DSprite.h
//  drift
//
//  Created by Steven Gallagher on 4/24/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#ifndef drift_Box2DSprite_h
#define drift_Box2DSprite_h

#import "cocos2d.h"
#import "Box2D.h"

@interface Box2DSprite : CCSprite
{
    b2Body *body;
    b2World *_world;
    
}

@property (assign) b2Body *body;

- (id)initWithWorld:(b2World *)world;

@end


#endif
