//
//  StatusLayer.mm
//  TinyDrift
//
//  Created by Steven Gallagher on 3/17/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#include "StatusLayer.h"

@implementation StatusLayer

-(CCSprite *)spriteWithColor:(ccColor4F)barColor barHeight:(float)barHeight {
    
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:BAR_WIDTH height:barHeight];
    
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:barColor.r g:barColor.g b:barColor.b a:barColor.a];
    
    // 3: Draw into the texture
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    float gradientAlpha = 0.7;    
    CGPoint vertices[4];
    ccColor4F colors[4];
    int nVertices = 0;
    
    vertices[nVertices] = CGPointMake(0, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0 };
    vertices[nVertices] = CGPointMake(BAR_WIDTH, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    vertices[nVertices] = CGPointMake(0, barHeight);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    vertices[nVertices] = CGPointMake(BAR_WIDTH, barHeight);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, colors);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
        
    // 4: Call CCRenderTexture:end
    [rt end];
    
    // 5: Create a new Sprite from the texture
    return [CCSprite spriteWithTexture:rt.sprite.texture];
    
}

- (void)genCarBar {
    
    [_carBar removeFromParentAndCleanup:YES];
    ccColor4B carColor = ccc4(20, 200, 30, 255); // green
    ccColor4F barColor = ccc4FFromccc4B(carColor);
    
    _carBar = [self spriteWithColor:barColor barHeight:100/CC_CONTENT_SCALE_FACTOR()];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _carBar.position = ccp(20, winSize.height-140);        
    ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [_carBar.texture setTexParameters:&tp];
//    [_carBar setTextureRect:CGRectMake(0, 0, winSize.width / 0.5, winSize.height / 0.5)];
    
    [self addChild:_carBar];
    
}


-(id) init {
    if((self=[super init])) {
        
        [self genCarBar];
//        CGSize winSize = [CCDirector sharedDirector].winSize;
//        
//        _label = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:32];
//        _label.color = ccc3(0,0,0);
//        _label.position = ccp(winSize.width/2, winSize.height/2);
//        [self addChild:_label];
        
    }
    return self;
}

@end