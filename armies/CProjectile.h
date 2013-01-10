//
//  CProjectile.h
//  armies
//
//  Created by Дмитрий Заборовский on 8/20/12.
//
//

#pragma once

#import "CObject.h"
#import "CSprite.h"
#include "CCollision.h"
#include "CCamera.h"
#include "LH_strings.h"
#import "CUtil.h"
#import "Box2D/Box2D.h"


enum ProjectileType {
    PROJ_FIREBALL,
    PROJ_LIGHTNING,
    PROJ_BURST,
    PROJ_ICESHIELD,
    PROJ_KICK,
    PROJ_DARKBLAST,
    PROJ_FIRENOVA,
    PROJ_FIRESHIELD,
    PROJ_ICENOVA,
    PROJ_METEOR,
    PROJ_STONEFIST,
    PROJ_STONEWALL
};


class CProjectile: public CObject
{
    
public:
    int initProjectile(ProjectileType type, CObject* caster);
    void FrameMove(NSTimeInterval dt);
    
    
    int DeleteAfterDelay(float delay);
    
    ProjectileType getType() { return proj_type; }
    
    CObject* caster;
    
    
    void ConnectToCasterWithOffset(b2Vec2 vOffset);
    void DisconnectFromCaster();
    bool bConnectedToCaster;
    b2Vec2 vConnectOffset;
    
    
protected:
    ProjectileType proj_type;
    float lifetime;
    float life_limit;
    
    
};
