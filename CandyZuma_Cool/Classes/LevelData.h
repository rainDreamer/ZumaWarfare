//
//  LevelData.h
//  CandyZuma_Cool
//
//  Created by lion on 9/12/13.
//  Copyright 2013 MingGong. All rights reserved.
//

@interface LevelData : NSOperation{
    int         m_nLevel;
    int         m_nrollTo;
    CGPoint     m_ptShooterPos;
    int         m_colorArray[1000];
    int         m_nColorCount;
    CGPoint     m_locationArray[1000];
    int         m_nlPosCount;
    CGPoint     m_ptStartLineFrom;
    CGPoint     m_ptStartLineTo;
    bool        m_bXMLLoaded;
    CGSize      m_winSize;
    
    NSData      *m_levelData;
    
}

@property (nonatomic,readwrite,assign) NSInteger tag;

- (id)initWithXML:(NSURL *)xmlURL WinSize:(CGSize)winSize;
- (int)getLevel;
- (int)getRollTo;
- (CGPoint)getShooterPos;
- (int)getColorCount;
- (int)getColorFromIndex:(int)nIndex;
- (int)getLocationCount;
- (CGPoint)getPosFromIndex:(int)nIndex;
- (CGPoint)getStartLineFrom;
- (CGPoint)getStartLineTo;
- (bool)isXMLLoaded;

@end
