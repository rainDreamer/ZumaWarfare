//
//  GameScreen.h
//  IceCreamDriver

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "StoreKit/StoreKit.h"
#import "AppDelegate.h"
#import "MathLayer.h"
#import "LevelData.h"
#import "PauseLayer.h"

@interface GameScreen : MathLayer <AVAudioPlayerDelegate>{
    
	AVAudioPlayer*      backgroundMusic;
	AppController*      del;
    LevelData*          m_parseOperation;       // loading leve data from XML
    PauseLayer*         m_layerPause;
    
    NSMutableArray*     m_sprBallArray;         // ball array
    NSMutableArray*     m_BallPosIndex;         // ball position array
    NSMutableArray*     m_BallColorArray;       // ball color array

    CCSprite*           m_sprFires[20][10];     // When the game is completed, these sprites are shown and animated.
    CCSprite*           m_sprBomb[3][3];        // [x][y]:x means the count of bomb kind. y means the count of animation of one bomb.
    CCSprite*           m_sprShooter;           // character image
    CCSprite*           m_sprShootBall;         // the image of ball to shoot from character to trace
    CCSprite*           m_sprFlyingBall;        // the image of ball being flying from character to trace
    
    CCMenuItemImage*    m_btnPause;             // pause button standing on right top corner of screen

    CCLabelTTF          *m_lblShadowScore;      // label for showing the score
    CCLabelTTF          *m_lblScore;            // label for showing the score
    CCLabelTTF          *m_lblShadowLevelSkips; // label for showing level skips
    CCLabelTTF          *m_lblLevelSkips;       // label for showing level skips

    CGSize              m_winSize;              // screen size
    CGSize              m_FlyingSpeed;          // speed of ball flying from character to trace. it is depends on DEF_Ball_FlyingSpeed and angle.
    CGPoint             m_ptComplete;           // After game is completed, some animation will be started from this point.

    ccTime              m_ccUpdateBallTime;
    ccTime              m_ccUpdateFlyingTime;
    ccTime              m_ccUpdateFiringTime;
    ccTime              m_ccUpdateBombShowTime;
    ccTime              m_ccUpdateBombBackDelay;
    ccTime              m_ccUpdateBombStopDelay;
    ccTime              m_ccUpdateFastSortTime;

    double              m_fRemainedDist;        // the distance to go in a time
    double              m_bShooterAngle;        // angle of character

    int                 m_nBombAnimationIndex;
    int                 m_nBombKind;            // Bomb, Back, Stop
    int                 m_nBombParam;           // valid when m_nBombKind is Bomb
    int                 m_nShootBallColor;      // the color of ball to shoot
    int                 m_nFlyingBallColor;     // the color of ball being flying to trace
    int                 m_nCompletePosIndex;    // for animating when the game is completed
    int                 m_nFireIndex;           // for animating when the game is completed
    int                 m_nFireFrom;            // for animating when the game is completed
    int                 m_nFireTo;              // for animating when the game is completed
    int                 m_nBackPower;
    int                 m_nLevel;               // level
    int                 m_nScore;               // score
    int                 m_nCountOfBallKind;
    int                 m_BallKind[20];
    int                 m_nFastSortFrom;        // When the flying ball is near to trace, the chain of ball is sorted from m_nFastSortFrom
    int                 m_nFastSortTo;          // When the flying ball is near to trace, the chain of ball is sorted to m_nFastSortTo
    int                 m_nBallCount;
    int                 m_nPowerIndex;          // the first index of chain being moving

    bool                m_bIsPlaying;
    bool                m_bOverLayerExist;
    bool                m_bFirstSlide;
    bool                m_bAllStopTimer;
    bool                m_bIsGameOver;
    bool                m_bIsGameComplete;
    bool                m_bIsGameDone;
    bool                m_bHasFlyingBall;
    bool                m_bIsFiring;
    bool                m_bIsFastSortingChain;
    bool                m_bBallLoaded;
    bool                m_bBackgroundMusicEnable;
    bool                m_bEffectMusicEnable;
    bool                m_bDanger;
    NSOperationQueue *  parseQueue;
}

//@property (nonatomic) NSOperationQueue *parseQueue; // The queue that manages our NSOperation for parsing earthquake data.

+(CCScene *) scene;
-(void) setContinue;
-(void) restartGame;
-(void) setBackgroundMusicEnable:(bool)bEnable;
-(void) setEffectMusicEnable:(bool)bEnable;
-(void) gotoHome;
-(void)GotoSelectStage;
-(void) onPlayOn: (id) sender;

@end
