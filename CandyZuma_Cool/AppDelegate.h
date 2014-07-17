//
//  AppDelegate.h
//  CandyZuma_Cool
//
//  Created by lion on 9/12/13.
//  Copyright MingGong 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "RevMobAds/RevMobAds.h"
#import "Chartboost.h"
#import <GameKit/GameKit.h>
#import "GameCenterManager.h"
#import "PlayHavenSDK.h"
#import <AdColony/AdColony.h>

#define REVMOB_ID  @"YOUR REVMOB ID"
#define kLeaderboardID @"com.yourbundleid.leaderboard"
#define phtoken @"YOUR PLAYHAVEN TOKEN"     // PlayHaven
#define phsecret @"YOUR PLAYHAVEN SECRET"    // PlayHaven
#define PlayHaven_PlacementID_1 @"game_launch"          // PlayHaven
#define PlayHaven_PlacementID_2 @"level_failed"         // PlayHaven
#define PlayHaven_PlacementID_3 @"pause_menu"           // PlayHaven
#define PlayHaven_PlacementID_4 @"level_complete"       // PlayHaven
#define PlayHaven_PlacementID_5 @"new_games"          // PlayHaven

/*      AdColony    */
#define kCurrencyBalance @"CurrencyBalance"
#define kCurrencyBalanceChange @"CurrencyBalanceChange"

#define kZoneLoading @"ZoneLoading"
#define kZoneReady @"ZoneReady"
#define kZoneOff @"ZoneOff"
#define AdColony_AppID @"YOUR ADCOLONY APP ID"
#define AdColony_ZoneID @"YOUR ADCOLONY ZONE ID"


@class GameCenterManager;

// Added only for iOS 6 support
@interface MyNavigationController : UINavigationController <CCDirectorDelegate>
@end

@interface AppController : NSObject <UIApplicationDelegate, RevMobAdsDelegate, ChartboostDelegate, PHAPIRequestDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, AdColonyDelegate, AdColonyAdDelegate,
    GameCenterManagerDelegate>
{
    GameCenterManager *gameCenterManager;
    int64_t  currentScore;
    NSString* currentLeaderBoard;
    
    NSError* lastError;
    bool isGameCenterAvailable;

	UIWindow *window_;
	MyNavigationController *navController_;

	CCDirectorIOS	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) MyNavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@property (nonatomic, retain) NSArray *permissions;
@property (nonatomic, retain) GameCenterManager *gameCenterManager;
@property (nonatomic, retain) NSString* currentLeaderBoard;

- (void) submitScore : (int) curScore;
- (void) checkAchievements :(int)checkType;
- (void) showLeaderboard;
- (void) showAchievements;
-(void) authenticate;

- (void) saveInfo;
- (void) loadInfo;
- (void)preloadPlayHaven;
-(void)showRevmob;
-(void)showCharboost;
-(void)showPlayhaven:(NSString*) strPlacement;

- (void)requestDidFinishLoading:(PHAPIRequest *)request;
- (void)request:(PHAPIRequest *)request didSucceedWithResponse:(NSDictionary *)responseData;
- (void)request:(PHAPIRequest *)request didFailWithError:(NSError *)error;

@end
