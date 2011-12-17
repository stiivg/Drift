//
//  GameManager.h
//  TinyDrift
//
//  Created by Steven Gallagher on 12/16/11.
//  Copyright (c) 2011 Steve Gallagher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface GameManager : NSObject {
    SceneTypes currentScene;
}
+(GameManager*)sharedGameManager;
-(void)runSceneWithID:(SceneTypes)sceneID;

@end
