//
//  Drums.mm
//  drift
//
//  Created by Steven Gallagher on 4/24/12.
//  Copyright (c) 2012 Steve Gallagher. All rights reserved.
//

#include "Drums.h"

@implementation Drums


- (id)initWithWorld:(b2World *)world {
    if ((self = [super init])) {
        myWorld = world;
    }
    return self;
}

-(void)createDrumAtLocation: (CGPoint)location {
    Box2DSprite *drumSprite = [Box2DSprite spriteWithSpriteFrameName:@"drum_top.png"];

    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    bodyDef.allowSleep = false;
    bodyDef.linearDamping = 0.8;
    b2Body *body = myWorld->CreateBody(&bodyDef);
    
    body->SetUserData(drumSprite);
    drumSprite.body = body;
    
    b2FixtureDef fixtureDef;
    
    b2CircleShape shape;
    shape.m_radius = drumSprite.contentSize.width/2/PTM_RATIO;
    fixtureDef.shape = &shape;
    
    fixtureDef.density = 10;
    
    body->CreateFixture(&fixtureDef);
    
    [_terrain.batchNode addChild:drumSprite];
    
}
-(void)releaseDrums {
    for (b2Body *b = myWorld->GetBodyList(); b != NULL; b = b->GetNext()) {
        if(b->GetUserData() != NULL) {
            Box2DSprite *sprite = (Box2DSprite *)b->GetUserData();
            [_terrain.batchNode removeChild:sprite cleanup:true];
            myWorld->DestroyBody(b);
        }
    }
}



-(void)createDrums:(Terrain *)terrain {
    [self releaseDrums];
    _terrain = terrain;
    
    CGPoint *path = _terrain.getPath;
    //    [self createDrumAtLocation:ccp(40,450+60*i)];
    float side = 1.0;    
    for (int i=20; i<600; i+=60) {
        float drumX =  path[i].x/CC_CONTENT_SCALE_FACTOR();
        float drumY =  path[i].y/CC_CONTENT_SCALE_FACTOR();
        [self createDrumAtLocation:ccp(drumX-side*80,drumY)];
        [self createDrumAtLocation:ccp(drumX-side*98,drumY)];
        [self createDrumAtLocation:ccp(drumX-side*89,drumY-16)];
        
        side = -side;
    }
}

-(void)updateDrums {
    for (b2Body *b = myWorld->GetBodyList(); b != NULL; b = b->GetNext()) {
        if(b->GetUserData() != NULL) {
            Box2DSprite *sprite = (Box2DSprite *)b->GetUserData();
            sprite.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
        }
    }
}

-(void) dealloc {
    
    //Release all our retained objects
    [super dealloc];
}


@end
