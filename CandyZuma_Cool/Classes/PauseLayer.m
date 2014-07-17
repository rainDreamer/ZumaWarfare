//
//  PauseLayer.m
//  CandyZuma_Cool
//
//  Created by lion on 9/12/13.
//  Copyright MingGong 2013. All rights reserved.
//


// Import the interfaces
#import "PauseLayer.h"
#import "GameScreen.h"
#import "SimpleAudioEngine.h"
#import "Global.h"
#import "MKStoreManager.h"
#import "MBProgressHUD.h"

#pragma mark - PauseLayer

const float  DEF_Screen_Width    = 480;
const float  DEF_Screen_Height   = 320;

const int DEF_Background_Y      = 20;
const int DEF_MusicButton_X     = 303;
const int DEF_MusicButton_Y     = 95;
const int DEF_SoundButton_X     = 310;
const int DEF_SoundButton_Y     = 140;

const int DEF_Resume_X          = 290;
const int DEF_Resume_Y          = 190;
const int DEF_Restart_X         = 213;
const int DEF_Restart_Y         = 95;
const int DEF_Home_X            = 200;
const int DEF_Home_Y            = 140;

const int DEF_RemoveAds_X       = 120;
const int DEF_RemoveAds_Y       = 245;
const int DEF_GetFreeGames_X    = 240;
const int DEF_GetFreeGames_Y    = 245;
const int DEF_UnlockAllLevels_X = 360;
const int DEF_UnlockAllLevels_Y = 245;

// HelloWorldLayer implementation
@implementation PauseLayer

-(void) initVariable
{
    m_bMusicOpen = true;
    m_bSoundOpen = true;
}

// 
-(id) init
{
	if( (self=[super init])) {
        [self initVariable];

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];

        xRate = size.width / DEF_Screen_Width;
        yRate = size.height / DEF_Screen_Height;
        
        if (size.width == DEF_Screen_Width)
            yRate = 1;
        
		CCSprite *background;
		
        
        if (size.width == 568 || size.height == 568)
        {
            background = [CCSprite spriteWithFile:@"pause_screen_568h.png"];
        }
        else
        {
            background = [CCSprite spriteWithFile:@"pause_screen.png"];
        }
		background.position = ccp(size.width/2, size.height/2+DEF_Background_Y);

        if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        {
            background.position = ccp(background.position.x, background.position.y - 10);
        }

		// add the label as a child to this Layer
		[self addChild: background];
        
        m_itemMusic = [CCMenuItemImage itemWithNormalImage:@"music_on.png" selectedImage:@"music_off.png" target:self selector:@selector(onMusic:)];
        if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        {
            m_itemMusic.position = ccp((DEF_MusicButton_X+2)*xRate, DEF_MusicButton_Y*yRate);
        }
        else
        {
            m_itemMusic.position = ccp(DEF_MusicButton_X*xRate, DEF_MusicButton_Y*yRate);
        }
        m_itemSound = [CCMenuItemImage itemWithNormalImage:@"sounds_on.png" selectedImage:@"sounds_off.png" target:self selector:@selector(onSound:)];
        m_itemSound.position = ccp(DEF_SoundButton_X*xRate, DEF_SoundButton_Y*yRate);
        
        CCMenu* myMenu1 = [CCMenu menuWithItems: m_itemMusic, m_itemSound, nil];
        myMenu1.position = ccp(0, 0);
        [self addChild:myMenu1 z:7];
        
        CCMenuItemImage *itemResume = [CCMenuItemImage itemWithNormalImage:@"pause_resume.png" selectedImage:@"pause_resume.png" target:self selector:@selector(onResume:)];
//        itemResume.anchorPoint = ccp(1,0.5);
        itemResume.position = ccp(size.width/2, DEF_Resume_Y*yRate);
        CCMenuItemImage *itemRestart = [CCMenuItemImage itemWithNormalImage:@"pause_restart.png" selectedImage:@"pause_restart.png" target:self selector:@selector(onRestart:)];
        itemRestart.anchorPoint = ccp(1,0.5);
        if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        {
            
            if (size.width == 568 || size.height == 568)
            {
                itemRestart.position = ccp(DEF_Restart_X*xRate-5, DEF_Restart_Y*yRate);
            }
            else
            {
                itemRestart.position = ccp(DEF_Restart_X*xRate-2, DEF_Restart_Y*yRate);
            }
        }
        else
        {
            itemRestart.position = ccp(DEF_Restart_X*xRate, DEF_Restart_Y*yRate);
        }
        CCMenuItemImage *itemHome = [CCMenuItemImage itemWithNormalImage:@"pause_home.png" selectedImage:@"pause_home.png" target:self selector:@selector(onHome:)];
        itemHome.anchorPoint = ccp(1,0.5);
        itemHome.position = ccp(DEF_Home_X*xRate, DEF_Home_Y*yRate);
        
        CCMenu* myMenu2 = [CCMenu menuWithItems: itemResume, itemRestart, itemHome, nil];
        myMenu2.position = ccp(0, 0);
        [self addChild:myMenu2 z:7];
        
        CCMenuItemImage *itemRemoveAds = [CCMenuItemImage itemWithNormalImage:@"pause_removeads.png" selectedImage:@"pause_removeads.png" target:self selector:@selector(onRemoveAds:)];
        itemRemoveAds.position = ccp(DEF_RemoveAds_X*xRate, DEF_RemoveAds_Y*yRate);
        CCMenuItemImage *itemGetFreeGames = [CCMenuItemImage itemWithNormalImage:@"pause_getfreegames.png" selectedImage:@"pause_getfreegames.png" target:self selector:@selector(onNewGames:)];
        itemGetFreeGames.position = ccp(DEF_GetFreeGames_X*xRate, DEF_GetFreeGames_Y*yRate);
        CCMenuItemImage *itemUnlockAllLevels = [CCMenuItemImage itemWithNormalImage:@"pause_unlock_all_levels.png" selectedImage:@"pause_unlock_all_levels.png" target:self selector:@selector(onUnlockAllLevels:)];
        itemUnlockAllLevels.position = ccp(DEF_UnlockAllLevels_X*xRate, DEF_UnlockAllLevels_Y*yRate);
        CCMenu* myMenu3 = [CCMenu menuWithItems: itemRemoveAds, itemGetFreeGames, itemUnlockAllLevels, nil];
        myMenu3.position = ccp(0, 0);
        [self addChild:myMenu3 z:7];
  
        
        // menu bar
        CCSprite* menuBar;
        if (size.width == 568 || size.height == 568)
        {
            menuBar = [CCSprite spriteWithFile:@"menubar_4inch.png"];
        }
        else
        {
            menuBar = [CCSprite spriteWithFile:@"menubar.png"];
        }
        menuBar.anchorPoint = ccp(0.5f, 0);
        menuBar.position = ccp(size.width * 0.5f, 0);
        [self addChild:menuBar z:7];

	        // menu bar
        CCMenuItemSprite *menuItemLevelSkips = [CCMenuItemImage itemWithNormalImage:@"menu_levelskips.png" selectedImage:nil target:self selector:@selector(onLevelSkips:)];
        CCMenuItemSprite *menuItemMoreGames = [CCMenuItemImage itemWithNormalImage:@"homepage_moregames.png" selectedImage:nil target:self selector:@selector(onMoreGames:)];
        CCMenuItemSprite *menuItemNewGames = [CCMenuItemImage itemWithNormalImage:@"homepage_newgames.png" selectedImage:nil target:self selector:@selector(onNewGames:)];
        CCMenuItemSprite *menuItemExit = [CCMenuItemImage itemWithNormalImage:@"menu_exit.png" selectedImage:nil target:self selector:@selector(onLink:)];
        
        
        CCMenu * menu4 = [CCMenu menuWithItems:menuItemLevelSkips, menuItemMoreGames, menuItemNewGames, menuItemExit, nil];
        
        float padding = (size.width - menuItemLevelSkips.contentSize.width - menuItemMoreGames.contentSize.width- menuItemNewGames.contentSize.width- menuItemExit.contentSize.width) / 5;
        [menu4 alignItemsHorizontallyWithPadding:padding];
        menu4.position = ccp(size.width * 0.5f, menuBar.contentSize.height * 0.5f);
        
		[self addChild:menu4 z:7];


	}
	
	return self;
}

-(void) setMusicEnable:(bool)bEnable
{
    m_bMusicOpen = !bEnable;
    [self onMusic:NULL];
}
-(void) setSoundEnable:(bool)bEnable
{
    m_bSoundOpen = !bEnable;
    [self onSound:NULL];
}

-(void) onMusic: (id) sender{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    if (m_bMusicOpen)
    {
        [m_itemMusic initWithNormalImage: @"music_off.png" selectedImage:@"music_on.png" disabledImage: @"music_off.png" target:self selector:@selector(onMusic:)];
        if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        {
            m_itemMusic.position = ccp((DEF_MusicButton_X+2)*xRate, DEF_MusicButton_Y*yRate);
        }
        else
        {
            m_itemMusic.position = ccp(DEF_MusicButton_X*xRate, DEF_MusicButton_Y*yRate);
        }
//        m_itemMusic.position = ccp(DEF_MusicButton_X*xRate, DEF_MusicButton_Y*yRate);
    }
    else
    {
        [m_itemMusic initWithNormalImage: @"music_on.png" selectedImage:@"music_off.png" disabledImage: @"music_on.png" target:self selector:@selector(onMusic:)];
        if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        {
            m_itemMusic.position = ccp((DEF_MusicButton_X+2)*xRate, DEF_MusicButton_Y*yRate);
        }
        else
        {
            m_itemMusic.position = ccp(DEF_MusicButton_X*xRate, DEF_MusicButton_Y*yRate);
        }
//        m_itemMusic.position = ccp(DEF_MusicButton_X*xRate, DEF_MusicButton_Y*yRate);
    }
    m_bMusicOpen = !m_bMusicOpen;
    if (sender != NULL)
    {
        GameScreen* pParent = (GameScreen*)[self parent];
        [pParent setBackgroundMusicEnable:m_bMusicOpen];
    }
}

-(void) onSound: (id) sender{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    if (m_bSoundOpen)
    {
        [m_itemSound initWithNormalImage: @"sounds_off.png" selectedImage:@"sounds_on.png" disabledImage: @"sounds_off.png" target:self selector:@selector(onSound:)];
        m_itemSound.position = ccp(DEF_SoundButton_X*xRate, DEF_SoundButton_Y*yRate);
    }
    else
    {
        [m_itemSound initWithNormalImage: @"sounds_on.png" selectedImage:@"sounds_off.png" disabledImage: @"sounds_on.png" target:self selector:@selector(onSound:)];
        m_itemSound.position = ccp(DEF_SoundButton_X*xRate, DEF_SoundButton_Y*yRate);
    }
    m_bSoundOpen = !m_bSoundOpen;
    
    if (sender != NULL)
    {
        GameScreen* pParent = (GameScreen*)[self parent];
        [pParent setEffectMusicEnable:m_bSoundOpen];
    }
}

-(void) onResume: (id) sender{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    GameScreen* pParent = (GameScreen*)[self parent];
    [self setVisible:FALSE];
    [pParent setContinue];
}

-(void) onRestart: (id) sender{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    GameScreen* pParent = (GameScreen*)[self parent];
    [self setVisible:FALSE];
    [pParent restartGame];
}

-(void) onHome: (id) sender{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    GameScreen* pParent = (GameScreen*)[self parent];
    [self setVisible:FALSE];
    [pParent gotoHome];
}

-(void) onRemoveAds: (id) sender
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

- (void) onLevelSkips: (id) sender
{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    
    GameScreen* pParent = (GameScreen*)[self parent];
    [pParent onPlayOn:sender];

}

- (void) onMoreGames: (id) sender
{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    [[Chartboost sharedChartboost] showMoreApps];
}

- (void) onNewGames: (id) sender
{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    AppController* appDel = (AppController*)[[UIApplication sharedApplication] delegate];
    [[PHPublisherContentRequest requestForApp:phtoken secret: phsecret placement: PlayHaven_PlacementID_5 delegate: appDel] send];
}

- (void) onLink: (id) sender
{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    NSURL *myURL = [NSURL URLWithString:@"http://georiot.co/2N9n"];
    if ([[UIApplication sharedApplication] canOpenURL:myURL]) {
        [[UIApplication sharedApplication] openURL:myURL];
    }
}

-(void) onUnlockAllLevels: (id) sender
{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
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
             {
                 gbLevelUnlock[i] = true;
             }
             [del saveInfo];
         }
         
     }
                                   onCancelled:^
     {
         [MBProgressHUD hideAllHUDsForView:vc.view animated:true];
         NSLog(@"User Cancelled Transaction");
     }];
}

- (void) dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    
	[super dealloc];
}

@end
