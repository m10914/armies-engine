//
//  CMotionTween.cpp
//  armies
//
//  Created by Дмитрий Заборовский on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "CMotionTween.h"


int CMotionTween::FrameMove(float time_in_seconds)
{
    lifetime += time_in_seconds;
    
    realX += speedX*time_in_seconds;
    realY += speedY*time_in_seconds;
    
    //obj->x = (int)realX;
    //obj->y = (int)realY;
    obj->physx_body->SetTransform(b2Vec2((realX + obj->boxWidth/2)/PTM_RATIO, (realY + obj->boxHeight/2)/PTM_RATIO), 0);
    
    if(fabs(obj->x - destX) < 2 || lifetime > life_limit) return 1;
		
    return 0;
}
