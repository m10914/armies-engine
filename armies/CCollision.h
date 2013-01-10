//
//  CCollision.h
//  armies
//
//  Created by Дмитрий Заборовский on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#pragma once

#include <stdio.h>
#include <stdlib.h>


typedef struct {
	int lx,ly,ux,uy;
} AABB;

typedef struct {
	int x,y;
} vec2;

class CCollision{

public:
	static bool IsCollide(AABB* a, AABB* b);
	static vec2* getCollision(AABB* a, AABB* b);
};