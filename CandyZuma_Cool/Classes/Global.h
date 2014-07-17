//
//  Global.h
//  Frogout
//
//  Created by YunCholHo on 3/24/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#ifndef _GLOBAL_H_
#define _GLOBAL_H_

#define MAXOFBOTTLECAP 10
#define LEVEL_COUNT 25

extern bool         gbFirstLaunch;
extern  int         gnCurrentStage;
extern  int         gnHighScore;
extern  int         gnLevelScore[LEVEL_COUNT];
extern  bool        gbLevelUnlock[LEVEL_COUNT];
extern  int         gnLevelSkips;

extern  bool         gbIsCharacter1Locked;
extern  bool         gbIsCharacter2Locked;
extern  bool         gbIsCharacter3Locked;
extern  int         gnSelectedCharacter;

extern  bool        gbMusicEnable;
extern  bool        gbSoundEnable;

extern  bool        gbIsUnlockAllCharacters;
extern  bool        gbIsUnlockAllLevels;
extern  bool        gbIsRemoveAds;
//extern  bool        gbIsLevelSkips;

#endif
