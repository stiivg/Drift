//
//  LoopLayer.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 1/22/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//


#import "LoopLayer.h"
#import "GameManager.h"

@implementation LoopLayer


-(CCSprite *)spriteWithColor:(ccColor4F)bgColor textureSize:(float)textureSize {
    
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize height:textureSize];
    
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:bgColor.r g:bgColor.g b:bgColor.b a:bgColor.a];
    
    // 3: Draw into the texture
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    //SJG 0.7 to 0.0 to remove top to bottom gradient
    float gradientAlpha = 0.0;    
    CGPoint vertices[4];
    ccColor4F colors[4];
    int nVertices = 0;
    
    vertices[nVertices] = CGPointMake(0, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0 };
    vertices[nVertices] = CGPointMake(textureSize, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    vertices[nVertices] = CGPointMake(0, textureSize);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    vertices[nVertices] = CGPointMake(textureSize, textureSize);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, colors);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
    
    CCSprite *noise = [CCSprite spriteWithFile:@"Noise.png"];
    [noise setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
    noise.position = ccp(textureSize/2, textureSize/2);
    [noise visit];
    
    // 4: Call CCRenderTexture:end
    [rt end];
    
    // 5: Create a new Sprite from the texture
    return [CCSprite spriteWithTexture:rt.sprite.texture];
    
}


- (void)genBackground {
    
    [_background removeFromParentAndCleanup:YES];
    //Use fixed road color
    ccColor4B roadColor = ccc4(209, 133, 34, 255);
    ccColor4F bgColor = ccc4FFromccc4B(roadColor);
    
    _background = [self spriteWithColor:bgColor textureSize:512/CC_CONTENT_SCALE_FACTOR()];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _background.position = ccp(winSize.width/2, winSize.height/2);        
    ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [_background.texture setTexParameters:&tp];
    [_background setTextureRect:CGRectMake(0, 0, winSize.width / MIN_SCALE, winSize.height / MIN_SCALE)];
    
    [self addChild:_background];
    
}

- (void)setupWorld {    
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    bool doSleep = true;
    _world = new b2World(gravity, doSleep);            
}


-(id) init {
    if((self=[super init])) {
        
        [self setupWorld];
        //set to 0.5 to zoom out
        self.scale = 1.0;
        
        targetScale = 1.0;
        
        _terrain = [[[Terrain alloc] initWithWorld:_world] autorelease];
        [self addChild:_terrain z:1];
        CCSprite *road = [CCSprite spriteWithFile:@"road_pattern_inverted_fade.png"];
        ccTexParams tp2 = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
        [road.texture setTexParameters:&tp2];
        _terrain.roadTexture = road;
        
        [self genBackground];
        
    }
    return self;
}


@end
