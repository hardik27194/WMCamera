//
//  Runtopia-Defines.h
//  RuntopiaDefines
//
//  Created by LeoKing on 16/10/12.
//  Copyright © 2016年 Runtopia. All rights reserved.
//

#ifndef Runtopia_Defines_h
#define Runtopia_Defines_h

#define Runtopia_Debug YES
#define RELEASE_TO_APPSTORE (!Runtopia_Debug)
#define FLURRY(x) (Runtopia_Debug? : [Flurry logEvent:x])


#endif /* Runtopia_Defines_h */
