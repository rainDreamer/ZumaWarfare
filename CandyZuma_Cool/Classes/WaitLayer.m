//
//  MainMenu.m
//  babycornrun
//
//  Created by Jiang Yong on 3/1/2012.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WaitLayer.h"
#import "GameScreen.h"

@implementation WaitLayer

+(id) scene:(NSString*) strBackImg
{
    CCScene *scene = [CCScene node];
    
    WaitLayer *layer = [WaitLayer node];

    [layer setBackImg:strBackImg];
    
    [scene addChild: layer];
    
    return scene;
}

-(void) setBackImg:(NSString*)strName
{
    CCSprite* backSprite = [CCSprite spriteWithFile:strName];
    CGSize size = [[CCDirector sharedDirector] winSize];
    backSprite.position = ccp(size.width / 2, size.height / 2);
    [self addChild:backSprite z:0];
}

-(id) init
{
    if( (self=[super init] )) {
        [self schedule:@selector(RunGameScreen:) interval:1];
    }
    
    return self;
}

-(void)RunGameScreen:(ccTime)dt
{
    [self unschedule:@selector(RunGameScreen:)];
    CCScene *scene = [GameScreen scene];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void) dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    
	[super dealloc];
}

@end