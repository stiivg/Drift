//
//  emitters.m
//  TinyDrift
//
//  Created by Steven Gallagher on 12/30/11.
//  Copyright 2011 Steve Gallagher. All rights reserved.
//

#import "emitters.h"

//
// ParticleSun
//
@implementation CCParticleTurbo
-(id) init
{
	return [self initWithTotalParticles:350];
}

-(id) initWithTotalParticles:(NSUInteger) p
{
	if( (self=[super initWithTotalParticles:p]) ) {
        
        self.positionType = kCCPositionTypeRelative;

		// additive
		self.blendAdditive = YES;
        
		// duration
		duration = kCCParticleDurationInfinity;
		
		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;
		
		// Gravity Mode: gravity
		self.gravity = ccp(0,0);
		
		// Gravity mode: radial acceleration
		self.radialAccel = 0;
		self.radialAccelVar = 0;
		
		// Gravity mode: speed of particles
		self.speed = 20;
		self.speedVar = 5;
        
		
		// angle
		angle = 90;
		angleVar = 360;
		
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		posVar = CGPointZero;
		
		// life of particles
		life = 1;
		lifeVar = 0.0f;
		
		// size, in pixels
		startSize = 30.0f;
		startSizeVar = 10.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;
        
		// emits per seconds
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.76f;
		startColor.g = 0.25f;
		startColor.b = 0.12f;
		startColor.a = 1.0f;
		startColorVar.r = 0.0f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.0f;
		startColorVar.a = 0.0f;
		endColor.r = 0.0f;
		endColor.g = 0.0f;
		endColor.b = 0.0f;
		endColor.a = 1.0f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.0f;
		endColorVar.a = 0.0f;
		
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
	}
    
	return self;
}

@end



//
// ParticleSmoke
//
@implementation CCParticleDrift
-(id) init
{
	return [self initWithTotalParticles:200];
}

-(id) initWithTotalParticles:(NSUInteger) p
{
	if( (self=[super initWithTotalParticles:p]) ) {
        
        self.positionType = kCCPositionTypeRelative;

		// duration
		duration = kCCParticleDurationInfinity;
		
		// Emitter mode: Gravity Mode
		self.emitterMode = kCCParticleModeGravity;
		
		// Gravity Mode: gravity
		self.gravity = ccp(0,0);
        
		// Gravity Mode: radial acceleration
		self.radialAccel = 0;
		self.radialAccelVar = 0;
		
		// Gravity Mode: speed of particles
		self.speed = 0;
		self.speedVar = 0;
		
		// angle
		angle = 90;
		angleVar = 5;
		
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, 0);
		posVar = ccp(5, 0);
		
		// life of particles
		life = .5;
		lifeVar = .1;
		
		// size, in pixels
		startSize = 30.0f;
		startSizeVar = 5.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;
        
		// emits per frame
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.8f;
		startColor.g = 0.8f;
		startColor.b = 0.8f;
		startColor.a = 1.0f;
		startColorVar.r = 0.02f;
		startColorVar.g = 0.02f;
		startColorVar.b = 0.02f;
		startColorVar.a = 0.0f;
		endColor.r = 0.0f;
		endColor.g = 0.0f;
		endColor.b = 0.0f;
		endColor.a = 1.0f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.0f;
		endColorVar.a = 0.0f;
		
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
		
		// additive
		self.blendAdditive = NO;
	}
	
	return self;
}
@end

