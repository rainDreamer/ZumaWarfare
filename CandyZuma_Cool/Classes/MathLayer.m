#import "MathLayer.h"


@implementation MathLayer

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
    }
    
    return self;
}

-(bool) isLine:(CGPoint)ptFirst Second:(CGPoint)ptSecond Third:(CGPoint)ptThird
{
    float fAngle = [self getAngleBetweenTowLines:ptFirst FirstTo:ptSecond SecondFrom:ptFirst SecondTo:ptThird];
    
    if (fAngle > -0.02f && fAngle < 0.02f)
        return true;
    
    return false;
    
/*    float nCheckValue = (ptFirst.x-ptSecond.x)*(ptThird.y-ptFirst.y)-(ptFirst.x-ptThird.x)*(ptSecond.y-ptFirst.y);
    if (nCheckValue > -3 && nCheckValue < 3)   // it is a line
        return true;
    return false;*/
}

-(float) absf:(float)fValue
{
    float fReturnValue = fValue;
    
    if (fReturnValue < 0)
        fReturnValue = -fReturnValue;
    
    return fReturnValue;
}

-(float) getParamOfCircleEquation:(int)nParamIndex First:(CGPoint)ptFirst Second:(CGPoint)ptSecond Third:(CGPoint) ptThird
{
//    float nCheckValue = (ptFirst.x-ptSecond.x)*(ptThird.y-ptFirst.x)-(ptFirst.x-ptThird.x)*(ptSecond.y-ptFirst.y);
//    if (nCheckValue > -3 && nCheckValue < 3)
//    {
//        return 0;
//    }

    if ([self isLine:ptFirst Second:ptSecond Third:ptThird] == true)
    {
        return 0;
    }
    
    // To avoid crashing because of zero /
    if (ptFirst.y == ptSecond.y)
    {
        CGPoint temp = ptFirst;
        ptFirst = ptThird;
        ptThird = temp;
    }
    else if (ptFirst.y == ptThird.y)
    {
        CGPoint temp = ptFirst;
        ptFirst = ptSecond;
        ptSecond = temp;
    }
    
    // get the position fo the centre of circle (cx, cy) and radius (r)
    float cx, cy, r;
    float fTemp1 = (ptThird.x*ptThird.x+ptThird.y*ptThird.y-ptFirst.x*ptFirst.x-ptFirst.y*ptFirst.y)/(2*(ptThird.y-ptFirst.y));
    float fTemp2 = (ptSecond.x*ptSecond.x+ptSecond.y*ptSecond.y-ptFirst.x*ptFirst.x-ptFirst.y*ptFirst.y)/(2*(ptSecond.y-ptFirst.y));
    float fTemp3 = (ptFirst.x-ptSecond.x)/(ptSecond.y-ptFirst.y) - (ptFirst.x-ptThird.x)/(ptThird.y-ptFirst.y);
    cx = (fTemp1-fTemp2)/fTemp3;
    
    fTemp1 = 2*(ptFirst.x-ptSecond.x)*cx+ptSecond.x*ptSecond.x+ptSecond.y*ptSecond.y-ptFirst.x*ptFirst.x-ptFirst.y*ptFirst.y;
    fTemp2 = 2*(ptSecond.y-ptFirst.y);
    cy = fTemp1/fTemp2;
    
    fTemp1 = (ptFirst.x-cx)*(ptFirst.x-cx)+(ptFirst.y-cy)*(ptFirst.y-cy);
    r = sqrt(fTemp1);

    if (nParamIndex == 0)
        return cx;
    else if (nParamIndex == 1)
        return cy;
    else if (nParamIndex == 2)
        return r;
    
    return 0;
}

-(float) getCXOfCircleEquation:(CGPoint)ptFirst Second:(CGPoint)ptSecond Third:(CGPoint) ptThird
{
    return [self getParamOfCircleEquation:0 First:ptFirst Second:ptSecond Third:ptThird];
}

-(float) getCYOfCircleEquation:(CGPoint)ptFirst Second:(CGPoint)ptSecond Third:(CGPoint) ptThird
{
    return [self getParamOfCircleEquation:1 First:ptFirst Second:ptSecond Third:ptThird];
}

-(float) getROfCircleEquation:(CGPoint)ptFirst Second:(CGPoint)ptSecond Third:(CGPoint) ptThird
{
    return [self getParamOfCircleEquation:2 First:ptFirst Second:ptSecond Third:ptThird];
}

-(float) getParamOfLineEquation:(int)nParamIndex From:(CGPoint)ptFrom To:(CGPoint)ptTo // y=ax+b
{
    if (ptFrom.x == ptTo.x)
        return  0;
    
    float a = (ptTo.y - ptFrom.y) / (ptTo.x - ptFrom.x);
    float b = ptFrom.y-ptFrom.x*a;
    
    if (nParamIndex == 0)
        return a;
    else if (nParamIndex == 1)
        return b;
    
    return 0;
}

-(float) getAOfLineEquation:(CGPoint)ptFrom To:(CGPoint)ptTo   // y=ax+b
{
    return [self getParamOfLineEquation:0 From:ptFrom To:ptTo];
}

-(float) getBOfLineEquation:(CGPoint)ptFrom To:(CGPoint)ptTo   // y=ax+b
{
    return [self getParamOfLineEquation:1 From:ptFrom To:ptTo];
}

-(float) intersectionEquationParamOfLineAndCircle:(int)nParam From:(CGPoint)ptFrom To:(CGPoint)ptTo CX:(int)cx CY:(int)cy R:(int)r
{
    // get line equation y = mx+c
    float m = [self getAOfLineEquation:ptFrom To:ptTo];
    float c = [self getBOfLineEquation:ptFrom To:ptTo];
    
    // intersection equation Ax^2+Bx+C=0
    float A = m*m+1;
    float B = 2*(m*c-m*cy-cx);
    float C = cy*cy-r*r+cx*cx-2*c*cy+c*c;
    
    if (B*B-4*A*C < 0)
        return 0;
    
    float x1 = (-B+sqrt(B*B-4*A*C))/(2*A);
    float x2 = (-B-sqrt(B*B-4*A*C))/(2*A);
    
    if (abs(ptFrom.x-x1) > abs(ptFrom.x-x2))
        x1 = x2;
    
    if (nParam == 0)
    {
        return  x1;
    }
    else if (nParam == 1)
    {
        float y = m*x1+c;
        return y;
    }
    
    return 0;
}

-(float) intersectionEquationYOfLineAndCircle:(CGPoint)ptFrom To:(CGPoint)ptTo CX:(int)cx CY:(int)cy R:(int)r
{
    return [self intersectionEquationParamOfLineAndCircle:1 From:ptFrom To:ptTo CX:cx CY:cy R:r];
}

-(float) intersectionEquationXOfLineAndCircle:(CGPoint)ptFrom To:(CGPoint)ptTo CX:(int)cx CY:(int)cy R:(int)r
{
    return [self intersectionEquationParamOfLineAndCircle:0 From:ptFrom To:ptTo CX:cx CY:cy R:r];
}

-(float) getAlphaFromArcSinCos:(float)acosValue Sin:(float)asinValue
{
    if (acosValue < 0)
        acosValue = 0;
    if (acosValue > PI)
        acosValue = PI;
    if (asinValue < -PI/2)
        asinValue = -PI/2;
    if (asinValue > PI/2)
        asinValue = PI/2;
    
    if (acosValue >= 0 && acosValue < PI/2 &&
        asinValue >= -PI/2 && asinValue < 0)
    {
        return asinValue;
    }
    else if (acosValue >= 0 && acosValue < PI/2 &&
             asinValue >= 0 && asinValue < PI/2)
    {
        return asinValue;
    }
    else if (acosValue >= PI/2 && acosValue < PI &&
             asinValue >= -PI/2 && asinValue < 0)
    {
        return -acosValue;
    }

    return acosValue;
}

-(float) getAngleBetweenTowLines:(CGPoint)ptFirstFrom FirstTo:(CGPoint)ptFirstTo SecondFrom:(CGPoint)ptSecondFrom SecondTo:(CGPoint)ptSecondTo
{
    ptSecondTo.x -= (ptSecondFrom.x - ptFirstFrom.x);
    ptSecondTo.y -= (ptSecondFrom.y - ptFirstFrom.y);
    ptSecondFrom = ptFirstFrom;
    
    ptFirstTo.x = ptFirstTo.x - ptFirstFrom.x;
    ptFirstTo.y = ptFirstTo.y - ptFirstFrom.y;
    ptSecondTo.x = ptSecondTo.x - ptSecondFrom.x;
    ptSecondTo.y = ptSecondTo.y - ptSecondFrom.y;
    ptFirstFrom.x = 0; ptFirstFrom.y = 0;
    ptSecondFrom.x = 0; ptSecondFrom.y = 0;
    
    float firstLineDaeGak = sqrt(ptFirstTo.x*ptFirstTo.x+ptFirstTo.y*ptFirstTo.y);
    if (ptFirstTo.x == 0)
        firstLineDaeGak = ptFirstTo.y;
    else if (ptFirstTo.y == 0)
        firstLineDaeGak = ptFirstTo.x;
    float a;
    a = ptFirstTo.x/firstLineDaeGak;
    float alpha1 = [self acosfnear:(a)];
    a = ptFirstTo.y/firstLineDaeGak;
    float alpha2 = [self asinfnear:(a)];
    float firstalpha = [self getAlphaFromArcSinCos:alpha1 Sin:alpha2];
    float secondLineDaeGak = sqrt(ptSecondTo.x*ptSecondTo.x+ptSecondTo.y*ptSecondTo.y);
    if (ptSecondTo.x == 0)
        secondLineDaeGak = ptSecondTo.y;
    else if (ptSecondTo.y == 0)
        secondLineDaeGak = ptSecondTo.x;
    a = ptSecondTo.x/secondLineDaeGak;
    alpha1 = [self acosfnear:(a)];
    a = ptSecondTo.y/secondLineDaeGak;
    alpha2 = [self asinfnear:(a)];
    float secondalpha = [self getAlphaFromArcSinCos:alpha1 Sin:alpha2];
    return firstalpha-secondalpha;
}

-(float) asinfnear:(float)sinValue
{
    float returnValue = sinValue;
    if (sinValue > 1/* && sinValue-1 < 3*/)
        returnValue = 1;
    if (sinValue < -1/* && (-1-sinValue) < 3*/)
        returnValue = -1;
    return asinf(returnValue);
}

-(float) acosfnear:(float)cosValue
{
    float returnValue = cosValue;
    if (cosValue > 1 && cosValue-1 < 0.01)
        returnValue = 1;
    if (cosValue < -1 && (-1-cosValue) < 0.01)
        returnValue = -1;
    return acosf(returnValue);
}

-(float) calcRadianFromThreePoints:(CGPoint)ptFirst Second:(CGPoint)ptSecond Third:(CGPoint)ptThird
{
    // calculating the angle for ptSecond. I call ptFirst a, ptSecond b, and ptThird c.
    float ab = sqrt((ptFirst.x-ptSecond.x)*(ptFirst.x-ptSecond.x)+(ptFirst.y-ptSecond.y)*(ptFirst.y-ptSecond.y));
    float bc = sqrt((ptThird.x-ptSecond.x)*(ptThird.x-ptSecond.x)+(ptThird.y-ptSecond.y)*(ptThird.y-ptSecond.y));
    float ca = sqrt((ptFirst.x-ptThird.x)*(ptFirst.x-ptThird.x)+(ptFirst.y-ptThird.y)*(ptFirst.y-ptThird.y));
    float radian = (ab*ab+bc*bc-ca*ca)/(2*ab*bc);
    return acosf(radian);
}

@end
