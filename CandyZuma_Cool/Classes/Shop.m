//
//  MainMenu.m
//  babycornrun
//
//  Created by Jiang Yong on 3/1/2012.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Shop.h"
#import "SelectStage.h"
#import "GameScreen.h"
#import "MainMenu.h"
#import "Global.h"
#import "SimpleAudioEngine.h"
#import "MKStoreManager.h"
#import "MBProgressHUD.h"

@implementation Shop

+(id) scene
{
    CCScene *scene = [CCScene node];
    
    Shop *layer = [Shop node];
    
    [scene addChild: layer];
    
    return scene;
}

-(id) init
{   
    if( (self=[super init] )) {
        
        [self setTouchEnabled:YES];
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        // backbround
        CCSprite *background;
        if (screenSize.width == 568 || screenSize.height == 568)
        {
            background = [CCSprite spriteWithFile:@"shop_background_4inch.png"];
            
        }
        else
        {
            background = [CCSprite spriteWithFile:@"shop_background.png"];
        }
        background.position = ccp(screenSize.width * 0.5f, screenSize.height * 0.5f);
        [self addChild:background];         
     
        // menu bar
        CCSprite* menuBar;
        if (screenSize.width == 568 || screenSize.height == 568)
        {
            menuBar = [CCSprite spriteWithFile:@"menubar_4inch.png"];
        }
        else
        {
            menuBar = [CCSprite spriteWithFile:@"menubar.png"];
        }
        menuBar.anchorPoint = ccp(0.5f, 0);
        menuBar.position = ccp(screenSize.width * 0.5f, 0);
        [self addChild:menuBar];
        
        // shop board
        CCSprite *shopBoard;
        if (screenSize.width == 568 || screenSize.height == 568)
        {
             shopBoard = [CCSprite spriteWithFile:@"shop_screen_4inch.png"];
        }
        else
        {
            shopBoard = [CCSprite spriteWithFile:@"shop_screen.png"];
        }
        shopBoard.position = ccp(screenSize.width * 0.5f, (screenSize.height + menuBar.contentSize.height) * 0.5f);
        [self addChild:shopBoard];     
        
        
        // characters
        menuItemCharacter1 = [CCMenuItemImage itemWithNormalImage:@"shop_unlock_btn.png" selectedImage:@"shop_selected_btn.png" disabledImage:@"shop_unlock_btn.png" target:self selector:@selector(onCharacter:)];
        menuItemCharacter1.tag = 1201;
        menuItemCharacter2 = [CCMenuItemImage itemWithNormalImage:@"shop_unlock_btn.png" selectedImage:@"shop_selected_btn.png" disabledImage:@"shop_unlock_btn.png" target:self selector:@selector(onCharacter:)];
        menuItemCharacter2.tag = 1202;
        menuItemCharacter3 = [CCMenuItemImage itemWithNormalImage:@"shop_unlock_btn.png" selectedImage:@"shop_selected_btn.png" disabledImage:@"shop_unlock_btn.png" target:self selector:@selector(onCharacter:)];
        menuItemCharacter3.tag = 1203;        
        
        CCMenu* menu1 = [CCMenu menuWithItems: menuItemCharacter1, menuItemCharacter2, menuItemCharacter3, nil];
        float padding = (screenSize.width - menuItemCharacter1.contentSize.width * 3) / 4;
        [menu1 alignItemsHorizontallyWithPadding:padding];
        menu1.position = ccp(screenSize.width * 0.5f, (screenSize.height + menuBar.contentSize.height) * 0.5f);
        
		[self addChild:menu1];
        
        menuItemCharacter1_Selected = [CCMenuItemImage itemWithNormalImage:@"shop_selected.png" selectedImage:@"shop_selected.png" disabledImage:@"shop_selected.png" target:self selector:@selector(onCharacter:)];
        menuItemCharacter1_Selected.tag = 1201;
        menuItemCharacter2_Selected = [CCMenuItemImage itemWithNormalImage:@"shop_selected.png" selectedImage:@"shop_selected.png" disabledImage:@"shop_selected.png" target:self selector:@selector(onCharacter:)];
        menuItemCharacter2_Selected.tag = 1202;
        menuItemCharacter3_Selected = [CCMenuItemImage itemWithNormalImage:@"shop_selected.png" selectedImage:@"shop_selected.png" disabledImage:@"shop_selected.png" target:self selector:@selector(onCharacter:)];
        menuItemCharacter3_Selected.tag = 1203;
        
        CCMenu* menu2 = [CCMenu menuWithItems: menuItemCharacter1_Selected, menuItemCharacter2_Selected, menuItemCharacter3_Selected, nil];
        padding = (screenSize.width - menuItemCharacter1_Selected.contentSize.width * 3) / 4;
        [menu2 alignItemsHorizontallyWithPadding:padding];
        menu2.position = ccp(screenSize.width * 0.5f, shopBoard.position.y - 0.25f * (menuItemCharacter1.contentSize.height + shopBoard.contentSize.height));
        
		[self addChild:menu2];
        menuItemCharacter1_Selected.position = menuItemCharacter1.position;
        menuItemCharacter2_Selected.position = menuItemCharacter2.position;
        menuItemCharacter3_Selected.position = menuItemCharacter3.position;

        menuItemCharacter1_Select = [CCMenuItemImage itemWithNormalImage:@"shop_select.png" selectedImage:@"shop_select.png" disabledImage:@"shop_select.png" target:self selector:@selector(onCharacter:)];
        menuItemCharacter1_Select.tag = 1201;
        menuItemCharacter2_Select = [CCMenuItemImage itemWithNormalImage:@"shop_select.png" selectedImage:@"shop_select.png" disabledImage:@"shop_select.png" target:self selector:@selector(onCharacter:)];
        menuItemCharacter2_Select.tag = 1202;
        menuItemCharacter3_Select = [CCMenuItemImage itemWithNormalImage:@"shop_select.png" selectedImage:@"shop_select.png" disabledImage:@"shop_select.png" target:self selector:@selector(onCharacter:)];
        menuItemCharacter3_Select.tag = 1203;
        
        CCMenu* menu3 = [CCMenu menuWithItems: menuItemCharacter1_Select, menuItemCharacter2_Select, menuItemCharacter3_Select, nil];
        padding = (screenSize.width - menuItemCharacter1_Select.contentSize.width * 3) / 4;
        [menu3 alignItemsHorizontallyWithPadding:padding];
        menu3.position = ccp(screenSize.width * 0.5f, shopBoard.position.y - 0.25f * (menuItemCharacter1.contentSize.height + shopBoard.contentSize.height));
        
		[self addChild:menu3];
        menuItemCharacter1_Select.position = menuItemCharacter1.position;
        menuItemCharacter2_Select.position = menuItemCharacter2.position;
        menuItemCharacter3_Select.position = menuItemCharacter3.position;

        menuItemCharacter1_Purchase = [CCMenuItemImage itemWithNormalImage:@"shop_purchase.png" selectedImage:@"shop_purchase.png" disabledImage:@"shop_purchase.png" target:self selector:@selector(onCharacter:)];
        menuItemCharacter1_Purchase.tag = 1201;
        menuItemCharacter2_Purchase = [CCMenuItemImage itemWithNormalImage:@"shop_purchase.png" selectedImage:@"shop_purchase.png" disabledImage:@"shop_purchase.png" target:self selector:@selector(onCharacter:)];
        menuItemCharacter2_Purchase.tag = 1202;
        menuItemCharacter3_Purchase = [CCMenuItemImage itemWithNormalImage:@"shop_purchase.png" selectedImage:@"shop_purchase.png" disabledImage:@"shop_purchase.png" target:self selector:@selector(onCharacter:)];
        menuItemCharacter3_Purchase.tag = 1203;
        
        CCMenu* menu4 = [CCMenu menuWithItems: menuItemCharacter1_Purchase, menuItemCharacter2_Purchase, menuItemCharacter3_Purchase, nil];
        padding = (screenSize.width - menuItemCharacter1_Purchase.contentSize.width * 3) / 4;
        [menu4 alignItemsHorizontallyWithPadding:padding];
        menu4.position = ccp(screenSize.width * 0.5f, shopBoard.position.y - 0.25f * (menuItemCharacter1.contentSize.height + shopBoard.contentSize.height));
        
		[self addChild:menu4];
        menuItemCharacter1_Purchase.position = menuItemCharacter1.position;
        menuItemCharacter2_Purchase.position = menuItemCharacter2.position;
        menuItemCharacter3_Purchase.position = menuItemCharacter3.position;

        // character images
//        /*CCSprite* */spriteimage1_1 = [CCSprite spriteWithFile:@"store_button.png"];
//        [self addChild:spriteimage1_1 z:10];
//        /*CCSprite* */spriteimage2_1 = [CCSprite spriteWithFile:@"store_button.png"];
//        [self addChild:spriteimage2_1 z:10];
//        /*CCSprite* */spriteimage3_1 = [CCSprite spriteWithFile:@"store_button.png"];
//        [self addChild:spriteimage3_1 z:10];

        /*CCSprite* */spriteimage1_2 = [CCSprite spriteWithFile:@"store_character_1.png"];
        [self addChild:spriteimage1_2 z:10];
        /*CCSprite* */spriteimage2_2 = [CCSprite spriteWithFile:@"store_character_2.png"];
        [self addChild:spriteimage2_2 z:10];
        /*CCSprite* */spriteimage3_2 = [CCSprite spriteWithFile:@"store_character_3.png"];
        [self addChild:spriteimage3_2 z:10];

        // character labels
        spriteCharacter1 = [CCSprite spriteWithFile:@"shop_character1.png"];
        spriteCharacter2 = [CCSprite spriteWithFile:@"shop_character2.png"];
        spriteCharacter3 = [CCSprite spriteWithFile:@"shop_character3.png"];
        
//        spriteCharacterSelected1 = [CCSprite spriteWithFile:@"shop_selected.png"];
//        spriteCharacterUnlock1 = [CCSprite spriteWithFile:@"shop_unlock.png"];
//        
//        spriteCharacterSelected2 = [CCSprite spriteWithFile:@"shop_selected.png"];
//        spriteCharacterUnlock2 = [CCSprite spriteWithFile:@"shop_unlock.png"];
//        
//        spriteCharacterSelected3 = [CCSprite spriteWithFile:@"shop_selected.png"];
//        spriteCharacterUnlock3 = [CCSprite spriteWithFile:@"shop_unlock.png"];
        
        [self addChild:spriteCharacter1];
        [self addChild:spriteCharacter2];
        [self addChild:spriteCharacter3];
        
//        [self addChild:spriteCharacterSelected1];
//        [self addChild:spriteCharacterUnlock1];
//        
//        [self addChild:spriteCharacterSelected2];
//        [self addChild:spriteCharacterUnlock2];
//        
//        [self addChild:spriteCharacterSelected3];
//        [self addChild:spriteCharacterUnlock3];
        
        int posX;
        int posY;        
        
        posY = shopBoard.position.y + 0.25f * (menuItemCharacter1.contentSize.height + shopBoard.contentSize.height);
        posX = menuItemCharacter1.position.x + screenSize.width * 0.5f;
        spriteCharacter1.position = ccp(posX, posY);        
//        spriteimage1_1.position = ccp(posX, (screenSize.height + menuBar.contentSize.height) * 0.5f);
        spriteimage1_2.position = ccp(posX, (screenSize.height + menuBar.contentSize.height) * 0.5f);

        posX = menuItemCharacter2.position.x + screenSize.width * 0.5f;
        spriteCharacter2.position = ccp(posX, posY);
//        spriteimage2_1.position = ccp(posX, (screenSize.height + menuBar.contentSize.height) * 0.5f);
        spriteimage2_2.position = ccp(posX, (screenSize.height + menuBar.contentSize.height) * 0.5f);

        posX = menuItemCharacter3.position.x + screenSize.width * 0.5f;
        spriteCharacter3.position = ccp(posX, posY);
//        spriteimage3_1.position = ccp(posX, (screenSize.height + menuBar.contentSize.height) * 0.5f);
        spriteimage3_2.position = ccp(posX, (screenSize.height + menuBar.contentSize.height) * 0.5f);

        
        posY = shopBoard.position.y - 0.25f * (menuItemCharacter1.contentSize.height + shopBoard.contentSize.height);
        posX = menuItemCharacter1.position.x + screenSize.width * 0.5f;
//        spriteCharacterSelected1.position = ccp(posX, posY);
//        spriteCharacterUnlock1.position = ccp(posX, posY);
//        
//        posX = menuItemCharacter2.position.x + screenSize.width * 0.5f;
//        spriteCharacterSelected2.position = ccp(posX, posY);
//        spriteCharacterUnlock2.position = ccp(posX, posY);
//        
//        posX = menuItemCharacter3.position.x + screenSize.width * 0.5f;
//        spriteCharacterSelected3.position = ccp(posX, posY);
//        spriteCharacterUnlock3.position = ccp(posX, posY);         

        // initialize characters
        m_bCharacter1Locked = gbIsCharacter1Locked;
        m_bCharacter2Locked = gbIsCharacter2Locked;
        m_bCharacter3Locked = gbIsCharacter3Locked;
        
        [self setCharacterStates]; 
        
        //menus        
//        CCSprite* spriteBack = [CCSprite spriteWithFile:@"menu_back.png"];
//        CCSprite* spriteMoreGames = [CCSprite spriteWithFile:@"menu_moregames.png"];
//        CCSprite* spriteRestore = [CCSprite spriteWithFile:@"menu_restore.png"];
//        CCSprite* spriteStart = [CCSprite spriteWithFile:@"menu_start.png"];         
//        
//        CCMenuItemSprite *menuItemBack = [CCMenuItemSprite itemWithNormalSprite:spriteBack selectedSprite:nil target:self selector:@selector(onShopBack)];
//        CCMenuItemSprite *menuItemMoreGames = [CCMenuItemSprite itemWithNormalSprite:spriteMoreGames selectedSprite:nil target:self selector:@selector(onMoreGames)];
//        CCMenuItemSprite *menuItemRestore = [CCMenuItemSprite itemWithNormalSprite:spriteRestore selectedSprite:nil target:self selector:@selector(onRestore)];
//        CCMenuItemSprite *menuItemStart = [CCMenuItemSprite itemWithNormalSprite:spriteStart selectedSprite:nil target:self selector:@selector(onShopStart)];

        CCMenuItemSprite *menuItemBack = [CCMenuItemImage itemWithNormalImage:@"menu_back.png" selectedImage:nil target:self selector:@selector(onShopBack)];
        CCMenuItemSprite *menuItemMoreGames = [CCMenuItemImage itemWithNormalImage:@"homepage_moregames.png" selectedImage:nil target:self selector:@selector(onMoreGames)];
        CCMenuItemSprite *menuItemRestore = [CCMenuItemImage itemWithNormalImage:@"menu_restore.png" selectedImage:nil target:self selector:@selector(onRestore)];
        CCMenuItemSprite *menuItemStart = [CCMenuItemImage itemWithNormalImage:@"menu_start.png" selectedImage:nil target:self selector:@selector(onShopStart)];

        
        CCMenu * menu5 = [CCMenu menuWithItems:menuItemBack, menuItemMoreGames, menuItemRestore, menuItemStart, nil];
       
        padding = (screenSize.width - menuItemBack.contentSize.width - menuItemMoreGames.contentSize.width- menuItemRestore.contentSize.width- menuItemStart.contentSize.width) / 5;
        [menu5 alignItemsHorizontallyWithPadding:padding];
        menu5.position = ccp(screenSize.width * 0.5f, menuBar.contentSize.height * 0.5f);
        
		[self addChild:menu5];
    }
    
    return self;
}

-(void) setCharacterStates
{
    
//    if (gbIsCharacter1Locked == true)
//    {
//        [spriteimage1_1 setVisible:TRUE];
//        [spriteimage1_2 setVisible:FALSE];
//    }
//    else
//    {
//        [spriteimage1_1 setVisible:FALSE];
//        [spriteimage1_2 setVisible:TRUE];
//    }
//
//    if (gbIsCharacter2Locked == true)
//    {
//        [spriteimage2_1 setVisible:TRUE];
//        [spriteimage2_2 setVisible:FALSE];
//    }
//    else
//    {
//        [spriteimage2_1 setVisible:FALSE];
//        [spriteimage2_2 setVisible:TRUE];
//    }
//    
//    if (gbIsCharacter3Locked == true)
//    {
//        [spriteimage3_1 setVisible:TRUE];
//        [spriteimage3_2 setVisible:FALSE];
//    }
//    else
//    {
//        [spriteimage3_1 setVisible:FALSE];
//        [spriteimage3_2 setVisible:TRUE];
//    }

    if (gbIsCharacter1Locked == true)
    {
        [menuItemCharacter1_Selected setVisible:FALSE];
        [menuItemCharacter1_Select setVisible:FALSE];
        [menuItemCharacter1_Purchase setVisible:TRUE];
    } else
    {
        [menuItemCharacter1_Selected setVisible:FALSE];
        [menuItemCharacter1_Select setVisible:TRUE];
        [menuItemCharacter1_Purchase setVisible:FALSE];
    }
    
    if (gbIsCharacter2Locked == true)
    {
        [menuItemCharacter2_Selected setVisible:FALSE];
        [menuItemCharacter2_Select setVisible:FALSE];
        [menuItemCharacter2_Purchase setVisible:TRUE];
    } else
    {
        [menuItemCharacter2_Selected setVisible:FALSE];
        [menuItemCharacter2_Select setVisible:TRUE];
        [menuItemCharacter2_Purchase setVisible:FALSE];
    }
    
    if (gbIsCharacter3Locked == true)
    {
        [menuItemCharacter3_Selected setVisible:FALSE];
        [menuItemCharacter3_Select setVisible:FALSE];
        [menuItemCharacter3_Purchase setVisible:TRUE];
    } else
    {
        [menuItemCharacter3_Selected setVisible:FALSE];
        [menuItemCharacter3_Select setVisible:TRUE];
        [menuItemCharacter3_Purchase setVisible:FALSE];
    }
    
    switch (gnSelectedCharacter) {
        case 0:
            [menuItemCharacter1_Selected setVisible:TRUE];
            [menuItemCharacter1_Select setVisible:FALSE];
            [menuItemCharacter1_Purchase setVisible:FALSE];
            break;
        case 1:
            [menuItemCharacter2_Selected setVisible:TRUE];
            [menuItemCharacter2_Select setVisible:FALSE];
            [menuItemCharacter2_Purchase setVisible:FALSE];
            break;
        case 2:
            [menuItemCharacter3_Selected setVisible:TRUE];
            [menuItemCharacter3_Select setVisible:FALSE];
            [menuItemCharacter3_Purchase setVisible:FALSE];
            break;
        default:
            [menuItemCharacter1_Selected setVisible:TRUE];
            [menuItemCharacter1_Select setVisible:FALSE];
            [menuItemCharacter1_Purchase setVisible:FALSE];
            break;
    }
    
//    [spriteCharacterSelected1 setVisible:NO];
//    [spriteCharacterUnlock1 setVisible:NO];
//    [spriteCharacterSelected2 setVisible:NO];
//    [spriteCharacterUnlock2 setVisible:NO];
//    [spriteCharacterSelected3 setVisible:NO];
//    [spriteCharacterUnlock3 setVisible:NO];
    if ([menuItemCharacter1 isSelected])
        [menuItemCharacter1 unselected];
    if ([menuItemCharacter2 isSelected])
        [menuItemCharacter2 unselected];
    if ([menuItemCharacter3 isSelected])
        [menuItemCharacter3 unselected];
    
//    [menuItemCharacter1 setIsEnabled:!m_bCharacter1Locked];
//    [menuItemCharacter2 setIsEnabled:!m_bCharacter2Locked];
//    [menuItemCharacter3 setIsEnabled:!m_bCharacter3Locked];

    switch (m_nSelectedCharacter)
    {
        case 0:
//            [spriteCharacterSelected1 setVisible:YES];
            [menuItemCharacter1 selected];
            break;
        case 1:
//            [spriteCharacterSelected2 setVisible:YES];
            [menuItemCharacter2 selected];
            break;
        case 2:
//            [spriteCharacterSelected3 setVisible:YES];
            [menuItemCharacter3 selected];
            break;
    }
}

- (void) onCharacter:(CCMenuItem *)sender
{
    
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    NSLog(@"selected level number %d", sender.tag);
    
    if (sender.tag-1201 == 0 && gbIsCharacter1Locked == true)
    {
        [self unlockCharacter:0];
        return;
    } else if (sender.tag-1201 == 1 && gbIsCharacter2Locked == true)
    {
        [self unlockCharacter:1];
        return;
    } else if (sender.tag-1201 == 2 && gbIsCharacter3Locked == true)
    {
        [self unlockCharacter:2];
        return;
    }
    
    m_nSelectedCharacter = sender.tag-1201;
    gnSelectedCharacter = sender.tag-1201;
    [self setCharacterStates];    
}

- (void) onShopBack
{    
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
	CCScene *scene = [MainMenu scene];
    CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0 scene:scene withColor:ccBLACK];
    [[CCDirector sharedDirector] replaceScene:ts];    
}

- (void) onMoreGames
{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    [[Chartboost sharedChartboost] showMoreApps];
    AppController* appDel = (AppController*)[[UIApplication sharedApplication] delegate];
    [[PHPublisherContentRequest requestForApp:phtoken secret: phsecret placement: PlayHaven_PlacementID_6 delegate: appDel] send];
}

- (void) unlockCharacter:(int)nIndex
{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    NSString* nonconsumableId = nil;
    
    if (nIndex == 0)
        return;
    else if (nIndex == 1)
        nonconsumableId = userStatus3_hd;
    else if (nIndex == 2)
        nonconsumableId = userStatus4_hd;
    
    AppController* del = (AppController*)[UIApplication sharedApplication].delegate;
    MyNavigationController* vc = del.navController;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
    [hud hide:true afterDelay:30];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    [[MKStoreManager sharedManager] buyFeature:nonconsumableId
                                    onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt,SKPaymentTransaction* transaction)
     {
         [MBProgressHUD hideAllHUDsForView:vc.view animated:true];
         
         if([purchasedFeature isEqualToString:userStatus3_hd])
         {
             gbIsCharacter2Locked = false;
             m_nSelectedCharacter = 1;
             gnSelectedCharacter = 1;
             [del saveInfo];
             [self setCharacterStates];
         }
         else if([purchasedFeature isEqualToString:userStatus4_hd])
         {
             gbIsCharacter3Locked = false;
             m_nSelectedCharacter = 2;
             gnSelectedCharacter = 2;
             [del saveInfo];
             [self setCharacterStates];
         }

     }
                                   onCancelled:^
     {
         [MBProgressHUD hideAllHUDsForView:vc.view animated:true];
         NSLog(@"User Cancelled Transaction");
     }];
}

- (void) onRestore
{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^
     {
     }
                                                                  onError:
     ^(NSError* error)
     {
         NSLog(@"Restore Failed");
     }];
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"Restore Failed With Error:%@", error);
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    AppController* del = (AppController*)[UIApplication sharedApplication].delegate;
    for (SKPaymentTransaction* transaction in queue.transactions) {
        NSString* productID = transaction.payment.productIdentifier;
        
        if ([productID isEqualToString:userStatus1_hd]) {
            gbIsUnlockAllLevels = true;
            for (int i = 0; i < LEVEL_COUNT; i++)
                gbLevelUnlock[i] = true;
            [del saveInfo];
        }
        else if ([productID isEqualToString:userStatus3_hd]) {
            gbIsCharacter2Locked = false;
            [del saveInfo];
            [self setCharacterStates];
        }
        else if ([productID isEqualToString:userStatus4_hd]) {
            gbIsCharacter3Locked = false;
            [del saveInfo];
            [self setCharacterStates];
        }
        else if ([productID isEqualToString:userStatus5_hd]) {
            gbIsRemoveAds = true;
            [del saveInfo];
        }
    }
}

- (void) onShopStart
{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
//    gnCharacter1 = nCharacter1;
//    gnCharacter2 = nCharacter2;
//    gnCharacter3 = nCharacter3;

	CCScene *scene = [SelectStage scene];
    CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0 scene:scene withColor:ccBLACK];
    [[CCDirector sharedDirector] replaceScene:ts];
}

- (void) dealloc
{    
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end