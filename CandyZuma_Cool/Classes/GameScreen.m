#import "GameScreen.h"
#import "LevelData.h"
#import "SimpleAudioEngine.h"
#import "SelectStage.h"
#import "PauseLayer.h"
#import "Global.h"
#import "WaitLayer.h"
#import "MainMenu.h"
#import "MKStoreManager.h"
#import "MBProgressHUD.h"

@implementation GameScreen

const ccTime DEF_BallAni_Interval       = 0.03f;
const ccTime DEF_FastSortChain_Interval = 0.01f;
const ccTime DEF_Firing_Interval        = 0.01f;
const float  DEF_Ball_FlyingInterval    = 0.03f;
const float  DEF_BombShow_Interval      = 60.0f;
const float  DEF_BombBack_Delay         = 3.0f;
const float  DEF_BombStop_Delay         = 3.0f;

float  DEF_Ball_Offset            = 1.0f;
float  DEF_Ball_FlyingSpeed       = 10.0f;
float  DEF_GameOverSpeed          = 10;
float  DEF_Back_Power             = 10;
float  DEF_SpeedUpRateByLevel     = 0.1f;
float  DEF_DistCalc_Offset        = 1.5f;
float  DEF_CheckValue             = 0.1f;

const int    DEF_FiringBall_Count       = 20;
const int    DEF_Fire_Count             = 8;
const int    DEF_BombAni_Count          = 1;

const int    DEF_BombTag_Bomb           = 1;
const int    DEF_BombTag_Back           = 2;
const int    DEF_BombTag_Stop           = 3;
const int    DEF_BombKind_Count         = 3;

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameScreen *layer = [GameScreen node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
        if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad )
        {
            DEF_Ball_Offset            = 2.4f;
            DEF_Ball_FlyingSpeed       = 24.0f;
            DEF_GameOverSpeed          = 24.0f;
            DEF_Back_Power             = 24.0f;
            DEF_SpeedUpRateByLevel     = 0.2f;
            DEF_DistCalc_Offset        = 3.6f;
            DEF_CheckValue             = 0.24f;
        }
        
        [self setTouchEnabled:YES];
        [self initVariables];
        parseQueue = [NSOperationQueue new];
        [self loadLevelXML];
        [self loadBackgroundMusic];
        [self loadGameInfo];
        [self loadBackgroundImg];            
        [self scheduleUpdate];
        m_layerPause = [[[PauseLayer alloc] init] autorelease];
        [m_layerPause setVisible:FALSE];
        [self addChild:m_layerPause z:10];
    }
    
    return self;
}

-(void) initVariables
{
    m_nLevel = gnCurrentStage;
    m_nPowerIndex = 0;
    m_ccUpdateBallTime = 0;
    m_ccUpdateFlyingTime = 0;
    m_ccUpdateFiringTime = 0;
    m_ccUpdateBombShowTime = 0;
    m_ccUpdateFastSortTime = 0;
    m_ccUpdateBombBackDelay = 0;
    m_ccUpdateBombStopDelay = 0;
    m_bIsGameOver = false;
    m_bIsGameComplete = false;
    m_sprBallArray = NULL;
    m_BallPosIndex = NULL;
    m_BallColorArray = NULL;
    m_bBallLoaded = false;
    m_bShooterAngle = 0.0f;
    m_nCountOfBallKind = 0;
    m_bHasFlyingBall = false;
    m_bIsFastSortingChain = false;
    m_bIsFiring = false;
    m_nFireIndex = 0;
    m_bIsGameDone = false;
    m_bIsPlaying = true;
    m_nBackPower = 0;
    m_bFirstSlide = true;
    m_nBombAnimationIndex = 0;
    m_nBombKind = -1;
    m_nBombParam = 0;
    m_bOverLayerExist = false;
    m_bBackgroundMusicEnable = gbMusicEnable;
    m_bEffectMusicEnable = gbSoundEnable;
    m_bDanger = false;
}

- (void) dealloc
{
    [m_sprBallArray removeAllObjects];
    [m_sprBallArray release];m_sprBallArray = nil;
    [m_BallPosIndex removeAllObjects];
    [m_BallPosIndex release];m_BallPosIndex = nil;
    [m_BallColorArray removeAllObjects];
    [m_BallColorArray release];m_BallColorArray=nil;
    [m_parseOperation release];m_parseOperation=nil;
    [parseQueue release];parseQueue=nil;
    [self removeAllChildrenWithCleanup:YES];
    
	[super dealloc];
}

-(void) loadBackgroundMusic
{
    if (m_bBackgroundMusicEnable)
    {
        if (m_bDanger == false)
        {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bgm.mp3"];
        }
        else
        {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"heartbeat-game-play.mp3"];
        }
    }
}

-(void) loadLevelXML
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    m_winSize = size;

    NSString* strLevelXML = [NSString stringWithFormat:@"level-%d",m_nLevel+1];
    
//    NSString* strLevelXML = [NSString stringWithFormat:@"level-1"];

    if (strLevelXML == NULL)
        return;
    
    NSString *szLevelXML = [[NSBundle mainBundle] pathForResource:strLevelXML ofType:@"xml" ];
    NSURL *urlLevelXML = [NSURL fileURLWithPath:szLevelXML];
    
    m_parseOperation = [[LevelData alloc] initWithXML:urlLevelXML WinSize:size];
    [parseQueue addOperation:m_parseOperation];
}

-(void) loadGameInfo
{
    
}

-(void) loadBackgroundImg
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    m_winSize = size;
    
    CCSprite *backSprite = NULL;
    NSString* strLevelBg = NULL;
    if (m_nLevel < 9)
    {
        if (size.width == 568 || size.height == 568)
            strLevelBg = [NSString stringWithFormat:@"stage000%d_4inch.png",m_nLevel+1];
        else
            strLevelBg = [NSString stringWithFormat:@"stage000%d.png",m_nLevel+1];
    }
    else if (m_nLevel < 99)
    {
        if (size.width == 568 || size.height == 568)
            strLevelBg = [NSString stringWithFormat:@"stage00%d_4inch.png",m_nLevel+1];
        else
            strLevelBg = [NSString stringWithFormat:@"stage00%d.png",m_nLevel+1];
    }
    
//     if (size.width == 568 || size.height == 568)
//         strLevelBg = [NSString stringWithFormat:@"stage0001_4inch.png"];
//     else
//         strLevelBg = [NSString stringWithFormat:@"stage0001.png"];
//
//    if (strLevelBg == NULL)
//        return;
    
    backSprite = [CCSprite spriteWithFile:strLevelBg];
    backSprite.position = ccp(size.width / 2, size.height / 2);
    [self addChild:backSprite z:0];

    for (int i = 0; i < DEF_FiringBall_Count; i++)
    {
        for (int j = 0; j < DEF_Fire_Count; j++)
        {
            NSString* strFileName = [NSString stringWithFormat:@"fire%d.png",j+1];
            m_sprFires[i][j] = [CCSprite spriteWithFile:strFileName];
            [m_sprFires[i][j] setVisible:FALSE];
            [self addChild:m_sprFires[i][j] z:5];
        }
    }
    
/*    for (int j = 0; j < DEF_BombAni_Count; j++)
    {
        NSString* strFileName = [NSString stringWithFormat:@"bomb%d.png",j+1];
        m_sprBomb[0][j] = [CCSprite spriteWithFile:strFileName];
        [m_sprBomb[0][j] setVisible:FALSE];
        [self addChild:m_sprBomb[0][j] z:5];

        strFileName = [NSString stringWithFormat:@"back%d.png",j+1];
        m_sprBomb[1][j] = [CCSprite spriteWithFile:strFileName];
        [m_sprBomb[1][j] setVisible:FALSE];
        [self addChild:m_sprBomb[1][j] z:5];

        strFileName = [NSString stringWithFormat:@"stop%d.png",j+1];
        m_sprBomb[2][j] = [CCSprite spriteWithFile:strFileName];
        [m_sprBomb[2][j] setVisible:FALSE];
        [self addChild:m_sprBomb[2][j] z:5];
    }*/
    
    m_btnPause = [CCMenuItemImage itemWithNormalImage:@"pause_button.png" selectedImage:@"pause_button.png" target:self selector:@selector(onPlayPause:)];
    m_btnPause.anchorPoint = ccp(1,1);
	m_btnPause.position = ccp(size.width - 5, size.height-5);
	
	CCMenu* myMenu1 = [CCMenu menuWithItems: m_btnPause, nil];
	myMenu1.position = ccp(0, 0);
	[self addChild:myMenu1 z:7];
    
//    CCSprite* sprScoreName = [CCSprite spriteWithFile:@"score_board.png"];
//    sprScoreName.anchorPoint = ccp(0,1);
//    sprScoreName.position = ccp(5,size.height-5);
//    [self addChild:sprScoreName z:1];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];

    float fFontSize = m_winSize.height  / 320.0 * 15;
    CCLabelTTF* lblScoreShadowBg = [CCLabelTTF labelWithString:@"SCORE :" fontName:@"Marker Felt" fontSize:fFontSize];
    lblScoreShadowBg.anchorPoint = ccp(0, 0.5f);
    lblScoreShadowBg.color = ccc3(0, 0, 0);

	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        lblScoreShadowBg.position = ccp(winSize.width/21+1.5,winSize.height/20*19+1.5);
    else
        lblScoreShadowBg.position = ccp(winSize.width/21+3,winSize.height/20*19+3);
    [self addChild:lblScoreShadowBg z:4];

    CCLabelTTF* lblScoreBg = [CCLabelTTF labelWithString:@"SCORE :" fontName:@"Marker Felt" fontSize:fFontSize];
    lblScoreBg.anchorPoint = ccp(0, 0.5f);
    lblScoreBg.position = ccp(winSize.width/21,winSize.height/20*19);
    [self addChild:lblScoreBg z:4];

    m_lblShadowScore = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:fFontSize];
    m_lblScore = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:fFontSize];
//    [m_lblScore enableStrokeWithColor:ccc3(255,255,255) size:1.5f updateImage:true];
//    m_lblScore.anchorPoint = ccp(0,0.5);
    
    m_lblShadowScore.anchorPoint = ccp(0, 0.5f);
    m_lblShadowScore.color = ccc3(0, 0, 0);
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        m_lblShadowScore.position = ccp(lblScoreBg.position.x+lblScoreBg.contentSize.width + 10 + 1.5,winSize.height/20*19 + 1.5);
    else
        m_lblShadowScore.position = ccp(lblScoreBg.position.x+lblScoreBg.contentSize.width + 10 + 3,winSize.height/20*19 + 3);
    [self addChild:m_lblShadowScore z:4];

    m_lblScore.anchorPoint = ccp(0, 0.5f);
    m_lblScore.position = ccp(lblScoreBg.position.x+lblScoreBg.contentSize.width + 10,winSize.height/20*19);
    [self addChild:m_lblScore z:4];
    
    CCLabelTTF* lblSkipsShadowBg = [CCLabelTTF labelWithString:@"LEVEL SKIPS :" fontName:@"Marker Felt" fontSize:fFontSize];
    lblSkipsShadowBg.anchorPoint = ccp(0, 0.5f);
    lblSkipsShadowBg.color = ccc3(0, 0, 0);
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        lblSkipsShadowBg.position = ccp(winSize.width/3.5f + 1.5,winSize.height/20*19 + 1.5);
    else
        lblSkipsShadowBg.position = ccp(winSize.width/3.5f + 3,winSize.height/20*19 + 3);

    [self addChild:lblSkipsShadowBg z:4];

    CCLabelTTF* lblSkipsBg = [CCLabelTTF labelWithString:@"LEVEL SKIPS :" fontName:@"Marker Felt" fontSize:fFontSize];
    lblSkipsBg.anchorPoint = ccp(0, 0.5f);
    lblSkipsBg.position = ccp(winSize.width/3.5f,winSize.height/20*19);
    [self addChild:lblSkipsBg z:4];

    m_lblShadowLevelSkips = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:fFontSize];
    m_lblShadowLevelSkips.string = [NSString stringWithFormat:@"%d",gnLevelSkips];
    m_lblShadowLevelSkips.anchorPoint = ccp(0, 0.5f);
    m_lblShadowLevelSkips.color = ccc3(0, 0, 0);
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        m_lblShadowLevelSkips.position = ccp(lblSkipsBg.position.x+lblSkipsBg.contentSize.width + 10 + 1.5,winSize.height/20*19 + 1.5);
    else
        m_lblShadowLevelSkips.position = ccp(lblSkipsBg.position.x+lblSkipsBg.contentSize.width + 10 + 3,winSize.height/20*19 + 3);
    [self addChild:m_lblShadowLevelSkips z:4];

    m_lblLevelSkips = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:fFontSize];
    m_lblLevelSkips.string = [NSString stringWithFormat:@"%d",gnLevelSkips];
    m_lblLevelSkips.anchorPoint = ccp(0, 0.5f);
    m_lblLevelSkips.position = ccp(lblSkipsBg.position.x+lblSkipsBg.contentSize.width + 10,winSize.height/20*19);
    [self addChild:m_lblLevelSkips z:4];
}

-(void) onPlayPause: (id) sender{
    if (m_bOverLayerExist)
        return;
    
    AppController* appDel = (AppController*)[[UIApplication sharedApplication] delegate];
    [appDel showCharboost];
    [appDel showPlayhaven:PlayHaven_PlacementID_3];

    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    m_bIsPlaying = false;
    m_bOverLayerExist = true;
    [m_layerPause setMusicEnable:m_bBackgroundMusicEnable];
    [m_layerPause setSoundEnable:m_bEffectMusicEnable];
    [m_layerPause setVisible:TRUE];
}

-(void) setContinue
{
    m_bOverLayerExist = false;
    m_bIsPlaying = true;
}

-(void) restartGame
{
    CGSize size = [[CCDirector sharedDirector] winSize];

    NSString* strLevelBg = NULL;
    if (m_nLevel < 9)
    {
        if (size.width == 568 || size.height == 568)
            strLevelBg = [NSString stringWithFormat:@"stage000%d_4inch.png",m_nLevel+1];
        else
            strLevelBg = [NSString stringWithFormat:@"stage000%d.png",m_nLevel+1];
    }
    else if (m_nLevel < 99)
    {
        if (size.width == 568 || size.height == 568)
            strLevelBg = [NSString stringWithFormat:@"stage00%d_4inch.png",m_nLevel+1];
        else
            strLevelBg = [NSString stringWithFormat:@"stage00%d.png",m_nLevel+1];
    }

//    if (size.width == 568 || size.height == 568)
//        strLevelBg = [NSString stringWithFormat:@"stage0001_4inch.png"];
//    else
//        strLevelBg = [NSString stringWithFormat:@"stage0001.png"];

    [self unscheduleUpdate];

    CCScene *scene = [WaitLayer scene:strLevelBg];
    [[CCDirector sharedDirector] replaceScene:scene];

//    if (gbMusicEnable)
//    {
//        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
//        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu-music.mp3" loop:TRUE];
//    }
}

-(void) setBackgroundMusicEnable:(bool)bEnable
{
    m_bBackgroundMusicEnable = bEnable;
    gbMusicEnable = m_bBackgroundMusicEnable;
    if (m_bBackgroundMusicEnable)
    {
//        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
        [self loadBackgroundMusic];
    }
    else
    {
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    }
}

-(void) setEffectMusicEnable:(bool)bEnable
{
    m_bEffectMusicEnable = bEnable;
    gbSoundEnable = m_bEffectMusicEnable;
}

-(void) gotoHome
{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [self unscheduleUpdate];
    
    CCScene *scene = [MainMenu scene];
    [[CCDirector sharedDirector] replaceScene:scene];

    if (gbMusicEnable)
    {
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu-music.mp3" loop:TRUE];
    }
}

-(void) loadShooter
{
    m_sprShooter = [CCSprite spriteWithFile:[NSString stringWithFormat:@"character%d_1.png",gnSelectedCharacter+1]];
    m_sprShooter.scale = 0.6;
    [m_sprShooter setPosition:[m_parseOperation getShooterPos]];
    [self addChild:m_sprShooter z:1];
}

-(void) actionShooter
{
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:9];
    for (int i = 0; i < 9; i++)
    {
        NSString* file = nil;
        if (i == 8)
            file = [NSString stringWithFormat:@"character%d_1.png", gnSelectedCharacter+1];
        else
            file = [NSString stringWithFormat:@"character%d_%d.png", gnSelectedCharacter+1, i+1];
        
        CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:file];
        CGSize texSize = texture.contentSize;
        CGRect texRect = CGRectMake(0, 0, texSize.width, texSize.height);
        CCSpriteFrame* frame = [CCSpriteFrame frameWithTexture:texture rect:texRect];
        [frames addObject:frame];
    }
    
    CCAnimation *animationShooter = [CCAnimation animationWithSpriteFrames:frames delay:0.08f];
    id animateShooter = [CCAnimate actionWithAnimation:animationShooter];
    
    [m_sprShooter runAction:animateShooter];
}

-(void) loadBalls
{
    if (m_sprBallArray == NULL)
    {
        m_sprBallArray = [[NSMutableArray alloc] initWithCapacity:2];
        m_BallPosIndex = [[NSMutableArray alloc] initWithCapacity:2];
        m_BallColorArray = [[NSMutableArray alloc] initWithCapacity:2];
    }
    else
    {
        [m_sprBallArray removeAllObjects];
        [m_BallPosIndex removeAllObjects];
        [m_BallColorArray removeAllObjects];
    }
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    m_winSize = size;
    
    m_nBallCount = [m_parseOperation getColorCount];
    CGRect ballRect;
    
    for (int i = 0; i < m_nBallCount; i++)
    {
        
        
        NSString* strBallName = [NSString stringWithFormat:@"ball%d.png", [m_parseOperation getColorFromIndex:i]];
        CCSprite* sprBall = [CCSprite spriteWithFile:strBallName];
        
        CGPoint ptLineFrom = [m_parseOperation getStartLineFrom];
        CGPoint ptLineTo = [m_parseOperation getStartLineTo];
        if (i == 0)
        {
            [sprBall setPosition:ptLineTo];
            ballRect = [sprBall boundingBox];
        }
        else
        {
//            printf ("ObjectAtIndex 1\n");
            CCSprite* prevBall = [m_sprBallArray objectAtIndex:[m_sprBallArray count]-1];
            CGPoint prevPos = [prevBall position];
            CGPoint nextPos = [self getNextPosFromLine:prevPos Target:ptLineFrom offset:ballRect.size.width];
            [sprBall setPosition:nextPos];
        }
        
        int zero = 0;
        NSNumber* zeroNum = [[NSNumber alloc] initWithInt:zero];
        [m_BallPosIndex addObject:zeroNum];
        NSNumber* colorNum = [[NSNumber alloc] initWithInt:[m_parseOperation getColorFromIndex:i]];
        [m_BallColorArray addObject:colorNum];
        [m_sprBallArray addObject:sprBall];
        [self addChild:sprBall z:1];
    }
}

-(CGPoint) getNextPos:(CGPoint)ptCurrent Index:(int)nIndex offset:(float) fOffset
{
    // check if it is circle or line...
    int nFirstIndex;
    if (nIndex % 2 == 0)
    {
        nFirstIndex = nIndex;
    }
    else
    {
        nFirstIndex = nIndex-1;
    }
    
    CGPoint zeroPt; zeroPt.x = 0; zeroPt.y=0;
    if (fOffset > 0 && [m_parseOperation getLocationCount] <= nFirstIndex+2)
        return zeroPt;

    CGPoint ptFirst = [m_parseOperation getPosFromIndex:nFirstIndex];
    CGPoint ptSecond = [m_parseOperation getPosFromIndex:nFirstIndex+1];
    CGPoint ptThird = [m_parseOperation getPosFromIndex:nFirstIndex+2];
    if ([self isLine:ptFirst Second:ptSecond Third:ptThird])   // it is a line
    {
        if (fOffset > 0)
            return [self getNextPosFromLine:ptCurrent Target:[m_parseOperation getPosFromIndex:nIndex+2] offset:fOffset];
        else
            return [self getNextPosFromLine:ptCurrent Target:[m_parseOperation getPosFromIndex:nIndex] offset:-fOffset];
    }
    return [self getNextPosFromCircle:ptCurrent Circle:nFirstIndex offset:fOffset];
}

-(CGPoint) getNextPosFromCircle:(CGPoint) ptCurrent Circle:(int)nFirstIndex offset:(float)fOffset
{
    CGPoint zeroPt; zeroPt.x = 0; zeroPt.y=0;
    if (fOffset >= 0 && [m_parseOperation getLocationCount] <= nFirstIndex+2)
        return zeroPt;
    

    CGPoint ptFirst = [m_parseOperation getPosFromIndex:nFirstIndex];
    CGPoint ptSecond = [m_parseOperation getPosFromIndex:nFirstIndex+1];
    CGPoint ptThird = [m_parseOperation getPosFromIndex:nFirstIndex+2];
    
//    float nCheckValue = (ptFirst.x-ptSecond.x)*(ptThird.y-ptFirst.y)-(ptFirst.x-ptThird.x)*(ptSecond.y-ptFirst.y);
//    if (nCheckValue > -0.01 && nCheckValue < 0.01)
    if ([self isLine:ptFirst Second:ptSecond Third:ptThird])
    {
        CGPoint zeroPt; zeroPt.x = 0; zeroPt.y = 0;
        return zeroPt;
    }
    
    float cx = [self getCXOfCircleEquation:ptFirst Second:ptSecond Third:ptThird];
    float cy = [self getCYOfCircleEquation:ptFirst Second:ptSecond Third:ptThird];
    float r = [self getROfCircleEquation:ptFirst Second:ptSecond Third:ptThird];
    
    // get the way ( right or left)
    float alpha1 = [self acosfnear:(([m_parseOperation getPosFromIndex:nFirstIndex].x-cx)/r)];
    float alpha2 = [self asinfnear:(([m_parseOperation getPosFromIndex:nFirstIndex].y-cy)/r)];
    float firstAlpha = [self getAlphaFromArcSinCos:alpha1 Sin:alpha2];
    firstAlpha = (firstAlpha > 0) ? firstAlpha : firstAlpha+2*PI;
    
    alpha1 = [self acosfnear:(([m_parseOperation getPosFromIndex:nFirstIndex+1].x-cx)/r)];
    alpha2 = [self asinfnear:(([m_parseOperation getPosFromIndex:nFirstIndex+1].y-cy)/r)];
    float secondAlpha = [self getAlphaFromArcSinCos:alpha1 Sin:alpha2];
    secondAlpha = (secondAlpha > 0) ? secondAlpha : secondAlpha+2*PI;
    
    alpha1 = [self acosfnear:(([m_parseOperation getPosFromIndex:nFirstIndex+2].x-cx)/r)];
    alpha2 = [self asinfnear:(([m_parseOperation getPosFromIndex:nFirstIndex+2].y-cy)/r)];
    float thirdAlpha = [self getAlphaFromArcSinCos:alpha1 Sin:alpha2];
    thirdAlpha = (thirdAlpha > 0) ? thirdAlpha : thirdAlpha+2*PI;

    if (secondAlpha > firstAlpha && secondAlpha > thirdAlpha)
    {
        if (firstAlpha > PI)
            thirdAlpha += 2*PI;
        else
            firstAlpha += 2*PI;
    }
    else if (secondAlpha < firstAlpha && secondAlpha < thirdAlpha)
    {
        if (firstAlpha > PI)
        {
            secondAlpha += 2*PI;
            thirdAlpha += 2*PI;
        }
        else
        {
            firstAlpha += 2*PI;
            secondAlpha += 2*PI;
        }
    }

    float fArrow;
    if (firstAlpha > secondAlpha && secondAlpha > thirdAlpha)
    {
        fArrow = -1.0f;
    }
    else
    {
        fArrow = 1.0f;
    }
    
    // get the alpha of ptCurrent
    alpha1 = [self acosfnear:((ptCurrent.x-cx)/r)];
    alpha2 = [self asinfnear:((ptCurrent.y-cy)/r)];

    float orgAlpha = [self getAlphaFromArcSinCos:alpha1 Sin:alpha2];
    orgAlpha = (orgAlpha > 0) ? orgAlpha : orgAlpha+2*PI;
    orgAlpha = (firstAlpha < thirdAlpha && firstAlpha > 2*PI && orgAlpha < 2*PI) ? orgAlpha+2*PI : orgAlpha;
    orgAlpha = (firstAlpha > thirdAlpha && thirdAlpha > 2*PI && orgAlpha < 2*PI) ? orgAlpha+2*PI : orgAlpha;
    
    if (/*fArrow*fOffset < 0 && */firstAlpha > secondAlpha && firstAlpha > thirdAlpha && orgAlpha < thirdAlpha && firstAlpha-orgAlpha > PI)
    {
        orgAlpha += 2*PI;
    }
    
    else if (/*fArrow*fOffset > 0 && */thirdAlpha > secondAlpha && thirdAlpha > firstAlpha && orgAlpha < firstAlpha && thirdAlpha-orgAlpha > PI)
    {
        orgAlpha += 2*PI;
    }

    
    // get the next pos
    float alpha = orgAlpha + (fOffset / r)*fArrow;
    while (alpha < 0)
    {
        alpha += 2*PI;
    }
    CGPoint ptNext;
    ptNext.x = cx+r*cos(alpha);
    ptNext.y = cy+r*sin(alpha);
    
/*    if (firstAlpha > secondAlpha && orgAlpha-firstAlpha > 0 && orgAlpha-firstAlpha < 0.1)
    {
        m_fRemainedDist = 0;
        return ptNext;
    }
    else if (secondAlpha > firstAlpha && orgAlpha-thirdAlpha > 0 && orgAlpha-thirdAlpha < 0.1)
    {
        m_fRemainedDist = 0;
        return ptNext;
    }*/
    
    if (firstAlpha > secondAlpha)
    {
        if (orgAlpha > firstAlpha)
        {
            m_fRemainedDist = 0;
            return ptFirst;
        }
        else if (orgAlpha<thirdAlpha)
        {
            m_fRemainedDist = 0;
            return ptThird;
        }
    }
    else if (thirdAlpha > secondAlpha)
    {
        if (orgAlpha > thirdAlpha)
        {
            m_fRemainedDist = 0;
            return ptThird;
        }
        else if (orgAlpha<firstAlpha)
        {
            m_fRemainedDist = 0;
            return ptFirst;
        }
    }

    
    // check if the next pos is out of the last position
/*    if ((orgAlpha > firstAlpha && orgAlpha < thirdAlpha) || (orgAlpha > thirdAlpha && orgAlpha < firstAlpha))
    {
    }
    else
    {
        m_fRemainedDist = 0;
        return ptNext;
    }
*/
    if ((alpha >= firstAlpha && alpha <= thirdAlpha) || (alpha >= thirdAlpha && alpha <= firstAlpha))
    {
    }
    else
    {
        int nEndIndex = nFirstIndex+2;
        if (fOffset < 0)
            nEndIndex = nFirstIndex;
        ptNext = [m_parseOperation getPosFromIndex:nEndIndex];
        
        float fDist = (fOffset > 0) ? thirdAlpha-orgAlpha : firstAlpha-orgAlpha;
        fDist = (fDist > 0) ? fDist : -fDist;
        fDist = (fDist >  2*PI) ? fDist-2*PI : fDist;
        if (m_fRemainedDist > 0 && fOffset - r*fDist < 0)
        {
            m_fRemainedDist = 0;
            float fDist = (ptNext.x-ptCurrent.x)*(ptNext.x-ptCurrent.x)+(ptNext.y-ptCurrent.y)*(ptNext.y-ptCurrent.y);
            fDist = sqrtf(fDist);
            
            return ptNext;
        }
        
        m_fRemainedDist = (fOffset > 0) ? fOffset - r*fDist : fOffset + r*fDist;
        
//        if (m_fRemainedDist < 0.01 && m_fRemainedDist > -0.01)
//            m_fRemainedDist = 0;
        
        float fDist2 = (ptNext.x-ptCurrent.x)*(ptNext.x-ptCurrent.x)+(ptNext.y-ptCurrent.y)*(ptNext.y-ptCurrent.y);
        fDist2 = sqrtf(fDist2);
        
        return ptNext;
    }
    
    m_fRemainedDist = 0;
    float fDist3 = (ptNext.x-ptCurrent.x)*(ptNext.x-ptCurrent.x)+(ptNext.y-ptCurrent.y)*(ptNext.y-ptCurrent.y);
    fDist3 = sqrtf(fDist3);
    
    return ptNext;
}

-(CGPoint) getNextPosFromLine:(CGPoint)ptCurrent Target:(CGPoint)ptTarget offset:(float)fOffset
{
    float nLargeLine = sqrt((ptCurrent.x - ptTarget.x)*(ptCurrent.x - ptTarget.x) + (ptCurrent.y - ptTarget.y)*(ptCurrent.y - ptTarget.y));
    float nDifX = ptTarget.x - ptCurrent.x;
    float nDifY = ptTarget.y - ptCurrent.y;
    float rX, rY;
    
    if (nLargeLine == 0)
    {
        return ptCurrent;
    }
    
    rX = (fOffset*nDifX)/nLargeLine;
    rY = (fOffset*nDifY)/nLargeLine;

    float nNewLargeLine = sqrt(rX*rX+rY*rY);
    
    if (nNewLargeLine > nLargeLine)
    {
        if (m_fRemainedDist < 0 && nNewLargeLine-nLargeLine > 0)
        {
            m_fRemainedDist = nLargeLine - nNewLargeLine;
        }
        else
        {
            m_fRemainedDist = nNewLargeLine-nLargeLine;
        }
        return ptTarget;
    }
    
    m_fRemainedDist = 0;
    ptCurrent.x += rX;
    ptCurrent.y += rY;
    
    return ptCurrent;
}

-(void) BallAnimationBackPower:(int)nFromIndex To:(int)nToIndex RightArrow:(bool)bIsRightArrow
{
    float fMul = 1;
    if (bIsRightArrow == false)
        fMul = -1;
    
    int i = 0;
    
//    printf ("ObjectAtIndex 2\n");
    CCSprite* oneBallSprite = [m_sprBallArray objectAtIndex:0];
    
    int ncount = [m_sprBallArray count];
    
    if (nFromIndex > ncount)
        return;
    if (nToIndex >= ncount)
        nToIndex = ncount-1;
    
    for (i = nFromIndex; i <= nToIndex; i++)
    {
//        printf ("ObjectAtIndex 3\n");
        oneBallSprite = [m_sprBallArray objectAtIndex:i];
        CGPoint ptCurrent = [oneBallSprite position];
        
        if (fMul < 0)
            m_fRemainedDist = -m_nBackPower;
        else
            m_fRemainedDist = m_nBackPower;
        while (m_fRemainedDist >= 0.01 || m_fRemainedDist <= -0.01)
        {
            NSNumber* numBallPosIndex = m_BallPosIndex[i];
            int nMyIndex = [numBallPosIndex intValue];
            if (nMyIndex < 0)
            {
                
            }
            ptCurrent = [self getNextPos:ptCurrent Index:nMyIndex offset:m_fRemainedDist];
            
            if (bIsRightArrow && [m_parseOperation getLocationCount] <= nMyIndex+2)
                return;
            
            CGPoint ptTarget = [m_parseOperation getPosFromIndex:(nMyIndex+2)];
            if (bIsRightArrow == false)
                ptTarget = [m_parseOperation getPosFromIndex:(nMyIndex)];
            
            if (m_fRemainedDist >= 0.01 || m_fRemainedDist <= -0.01)
                //            if (ptTarget.x == ptCurrent.x && ptCurrent.y == ptTarget.y)
            {
                int intValue = [numBallPosIndex intValue]+fMul*2;
                
                NSNumber* newNum;
                if (intValue < 0)
                    intValue = 0;
                newNum = [NSNumber numberWithInt:[numBallPosIndex intValue]+fMul*2];
                //            [numBallPosIndex release];
//                printf ("ObjectAtIndex 4\n");
                [m_BallPosIndex replaceObjectAtIndex:i withObject:(id)newNum];
                
                int nVa = [newNum intValue];
                if (nVa >= [m_parseOperation getLocationCount]-1)
                {
                    m_bIsGameOver = true;
                    if (m_bBackgroundMusicEnable)
                        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
                }
            }
        }
        
        CGPoint pt = [oneBallSprite position];
        float fDist = (pt.x-ptCurrent.x)*(pt.x-ptCurrent.x)+(pt.y-ptCurrent.y)*(pt.y-ptCurrent.y);
        fDist = sqrtf(fDist);
        
//        printf ("ObjectAtIndex 5\n");
        oneBallSprite = [m_sprBallArray objectAtIndex:i];
        [oneBallSprite setPosition:ptCurrent];
    }
    
}

-(void) BallAnimationFrom:(int)nFromIndex To:(int)nToIndex RightArrow:(bool)bIsRightArrow Offset:(float)fOffset
{
    float fMul = 1;
    if (bIsRightArrow == false)
        fMul = -1;
    
    if (fOffset != 0)
    {
        if (fMul*fOffset > 0)
            fMul = 1;
        else
            fMul = -1;
    }
    
    int i = 0;
    
//    printf ("ObjectAtIndex 6\n");
    CCSprite* oneBallSprite = [m_sprBallArray objectAtIndex:0];
    
    int ncount = [m_sprBallArray count];
    
    if (nFromIndex > ncount)
        return;
    if (nToIndex >= ncount)
        nToIndex = ncount-1;

    NSNumber* firstBallIndex = m_BallPosIndex[i];
    if ([firstBallIndex intValue] >= [m_parseOperation getLocationCount]/3)
    {
        m_bFirstSlide = false;
    }

    for (i = nFromIndex; i <= nToIndex; i++)
    {
//        printf ("ObjectAtIndex 7\n");
        oneBallSprite = [m_sprBallArray objectAtIndex:i];
        CGPoint ptCurrent = [oneBallSprite position];
        
        if (m_nBombKind == DEF_BombTag_Back)
            m_fRemainedDist = (-1)*(DEF_Ball_Offset+(((m_nLevel+1)/5)*DEF_SpeedUpRateByLevel))*2;
        else if (fMul < 0)
            m_fRemainedDist = fMul*(DEF_Ball_Offset+(((m_nLevel+1)/5)*DEF_SpeedUpRateByLevel))*5;
        else if (m_bFirstSlide)
            m_fRemainedDist = fMul*(DEF_Ball_Offset+(((m_nLevel+1)/5)*DEF_SpeedUpRateByLevel))*5;
        else if (m_bIsFastSortingChain)
            m_fRemainedDist = fMul*(DEF_Ball_Offset+(((m_nLevel+1)/5)*DEF_SpeedUpRateByLevel))*2;
        else
            m_fRemainedDist = fMul*(DEF_Ball_Offset+(((m_nLevel+1)/5)*DEF_SpeedUpRateByLevel));
        
        if (fOffset != 0)
            m_fRemainedDist = fOffset;
        
        
        while (m_fRemainedDist >= 0.01 || m_fRemainedDist <= -0.01)
        {
            NSNumber* numBallPosIndex = m_BallPosIndex[i];
            int nMyIndex = [numBallPosIndex intValue];

            CGPoint ptOld = ptCurrent;
            ptCurrent = [self getNextPos:ptCurrent Index:nMyIndex offset:m_fRemainedDist];
            
            float fDist = (ptOld.x-ptCurrent.x)*(ptOld.x-ptCurrent.x)+(ptOld.y-ptCurrent.y)*(ptOld.y-ptCurrent.y);
            fDist = sqrtf(fDist);
            
            if (fMul>=0 && [m_parseOperation getLocationCount] <= nMyIndex+2)
                return;
            
            CGPoint ptTarget = [m_parseOperation getPosFromIndex:(nMyIndex+2)];
            if (fMul < 0)
                ptTarget = [m_parseOperation getPosFromIndex:(nMyIndex)];
            
            if (m_fRemainedDist >= 0.01 || m_fRemainedDist <= -0.01)
//            if (ptTarget.x == ptCurrent.x && ptCurrent.y == ptTarget.y)
            {
                int intValue = [numBallPosIndex intValue]+fMul*2;
                
                NSNumber* newNum;
                if (intValue < 0)
                    intValue = 0;
                newNum = [NSNumber numberWithInt:[numBallPosIndex intValue]+fMul*2];
                //            [numBallPosIndex release];
//                printf ("ObjectAtIndex 8\n");
                [m_BallPosIndex replaceObjectAtIndex:i withObject:(id)newNum];
                
                int nVa = [newNum intValue];
                if (nVa >= [m_parseOperation getLocationCount]-1)
                {
                    m_bIsGameOver = true;
                    if (m_bBackgroundMusicEnable)
                        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
                }
            }
        }
        
        CGPoint pt = [oneBallSprite position];
        float fDist = (pt.x-ptCurrent.x)*(pt.x-ptCurrent.x)+(pt.y-ptCurrent.y)*(pt.y-ptCurrent.y);
        fDist = sqrtf(fDist);
        
//        printf ("ObjectAtIndex 9\n");
        oneBallSprite = [m_sprBallArray objectAtIndex:i];
        [oneBallSprite setPosition:ptCurrent];
    }

}

-(float) getDistanceBetweenBalls:(int)nFirstIndex Second:(int)nSecondIndex
{
//    printf ("ObjectAtIndex 10\n");
    CCSprite* sprFirst = [m_sprBallArray objectAtIndex:nFirstIndex];
//    printf ("ObjectAtIndex 11\n");
    CCSprite* sprSecond = [m_sprBallArray objectAtIndex:nSecondIndex];
    CGPoint ptFirst = [sprFirst position];
    CGPoint ptSecond = [sprSecond position];
    float fDist = (ptFirst.x - ptSecond.x)*(ptFirst.x - ptSecond.x)+(ptFirst.y - ptSecond.y)*(ptFirst.y - ptSecond.y);

    fDist = sqrt(fDist);
    
    return fDist;
}

-(void) BallAnimation
{
    int ncount = [m_sprBallArray count];
    if (m_nBackPower < 0)
        m_nBackPower = 0;
    if (m_nBackPower == 0)
    {
        if (m_nBombKind == DEF_BombTag_Back)
            [self BallAnimationFrom:0 To:ncount-1 RightArrow:false Offset:0];
        else
            [self BallAnimationFrom:m_nPowerIndex To:ncount-1 RightArrow:true Offset:0];
    }
    else
    {
        [self BallAnimationBackPower:[self getFirstIndexOfChain:ncount-1] To:ncount-1 RightArrow:false];
        m_nBackPower -=2;
        if (m_nBackPower < 0)
            m_nBackPower = 0;
    }
}

-(bool)makeShootBall
{
    if (m_nCountOfBallKind == 0)
        return false;
    
    int nIndex = arc4random() % m_nCountOfBallKind;
    
    NSString* strBall = [NSString stringWithFormat:@"ball%d.png",m_BallKind[nIndex]];
    m_nShootBallColor = m_BallKind[nIndex];
    m_sprShootBall = [CCSprite spriteWithFile:strBall];
    CGPoint pt = [m_sprShooter position];
    [m_sprShootBall setPosition:pt];
    [self addChild:m_sprShootBall z:2];

    return true;
}

-(void)rotateShooter:(CGPoint)touchPos
{
    CGPoint ptShooter = [m_sprShooter position];
    CGRect rectShooter = [m_sprShooter boundingBox];
    CGPoint ptTemp = ptShooter; ptTemp.x = ptTemp.x + rectShooter.size.width;
    
    float angle = [self getAngleBetweenTowLines:ptShooter FirstTo:touchPos SecondFrom:ptShooter SecondTo:ptTemp];
    angle = angle * 180 / PI; angle = -angle;
    
    float actualAngle = angle - m_bShooterAngle;
    
    if (actualAngle > 180)
    {
        actualAngle = actualAngle-2*180;
    }
    else if (actualAngle < -180)
    {
        actualAngle = 2*180+actualAngle;
    }
    
    m_bShooterAngle = m_bShooterAngle + actualAngle;
    if (m_bShooterAngle > 360)
        m_bShooterAngle -= 360;
    else if (m_bShooterAngle < -360)
        m_bShooterAngle += 360;
    
    [m_sprShooter runAction:[CCRotateBy actionWithDuration:0.1f angle:actualAngle]];
}

-(void)GotoSelectStage
{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    [self unscheduleUpdate];
    
    CCScene *scene = [SelectStage scene];
    [[CCDirector sharedDirector] replaceScene:scene];

    if (gbMusicEnable)
    {
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu-music.mp3" loop:TRUE];
    }
}


-(void)GameOverProc
{
    m_bOverLayerExist = true;
    gnLevelScore[m_nLevel] = m_nScore;

    AppController* appDel = (AppController*)[[UIApplication sharedApplication] delegate];
    [appDel showCharboost];
    [appDel showPlayhaven:PlayHaven_PlacementID_2];

    CCSprite* spr = [CCSprite spriteWithFile:@"level_failed.png"];
    spr.position = ccp(m_winSize.width/2, m_winSize.height/7*4);
    [self addChild: spr z:10];
    
    CCMenuItemImage* btnPlayOn = [CCMenuItemImage itemWithNormalImage:@"level_playon.png" selectedImage:@"level_playon.png" target:self selector:@selector(onPlayOn:)];
	btnPlayOn.position = ccp(m_winSize.width/8*3, m_winSize.height/7*2);

    CCMenuItemImage* btnEndGame = [CCMenuItemImage itemWithNormalImage:@"level_endgame.png" selectedImage:@"level_endgame.png" target:self selector:@selector(onEndGame:)];
	btnEndGame.position = ccp(m_winSize.width/8*5, m_winSize.height/7*2);
	
	CCMenu* myMenu1 = [CCMenu menuWithItems: btnPlayOn, btnEndGame, nil];
	myMenu1.position = ccp(0, 0);
	[self addChild:myMenu1 z:11];
    
    CGSize size = [CCDirector sharedDirector].winSize;
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
    CCMenuItemSprite *menuItemLevelSkips = [CCMenuItemImage itemWithNormalImage:@"menu_levelskips.png" selectedImage:nil target:self selector:@selector(onPlayOn:)];
    CCMenuItemSprite *menuItemMoreGames = [CCMenuItemImage itemWithNormalImage:@"homepage_moregames.png" selectedImage:nil target:self selector:@selector(onMoreGames)];
    CCMenuItemSprite *menuItemNewGames = [CCMenuItemImage itemWithNormalImage:@"homepage_newgames.png" selectedImage:nil target:self selector:@selector(onNewGames)];
    CCMenuItemSprite *menuItemLink = [CCMenuItemImage itemWithNormalImage:@"menu_exit.png" selectedImage:nil target:self selector:@selector(onLink)];
    
    
    CCMenu * menu4 = [CCMenu menuWithItems:menuItemLevelSkips, menuItemMoreGames, menuItemNewGames, menuItemLink, nil];
    
    float padding = (size.width - menuItemLevelSkips.contentSize.width - menuItemMoreGames.contentSize.width- menuItemNewGames.contentSize.width- menuItemLink.contentSize.width) / 5;
    [menu4 alignItemsHorizontallyWithPadding:padding];
    menu4.position = ccp(size.width * 0.5f, menuBar.contentSize.height * 0.5f);
    
    [self addChild:menu4 z:7];    

}

-(void) onPlayOn: (id) sender{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];

//    if (gnLevelSkips <= 0) return;
    
    CCSprite* spr = nil;
    
    if (gnLevelSkips == 0)
        spr = [CCSprite spriteWithFile:@"level_skips.png"];
    else if (gnLevelSkips == 1)
        spr = [CCSprite spriteWithFile:@"level_skips_1.png"];
    else if (gnLevelSkips == 2)
        spr = [CCSprite spriteWithFile:@"level_skips_2.png"];
    else/* if (gnLevelSkips >= 3)*/
        spr = [CCSprite spriteWithFile:@"level_skips_3.png"];

    spr.position = ccp(m_winSize.width/2, m_winSize.height/7*4);
    spr.tag = 10001;
    [self addChild: spr z:10];
    
    CCMenuItemImage* btnSkipLevels = [CCMenuItemImage itemWithNormalImage:@"level_yesplease.png" selectedImage:@"level_yesplease.png" target:self selector:@selector(onLevelSkips)];
	btnSkipLevels.position = ccp(m_winSize.width/8*3, m_winSize.height/7*2);
    
    CCMenuItemImage* btnNoThanks = [CCMenuItemImage itemWithNormalImage:@"level_nothanks.png" selectedImage:@"level_nothanks.png" target:self selector:@selector(onClosePlayOn:)];
	btnNoThanks.position = ccp(m_winSize.width/8*5, m_winSize.height/7*2);
	
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
}

-(void) onEndGame: (id) sender{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    
    [self gotoHome];
}

-(void)showAdsOfCompleted:(ccTime)dt
{
    AppController* appDel = (AppController*)[[UIApplication sharedApplication] delegate];
    [appDel showCharboost];
    [appDel showPlayhaven:PlayHaven_PlacementID_4];
}

-(void)GameCompleteProc
{
    if (m_bBackgroundMusicEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"game-win.mp3"];
    
    AppController* appDel = (AppController*)[[UIApplication sharedApplication] delegate];

    [self scheduleOnce:@selector(showAdsOfCompleted:) delay:3];

    for (int i = 0; i < 20; i++)
    {
        CCParticleSystemQuad* myTestParticle = [[CCParticleFireworks alloc] init];
        CCSprite* sprParticle;
        sprParticle = [CCSprite spriteWithFile:@"particle_star.png"];
        myTestParticle.position = ccp(m_winSize.width/20*i+m_winSize.width/20,m_winSize.height/10*9);
        ccColor4F startColor,startColorVar,endColor,endColorVar;
        startColor.r = 1.0f;
        startColor.g = 1.0f;
        startColor.b = 1.0f;
        startColor.a = 1.0f;
        
        startColorVar.r = 0.0f;
        startColorVar.g = 0.0f;
        startColorVar.b = 0.0f;
        startColorVar.a = 0.0f;
        
        endColor.r = 1.0f;
        endColor.g = 1.0f;
        endColor.b = 1.0f;
        endColor.a = 1.0f;
        
        endColorVar.r = 0.0f;
        endColorVar.g = 0.0f;
        endColorVar.b = 0.0f;
        endColorVar.a = 0.0f;
        
        myTestParticle.startColor = startColor;
        myTestParticle.startColorVar = startColorVar;
        myTestParticle.endColor = endColor;
        myTestParticle.endColorVar = endColorVar;

        myTestParticle.duration = 0.2;
        //    myTestParticle.life = 1.0f;
        //    myTestParticle.lifeVar = 1;
        
        myTestParticle.speed = 80;
        myTestParticle.speedVar = 20;
        [myTestParticle setTexture:sprParticle.texture];
        myTestParticle.autoRemoveOnFinish = YES;
        [self addChild:myTestParticle z: 100];
    }

    m_bOverLayerExist = true;
    gnLevelScore[m_nLevel] = m_nScore;
    if (m_nLevel < LEVEL_COUNT-1)
    {
        gbLevelUnlock[m_nLevel+1] = true;
        [appDel saveInfo];
    }
    
    
    [appDel saveInfo];

    CCSprite* spr = [CCSprite spriteWithFile:@"level_complete.png"];
    spr.position = ccp(m_winSize.width/2, m_winSize.height/7*4);
    [self addChild: spr z:10];
    
//    float fFontSize = m_winSize.height  / 320.0 * 50;
//    NSString* strScore = [NSString stringWithFormat:@"%d", m_nScore];
//    CCLabelTTF* levelscore = [CCLabelTTF labelWithString:strScore fontName:@"Arial" fontSize:fFontSize];
//    levelscore.color = ccc3(255, 255, 0);
//    levelscore.position = ccp(m_winSize.width/2, m_winSize.height/2);
//    [self addChild:levelscore z:10];

    CCMenuItemImage* btnContinue = [CCMenuItemImage itemWithNormalImage:@"level_continue.png" selectedImage:@"level_continue.png" target:self selector:@selector(onContinue:)];
	btnContinue.position = ccp(m_winSize.width/2, m_winSize.height/7*2);
	
	CCMenu* myMenu1 = [CCMenu menuWithItems: btnContinue, nil];
	myMenu1.position = ccp(0, 0);
	[self addChild:myMenu1 z:11];
    
 
    
    CGSize size = [CCDirector sharedDirector].winSize;
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
    CCMenuItemSprite *menuItemLevelSkips = [CCMenuItemImage itemWithNormalImage:@"menu_levelskips.png" selectedImage:nil target:self selector:@selector(onPlayOn:)];
    CCMenuItemSprite *menuItemMoreGames = [CCMenuItemImage itemWithNormalImage:@"homepage_moregames.png" selectedImage:nil target:self selector:@selector(onMoreGames)];
    CCMenuItemSprite *menuItemNewGames = [CCMenuItemImage itemWithNormalImage:@"homepage_newgames.png" selectedImage:nil target:self selector:@selector(onNewGames)];
    CCMenuItemSprite *menuItemExit = [CCMenuItemImage itemWithNormalImage:@"menu_exit.png" selectedImage:nil target:self selector:@selector(onLink)];
    
    
    CCMenu * menu4 = [CCMenu menuWithItems:menuItemLevelSkips, menuItemMoreGames, menuItemNewGames, menuItemExit, nil];
    
    float padding = (size.width - menuItemLevelSkips.contentSize.width - menuItemMoreGames.contentSize.width- menuItemNewGames.contentSize.width- menuItemExit.contentSize.width) / 5;
    [menu4 alignItemsHorizontallyWithPadding:padding];
    menu4.position = ccp(size.width * 0.5f, menuBar.contentSize.height * 0.5f);
    
    [self addChild:menu4 z:7];    
    
}

-(void) flashScore
{
    CCScaleTo* increaseScale = [CCScaleTo actionWithDuration:0.1 scaleX:1.2f scaleY:1.2f];
    CCScaleTo* decreaseScale = [CCScaleTo actionWithDuration:0.1 scaleX:1 scaleY:1];
    id seq = [CCSequence actions:increaseScale, decreaseScale, nil];
    id action = [CCRepeat actionWithAction:seq times:1];
    
    [m_lblShadowScore runAction:action];
    [m_lblScore runAction:action];
}

- (void) onLevelSkips
{
    AppController* del = (AppController*)[UIApplication sharedApplication].delegate;
    
//	[AdColony playVideoAdForZone:AdColony_ZoneID withDelegate:nil withV4VCPrePopup:YES andV4VCPostPopup:YES];

    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    
    if (gnLevelSkips > 0)
    {
        if (m_nLevel < LEVEL_COUNT-1)
        {
            gnLevelSkips--;
            gbLevelUnlock[m_nLevel+1] = true;
            [del saveInfo];
        }
        [self GotoSelectStage];
        
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
             gnLevelSkips+=3;
             if (m_nLevel < LEVEL_COUNT-1)
             {
                 gnLevelSkips--;
                 gbLevelUnlock[m_nLevel+1] = true;
             }
             
             [del saveInfo];
             [self GotoSelectStage];
         }
         
     }
                                   onCancelled:^
     {
         [MBProgressHUD hideAllHUDsForView:vc.view animated:true];
         NSLog(@"User Cancelled Transaction");
     }];
}

- (void) onMoreGames
{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    [[Chartboost sharedChartboost] showMoreApps];
    AppController* appDel = (AppController*)[[UIApplication sharedApplication] delegate];
    [[PHPublisherContentRequest requestForApp:phtoken secret: phsecret placement: PlayHaven_PlacementID_6 delegate: appDel] send];
}

- (void) onNewGames
{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    AppController* appDel = (AppController*)[[UIApplication sharedApplication] delegate];
    [[PHPublisherContentRequest requestForApp:phtoken secret: phsecret placement: PlayHaven_PlacementID_5 delegate: appDel] send];
//    if (m_bIsGameComplete)
//        [[PHPublisherContentRequest requestForApp:phtoken secret: phsecret placement: PlayHaven_PlacementID_4 delegate: self] send];
//    else
//        [[PHPublisherContentRequest requestForApp:phtoken secret: phsecret placement: PlayHaven_PlacementID_2 delegate: self] send];
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


-(void) onContinue: (id) sender
{
    if (gbSoundEnable)
    [[SimpleAudioEngine sharedEngine] playEffect:@"buffoneffect.mp3"];
    [self GotoSelectStage];
}

-(void) playSecondCombo:(ccTime)dt{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"shoot.mp3"];
    [self scheduleOnce:@selector(playThirdHit:) delay:0.1];
}

-(void) playThirdCombo:(ccTime)dt{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"blank.mp3"];
}

-(void) setFlyingBall:(CCSprite*)sprBall TargetPos:(CGPoint) location
{
    if (m_bEffectMusicEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"blank.mp3"];
    
    if (m_bEffectMusicEnable)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"blank.mp3"];
       [self scheduleOnce:@selector(playSecondCombo:) delay:0.1];
    }
    
    m_sprFlyingBall = sprBall;
    CGPoint ptBall = [sprBall position];
    
    float nLargeLine = sqrt((ptBall.x - location.x)*(ptBall.x - location.x) + (ptBall.y - location.y)*(ptBall.y - location.y));
    float nDifX = location.x - ptBall.x;
    float nDifY = location.y - ptBall.y;
    
    float rX, rY;
    rX = (DEF_Ball_FlyingSpeed*nDifX)/nLargeLine;
    rY = (DEF_Ball_FlyingSpeed*nDifY)/nLargeLine;
    
    m_FlyingSpeed.width = rX;
    m_FlyingSpeed.height = rY;
    
    m_nFlyingBallColor = m_nShootBallColor;
    m_bHasFlyingBall = true;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches){
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        
        if (!m_bIsPlaying)
            return;
        
        if (m_bHasFlyingBall == false && m_bIsFastSortingChain == false && m_bIsFiring == false &&[self checkBackChainToPowerBall] == -1 && m_bFirstSlide == false)
        {
            [self rotateShooter:location];
            [self actionShooter];
            [self setFlyingBall:m_sprShootBall TargetPos:location];
            [self makeShootBall];
        }
    }
}

-(void) loadBallColor
{
    m_nCountOfBallKind = 0;
    int nCount = [m_parseOperation getColorCount];
    bool bIsExist = false;
    for (int i = 0; i < nCount; i++)
    {
        bIsExist = false;
        for (int j = 0; j < m_nCountOfBallKind; j++)
        {
            if ([m_parseOperation getColorFromIndex:i] == m_BallKind[j])
                bIsExist = true;
        }
        if (bIsExist == false)
        {
            m_BallKind[m_nCountOfBallKind] = [m_parseOperation getColorFromIndex:i];
            m_nCountOfBallKind++;
        }
    }
}

-(void) calcBallKind
{
    m_nCountOfBallKind = 0;
    int nCount = [m_BallColorArray count];
    bool bIsExist = false;
    for (int i = 0; i < nCount; i++)
    {
        bIsExist = false;
        NSNumber* oneNum = m_BallColorArray[i];
        for (int j = 0; j < m_nCountOfBallKind; j++)
        {
            if ([oneNum intValue] == m_BallKind[j])
                bIsExist = true;
        }
        if (bIsExist == false)
        {
            m_BallKind[m_nCountOfBallKind] = [oneNum intValue];
            m_nCountOfBallKind++;
        }
    }
}

-(void) BallFlyingAnimation
{
    if (m_sprFlyingBall == NULL)
        return;
    
    CGPoint pt = [m_sprFlyingBall position];
    
    pt.x += m_FlyingSpeed.width;
    pt.y += m_FlyingSpeed.height;
    
    if (pt.x < 0 || pt.x > m_winSize.width || pt.y < 0 || pt.y > m_winSize.height)
    {
        m_bHasFlyingBall = false;
        CGPoint outPt; outPt.x = -100; outPt.y = -100;
        [m_sprFlyingBall setPosition:outPt];
        [self removeChild:m_sprFlyingBall cleanup:YES];
        m_sprFlyingBall = NULL;
        return;
    }
    
    [m_sprFlyingBall setPosition:pt];
}

-(float) getDistanceToTrace:(CGPoint)ptFlying Index:(int)nIndex
{
    int nMyIndex = nIndex;
    float fDistance;
    if (nMyIndex % 2 == 1)
        nMyIndex--;
    
    CGPoint ptFirst = [m_parseOperation getPosFromIndex:nMyIndex];
    CGPoint ptSecond = [m_parseOperation getPosFromIndex:nMyIndex+1];
    CGPoint ptThird = [m_parseOperation getPosFromIndex:nMyIndex+2];
    
    if ([self isLine:ptFirst Second:ptSecond Third:ptThird])    // if it is line, ...
    {   // y = ax+b
        float a = [self getAOfLineEquation:ptFirst To:ptThird];
        float b = [self getBOfLineEquation:ptFirst To:ptThird];
        float x1 = ptFlying.x;
        float y1 = a*x1+b;

        if (a == 0 && b == 0)
            fDistance = ptFlying.x - ptFirst.x;
        else
            fDistance = y1-ptFlying.y;
    }
    else // if it is circle, ...
    {
        float cx = [self getCXOfCircleEquation:ptFirst Second:ptSecond Third:ptThird];
        float cy = [self getCYOfCircleEquation:ptFirst Second:ptSecond Third:ptThird];
        float r = [self getROfCircleEquation:ptFirst Second:ptSecond Third:ptThird];
        float x1 = ptFlying.x;
        float y1 = sqrt([self absf:(r*r-(x1-cx)*(x1-cx))])+cy;
        float y2 = cy - sqrt([self absf:(r*r-(x1-cx)*(x1-cx))]);
        
        float fDistance1 = [self absf:(y1-ptFlying.y)];
        float fDistance2 = [self absf:(y2-ptFlying.y)];

        fDistance = (fDistance1 > fDistance2) ? fDistance2 : fDistance1;
    }
    
    if (fDistance < 0)
        fDistance = -fDistance;
    return fDistance;
}

-(int) getFirstIndexOfChain:(int)nLastIndex
{
    CGRect ballRect = [m_sprShootBall boundingBox];
    int nFirstIndex = nLastIndex;
    int nNextIndex = nLastIndex;
    while (nFirstIndex >= 0)
    {
        CCSprite* sprBall1 = m_sprBallArray[nFirstIndex];
        CCSprite* sprBall2 = m_sprBallArray[nNextIndex];
        CGPoint pt1 = [sprBall1 position];
        CGPoint pt2 = [sprBall2 position];
        float dist = sqrt((pt1.x-pt2.x)*(pt1.x-pt2.x)+(pt1.y-pt2.y)*(pt1.y-pt2.y));
        if (dist > ballRect.size.width + DEF_DistCalc_Offset)
            break;
        
        if (nFirstIndex != nNextIndex)
            nNextIndex--;
        
        nFirstIndex--;
    }
    nFirstIndex++;
    
    return nFirstIndex;
}

-(int) getLastIndexOfChain:(int)nFirstIndex
{
    CGRect ballRect = [m_sprShootBall boundingBox];
    int nCount = [m_sprBallArray count];
    int nLastIndex = nFirstIndex;
    int nPrevIndex = nFirstIndex;
    while (nLastIndex < nCount)
    {
        CCSprite* sprBall1 = m_sprBallArray[nLastIndex];
        CCSprite* sprBall2 = m_sprBallArray[nPrevIndex];
        CGPoint pt1 = [sprBall1 position];
        CGPoint pt2 = [sprBall2 position];
        float dist = sqrt((pt1.x-pt2.x)*(pt1.x-pt2.x)+(pt1.y-pt2.y)*(pt1.y-pt2.y));
        if (dist > ballRect.size.width + DEF_DistCalc_Offset*2)
            break;
        
        if (nLastIndex != nPrevIndex)
            nPrevIndex++;
        
        nLastIndex++;
    }
    nLastIndex--;
    
    return nLastIndex;
}

-(void) setFastSortChain:(int)nSortIndex
{
    m_bIsFastSortingChain = true;
    m_nFastSortFrom = [self getFirstIndexOfChain:nSortIndex];
    m_nFastSortTo = nSortIndex;
}

-(bool) isCrashingTwoBalls:(CGPoint)ptFirst Second:(CGPoint)ptSecond Width:(int)nBallWidth
{
    float fDist = (ptFirst.x-ptSecond.x)*(ptFirst.x-ptSecond.x)+(ptFirst.y-ptSecond.y)*(ptFirst.y-ptSecond.y);
    fDist = sqrt(fDist);
    
    if (fDist < nBallWidth)
        return true;
    
    return false;
}

-(bool)isMyBallFrontOfBall:(CGPoint)ptMyBall Other:(CGPoint)ptOther LocationIndex:(int)nIndex
{
    if ([m_parseOperation getLocationCount] <= nIndex+2)
        return false;
    
    CGPoint ptFirst = [m_parseOperation getPosFromIndex:nIndex];
    CGPoint ptSecond = [m_parseOperation getPosFromIndex:nIndex+1];
    CGPoint ptThird = [m_parseOperation getPosFromIndex:nIndex+2];
    
//    float nCheckValue = (ptFirst.x-ptSecond.x)*(ptThird.y-ptFirst.x)-(ptFirst.x-ptThird.x)*(ptSecond.y-ptFirst.y);
//    if (nCheckValue > -0.01 && nCheckValue < 0.01)
    if ([self isLine:ptFirst Second:ptSecond Third:ptThird])
    {
        float distMy = sqrt((ptFirst.x-ptMyBall.x)*(ptFirst.x-ptMyBall.x)+(ptFirst.y-ptMyBall.y)*(ptFirst.y-ptMyBall.y));
        float distOther = sqrt((ptFirst.x-ptOther.x)*(ptFirst.x-ptOther.x)+(ptFirst.y-ptOther.y)*(ptFirst.y-ptOther.y));
        if (distOther > distMy)
            return false;
        else
            return true;
    }
    
    float cx = [self getCXOfCircleEquation:ptFirst Second:ptSecond Third:ptThird];
    float cy = [self getCYOfCircleEquation:ptFirst Second:ptSecond Third:ptThird];
    float r = [self getROfCircleEquation:ptFirst Second:ptSecond Third:ptThird];

    float alpha1 = [self acosfnear:((ptFirst.x-cx)/r)];
    float alpha2 = [self asinfnear:((ptFirst.y-cy)/r)];
    float firstAlpha = [self getAlphaFromArcSinCos:alpha1 Sin:alpha2];
    firstAlpha = (firstAlpha > 0) ? firstAlpha : firstAlpha+2*PI;

    alpha1 = [self acosfnear:((ptSecond.x-cx)/r)];
    alpha2 = [self asinfnear:((ptSecond.y-cy)/r)];
    float secondAlpha = [self getAlphaFromArcSinCos:alpha1 Sin:alpha2];
    secondAlpha = (secondAlpha > 0) ? secondAlpha : secondAlpha+2*PI;
    
    alpha1 = [self acosfnear:((ptThird.x-cx)/r)];
    alpha2 = [self asinfnear:((ptThird.y-cy)/r)];
    float thirdAlpha = [self getAlphaFromArcSinCos:alpha1 Sin:alpha2];
    thirdAlpha = (thirdAlpha > 0) ? thirdAlpha : thirdAlpha+2*PI;
    
    if (secondAlpha > firstAlpha && secondAlpha > thirdAlpha)
    {
        if (firstAlpha > PI)
            thirdAlpha += 2*PI;
        else
            firstAlpha += 2*PI;
    }
    else if (secondAlpha < firstAlpha && secondAlpha < thirdAlpha)
    {
        if (firstAlpha > PI)
        {
            secondAlpha += 2*PI;
            thirdAlpha += 2*PI;
        }
        else
        {
            firstAlpha += 2*PI;
            secondAlpha += 2*PI;
        }
    }

    float fArrow;
    if (firstAlpha > secondAlpha && secondAlpha > thirdAlpha)
    {
        fArrow = -1.0f;
    }
    else
    {
        fArrow = 1.0f;
    }

    alpha1 = [self acosfnear:((ptMyBall.x-cx)/r)];
    alpha2 = [self asinfnear:((ptMyBall.y-cy)/r)];
    float myAlpha = [self getAlphaFromArcSinCos:alpha1 Sin:alpha2];
    myAlpha = (myAlpha > 0) ? myAlpha : myAlpha+2*PI;
    myAlpha = (firstAlpha < thirdAlpha && firstAlpha > 2*PI && myAlpha < 2*PI) ? myAlpha+2*PI : myAlpha;
    myAlpha = (firstAlpha > thirdAlpha && thirdAlpha > 2*PI && myAlpha < 2*PI) ? myAlpha+2*PI : myAlpha;
    
    if (/*fArrow*fOffset < 0 && */firstAlpha > secondAlpha && firstAlpha > thirdAlpha && myAlpha < thirdAlpha && firstAlpha-myAlpha > PI)
    {
        myAlpha += 2*PI;
    }
    
    else if (/*fArrow*fOffset > 0 && */thirdAlpha > secondAlpha && thirdAlpha > firstAlpha && myAlpha < firstAlpha && thirdAlpha-myAlpha > PI)
    {
        myAlpha += 2*PI;
    }

    alpha1 = [self acosfnear:((ptOther.x-cx)/r)];
    alpha2 = [self asinfnear:((ptOther.y-cy)/r)];
    float otherAlpha = [self getAlphaFromArcSinCos:alpha1 Sin:alpha2];
    otherAlpha = (otherAlpha > 0) ? otherAlpha : otherAlpha+2*PI;
    otherAlpha = (firstAlpha < thirdAlpha && firstAlpha > 2*PI && otherAlpha < 2*PI) ? otherAlpha+2*PI : otherAlpha;
    otherAlpha = (firstAlpha > thirdAlpha && thirdAlpha > 2*PI && otherAlpha < 2*PI) ? otherAlpha+2*PI : otherAlpha;
    
    if (/*fArrow*fOffset < 0 && */firstAlpha > secondAlpha && firstAlpha > thirdAlpha && otherAlpha < thirdAlpha && firstAlpha-otherAlpha > PI)
    {
        otherAlpha += 2*PI;
    }
    
    else if (/*fArrow*fOffset > 0 && */thirdAlpha > secondAlpha && thirdAlpha > firstAlpha && otherAlpha < firstAlpha && thirdAlpha-otherAlpha > PI)
    {
        otherAlpha += 2*PI;
    }

    if ((secondAlpha > firstAlpha && myAlpha < otherAlpha) ||
        (secondAlpha < firstAlpha && myAlpha > otherAlpha))
    {
        return false;
    }
    
    return true;
}

-(void)checkAddingFlyingBallToChain
{
    if (m_sprFlyingBall == NULL)
        return;
    
    CGPoint ptFlying = [m_sprFlyingBall position];
    int nCount = [m_sprBallArray count];
    CGRect ballRect = [m_sprFlyingBall boundingBox];
    int nMyIndex = 0;
    
    bool bIsCrashing = false;
    
    for (int i = 0; i < nCount; i++)
    {
        CCSprite* sprBall = m_sprBallArray[i];
        
        CGPoint ptChain = [sprBall position];
        float fDistance = sqrt((ptFlying.x - ptChain.x)*(ptFlying.x - ptChain.x)+(ptFlying.y - ptChain.y)*(ptFlying.y - ptChain.y));
        if (fDistance < ballRect.size.width)
        {
            NSNumber* numFirst = m_BallPosIndex[i];
            
            if ([m_parseOperation getLocationCount] <= [numFirst intValue]+2)
                return;
            
            if (m_bIsFiring && i >= m_nFireFrom && i <= m_nFireTo)
                continue;
            
            CGPoint ptFirst = [m_parseOperation getPosFromIndex:[numFirst intValue]];
            CGPoint ptSecond = [m_parseOperation getPosFromIndex:[numFirst intValue]+1];
            CGPoint ptThird = [m_parseOperation getPosFromIndex:[numFirst intValue]+2];
            
            if ([self isLine:ptFirst Second:ptSecond Third:ptThird] == false)
            {
                float cx = [self getCXOfCircleEquation:ptFirst Second:ptSecond Third:ptThird];
                float cy = [self getCYOfCircleEquation:ptFirst Second:ptSecond Third:ptThird];
                float r = [self getROfCircleEquation:ptFirst Second:ptSecond Third:ptThird];
                float x = [self intersectionEquationXOfLineAndCircle:ptFlying To:[m_parseOperation getShooterPos] CX:cx CY:cy R:r];
                float y = [self intersectionEquationYOfLineAndCircle:ptFlying To:[m_parseOperation getShooterPos] CX:cx CY:cy R:r];
                CGPoint newPt; newPt.x = x; newPt.y = y;

                if (newPt.x != 0 && newPt.y != 0)
                {
                    newPt = [self getNextPosFromCircle:newPt Circle:[numFirst intValue] offset:0];
                    if (newPt.x != 0 && newPt.y != 0)
                    {
                        ptFlying = newPt;
                        [m_sprFlyingBall setPosition:newPt];
                    }
                    else
                    {
                        ptFlying = ptChain;
                        [m_sprFlyingBall setPosition:ptChain];
                    }
                }
                else
                {
                    ptFlying = ptChain;
                    [m_sprFlyingBall setPosition:ptChain];
                }
            }
            else
            {
                // y=ax+b y=cx+d
                float a = [self getAOfLineEquation:ptFirst To:ptThird];
                float b = [self getBOfLineEquation:ptFirst To:ptThird];
                float c = [self getAOfLineEquation:ptFlying To:[m_parseOperation getShooterPos]];
                float d = [self getBOfLineEquation:ptFlying To:[m_parseOperation getShooterPos]];
                
                float x=0,y=0;
                
                if (a==0 && b==0)
                {
                    x = ptFirst.x;
                    y = c*x+d;
                }
                else if (c==0 && d==0)
                {
                    x = ptFlying.x;
                    y = a*x+b;
                }
                else if (a != c)
                {
                    x = (d-b)/(a-c);
                    y = a*x+b;
                }
                
                
                CGPoint newPt; newPt.x = x; newPt.y = y;
                if (newPt.x != 0 && newPt.y != 0)
                {
                    float distorg = sqrtf((ptFirst.x-ptThird.x)*(ptFirst.x-ptThird.x)+(ptFirst.y-ptThird.y)*(ptFirst.y-ptThird.y));
                    float dist1 = sqrtf((ptFirst.x-newPt.x)*(ptFirst.x-newPt.x)+(ptFirst.y-newPt.y)*(ptFirst.y-newPt.y));
                    float dist2 = sqrtf((newPt.x-ptThird.x)*(newPt.x-ptThird.x)+(newPt.y-ptThird.y)*(newPt.y-ptThird.y));
                    
                    if (dist1 > distorg || dist2 > distorg)
                    {
                        ptFlying = ptChain;
                        [m_sprFlyingBall setPosition:ptChain];
                    }
                    else
                    {
                        ptFlying = newPt;
                        [m_sprFlyingBall setPosition:newPt];
                    }
                }
                else
                {
                    ptFlying = ptChain;
                    [m_sprFlyingBall setPosition:ptChain];
                }
                
            }
            
            bIsCrashing = true;
            break;
        }
    }
    
    if (bIsCrashing == false)
        return;
    
    float fMinDistance = 10000.0f;
    int nInsertIndex = 0;
    
    for (int i = 0; i < nCount; i++)
    {
        CCSprite* sprBall = m_sprBallArray[i];
        
        CGPoint ptChain = [sprBall position];
        float fDistance = sqrt((ptFlying.x - ptChain.x)*(ptFlying.x - ptChain.x)+(ptFlying.y - ptChain.y)*(ptFlying.y - ptChain.y));
        if (fDistance < ballRect.size.width && fDistance < fMinDistance)
        {
            nInsertIndex = i;
            fMinDistance = fDistance;
        }
    }
    
    CCSprite* sprBall = m_sprBallArray[nInsertIndex];
    NSNumber* numBallPosIndex = m_BallPosIndex[nInsertIndex];
    bool isFront = [self isMyBallFrontOfBall:ptFlying Other:[sprBall position] LocationIndex:[numBallPosIndex intValue]];
    
    if (!isFront)
        nMyIndex = nInsertIndex+1;
    else
        nMyIndex = nInsertIndex;
    
    NSNumber* prevN;
    if (nMyIndex == [self getFirstIndexOfChain:nInsertIndex])
    {
        prevN = m_BallPosIndex[nInsertIndex];
    }
    else
    {
        prevN = m_BallPosIndex[nMyIndex-1];
    }
    
    if (m_bEffectMusicEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"hit.mp3"];
    
    [m_sprBallArray insertObject:m_sprFlyingBall atIndex:nMyIndex];
    NSNumber* newN = [NSNumber numberWithInt:[prevN intValue]];
    [m_BallPosIndex insertObject:newN atIndex:nMyIndex];
    NSNumber* newColor = [NSNumber numberWithInt:m_nFlyingBallColor];
    [m_BallColorArray insertObject:newColor atIndex:nMyIndex];
    m_bHasFlyingBall = false;
    [self setFastSortChain:nMyIndex];
}

-(int) getFirstIndexSameColorOfChain:(int)nLastIndex
{
    int nFirstIndexOfChain = [self getFirstIndexOfChain:nLastIndex];
    
    int nFirstIndexSameColor = nLastIndex;
    NSNumber* nShootedColorNum = m_BallColorArray[nLastIndex];
    NSNumber* nNum = m_BallColorArray[nFirstIndexSameColor];
    
    while ([nShootedColorNum intValue] == [nNum intValue] && nFirstIndexSameColor > nFirstIndexOfChain)
    {
        nFirstIndexSameColor--;
        nNum = m_BallColorArray[nFirstIndexSameColor];
    }
    if ([nShootedColorNum intValue] != [nNum intValue])
        nFirstIndexSameColor++;

    return nFirstIndexSameColor;
}

-(int) getLastIndexSameColorOfChain:(int)nFirstIndex
{
    int nLastIndexOfChain = [self getLastIndexOfChain:nFirstIndex];
    int nLastIndexSameColor = nFirstIndex;
    NSNumber* nShootedColorNum = m_BallColorArray[nFirstIndex];
    NSNumber* nNum = m_BallColorArray[nLastIndexSameColor];
    while ([nShootedColorNum intValue] == [nNum intValue] && nLastIndexSameColor < nLastIndexOfChain)
    {
        nLastIndexSameColor++;
        nNum = m_BallColorArray[nLastIndexSameColor];
    }
    if ([nShootedColorNum intValue] != [nNum intValue])
        nLastIndexSameColor--;
    
    return nLastIndexSameColor;
}

-(void) onHit:(int)shootedIndex
{
    int nFirstIndexSameColor = [self getFirstIndexSameColorOfChain:shootedIndex];
    int nLastIndexSameColor = [self getLastIndexSameColorOfChain:shootedIndex];
    
    if (nLastIndexSameColor - nFirstIndexSameColor >= 2)    // more than 3
    {
        if (m_bIsFiring)
        {
            m_bIsFiring = false;
            m_nFireIndex = 0;
            [self removeBallsFromChainFrom:m_nFireFrom To:m_nFireTo];
        }
        
        for (int i = nFirstIndexSameColor; i <= nLastIndexSameColor; i++)
        {
            CCSprite* sprBall = m_sprBallArray[i];
            [sprBall setVisible:FALSE];
        }
        
        if (gbSoundEnable)
            [[SimpleAudioEngine sharedEngine] playEffect:@"pop.mp3"];

        
        [self scheduleOnce:@selector(playSecondHit:) delay:0.1];
        
        m_nFireFrom = nFirstIndexSameColor;
        m_nFireTo = nLastIndexSameColor;
        m_bIsFiring = true;
    }
}

-(void) playSecondHit:(ccTime)dt{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"blank.mp3"];
    [self scheduleOnce:@selector(playThirdHit:) delay:0.1];
}

-(void) playThirdHit:(ccTime)dt{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"blank.mp3"];
    [self scheduleOnce:@selector(playFourthHit:) delay:0.1];
}

-(void) playFourthHit:(ccTime)dt{
    if (gbSoundEnable)
        [[SimpleAudioEngine sharedEngine] playEffect:@"blank.mp3"];
}

-(void) removeBallsFromChainFrom:(int)nFromIndex To:(int)nToIndex
{
/*    for (int i = nFromIndex; i <= nToIndex; i++)
    {
        CCSprite* sprBall = m_sprBallArray[i];
        switch (sprBall.tag) {
            case DEF_BombTag_Back:
                m_nBombKind = DEF_BombTag_Back;
                m_ccUpdateBombBackDelay = DEF_BombBack_Delay;
                break;
            case DEF_BombTag_Bomb:
                m_nBombKind = DEF_BombTag_Bomb;
                NSNumber* oneNum = m_BallColorArray[i];
                m_nBombParam = [oneNum intValue];
                break;
            case DEF_BombTag_Stop:
                m_nBombKind = DEF_BombTag_Stop;
                m_ccUpdateBombStopDelay = DEF_BombStop_Delay;
                break;
            default:
                break;
        }
    }*/
    
    NSRange removeRange;
    removeRange.location = nFromIndex;
    removeRange.length = nToIndex-nFromIndex+1;
    
    if (m_nPowerIndex > nToIndex)
        m_nPowerIndex -= removeRange.length;
    else if (m_nPowerIndex >= nFromIndex && m_nPowerIndex <= nToIndex)
    {
        m_nPowerIndex = nToIndex+1-removeRange.length;
        if ([m_sprBallArray count]-1 <= nToIndex)
            m_nPowerIndex--;
    }
    
    CCSprite* sprBall = m_sprBallArray[0];
    NSNumber* oneNum = m_BallPosIndex[0];
    
    m_ptComplete = [sprBall position];
    m_nCompletePosIndex = [oneNum intValue];

    m_nScore = m_nScore + 10*removeRange.length*removeRange.length;
    NSString* str = [NSString stringWithFormat:@"%d", m_nScore];
    [m_lblShadowScore setString:str];
    [m_lblScore setString:str];
    
    [self flashScore];
    
    [m_sprBallArray removeObjectsInRange:removeRange];
    [m_BallPosIndex removeObjectsInRange:removeRange];
    [m_BallColorArray removeObjectsInRange:removeRange];
    
    if ([m_sprBallArray count] == 0)
    {
        [m_sprFires[0][0] setPosition:m_ptComplete];
        m_bIsGameComplete = true;
        if (m_bBackgroundMusicEnable)
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        return;
    }
    
    [self calcBallKind];
    
    int nLastIndex = [m_sprBallArray count]-1;
    if (nLastIndex < 0)
        return;
    
    [self updatePowerIndex:false];
}

-(void) updatePowerIndex:(bool)bHit
{
    int nLastIndex = [m_sprBallArray count]-1;
    if (nLastIndex < 0)
        return;
    
    int newPowerIndex = [self getFirstIndexOfChain:nLastIndex];
    
    if (newPowerIndex != m_nPowerIndex && m_nPowerIndex <= nLastIndex)
    {
        [self FitBall:m_nPowerIndex];
    }
    
    for (int i = 0; i<[m_sprBallArray count]; i++) {
        CGRect ballRect = [m_sprShootBall boundingBox];
        float fDist1=0, fDist2=0;
        if (i == 0)
            fDist1 = ballRect.size.width;
        else if ([self getDistanceBetweenBalls:i-1 Second:i] > ballRect.size.width+DEF_DistCalc_Offset)
        {
            fDist1 = ballRect.size.width;
        }
        else
            fDist1 = [self getDistanceBetweenBalls:i-1 Second:i];
        
        if (i >= [m_sprBallArray count]-1)
            fDist2 = ballRect.size.width;
        else if ([self getDistanceBetweenBalls:i+1 Second:i] > ballRect.size.width+DEF_DistCalc_Offset)
        {
            fDist2 = ballRect.size.width;
        }
        else
            fDist2 = [self getDistanceBetweenBalls:i+1 Second:i];
        
        if (m_bIsFastSortingChain == false && ([self absf:(fDist1-ballRect.size.width)] > DEF_CheckValue || [self absf:(fDist2-ballRect.size.width)] > DEF_CheckValue))
        {
            [self FitBall:i];
        }
    }

    if (newPowerIndex < m_nPowerIndex && bHit && m_nPowerIndex <= nLastIndex)
    {
        NSNumber* color1 = m_BallColorArray[m_nPowerIndex-1];
        NSNumber* color2 = m_BallColorArray[m_nPowerIndex];
        if ([color1 intValue] == [color2 intValue])
        {
            [self onHit:m_nPowerIndex];
            m_nBackPower = DEF_Back_Power;
        }
    }
    m_nPowerIndex = newPowerIndex;
}

-(int) checkBackChainToPowerBall
{
    if (m_nPowerIndex <= 0)
        return -1;
    
    NSNumber* prev = m_BallColorArray[m_nPowerIndex-1];
    NSNumber* power = m_BallColorArray[m_nPowerIndex];
    
    if ([prev intValue] == [power intValue])
    {
        return [self getFirstIndexOfChain:m_nPowerIndex-1];
    }
    
    return -1;
}

-(void) GameOverAnimation
{
    if (m_bDanger == true)
    {
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        if (m_bBackgroundMusicEnable)
            [[SimpleAudioEngine sharedEngine] playEffect:@"game-lose.mp3"];
        m_bDanger = false;
    }

//    printf ("ObjectAtIndex 12\n");
    CCSprite* oneBallSprite = [m_sprBallArray objectAtIndex:0];
    
    int ncount = [m_sprBallArray count];
    for (int i = 0; i < ncount; i++)
    {
//        printf ("ObjectAtIndex 13\n");
        oneBallSprite = [m_sprBallArray objectAtIndex:i];
        CGPoint ptCurrent = [oneBallSprite position];
        m_fRemainedDist = DEF_GameOverSpeed;
        while (m_fRemainedDist >= 0.01 || m_fRemainedDist <= -0.01)
        {
            NSNumber* numBallPosIndex = m_BallPosIndex[i];
            ptCurrent = [self getNextPos:ptCurrent Index:[numBallPosIndex intValue] offset:m_fRemainedDist];
            
            if ([m_parseOperation getLocationCount] <= [numBallPosIndex intValue]+2)
            {
                [oneBallSprite setVisible:FALSE];
                break;
            }
            
            if (m_fRemainedDist >= 0.01 || m_fRemainedDist <= -0.01)
            {
                NSNumber* newNum = [NSNumber numberWithInt:[numBallPosIndex intValue]+2];
//                printf ("ObjectAtIndex 14\n");
                [m_BallPosIndex replaceObjectAtIndex:i withObject:(id)newNum];
                
                int nVa = [newNum intValue];
                if (nVa >= [m_parseOperation getLocationCount]-1)
                {
                    [oneBallSprite setVisible:FALSE];
                    if (i == ncount-1)
                    {
                        m_bIsGameDone = true; [self GameOverProc]; return;
                    }
                    break;
                }
            }
        }
        [oneBallSprite setPosition:ptCurrent];
    }
}

-(void) CompleteAnimation
{
    CGRect boundingRect = [m_sprFires[0][0] boundingBox];
    CGPoint ptCurrent = [m_sprFires[0][0] position];
    m_fRemainedDist = boundingRect.size.width;
    [m_sprFires[0][0] setVisible:TRUE];
    while (m_fRemainedDist >= 0.01 || m_fRemainedDist <= -0.01)
    {
        ptCurrent = [self getNextPos:ptCurrent Index:m_nCompletePosIndex offset:m_fRemainedDist];
        if (m_fRemainedDist >= 0.01 || m_fRemainedDist <= -0.01)
        {
            m_nCompletePosIndex +=2;
        }
        if ([m_parseOperation getLocationCount] <= m_nCompletePosIndex+2)
        {
            [m_sprFires[0][0] setVisible:FALSE]; m_bIsGameDone = true; [self GameCompleteProc]; break;
        }
    }
    [m_sprFires[0][0] setPosition:ptCurrent];
    
    if (m_bIsGameDone)
    {
        for (int i = 0; i < DEF_Fire_Count; i++)
        {
            [m_sprFires[i][i] setVisible:FALSE];
        }
        return;
    }
    
    int nMovingIndex = m_nCompletePosIndex;
    for (int i = 1; i < DEF_Fire_Count; i++)
    {
        [m_sprFires[i][i] setVisible:TRUE];
        CGPoint ptCurrent = [m_sprFires[i-1][i-1] position];
        m_fRemainedDist = -boundingRect.size.width;
        while (m_fRemainedDist >= 0.01 || m_fRemainedDist <= -0.01)
        {
            ptCurrent = [self getNextPos:ptCurrent Index:nMovingIndex offset:m_fRemainedDist];
            if (m_fRemainedDist >= 0.01 || m_fRemainedDist <= -0.01)
            {
                nMovingIndex -=2;
            }
            if (nMovingIndex <= 0)
            {
                [m_sprFires[i][i] setVisible:FALSE]; break;
            }
        }
        [m_sprFires[i][i] setPosition:ptCurrent];
    }
}

-(void) procGameFinish
{
    if (m_ccUpdateFastSortTime > DEF_FastSortChain_Interval)
    {
        if (m_bIsGameComplete)
            [self CompleteAnimation];
        else if (m_bIsGameOver)
            [self GameOverAnimation];
    }
    
    if (m_bIsGameOver || m_bIsGameComplete)
    {
/*        for (int i = 0; i < DEF_BombKind_Count; i++)
        {
            for (int j = 0; j < DEF_BombAni_Count; j++)
            {
                [m_sprBomb[i][j] setVisible:FALSE];
            }
        }*/
        
        return;
    }
}

-(void) procBomb
{
    if (m_ccUpdateBombBackDelay <= 0 && m_nBombKind == DEF_BombTag_Back)
    {
        m_nBombKind = -1;
    }
    if (m_ccUpdateBombStopDelay <= 0 && m_nBombKind == DEF_BombTag_Stop)
    {
        m_nBombKind = -1;
    }
    if (m_nBombKind == DEF_BombTag_Bomb)
    {
        bool bAllProcess = true;
        int nCount = [m_sprBallArray count];
        for (int i = 0; i < nCount; i++)
        {
            NSNumber* oneNum = m_BallColorArray[i];
            if ([oneNum intValue] == m_nBombParam)
            {
                int nFirstIndexSameColor = [self getFirstIndexSameColorOfChain:i];
                int nLastIndexSameColor = [self getLastIndexSameColorOfChain:i];
                if (nLastIndexSameColor - nFirstIndexSameColor >= 2)    // more than 3
                {
                    bAllProcess = false;
                    [self onHit:i];
                    break;
                }
            }
            
        }
        if (bAllProcess == true)
            m_nBombKind = -1;
    }
    if (m_nBombKind == -1)
    {
        m_ccUpdateBombBackDelay = 0;
        m_ccUpdateBombStopDelay = 0;
    }
}

-(void) procBallAnimation
{
    if ([m_parseOperation getLocationCount] >= 1)
    {
        if (m_nBombKind != DEF_BombTag_Stop)
            [self BallAnimation];
//        [self BombAnimation];
    }
    
    if (m_BallPosIndex.count > 0)
    {
        bool bDanger;
        NSNumber* numBallPosIndex = m_BallPosIndex[0];
        if ([m_parseOperation getLocationCount] > [numBallPosIndex intValue]+11)
            bDanger = false;
        else
            bDanger = true;
        
        if (m_bDanger != bDanger)
        {
            m_bDanger = bDanger;
            [self loadBackgroundMusic];
        }
    }
}

-(void) initEngine
{
    [self loadShooter];
    [self loadBalls];
    [self loadBallColor];
    [self makeShootBall];
    m_nPowerIndex = 0;
}

-(void) FitBall:(int)nIndex
{
    CGRect ballRect = [m_sprShootBall boundingBox];
    float fDist1=0, fDist2=0;
    if (nIndex == 0)
        fDist1 = ballRect.size.width;
    else if ([self getDistanceBetweenBalls:nIndex-1 Second:nIndex] > ballRect.size.width+DEF_DistCalc_Offset)
    {
        fDist1 = ballRect.size.width;
    }
    else
        fDist1 = [self getDistanceBetweenBalls:nIndex-1 Second:nIndex];
    
    if (nIndex >= [m_sprBallArray count]-1)
        fDist2 = ballRect.size.width;
    else if ([self getDistanceBetweenBalls:nIndex+1 Second:nIndex] > ballRect.size.width+DEF_DistCalc_Offset)
    {
        fDist2 = ballRect.size.width;
    }
    else
        fDist2 = [self getDistanceBetweenBalls:nIndex+1 Second:nIndex];
    
    int nFirst = [self getFirstIndexOfChain:nIndex];
    
//    if ([self absf:(fDist1-ballRect.size.width)] <= DEF_DistCalc_Offset && [self absf:(fDist2-ballRect.size.width)] <= DEF_DistCalc_Offset)
    {
        float fRemained = ballRect.size.width-fDist1;
        if (fRemained != 0)
        {
            [self BallAnimationFrom:nFirst To:nIndex-1 RightArrow:true Offset:fRemained];
        }
        fRemained = ballRect.size.width-fDist2;
        if (fRemained != 0)
        {
            [self BallAnimationFrom:nFirst To:nIndex RightArrow:true Offset:fRemained];
        }
    }
}

-(void) procFastSort
{
    int nFirstIndex = [self checkBackChainToPowerBall];
    
    if (nFirstIndex >= 0 && m_bIsFastSortingChain == false)
    {
        [self BallAnimationFrom:nFirstIndex To:m_nPowerIndex-1 RightArrow:false Offset:0];
    }
    
    if (m_bIsFastSortingChain)
    {
        bool bIsNormal = true;
        if (m_nFastSortTo != 0 && m_nFastSortTo < [m_sprBallArray count]-1)
        {
            if ([self getDistanceBetweenBalls:m_nFastSortTo-1 Second:m_nFastSortTo] > [self getDistanceBetweenBalls:m_nFastSortTo-1 Second:m_nFastSortTo+1])
            {
                [self BallAnimationFrom:m_nFastSortTo To:m_nFastSortTo RightArrow:true Offset:0];bIsNormal = false;
            }
            if ([self getDistanceBetweenBalls:m_nFastSortTo Second:m_nFastSortTo+1] > [self getDistanceBetweenBalls:m_nFastSortTo-1 Second:m_nFastSortTo+1])
            {
                [self BallAnimationFrom:m_nFastSortTo To:m_nFastSortTo RightArrow:false Offset:0];bIsNormal = false;
            }
        }
        
        if (bIsNormal)
        {
            CGRect ballRect = [m_sprShootBall boundingBox];
            float fDist1=0, fDist2=0;
            if (m_nFastSortTo == 0)
                fDist1 = ballRect.size.width;
            else if ([self getDistanceBetweenBalls:m_nFastSortTo-1 Second:m_nFastSortTo] > ballRect.size.width+DEF_DistCalc_Offset)
            {
                fDist1 = ballRect.size.width;
            }
            else
                fDist1 = [self getDistanceBetweenBalls:m_nFastSortTo-1 Second:m_nFastSortTo];
            
            if (m_nFastSortTo >= [m_sprBallArray count]-1)
                fDist2 = ballRect.size.width;
            else if ([self getDistanceBetweenBalls:m_nFastSortTo+1 Second:m_nFastSortTo] > ballRect.size.width+DEF_DistCalc_Offset)
            {
                fDist2 = ballRect.size.width;
            }
            else
                fDist2 = [self getDistanceBetweenBalls:m_nFastSortTo+1 Second:m_nFastSortTo];
            
            m_nFastSortFrom = [self getFirstIndexOfChain:m_nFastSortTo];
            
            if ([self absf:(fDist1-ballRect.size.width)] <= DEF_DistCalc_Offset && [self absf:(fDist2-ballRect.size.width)] <= DEF_DistCalc_Offset)
            {
                [self FitBall:m_nFastSortTo];
                m_bIsFastSortingChain = false;
            }
            else
            {
                if ([self absf:(fDist1-ballRect.size.width)] > DEF_DistCalc_Offset && m_nFastSortFrom < m_nFastSortTo)
                    [self BallAnimationFrom:m_nFastSortFrom To:m_nFastSortTo-1 RightArrow:true Offset:0];
                else if ([self absf:(fDist2-ballRect.size.width)] > DEF_DistCalc_Offset)
                    [self BallAnimationFrom:m_nFastSortFrom To:m_nFastSortTo RightArrow:true Offset:0];
            }
        }
        if (m_bIsFastSortingChain == false)
        {
            [self onHit:m_nFastSortTo];
        }
    }
}

-(void) procFiring
{
    for (int i = m_nFireFrom; i <= m_nFireTo; i++)
    {
        CCSprite* sprBall = m_sprBallArray[i];
        CGPoint ptBall = [sprBall position];
        [m_sprFires[i-m_nFireFrom][m_nFireIndex] setVisible:TRUE];
        if (m_nFireIndex > 0)
        {
            [m_sprFires[i-m_nFireFrom][m_nFireIndex-1] setVisible:FALSE];
        }
        [m_sprFires[i-m_nFireFrom][m_nFireIndex] setPosition:ptBall];
    }
    m_nFireIndex++;
    if (m_nFireIndex >= DEF_Fire_Count)
    {
        for (int i = m_nFireFrom; i <= m_nFireTo; i++)
        {
            [m_sprFires[i-m_nFireFrom][m_nFireIndex-1] setVisible:FALSE];
        }
        m_bIsFiring = false;
        m_nFireIndex = 0;
        [self removeBallsFromChainFrom:m_nFireFrom To:m_nFireTo];
    }
}

-(void) update: (ccTime) dt
{
    if (m_bIsGameDone)
        return;
    
    m_ccUpdateBallTime = m_ccUpdateBallTime + dt;
    m_ccUpdateFlyingTime = m_ccUpdateFlyingTime + dt;
    m_ccUpdateFastSortTime = m_ccUpdateFastSortTime + dt;
    m_ccUpdateFiringTime = m_ccUpdateFiringTime + dt;
    m_ccUpdateBombShowTime = m_ccUpdateBombShowTime + dt;
    m_ccUpdateBombBackDelay = m_ccUpdateBombBackDelay - dt;
    m_ccUpdateBombStopDelay = m_ccUpdateBombStopDelay - dt;

    if (!m_bIsPlaying)
        return;
    
    if (m_bIsGameOver || m_bIsGameComplete)
    {
        [self procGameFinish];
        return;
    }

//    [self procBomb];
    
    if (m_bBallLoaded == false && [m_parseOperation isXMLLoaded])
    {
        [self initEngine];
        m_bBallLoaded = true;
    }

    [self updatePowerIndex:true];

    if (m_ccUpdateBallTime > DEF_BallAni_Interval)
    {
        [self procBallAnimation];
        m_ccUpdateBallTime = 0;
    }
    
    if (m_ccUpdateFastSortTime > DEF_FastSortChain_Interval)
    {
        [self procFastSort];
        m_ccUpdateFastSortTime = 0;
    }
    
    if (m_ccUpdateFlyingTime > DEF_Ball_FlyingInterval)
    {
        if (m_bHasFlyingBall == true)
        {
            [self BallFlyingAnimation];
            [self checkAddingFlyingBallToChain];
        }
        
        m_ccUpdateFlyingTime = 0;
    }
    
    if (m_ccUpdateFiringTime > DEF_Firing_Interval)
    {
        if (m_bIsFiring == true)
        {
            [self procFiring];
        }
        m_ccUpdateFiringTime = 0;
    }
    
    if (m_ccUpdateBombShowTime > DEF_BombShow_Interval)
    {
//        [self BombProc];
        m_ccUpdateBombShowTime = 0;
    }
}
/*
-(void) BombAnimation
{
    int nBallIndexForBomb = -1;
    int nBombKind = -1;
    int nCount = [m_sprBallArray count];
    for (int i = 0; i < nCount; i++)
    {
        CCSprite* sprBall = m_sprBallArray[i];
        if (sprBall.tag >= DEF_BombTag_Bomb && sprBall.tag <= DEF_BombTag_Stop)
        {
            nBallIndexForBomb = i;
            nBombKind = sprBall.tag-1;
            break;
        }
    }
    
    for (int i = 0; i < DEF_BombKind_Count; i++)
    {
        for (int j = 0; j < DEF_BombAni_Count; j++)
        {
            [m_sprBomb[i][j] setVisible:FALSE];
        }
    }

    if (nBallIndexForBomb == -1 || nBombKind == -1)
        return;
    
    for (int i = 0; i < DEF_BombKind_Count; i++)
    {
        for (int j = 0; j < DEF_BombAni_Count; j++)
        {
            if (i == nBombKind && j == m_nBombAnimationIndex)
            {
                CCSprite* sprBall = m_sprBallArray[nBallIndexForBomb];
                [m_sprBomb[i][j] setVisible:TRUE];
                m_sprBomb[i][j].position = sprBall.position;
            }
        }
    }
    
    m_nBombAnimationIndex = (m_nBombAnimationIndex+1)%DEF_BombAni_Count;
}

-(void) BombProc
{
    m_nBombAnimationIndex = 0;
    bool bShouldMakeBomb = true;
    int nCount = [m_sprBallArray count];
    int nBombIndex = arc4random() % nCount;
    int nBombKind = arc4random() % DEF_BombKind_Count;
    
    for (int i = 0; i < DEF_BombKind_Count; i++)
    {
        for (int j = 0; j < DEF_BombAni_Count; j++)
        {
            [m_sprBomb[i][j] setVisible:FALSE];
        }
    }
    for (int i = 0; i < nCount; i++)
    {
        CCSprite* sprBall = m_sprBallArray[i];
        if (sprBall.tag >= DEF_BombTag_Bomb && sprBall.tag <= DEF_BombTag_Stop)
        {
            bShouldMakeBomb = false;
            sprBall.tag = 0;
            return;
        }
    }

    if (bShouldMakeBomb == true && nCount > 10)
    {
        CCSprite* sprBall = m_sprBallArray[nBombIndex];
        sprBall.tag = nBombKind+1;
    }
}
*/
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	if (backgroundMusic != nil) {
		[backgroundMusic play];
	}
}


@end
