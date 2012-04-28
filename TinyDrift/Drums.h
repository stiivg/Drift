//
//  Drums.h
//  drift
//
//  Created by Steven Gallagher on 4/24/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#ifndef drift_Drums_h
#define drift_Drums_h

#import "cocos2d.h"
#import "Box2D.h"
#import "Constants.h"
#import "Terrain.h"
#import "Box2DSprite.h"

@interface Drums : NSObject
{
    b2World *myWorld;
    Terrain *_terrain;

}

- (id)initWithWorld:(b2World *)world;
- (void)createDrums:(CCNode *)terrain;
- (void)updateDrums;
@end



#endif
