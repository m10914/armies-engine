//
//  CProjectile.m
//  armies
//
//  Created by Дмитрий Заборовский on 8/20/12.
//
//


#import "CProjectile.h"



int CProjectile::initProjectile(ProjectileType type, CObject* caster)
{
    this->caster = caster;
    
    vConnectOffset = b2Vec2(0,0);
    bConnectedToCaster = false;
    
    
    NSString* str = [CUtil getAssetN:@"system/spells.cfg"];
    char* file = GetFile((char*)[str cStringUsingEncoding:NSUTF8StringEncoding]);
    char* desc;
    
    
    switch(type)
    {
        case PROJ_FIREBALL:
            desc = GetBlock("[FIREBALL]",file);
            life_limit = 3;
            break;
        
        case PROJ_LIGHTNING:
            desc = GetBlock("[LIGHTNING]",file);
            life_limit = 0.5;
            break;
            
        case PROJ_BURST:
            desc = GetBlock("[BURST]", file);
            break;
            
        case PROJ_ICESHIELD:
            desc = GetBlock("[ICESHIELD]", file);
            break;
            
        case PROJ_FIRESHIELD:
            desc = GetBlock("[FIRESHIELD]", file);
            break;
            
        case PROJ_KICK:
            desc = GetBlock("[KICK]", file);
            break;
            
        case PROJ_STONEFIST:
            desc = GetBlock("[STONEFIST]", file);
            life_limit = 5;
            break;
            
        case PROJ_STONEWALL:
            desc = GetBlock("[STONEWALL]", file);
            life_limit = 5;
            break;
            
        default:
            return 0;
            break;
    }
    
    this->Init(desc);
    proj_type = type;
    
    
    free(desc);
    free(file);
    
    
    lifetime = 0;
    
    return 1;
}

int CProjectile::DeleteAfterDelay(float delay)
{
    life_limit = delay;
    lifetime = 0;
    
    return 0;
}


void CProjectile::FrameMove(NSTimeInterval dt)
{
    lifetime += dt;
    if(lifetime > life_limit) toDelete = true;
    
    if(bConnectedToCaster && caster != NULL)
    {
        x = caster->x + vConnectOffset.x;
        y = caster->y + vConnectOffset.y;
    }
    
}

void CProjectile::ConnectToCasterWithOffset(b2Vec2 vOffset)
{
    bConnectedToCaster = true;
    vConnectOffset = vOffset;
}

void CProjectile::DisconnectFromCaster()
{
    bConnectedToCaster = false;
}

