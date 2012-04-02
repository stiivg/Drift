//
//  TutorialLayer.h
//  TinyDrift
//
//  Created by Steven Gallagher on 4/1/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#ifndef TinyDrift_TutorialLayer_h
#define TinyDrift_TutorialLayer_h



#import "cocos2d.h"

#define LINE_SPACING 20
#define TOP_LINE 100
#define FONT_SIZE 16

@interface TutorialLayer : CCLayer
{
    CCLabelBMFont *helpLabel1;
    CCLabelBMFont *helpLabel2;
    CCLabelBMFont *helpLabel3;
}

-(void)touchOffMessage;
-(void)touchOnMessage;
-(void)turboMessage;

@end


#endif
