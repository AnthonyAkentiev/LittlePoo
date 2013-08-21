#include "Snow.h"

@implementation Snow

-(id) init
{
    if(self=[super init])
    {
        emitter = [CCParticleSnow node];
        
        //[background addChild: emitter z:10];
        [self addChild:emitter z:10];
        
        CGSize screen = [[CCDirector sharedDirector] winSize];
        emitter.life    = 6;
        emitter.lifeVar = 2;
        
        // gravity
        emitter.gravity = ccp(2,-5);
        
        // speed of particles
        emitter.speed    = 30;
        emitter.speedVar = 30;
        
        ccColor4F startColor = emitter.startColor;
        startColor.r = 0.9f;
        startColor.g = 0.9f;
        startColor.b = 0.9f;
        emitter.startColor = startColor;
        
        ccColor4F startColorVar = emitter.startColorVar;
        startColorVar.b = 0.1f;
        emitter.startColorVar = startColorVar;
        
        emitter.emissionRate = 0.2f * emitter.totalParticles/emitter.life;
        
        emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"snow.png"];
        
        emitter.position = ccp(screen.width/2, screen.height);
    }
    
    return self;
}

@end
