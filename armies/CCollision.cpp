//
//  CCollision.cpp
//  armies
//
//  Created by Дмитрий Заборовский on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "CCollision.h"



bool CCollision::IsCollide(AABB* a, AABB* b)
{
	return false;
}


vec2* CCollision::getCollision(AABB* a, AABB* b)
{
	int dx = 0, dy = 0;
	vec2 *res = new vec2;
    
    //debug stuff
    /*if(a->lx == 230 || b->lx == 230)
    {
        fprintf(stderr,"obj1: %d %d %d %d\n",(int)a->lx,(int)a->ux,(int)a->ly,(int)a->uy);
        fprintf(stderr,"obj2: %d %d %d %d\n",(int)b->lx,(int)b->ux,(int)b->ly,(int)b->uy);
    }*/
    
	//pushing a upwards
	if( a->lx < b->ux && a->lx > b->lx ) dx = b->ux - a->lx;
	if( a->ux < b->ux && a->ux > b->lx ) dx = b->lx - a->ux;
	if( a->lx >= b->lx && a->ux <= b->ux ) dx = b->lx - a->ux;
	if( a->lx <= b->lx && a->ux >= b->ux ) dx = b->lx - a->ux;
    
	if( a->ly < b->uy && a->ly > b->ly ) dy = b->uy - a->ly;
	if( a->uy < b->uy && a->uy > b->ly ) dy = b->ly - a->uy;
	if( a->ly >= b->ly && a->uy <= b->uy ) dy = b->ly - a->uy;
	if( a->ly <= b->ly && a->uy >= b->uy ) dy = b->ly - a->uy;
    
    
	if( dx == 0 || dy == 0 )
	{
		free(res);
		return NULL;
	}
	else
	{
		if(abs(dx) > abs(dy)) dx = 0;
		else if(abs(dx) < abs(dy)) dy = 0;
		res->x = dx;
		res->y = dy;
        
		return res;
	}
}