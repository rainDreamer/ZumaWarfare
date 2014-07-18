//
//  AppDelegate.m
//  CandyZuma_Cool
//
//  Created by lion on 9/12/13.
//  Copyright MingGong 2013. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
//#import "IntroLayer.h"
#import "MainMenu.h"
#import "Global.h"
#import "MKStoreManager.h"
#import "SimpleAudioEngine.h"

@implementation MyNavigationController

// The available orientations should be defined in the Info.plist file.
// And in iOS 6+ only, you can override it in the Root View controller in the "supportedInterfaceOrientations" method.
// Only valid for iOS 6+. NOT VALID for iOS 4 / 5.
-(NSUInteger)supportedInterfaceOrientations {
	
	// iPhone only
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
		return UIInterfaceOrientationMaskLandscape;
	
	// iPad only
	return UIInterfaceOrientationMaskLandscape;
}

// Supported orientations. Customize it for your own needs
// Only valid on iOS 4 / 5. NOT VALID for iOS 6.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// iPhone only
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	
	// iPad only
	// iPhone only
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil) {
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
		[director runWithScene: [MainMenu scene]];
	}
}
@end

#import <Parse/Parse.h>
#import "TestFlight.h"
#import "Flurry.h"

@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;
@synthesize gameCenterManager;
@synthesize currentLeaderBoard;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"DDNBSZSFHBDQ8G7N8TVN"];
    [TestFlight takeOff:@"3b9e146b-55ce-4c6e-b970-1c23e0b1756a"];
    [Parse setApplicationId:@"69kMuSNyvz3uwA7RjtxASTe3Eyc7kejSf1CUOEZ4"
                  clientKey:@"TEDZbQ8f3NRLZvgbqKVSSrMU1QtZRxdKN2O4uedN"];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    [RevMobAds startSessionWithAppID:REVMOB_ID];
    [MKStoreManager sharedManager];
    
    self.currentLeaderBoard = kLeaderboardID;
    
    if ([GameCenterManager isGameCenterAvailable]) {
        isGameCenterAvailable = YES;
        self.gameCenterManager = [[[GameCenterManager alloc] init] autorelease];
        [self.gameCenterManager setDelegate:self];
        [self.gameCenterManager authenticateLocalUser];
        
    } else {
        isGameCenterAvailable = NO;
        // The current device does not support Game Center.
        
    }

	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	
	// CCGLView creation
	// viewWithFrame: size of the OpenGL view. For full screen use [_window bounds]
	//  - Possible values: any CGRect
	// pixelFormat: Format of the render buffer. Use RGBA8 for better color precision (eg: gradients). But it takes more memory and it is slower
	//	- Possible values: kEAGLColorFormatRGBA8, kEAGLColorFormatRGB565
	// depthFormat: Use stencil if you plan to use CCClippingNode. Use Depth if you plan to use 3D effects, like CCCamera or CCNode#vertexZ
	//  - Possible values: 0, GL_DEPTH_COMPONENT24_OES, GL_DEPTH24_STENCIL8_OES
	// sharegroup: OpenGL sharegroup. Useful if you want to share the same OpenGL context between different threads
	//  - Possible values: nil, or any valid EAGLSharegroup group
	// multiSampling: Whether or not to enable multisampling
	//  - Possible values: YES, NO
	// numberOfSamples: Only valid if multisampling is enabled
	//  - Possible values: 0 to glGetIntegerv(GL_MAX_SAMPLES_APPLE)
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565
								   depthFormat:0
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
	
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
//	[director_ setDisplayStats:YES];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/90];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director_ setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
    {
        [director_ enableRetinaDisplay:YES];
    }
    else
    {
        [director_ enableRetinaDisplay:NO];
    }
    
//	if( ! [director_ enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change this setting at any time.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
    [self loadInfo];

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// Create a Navigation Controller with the Director
	navController_ = [[MyNavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;

	// for rotation and other messages
	[director_ setDelegate:navController_];
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];
	
    if (gbMusicEnable)
    {
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu-music.mp3" loop:TRUE];
    }

    [[PHPublisherOpenRequest requestForApp:phtoken secret:phsecret] send];
//    [[PHPublisherContentRequest requestForApp:phtoken secret: phsecret placement: PlayHaven_PlacementID_1 delegate: self] send];
    [self preloadPlayHaven];

    [AdColony configureWithAppID:AdColony_AppID zoneIDs:@[AdColony_ZoneID] delegate:self logging:YES];

    Chartboost* cb = [Chartboost sharedChartboost];
    cb.appId = @"53c7e6c51873da0f92f97b7a";
    cb.appSignature = @"3c07b0ceab00637fa0e9a5c8765ca095299fed97";
    cb.delegate = self;
    [cb startSession];
    //    [cb cacheInterstitial];
    [cb cacheMoreApps];
    [self showRevmob];
    [self showCharboost];
    [self showPlayhaven:PlayHaven_PlacementID_1];

	return YES;
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

- (void) submitScore : (int) curScore
{
    if(curScore > 0)
    {
        [self.gameCenterManager reportScore: curScore forCategory: self.currentLeaderBoard];
    }
}

- (void) loadInfo
{
    NSUserDefaults* defaultData = [NSUserDefaults standardUserDefaults];
    gbFirstLaunch = ![defaultData boolForKey:@"FirstLaunch"];
    gnCurrentStage = [defaultData integerForKey:@"CurrentStage"];
    gnHighScore = [defaultData integerForKey:@"HighScore"];
    gnLevelSkips = [defaultData integerForKey:@"LevelSkipsCount"];
    gbMusicEnable = ![defaultData boolForKey:@"MusicDisable"];
    gbSoundEnable = ![defaultData boolForKey:@"SoundDisable"];
    /*gbIsCharacter1Locked = ![defaultData boolForKey:@"Character1Locked"];*/ gbIsCharacter1Locked = false;
    gbIsCharacter2Locked = ![defaultData boolForKey:@"Character2Locked"];
    gbIsCharacter3Locked = ![defaultData boolForKey:@"Character3Locked"];
    gnSelectedCharacter = [defaultData integerForKey:@"SelectedCharacter"];
    gbIsUnlockAllCharacters = [defaultData boolForKey:@"UnlockAllCharacters"];
    gbIsUnlockAllLevels = [defaultData boolForKey:@"UnlockAllLevels"];
    gbIsRemoveAds = [defaultData boolForKey:@"RemoveAds"];
//    gbIsLevelSkips = [defaultData boolForKey:@"LevelSkips"];
    
    for (int i = 0; i < LEVEL_COUNT; i++)
    {
        gnLevelScore[i] = [defaultData integerForKey:[NSString stringWithFormat:@"Level%dScore",i]];
        gbLevelUnlock[i] = [defaultData boolForKey:[NSString stringWithFormat:@"Level%dUnlock",i]];
    }
    
    if (gbIsUnlockAllLevels)
    {
        for (int i = 0; i < LEVEL_COUNT; i++)
        {
            gbLevelUnlock[i] = true;
        }
    }
    
    gbLevelUnlock[0] = true;
}

- (void) saveInfo
{
    gnHighScore = 0;
    for (int i = 0; i < LEVEL_COUNT; i++)
    {
        gnHighScore +=gnLevelScore[i];
    }
    [self submitScore:gnHighScore];
    
    NSUserDefaults* defaultData = [NSUserDefaults standardUserDefaults];
    [defaultData setBool:!gbFirstLaunch forKey:@"FirstLaunch"];
    [defaultData setInteger:gnCurrentStage forKey:@"CurrentStage"];
    [defaultData setInteger:gnLevelSkips forKey:@"LevelSkipsCount"];
    [defaultData setInteger:gnHighScore forKey:@"HighScore"];
    [defaultData setBool:!gbMusicEnable forKey:@"MusicDisable"];
    [defaultData setBool:!gbSoundEnable forKey:@"SoundDisable"];
    [defaultData setBool:!gbIsCharacter1Locked forKey:@"Character1Locked"];
    [defaultData setBool:!gbIsCharacter2Locked forKey:@"Character2Locked"];
    [defaultData setBool:!gbIsCharacter3Locked forKey:@"Character3Locked"];
    [defaultData setInteger:gnSelectedCharacter forKey:@"SelectedCharacter"];
    [defaultData setBool:gbIsUnlockAllCharacters forKey:@"UnlockAllCharacters"];
    [defaultData setBool:gbIsUnlockAllLevels forKey:@"UnlockAllLevels"];
    [defaultData setBool:gbIsRemoveAds forKey:@"RemoveAds"];
//    [defaultData setBool:gbIsLevelSkips forKey:@"LevelSkips"];

    for (int i = 0; i < LEVEL_COUNT; i++)
    {
        [defaultData setInteger:gnLevelScore[i] forKey:[NSString stringWithFormat:@"Level%dScore",i]];
        [defaultData setBool:gbLevelUnlock[i] forKey:[NSString stringWithFormat:@"Level%dUnlock",i]];
    }
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
    self.gameCenterManager = nil;
    self.currentLeaderBoard = nil;
    [self saveInfo];
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)preloadPlayHaven
{
    [[PHPublisherContentRequest requestForApp: phtoken secret: phsecret placement: @"nag_on_return_to_front" delegate: self] preload];
}

- (void) dealloc
{
	[window_ release];
	[navController_ release];
    [gameCenterManager release];
    [currentLeaderBoard release];

	[super dealloc];
}

-(void)showPlayhaven:(NSString*) strPlacement
{
    if (!gbIsRemoveAds)
    {
        [[PHPublisherContentRequest requestForApp:phtoken secret: phsecret placement: strPlacement delegate: self] send];
    }
}

-(void)showRevmob
{
    if (!gbIsRemoveAds)
    {
        [[RevMobAds session] showFullscreen];
    }
}

-(void)showCharboost
{
    if (!gbIsRemoveAds)
    {
        [[Chartboost sharedChartboost] showInterstitial];
//        [[Chartboost sharedChartboost] showMoreApps];
    }
}

- (void)requestDidFinishLoading:(PHAPIRequest *)request
{
}

- (void)request:(PHAPIRequest *)request didSucceedWithResponse:(NSDictionary *)responseData
{
}

- (void)request:(PHAPIRequest *)request didFailWithError:(NSError *)error
{
}
/*
- (BOOL)shouldRequestInterstitial:(NSString *)location{
    return YES;
}

// Called when an interstitial has been received, before it is presented on screen
// Return NO if showing an interstitial is currently innapropriate, for example if the user has entered the main game mode.
- (BOOL)shouldDisplayInterstitial:(NSString *)location{
    return YES;
}

// Called when an interstitial has been received and cached.
- (void)didCacheInterstitial:(NSString *)location{
    int i = 0;
}

// Called when an interstitial has failed to come back from the server
- (void)didFailToLoadInterstitial:(NSString *)location{
    int i =0;
}

// Called when the user dismisses the interstitial
// If you are displaying the add yourself, dismiss it now.
- (void)didDismissInterstitial:(NSString *)location{
    int i = 0;
}

// Same as above, but only called when dismissed for a close
- (void)didCloseInterstitial:(NSString *)location{
    int i = 0;
}

// Same as above, but only called when dismissed for a click
- (void)didClickInterstitial:(NSString *)location{
    int i = 0;
}


// Called before requesting the more apps view from the back-end
// Return NO if when showing the loading view is not the desired user experience.
- (BOOL)shouldDisplayLoadingViewForMoreApps{
    return NO;
}

// Called when an more apps page has been received, before it is presented on screen
// Return NO if showing the more apps page is currently innapropriate
- (BOOL)shouldDisplayMoreApps{
    return YES;
}

// Called when the More Apps page has been received and cached
- (void)didCacheMoreApps{
    int i = 0;
    
}

// Called when a more apps page has failed to come back from the server
- (void)didFailToLoadMoreApps{
    
    int i = 0;
}

// Called when the user dismisses the more apps view
// If you are displaying the add yourself, dismiss it now.
- (void)didDismissMoreApps{
    int i = 0;
    
}

// Same as above, but only called when dismissed for a close
- (void)didCloseMoreApps{
    int i = 0;
    
}

// Same as above, but only called when dismissed for a click
- (void)didClickMoreApps{
    int i = 0;
}



// Whether Chartboost should show ads in the first session
// Defaults to YES
- (BOOL)shouldRequestInterstitialsInFirstSession{
    return YES;
}
*/

#pragma mark AdColony V4VC

// Callback activated when a V4VC currency reward succeeds or fails
// This implementation is designed for client-side virtual currency without a server
// It uses NSUserDefaults for persistent client-side storage of the currency balance
// For applications with a server, contact the server to retrieve an updated currency balance
// On success, posts an NSNotification so the rest of the app can update the UI
// On failure, posts an NSNotification so the rest of the app can disable V4VC UI elements
- ( void ) onAdColonyV4VCReward:(BOOL)success currencyName:(NSString*)currencyName currencyAmount:(int)amount inZone:(NSString*)zoneID {
	NSLog(@"AdColony zone %@ reward %i %i %@", zoneID, success, amount, currencyName);
	
	if (success) {

        gnLevelSkips++;
		
		// Post a notification so the rest of the app knows the balance changed
		[[NSNotificationCenter defaultCenter] postNotificationName:kCurrencyBalanceChange object:nil];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:kZoneOff object:nil];
	}
}

#pragma mark -
#pragma mark AdColony ad fill

- ( void ) onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString*) zoneID {
	if(available) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kZoneReady object:nil];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:kZoneLoading object:nil];
	}
}


- ( void ) onAdColonyAdStartedInZone:( NSString * )zoneID
{
    if (gbMusicEnable)
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
}

- ( void ) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID
{
    if (gbMusicEnable)
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

#pragma mark - Push Notification
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}
@end
