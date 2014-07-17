//
//  Global.m
//  Frogout
//
//  Created by YunCholHo on 3/24/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Global.h"

bool         gbFirstLaunch = true;
int         gnCurrentStage = 0;
int         gnHighScore = 0;
int         gnLevelSkips = 0;

bool         gbIsCharacter1Locked = false;
bool         gbIsCharacter2Locked = true;
bool         gbIsCharacter3Locked = true;
int         gnSelectedCharacter = 0;

bool        gbMusicEnable = true;
bool        gbSoundEnable = true;

int         gnLevelScore[LEVEL_COUNT];
bool        gbLevelUnlock[LEVEL_COUNT];

bool        gbIsUnlockAllCharacters = false;
bool        gbIsUnlockAllLevels = false;
bool        gbIsRemoveAds = false;
//bool        gbIsLevelSkips = false;
