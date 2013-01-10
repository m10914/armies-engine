//
//  CMotionTween.h
//  armies
//
//  Created by Дмитрий Заборовский on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include "CObject.h"

#define PTM_RATIO 60.f


class CMotionTween
{
public:
	CObject* obj;
	float speedX, speedY;
	float destX, destY;
    float lifetime;
    float life_limit;
    
	CMotionTween(CObject* objIn, float speedXIn, float speedYIn, float dX, float dY, float lifelimit)
    {
        obj = objIn;
        speedX = speedXIn;
        speedY = speedYIn;
        destX = dX;
        destY = dY;
        realX = (float)obj->x;
        realY = (float)obj->y;
        
        lifetime = 0;
        life_limit = lifelimit;
    };
    
	int FrameMove(float time_in_seconds);
	
protected:
	float realX, realY;
};


