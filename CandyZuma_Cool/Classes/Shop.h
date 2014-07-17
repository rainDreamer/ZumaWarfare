//
//  MainMenu.h
//  babycornrun
//
//  Created by Jiang Yong on 3/1/2012.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MKStoreManager.h"

@interface Shop : CCLayer<SKPaymentTransactionObserver>
{
    CCMenuItemImage *menuItemCharacter1;
    CCMenuItemImage *menuItemCharacter2;
    CCMenuItemImage *menuItemCharacter3;

    CCMenuItemImage *menuItemCharacter1_Selected;
    CCMenuItemImage *menuItemCharacter2_Selected;
    CCMenuItemImage *menuItemCharacter3_Selected;

    CCMenuItemImage *menuItemCharacter1_Select;
    CCMenuItemImage *menuItemCharacter2_Select;
    CCMenuItemImage *menuItemCharacter3_Select;

    CCMenuItemImage *menuItemCharacter1_Purchase;
    CCMenuItemImage *menuItemCharacter2_Purchase;
    CCMenuItemImage *menuItemCharacter3_Purchase;
    
    // character labels
    CCSprite *spriteCharacter1;
    CCSprite *spriteCharacter2;
    CCSprite *spriteCharacter3;
    
    CCSprite *spriteimage1_1;
    CCSprite *spriteimage2_1;
    CCSprite *spriteimage3_1;

    CCSprite *spriteimage1_2;
    CCSprite *spriteimage2_2;
    CCSprite *spriteimage3_2;
    
//    CCSprite *spriteCharacterSelected1;
//    CCSprite *spriteCharacterUnlock1;
//    
//    CCSprite *spriteCharacterSelected2;
//    CCSprite *spriteCharacterUnlock2;
//    
//    CCSprite *spriteCharacterSelected3;
//    CCSprite *spriteCharacterUnlock3;
    
    bool        m_bCharacter1Locked;
    bool        m_bCharacter2Locked;
    bool        m_bCharacter3Locked;
    int         m_nSelectedCharacter;

    
}

+(CCScene *) scene;

@end
