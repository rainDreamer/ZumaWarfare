//
//  MainMenu.h
//  babycornrun
//
//  Created by Jiang Yong on 3/1/2012.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Global.h"
//#import <AVFoundation/AVFoundation.h>
//#import <AudioToolbox/AudioToolbox.h>

@interface SelectStage : CCLayer
{
    int             m_nSkipLevel;
    int             m_nHighScore;

    CCLabelTTF      *m_lblLevelScore[LEVEL_COUNT];
    NSMutableArray *stageMenuArray;
    CCMenu *menuStage;
}

+(CCScene *) scene;


@end
