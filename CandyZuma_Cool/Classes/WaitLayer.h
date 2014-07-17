//
//  MainMenu.h
//  babycornrun
//
//  Created by Jiang Yong on 3/1/2012.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface WaitLayer : CCLayer
{
}

-(void) setBackImg:(NSString*)strName;
+(CCScene *) scene:(NSString*) strBackImg;


@end
