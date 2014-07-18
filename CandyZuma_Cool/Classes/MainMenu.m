//
//  MainMenu.m
//  babycornrun
//
//  Created by Jiang Yong on 3/1/2012.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "SelectStage.h"
#import "GameScreen.h"
#import "Shop.h"
#import "AppDelegate.h"
#import "SimpleAudioEngine.h"

@implementation MainMenu

+(id) scene
{
    CCScene *scene = [CCScene node];
    
    MainMenu *layer = [MainMenu node];
    
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
            background = [CCSprite spriteWithFile:@"homepage_background_4inch.png"];
        }
        else
        {
            background = [CCSprite spriteWithFile:@"homepage_background.png"];
        }        
        background.position = ccp(screenSize.width * 0.5f, screenSize.height * 0.5f);
        [self addChild:background];
        
        CCSprite* sprLogoMark = [CCSprite spriteWithFile:@"logo_mark.png"];
        sprLogoMark.position = ccp(screenSize.width/4*3, screenSize.height/4*3);
        [self addChild:sprLogoMark];
        
        // let's start and shop
        int nMenuPosX;
        int nMenuPosY;

        CCSprite* spriteLetsStart = [CCSprite spriteWithFile:@"lets_start.png"];
//        CCSprite* spriteShop = [CCSprite spriteWithFile:@"shop.png"];
        
        menuItemLetsStart = [CCMenuItemSprite itemWithNormalSprite:spriteLetsStart selectedSprite:nil target:self selector:@selector(onLetsStart)];
        
        nMenuPosX = 0.23f * screenSize.width;
        nMenuPosY = -0.15f * screenSize.height;
        menuItemLetsStart.position = ccp(nMenuPosX, nMenuPosY);
        
//        CCMenuItemSprite *menuItemShop = [CCMenuItemSprite itemWithNormalSprite:spriteShop selectedSprite:nil target:self selector:@selector(onShop)];
//        nMenuPosX = 0.25f * screenSize.width;
//        nMenuPosY = -0.15f * screenSize.height;
//        menuItemShop.position = ccp(nMenuPosX, nMenuPosY);

        CCMenu * menu1 = [CCMenu menuWithItems:menuItemLetsStart,/* menuItemShop,*/ nil];
        menu1.position = ccp(screenSize.width/2, screenSize.height/2);
		[self addChild:menu1];
        
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
        
        //menus        
        CCSprite* spriteMoreGames = [CCSprite spriteWithFile:@"homepage_moregames.png"];
        CCSprite* spriteNewGames = [CCSprite spriteWithFile:@"homepage_newgames.png"];
        CCSprite* spriteLeaderBoards = [CCSprite spriteWithFile:@"homepage_leaderboards.png"];
        CCSprite* spriteExit = [CCSprite spriteWithFile:@"menu_exit.png"];        
        
        CCMenuItemSprite *menuItemMoreGames = [CCMenuItemSprite itemWithNormalSprite:spriteMoreGames selectedSprite:nil target:self selector:@selector(onMoreGames)];
        CCMenuItemSprite *menuItemNewGames = [CCMenuItemSprite itemWithNormalSprite:spriteNewGames selectedSprite:nil target:self selector:@selector(onNewGames)];
        CCMenuItemSprite *menuItemLeaderBoards = [CCMenuItemSprite itemWithNormalSprite:spriteLeaderBoards selectedSprite:nil target:self selector:@selector(onLeaderBoards)];
        CCMenuItemSprite *menuItemExit = [CCMenuItemSprite itemWithNormalSprite:spriteExit selectedSprite:nil target:self selector:@selector(onLink)];

        CCMenu * menu2 = [CCMenu menuWithItems:menuItemMoreGames, menuItemNewGames, menuItemLeaderBoards, menuItemExit, nil];
       
        float padding = (screenSize.width - menuItemMoreGames.contentSize.width - menuItemNewGames.contentSize.width- menuItemLeaderBoards.contentSize.width- menuItemExit.contentSize.width) / 5;
        [menu2 alignItemsHorizontallyWithPadding:padding];
        menu2.position = ccp(screenSize.width * 0.5f, menuBar.contentSize.height * 0.5f);
        
		[self addChild:menu2];
        
        [self actionPlayButton];
    }
    
    return self;
}

-(void) actionPlayButton
{
    CCScaleTo* increaseScale = [CCScaleTo actionWithDuration:0.5 scaleX:1.1 scaleY:1.05];
    CCScaleTo* decreaseScale = [CCScaleTo actionWithDuration:0.5 scaleX:0.9 scaleY:0.95];
    id seq = [CCSequence actions:increaseScale, decreaseScale, nil];
    id action = [CCRepeatForever actionWithAction:seq];
    
    [menuItemLetsStart runAction:action];
}

- (void) onLetsStart
{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    
    CCScene *scene;
//    if (gbFirstLaunch)
    {
        scene = [Shop scene];
        gbFirstLaunch = false;
        NSUserDefaults* defaultData = [NSUserDefaults standardUserDefaults];
        [defaultData setBool:!gbFirstLaunch forKey:@"FirstLaunch"];
    }
//    else
//        scene = [SelectStage scene];
    CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0 scene:scene withColor:ccBLACK];
    [[CCDirector sharedDirector] replaceScene:ts];
    
    // temperary
//    CCScene *scene = [GameScreen scene];
//    CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:1.0 scene:scene withColor:ccBLACK];
//    [[CCDirector sharedDirector] replaceScene:ts];

}

- (void) onShop
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
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
//    [[RevMobAds session] openAdLinkWithDelegate: appDel];
    AppController* appDel = (AppController*)[[UIApplication sharedApplication] delegate];
    [[PHPublisherContentRequest requestForApp:phtoken secret: phsecret placement: PlayHaven_PlacementID_5 delegate: appDel] send];

}

- (void) onLeaderBoards
{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    AppController* appDel = (AppController*)[[UIApplication sharedApplication] delegate];
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = appDel;
    leaderboardViewController.timeScope = GKLeaderboardTimeScopeAllTime;

    [[appDel navController] presentModalViewController:leaderboardViewController animated:YES];
    
    [leaderboardViewController release];
}

- (void) onLink
{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    NSURL *myURL = [NSURL URLWithString:@"https://itunes.apple.com/us/artist/intence-media/id592330573?mt=8&uo=4&at=10lJ9a"];
    if ([[UIApplication sharedApplication] canOpenURL:myURL]) {
        [[UIApplication sharedApplication] openURL:myURL];
    }
}

- (void) dealloc
{    
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end