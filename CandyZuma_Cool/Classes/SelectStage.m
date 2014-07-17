//
//  MainMenu.m
//  babycornrun
//
//  Created by Jiang Yong on 3/1/2012.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectStage.h"
#import "GameScreen.h"
#import "Shop.h"
#import "SimpleAudioEngine.h"
#import "MKStoreManager.h"
#import "MBProgressHUD.h"

@implementation SelectStage

+(id) scene
{
    CCScene *scene = [CCScene node];
    
    SelectStage *layer = [SelectStage node];
    
    [scene addChild: layer];
    
    return scene;
}

#define STAGE_NUM   25
#define MARGINX_RATE    0.1f
#define MARGINY_RATE    0.12f
#define ROW_NUM         5
#define COL_NUM         5

#define STAGE_MENU_RATEX        0.75f

-(id) init
{   
    if( (self=[super init] )) {
        
        [self setTouchEnabled:YES];
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        if (gbMusicEnable)
        {
//            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
//            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu-music.mp3" loop:TRUE];
        }

        // backbround
        CCSprite *background;
        if (screenSize.width == 568 || screenSize.height == 568)
        {
            background = [CCSprite spriteWithFile:@"level_background_4inch.png"];
        }
        else
        {
            background = [CCSprite spriteWithFile:@"level_background.png"];
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
        menuBar.tag = 20001;
        [self addChild:menuBar];        
        
        //menu1
        CCSprite* spriteUnlockAllLevels = [CCSprite spriteWithFile:@"levelselect_unlock_all_levels.png"];
        CCSprite* spriteRemoveAds = [CCSprite spriteWithFile:@"levelselect_removeads.png"];
        CCSprite* spriteLevelSkips = [CCSprite spriteWithFile:@"levelselect_levelskips.png"];
      
        CCMenuItemSprite *menuItemUnlockAllLevels = [CCMenuItemSprite itemWithNormalSprite:spriteUnlockAllLevels selectedSprite:nil target:self selector:@selector(onUnlockAllLevels)];

        CCMenuItemSprite *menuItemRemoveAds = [CCMenuItemSprite itemWithNormalSprite:spriteRemoveAds selectedSprite:nil target:self selector:@selector(onRemoveAds)];

        CCMenuItemSprite *menuItemLevelSkips = [CCMenuItemSprite itemWithNormalSprite:spriteLevelSkips selectedSprite:nil target:self selector:@selector(onGetFreeSkip)];

        CCMenu * menu1 = [CCMenu menuWithItems:menuItemUnlockAllLevels, menuItemRemoveAds, menuItemLevelSkips, nil];
		[self addChild:menu1];
        
        float padding = (screenSize.height - menuBar.contentSize.height -  3 * spriteUnlockAllLevels.contentSize.height) / 4;
        [menu1 alignItemsVerticallyWithPadding:padding];
        menu1.position = ccp(screenSize.width * 0.12f, (screenSize.height + menuBar.contentSize.height) * 0.5f);
        
        //menu2
        CCSprite* spriteBack = [CCSprite spriteWithFile:@"menu_back.png"];
        CCSprite* spriteMoreGames = [CCSprite spriteWithFile:@"homepage_moregames.png"];
        CCSprite* spriteNewGames = [CCSprite spriteWithFile:@"homepage_newgames.png"];
        CCSprite* spriteExit = [CCSprite spriteWithFile:@"menu_exit.png"];        
        
        CCMenuItemSprite *menuItemBack = [CCMenuItemSprite itemWithNormalSprite:spriteBack selectedSprite:nil target:self selector:@selector(onBack)];
        CCMenuItemSprite *menuItemMoreGames = [CCMenuItemSprite itemWithNormalSprite:spriteMoreGames selectedSprite:nil target:self selector:@selector(onMoreGames)];
        CCMenuItemSprite *menuItemNewGames = [CCMenuItemSprite itemWithNormalSprite:spriteNewGames selectedSprite:nil target:self selector:@selector(onNewGames)];
        CCMenuItemSprite *menuItemExit = [CCMenuItemSprite itemWithNormalSprite:spriteExit selectedSprite:nil target:self selector:@selector(onLink)];
        
        CCMenu * menu2 = [CCMenu menuWithItems:menuItemBack, menuItemMoreGames, menuItemNewGames, menuItemExit, nil];
        padding = (screenSize.width - menuItemBack.contentSize.width - menuItemMoreGames.contentSize.width- menuItemNewGames.contentSize.width- menuItemExit.contentSize.width) / 5;
        [menu2 alignItemsHorizontallyWithPadding:padding];
        menu2.position = ccp(screenSize.width * 0.5f, menuBar.contentSize.height * 0.5f);
        
		[self addChild:menu2];
               
        // stages
        m_nHighScore = gnHighScore;
        m_nSkipLevel = 0;
      
//        [self showLevelScore];
        
        // stage menu
        int i;
        float marginX = (screenSize.width * STAGE_MENU_RATEX) * MARGINX_RATE;
        float marginY = (screenSize.height - menuBar.contentSize.height) * MARGINY_RATE;
        float stepX = (screenSize.width * STAGE_MENU_RATEX - 2 *  marginX) / (COL_NUM - 1) ;
        float stepY = (screenSize.height- menuBar.contentSize.height - 2 *  marginY) / (ROW_NUM - 1);
        stageMenuArray = [NSMutableArray arrayWithCapacity:STAGE_NUM];
        for (i = 0; i < STAGE_NUM; i++)
        {
            CCMenuItemImage *menuItem;
            if (gbLevelUnlock[i])
            {
                menuItem = [CCMenuItemImage itemWithNormalImage:@"levelselect_on.png" selectedImage:@"levelselect_on.png" target:self selector:@selector(onSelectStage:)];
            }
            else
            {
                menuItem = [CCMenuItemImage itemWithNormalImage:@"levelselect_off.png" selectedImage:@"levelselect_off.png" target:self selector:@selector(onSelectStage:)];
            }

//            [menuItem setNormalImage:[CCSprite spriteWithFile:@"levelselect_off.png"]];
//            [menuItem setSelectedImage:[CCSprite spriteWithFile:@"levelselect_off.png"]];

            if (gbLevelUnlock[i])
            {
                CCLabelTTF* levelscore = [self initLevelScore:i];
                levelscore.anchorPoint = ccp(0.5, 0.5);
                levelscore.position = ccp(menuItem.contentSize.width/2, menuItem.contentSize.height/2);
                levelscore.color = ccc3(255, 255, 255);
                [menuItem addChild:levelscore];
            }
            
            menuItem.tag = i + 1000;
            
            [stageMenuArray addObject:menuItem];
            
            menuItem.position = ccp(0, 0);
            
            if (gbLevelUnlock[i] == false)
            {
                menuItem.isEnabled = YES;
            }
        }
        
        menuStage = [CCMenu menuWithArray:stageMenuArray];
        [self addChild:menuStage];
        
        menuStage.position = ccp(screenSize.width * (1 - STAGE_MENU_RATEX - 0.03f), screenSize.height);
        
        // menu animation
        float duration = 0.8f;
        for ( i = STAGE_NUM - 1; i >= 0; i-- )
        {
            int nRow = (i) / COL_NUM;
            int nCol = (i) % COL_NUM;
            float posX = marginX + stepX * nCol;
            float posY = -marginY - stepY * nRow;
            
            CCMenuItem *menuItem = (CCMenuItem*)[menuStage getChildByTag:(i+1000)];
            duration += 0.02f;
            CCMoveTo *move = [CCMoveTo actionWithDuration:duration position:CGPointMake(posX, posY)];
            CCEaseIn *ease = [CCEaseIn actionWithAction:move rate:4];
            [menuItem runAction:ease];
        }
        
         
        [self loadBackgroundMusic];
    }
    
    return self;
}

#define DEF_Score_X         155
#define DEF_Score_Y         290
#define DEF_Score_OffsetX   72
#define DEF_Score_OffsetY   55
#define DEF_Screen_Width    480
#define DEF_Screen_Height   320

-(void) showLevelScore
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    float fFontSize = screenSize.height  / 320.0 * 15;
    for (int i = 0; i < LEVEL_COUNT; i++)
    {
        if (gbLevelUnlock[i] == false)
            continue;
        
        NSString* strScore = [NSString stringWithFormat:@"%d", gnLevelScore[i]];
        CCLabelTTF* levelscore = [CCLabelTTF labelWithString:strScore fontName:@"Arial" fontSize:fFontSize];
        levelscore.color = ccc3(255, 255, 255);
        int nRow = i / 5;
        int nCol = i % 5;
        
        float x = DEF_Score_X+nCol*DEF_Score_OffsetX; x = (screenSize.width / DEF_Screen_Width)*x;
        float y = DEF_Score_Y-nRow*DEF_Score_OffsetY; y = (screenSize.height / DEF_Screen_Height)*y;
        
        levelscore.position = ccp(x, y);
        [self addChild:levelscore z:10];

    }
}

-(CCLabelTTF*) initLevelScore: (int) nIndex
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    float fFontSize = screenSize.height  / 320.0 * 15;
    
    NSString* strScore = [NSString stringWithFormat:@"%d", gnLevelScore[nIndex]];
    CCLabelTTF* levelscore = [CCLabelTTF labelWithString:strScore fontName:@"Arial" fontSize:fFontSize];
    levelscore.color = ccc3(255, 255, 255);
    return levelscore;
}

- (void) onUnlockAllLevels
{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;

    CCSprite* sprBg;
    if (screenSize.height == 568 || screenSize.width == 568)
        sprBg = [CCSprite spriteWithFile:@"popup-bg-568h.png"];
    else
        sprBg = [CCSprite spriteWithFile:@"popup-bg.png"];
    sprBg.anchorPoint = ccp(0.5, 0);
    sprBg.position = ccp(screenSize.width/2, [self getChildByTag:20001].contentSize.height);
    sprBg.tag = 10003;
    [self addChild: sprBg z:10];

    CCSprite* spr = [CCSprite spriteWithFile:@"unlock-all-levels-pop-up.png"];
    spr.position = ccp(screenSize.width/2, screenSize.height/7*4);
    spr.tag = 10001;
    [self addChild: spr z:10];
    
    CCMenuItemImage* btnYes = [CCMenuItemImage itemWithNormalImage:@"level_yesplease.png" selectedImage:@"level_yesplease.png" target:self selector:@selector(onUnlockAllLevelsPurchase:)];
	btnYes.position = ccp(screenSize.width/8*3, screenSize.height/7*2);
    
    CCMenuItemImage* btnNoThanks = [CCMenuItemImage itemWithNormalImage:@"level_nothanks.png" selectedImage:@"level_nothanks.png" target:self selector:@selector(onClosePopup:)];
	btnNoThanks.position = ccp(screenSize.width/8*5, screenSize.height/7*2);
	
	CCMenu* myMenu1 = [CCMenu menuWithItems: btnYes, btnNoThanks, nil];
	myMenu1.position = ccp(0, 0);
    myMenu1.tag = 10002;
	[self addChild:myMenu1 z:11];
}

- (void) onLevelUnlock:(int)nLevel
{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    CCSprite* sprBg;
    if (screenSize.height == 568 || screenSize.width == 568)
        sprBg = [CCSprite spriteWithFile:@"popup-bg-568h.png"];
    else
        sprBg = [CCSprite spriteWithFile:@"popup-bg.png"];

    sprBg.anchorPoint = ccp(0.5, 0);
    sprBg.position = ccp(screenSize.width/2, [self getChildByTag:20001].contentSize.height);
    sprBg.tag = 10003;
    [self addChild: sprBg z:10];

    CCSprite* spr = nil;
    
    if (gnLevelSkips == 0)
        spr = [CCSprite spriteWithFile:@"level_skips.png"];
    else if (gnLevelSkips == 1)
        spr = [CCSprite spriteWithFile:@"level_skips_1.png"];
    else if (gnLevelSkips == 2)
        spr = [CCSprite spriteWithFile:@"level_skips_2.png"];
    else/* if (gnLevelSkips >= 3)*/
        spr = [CCSprite spriteWithFile:@"level_skips_3.png"];
    
    spr.position = ccp(screenSize.width/2, screenSize.height/7*4);
    spr.tag = 10001;
    [self addChild: spr z:10];
    
    m_nSkipLevel = nLevel;
    
    CCMenuItemImage* btnSkipLevels = [CCMenuItemImage itemWithNormalImage:@"level_yesplease.png" selectedImage:@"level_yesplease.png" target:self selector:@selector(onLevelSkips)];
	btnSkipLevels.position = ccp(screenSize.width/8*3, screenSize.height/7*2);
    
    CCMenuItemImage* btnNoThanks = [CCMenuItemImage itemWithNormalImage:@"level_nothanks.png" selectedImage:@"level_nothanks.png" target:self selector:@selector(onClosePlayOn:)];
	btnNoThanks.position = ccp(screenSize.width/8*5, screenSize.height/7*2);
	
	CCMenu* myMenu1 = [CCMenu menuWithItems: btnSkipLevels, btnNoThanks, nil];
	myMenu1.position = ccp(0, 0);
    myMenu1.tag = 10002;
	[self addChild:myMenu1 z:11];
}

-(void) onClosePlayOn: (id) sender{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    
    [self removeChildByTag:10001 cleanup:YES];
    [self removeChildByTag:10002 cleanup:YES];
    [self removeChildByTag:10003 cleanup:YES];
}

- (void) onLevelSkips
{
    AppController* del = (AppController*)[UIApplication sharedApplication].delegate;
    
    //	[AdColony playVideoAdForZone:AdColony_ZoneID withDelegate:nil withV4VCPrePopup:YES andV4VCPostPopup:YES];
    
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    
    [self onClosePlayOn : nil];
    
    if (gnLevelSkips > 0)
    {
        gnLevelSkips--;
        gbLevelUnlock[m_nSkipLevel] = true;
        [del saveInfo];
        [self procUnlockevels];

        
        return;
    }
    
    NSString* consumableId = userStatus6_hd;
    
    MyNavigationController* vc = del.navController;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
    [hud hide:true afterDelay:30];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    [[MKStoreManager sharedManager] buyFeature:consumableId
                                    onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt,SKPaymentTransaction* transaction)
     {
         [MBProgressHUD hideAllHUDsForView:vc.view animated:true];
         
         if([purchasedFeature isEqualToString:userStatus6_hd])
         {
             gnLevelSkips+=2;
             gbLevelUnlock[m_nSkipLevel] = true;
             [del saveInfo];
             [self procUnlockevels];
         }
         
     }
                                   onCancelled:^
     {
         [MBProgressHUD hideAllHUDsForView:vc.view animated:true];
         NSLog(@"User Cancelled Transaction");
     }];
}

-(void) onClosePopup: (id) sender{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    
    [self removeChildByTag:10001 cleanup:YES];
    [self removeChildByTag:10002 cleanup:YES];
    [self removeChildByTag:10003 cleanup:YES];
}

-(void) onUnlockAllLevelsPurchase: (id) sender
{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    
    [self onClosePopup:sender];
    
    NSString* nonconsumableId = @"";
    nonconsumableId = userStatus1_hd;
    
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
         
         if([purchasedFeature isEqualToString:userStatus1_hd])
         {
             gbIsUnlockAllLevels = true;
             for (int i = 0; i < LEVEL_COUNT; i++)
                 gbLevelUnlock[i] = true;
             [del saveInfo];
             [self procUnlockevels];
         }
         
     }
                                   onCancelled:^
     {
         [MBProgressHUD hideAllHUDsForView:vc.view animated:true];
         NSLog(@"User Cancelled Transaction");
     }];
}

-(void) procUnlockevels
{
    for (int i = 0; i < LEVEL_COUNT; i++)
    {
        if (gbLevelUnlock[i] == false)
            continue;
//        CCMenuItemImage *menuItem = [stageMenuArray objectAtIndex:i];
        CCMenuItemImage* menuItem = (CCMenuItemImage*)[menuStage getChildByTag:i+1000];
        CCSprite* sprNormal = [CCSprite spriteWithFile:@"levelselect_on.png"];
        [menuItem setNormalImage:sprNormal];
        CCSprite* sprSelected = [CCSprite spriteWithFile:@"levelselect_on.png"];
        [menuItem setSelectedImage:sprSelected];
        
        
//        CCMenuItemImage* menuItemNew = [CCMenuItemImage itemWithNormalImage:@"levelselect_on.png" selectedImage:@"levelselect_on.png" target:self selector:@selector(onSelectStage:)];
//        menuItemNew.position = menuItemOld.position;
//        menuItemNew.tag = menuItemOld.tag;
//        [menuStage addChild:menuItemNew];

//        menuItemOld.visible = FALSE;
//        [menuStage removeChild:menuItemOld cleanup:YES];
        
        CCLabelTTF* levelscore = [self initLevelScore:i];
        levelscore.anchorPoint = ccp(0.5, 0.5);
        levelscore.position = ccp(menuItem.contentSize.width/2, menuItem.contentSize.height/2);
        levelscore.color = ccc3(255, 255, 255);
        [menuItem addChild:levelscore];
    }
}

- (void) onRemoveAds
{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    NSString* nonconsumableId = @"";
    nonconsumableId = userStatus5_hd;
    
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
         
         if([purchasedFeature isEqualToString:userStatus5_hd])
         {
             gbIsRemoveAds = true;
             [del saveInfo];
         }
         
     }
                                   onCancelled:^
     {
         [MBProgressHUD hideAllHUDsForView:vc.view animated:true];
         NSLog(@"User Cancelled Transaction");
     }];
    
}

- (void) onGetFreeSkip
{
    AppController* del = (AppController*)[UIApplication sharedApplication].delegate;
	[AdColony playVideoAdForZone:AdColony_ZoneID withDelegate:del withV4VCPrePopup:YES andV4VCPostPopup:YES];

    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
}

- (void) onBack
{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    CCScene *scene = [Shop scene];
    CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0 scene:scene withColor:ccBLACK];
    [[CCDirector sharedDirector] replaceScene:ts];

}

- (void) onMoreGames
{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    [[Chartboost sharedChartboost] showMoreApps];
}

- (void) onNewGames
{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    AppController* appDel = (AppController*)[[UIApplication sharedApplication] delegate];
    [[PHPublisherContentRequest requestForApp:phtoken secret: phsecret placement: PlayHaven_PlacementID_5 delegate: appDel] send];
}

- (void) onLink
{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    NSURL *myURL = [NSURL URLWithString:@"http://georiot.co/2N9n"];
    if ([[UIApplication sharedApplication] canOpenURL:myURL]) {
        [[UIApplication sharedApplication] openURL:myURL];
    }
}

-(void) loadBackgroundMusic
{
//    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"waterBack.mp3" loop:YES];

}

- (void) onSelectStage:(CCMenuItem *)sender
{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
//    if ((soundState == soundOn) || (soundState == musicOff))
//        [[SimpleAudioEngine sharedEngine] playEffect:@"ButtondownFx.mp3"];

    int nTag = sender.tag - 1000;
    if (gbLevelUnlock[nTag] == false)
    {
        [self onLevelUnlock:nTag];
        return;
    }
    
    NSLog(@"selected level number %d", nTag);
    gnCurrentStage = nTag;
    
//    if (sender.tag == 1)
    {
//        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        
        CCScene *scene = [GameScreen scene]; 
        CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0 scene:scene withColor:ccBLACK];
        [[CCDirector sharedDirector] replaceScene:ts];
    } 
}


- (void) dealloc
{    
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end