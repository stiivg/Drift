//
//  OptionsLayer.h
//  TinyDrift
//
//  Created by Steven Gallagher on 3/29/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_OptionsLayer_h
#define TinyDrift_OptionsLayer_h

#import "cocos2d.h"


@interface OptionsLayer : CCLayer
{
    CCScene *_mainScene;

}

- (id)initWithMain:(CCScene *)mainScene;

@end

#endif
