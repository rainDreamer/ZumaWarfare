//
//  GameScreen.h
//  IceCreamDriver

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "StoreKit/StoreKit.h"
#import "AppDelegate.h"

#define PI 3.141592f

@interface MathLayer : CCLayer {
}

-(bool) isLine:(CGPoint)ptFirst Second:(CGPoint)ptSecond Third:(CGPoint)ptThird;
-(float) getParamOfCircleEquation:(int)nParamIndex First:(CGPoint)ptFirst Second:(CGPoint)ptSecond Third:(CGPoint) ptThird;
-(float) getCXOfCircleEquation:(CGPoint)ptFirst Second:(CGPoint)ptSecond Third:(CGPoint) ptThird;
-(float) getCYOfCircleEquation:(CGPoint)ptFirst Second:(CGPoint)ptSecond Third:(CGPoint) ptThird;
-(float) getROfCircleEquation:(CGPoint)ptFirst Second:(CGPoint)ptSecond Third:(CGPoint) ptThird;
-(float) getParamOfLineEquation:(int)nParamIndex From:(CGPoint)ptFrom To:(CGPoint)ptTo; // y=ax+b
-(float) getAOfLineEquation:(CGPoint)ptFrom To:(CGPoint)ptTo;   // y=ax+b
-(float) getBOfLineEquation:(CGPoint)ptFrom To:(CGPoint)ptTo;   // y=ax+b
-(float) intersectionEquationParamOfLineAndCircle:(int)nParam From:(CGPoint)ptFrom To:(CGPoint)ptTo CX:(int)cx CY:(int)cy R:(int)r;
-(float) intersectionEquationYOfLineAndCircle:(CGPoint)ptFrom To:(CGPoint)ptTo CX:(int)cx CY:(int)cy R:(int)r;
-(float) intersectionEquationXOfLineAndCircle:(CGPoint)ptFrom To:(CGPoint)ptTo CX:(int)cx CY:(int)cy R:(int)r;
-(float) getAlphaFromArcSinCos:(float)acosValue Sin:(float)asinValue;
-(float) getAngleBetweenTowLines:(CGPoint)ptFirstFrom FirstTo:(CGPoint)ptFirstTo SecondFrom:(CGPoint)ptSecondFrom SecondTo:(CGPoint)ptSecondTo;
-(float) asinfnear:(float)sinValue;
-(float) acosfnear:(float)cosValue;
-(float) calcRadianFromThreePoints:(CGPoint)ptFirst Second:(CGPoint)ptSecond Third:(CGPoint)ptThird;
-(float) absf:(float)fValue;

@end
