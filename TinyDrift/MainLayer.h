//
//  MainLayer.h
//  TinyDrift
//
//  Created by Steven Gallagher on 1/20/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_MainLayer_h
#define TinyDrift_MainLayer_h

#import "cocos2d.h"

#define MAX_LENGTH 10

@interface MainLayer : CCLayer <UITextFieldDelegate>
{
    CCScene *_mainScene; 
    UITextField *name;
    CCMenuItemLabel *nameMenuItem;
    NSString *origString;
    BOOL nameEditing;
}

- (id)initWithMain:(CCScene *)mainScene;

@end



#endif
