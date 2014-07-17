//
//  PauseLayer.h
//  CandyZuma_Cool
//
//  Created by lion on 9/12/13.
//  Copyright MingGong 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface PauseLayer : CCLayer
{
    bool        m_bMusicOpen;
    bool        m_bSoundOpen;
    CCMenuItemImage* m_itemMusic;
    CCMenuItemImage* m_itemSound;
    float xRate;
    float yRate;
}

-(void) setMusicEnable:(bool)bEnable;
-(void) setSoundEnable:(bool)bEnable;

@end
