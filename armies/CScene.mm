//
//  CScene.m
//  armies
//
//  Created by Дмитрий Заборовский on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CScene.h"




//--------------
// C O N T A C T
// listener
//

void myContactListener::BeginContact(b2Contact* contact)
{
    b2Fixture* fixA = contact->GetFixtureA();
    b2Fixture* fixB = contact->GetFixtureB();
    
    CObject* objA = (CObject*)fixA->GetUserData();
    CObject* objB = (CObject*)fixB->GetUserData();
    CObject* buf = NULL;
    
    // processing bInAir for characters
    //
    if(objA->getType() == CHR || objB->getType() == CHR)
    {
        b2Manifold* manif = contact->GetManifold();
        if(manif->pointCount > 0)
        {
            b2WorldManifold* worldManifold = new b2WorldManifold();
            contact->GetWorldManifold(worldManifold);
            b2Vec2 worldPoint1 = worldManifold->points[1];
            b2Vec2 worldPoint2 = worldManifold->points[0];
            
            if(objB->getType() == CHR)
            {
                b2Body* body = fixB->GetBody();
                b2Vec2 lp1 = body->GetLocalPoint(worldPoint1);
                b2Vec2 lp2 = body->GetLocalPoint(worldPoint2);

                //bottom touch
                if(lp2.y < -0.5f && lp2.y > -0.6f)
                {
                    objB->bInAir = false;
                }
            }
            if(objA->getType() == CHR)
            {
                b2Body* body = fixA->GetBody();
                b2Vec2 lp1 = body->GetLocalPoint(worldPoint1);
                b2Vec2 lp2 = body->GetLocalPoint(worldPoint2);
                
                //bottom touch
                if(lp2.y < -0.5f && lp2.y > -0.6f)
                {
                    objA->bInAir = false;
                }
            }
        }

        
    }
    
    

    
    // T R I G G E R S
    //
    if(objA->getType() == TRG && EQ(objB->getName(),"player"))
    {
        objA->bEntered = true;
    }
    else if(objB->getType() == TRG && EQ(objA->getName(),"player"))
    {
        objB->bEntered = true;
    }
    
    
    
    // P R O J E C T I L E S
    //
    
    //proj vs chars
    if(objA->getType() == PRO && objB->getType() == CHR && !objB->bDead && !objA->bDead)
    {
        buf = objA;
        objA = objB;
        objB = buf;
        buf = NULL;
    }
    if(objB->getType() == PRO && objA->getType() == CHR && !objA->bDead && !objB->bDead)
    {
        CProjectile* proj = (CProjectile*)objB;
        if(proj->caster == objA)
        {
            //self-casting
        }
        else
        {
            //do the spell effect
            
            if(proj->getType() == PROJ_FIREBALL)
            {
                objA->health -= 45;
                objA->AnimPlay("Hurt");
                if(objA->health <= 0)
                {
                    objA->health = 0;
                    objA->AnimPlay("Die");
                }
                if(!EQ(objA->getName(),"player")) objA->bShowHealth = true;

                
                proj->AnimPlay("Blow");
                proj->DeleteAfterDelay(0.2f);
                proj->bDead = true;
                proj->physx_body->SetLinearVelocity(b2Vec2(0,0));
            }
            else if(proj->getType() == PROJ_BURST)
            {
                objA->health -= 100;
                objA->AnimPlay("Hurt");
                if(objA->health <= 0)
                {
                    objA->health = 0;
                    objA->AnimPlay("Die");
                }
                if(!EQ(objA->getName(),"player")) objA->bShowHealth = true;
            }
            else if(proj->getType() == PROJ_KICK)
            {
                if(EQ(objA->getName(),"player"))
                {
                    objA->health -= 15;
                    objA->AnimPlay("Hurt");
                    if(objA->health <= 0)
                    {
                        objA->health = 0;
                        objA->AnimPlay("Die");
                    }
                    
                    float signum = proj->caster->x + proj->caster->boxWidth/2 - objA->x-objA->boxWidth/2;
                    signum = signof(signum);
                    objA->physx_body->ApplyForceToCenter(b2Vec2(-80.f*signum,20.f));
                    objA->immobilizeFor(0.2f);
                    
                }
            }
            else if(proj->getType() == PROJ_STONEFIST)
            {
                objA->health -= 100;
                objA->AnimPlay("Hurt");

                if(objA->health <= 0)
                {
                    objA->health = 0;
                    objA->AnimPlay("Die");
                }
                if(!EQ(objA->getName(),"player")) objA->bShowHealth = true;
            }
            
        }
    }
    
    
    //------------
    // proj vs proj
    if(objA->getType() == PRO && objB->getType() == PRO)
    {
        CProjectile* projA = (CProjectile*)objA;
        CProjectile* projB = (CProjectile*)objB;
        CProjectile* buf = NULL;
        
        //fireball vs fireball
        if(projA->getType() == PROJ_FIREBALL && projB->getType() == PROJ_FIREBALL)
        {
            projA->AnimPlay("Blow");
            projA->DeleteAfterDelay(0.2f);
            projA->bDead = true;
            projA->physx_body->SetLinearVelocity(b2Vec2(0,0));
            projB->AnimPlay("Blow");
            projB->DeleteAfterDelay(0.2f);
            projB->bDead = true;
            projB->physx_body->SetLinearVelocity(b2Vec2(0,0));
        }
        
        //iceshield vs fire projectiles
        if(projB->getType() == PROJ_ICESHIELD)
        {
            buf = projB;
            projB = projA;
            projA = buf;
        }
        if(projA->getType() == PROJ_ICESHIELD)
        {
            ProjectileType type = projB->getType();
            switch(type)
            {
                case PROJ_FIREBALL:
                    
                    projB->AnimPlay("Blow");
                    projB->DeleteAfterDelay(0.2f);
                    projB->bDead = true;
                    projB->physx_body->SetLinearVelocity(b2Vec2(0,0));
                    
                    break;
            }
        }
        
        //stonefist vs fire projectiles
        if(projB->getType() == PROJ_STONEFIST)
        {
            buf = projB;
            projB = projA;
            projA = buf;
        }
        if(projA->getType() == PROJ_ICESHIELD)
        {
            ProjectileType type = projB->getType();
            switch(type)
            {
                case PROJ_FIREBALL:
                    
                    projB->AnimPlay("Blow");
                    projB->DeleteAfterDelay(0.2f);
                    projB->bDead = true;
                    projB->physx_body->SetLinearVelocity(b2Vec2(0,0));
                    
                    break;
            }
        }
    }
    
    
    //------------
    // proj vs phys
    if(objA->getType() == PRO && objB->getType() == PHY)
    {
        buf = objA;
        objA = objB;
        objB = buf;
        buf = NULL;
    }
    if(objA->getType() == PHY && objB->getType() == PRO)
    {
        CProjectile* proj = (CProjectile*)objB;
        
        if(proj->getType() == PROJ_FIREBALL)
        {
            proj->bDead = true;
            proj->AnimPlay("Blow");
            proj->DeleteAfterDelay(0.2f);
            proj->physx_body->SetLinearVelocity(b2Vec2(0,0));
        }
    }
    
    
    
    return;
}

void myContactListener::EndContact(b2Contact* contact)
{
    b2Fixture* fixA = contact->GetFixtureA();
    b2Fixture* fixB = contact->GetFixtureB();
    
    CObject* objA = (CObject*)fixA->GetUserData();
    CObject* objB = (CObject*)fixB->GetUserData();
    
    
    // processing!
    
    
    // T R I G G E R S
    if(objA->getType() == TRG && EQ(objB->getName(),"player"))
    {
        objA->bLeft = true;
        //objB->
    }
    else if(objB->getType() == TRG && EQ(objA->getName(),"player"))
    {
        objB->bLeft = true;
    }
    
    return;
}


void myContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
    b2Fixture* fixA = contact->GetFixtureA();
    b2Fixture* fixB = contact->GetFixtureB();
    CObject* objA = (CObject*)fixA->GetUserData();
    CObject* objB = (CObject*)fixB->GetUserData();
    
    
    //check if someone is dead
    if(objA->bDead && objB->getType() != PHY) contact->SetEnabled(false);
    else if(objB->bDead && objA->getType() != PHY) contact->SetEnabled(false);
    else if(objA->getType() == CHR && objB->getType() == CHR)
    {
        contact->SetEnabled(false);
    }
    
    
    
    // check if projectile not affect it's own caster
    CProjectile* proj = NULL;
    CObject* target = NULL;
    if(objA->getType() == PRO)
    {
        target = objB;
        proj = (CProjectile*)objA;
    }
    else if(objB->getType() == PRO)
    {
        target = objA;
        proj = (CProjectile*)objB; 
    }
    
    if(proj != NULL && target != NULL)
    {
        if(proj->caster == target)
            contact->SetEnabled(false);
    }
    
    
}

//
//-----
//---------------













@implementation CScene

@synthesize camera;




//----------------------------------------------------
// I N T E R A C T I V E

-(void)tilt:(float)angle
{
    tilt = angle;
}
-(float)tilt
{
    return tilt;
}


-(void)fingerDown:(GLKVector2)location
{
    int i;
    bool bButtons = false;
    for(i=0;i<vButtons.size();i++)
    {
        if( (location.y > vButtons[i].x && location.y < vButtons[i].z) &&
            (location.x > vButtons[i].y && location.x < vButtons[i].w) )
        {
            if(i > buttonsAllowed) break;
                
            [sprButtons[i] setFrame:1];
            [self onBtnPressed:i];
            bButtons = true;
        }
        else [sprButtons[i] setFrame:0];
    }
    
    //screen was tapped
    if(!bButtons)
    {
        [self castCurrentSpell:location];
    }
    
}

-(void)fingerUp:(GLKVector2)location
{
    int i;
    for(i=0;i<vButtons.size();i++)
    {
        if( (location.y > vButtons[i].x && location.y < vButtons[i].z) &&
           (location.x > vButtons[i].y && location.x < vButtons[i].w) )
        {
            //[sprButtons[i] setFrame:1];
            //[self onBtnPressed:i];
        }
        [sprButtons[i] setFrame:0];
    }
}

-(void)fingerMove:(GLKVector2)prevLocation to:(GLKVector2)location
{
    int i;
    for(i=0;i<vButtons.size();i++)
    {
        if( (location.y > vButtons[i].x && location.y < vButtons[i].z) &&
           (location.x > vButtons[i].y && location.x < vButtons[i].w) )
        {
            [sprButtons[i] setFrame:1];
        }
        else [sprButtons[i] setFrame:0];
    }
    
}

//----------------------------------------------------




//----------------------------------------------------
//  F O R    S P E L L S


// Name: addToCombo
// Desc: performs all stuff with spells, combo, etc

-(void)addToCombo:(int)buttonNum
{
    
    //TODO: animation and sounds of spells
    if(bComboReady || player->bDead || player->isImmobilized()) return;
    
    combo[comboCurLength] = (SpellButton)buttonNum;
    comboCurLength++;
    
    bool bMatch = false;
    bool bImmediatelyCast = false;
    char* c, *q;
    char line[128];
    char* file = GetFile((char*)[[CUtil getAssetN:@"system/combos.cfg"] cStringUsingEncoding:NSUTF8StringEncoding]);
    int curlen = 0;
    char ln2[64];
    char sname[64];
    char* p;
    bool bFin = false;
    
    
    for(c = file; *c != '\0'; c++)
    {
        //readline
        q=line;
        while(*c != '\n' && *c != '\r' && *c != '\0')
        {
            *q = *c;
            q++;
            c++;
        }
        if(*c == '\0') c--;
        *q = '\0';
        
        //separate the line
        curlen = 0;
        sprintf(sname,"empty");
        bFin = false;
        
        //explode by space
        for(q = line;*q != '\0';q++)
        {
            p = ln2;
            while(*q != ' ' && *q != '\0')
            {
                *p = *q;
                q++;
                p++;
            }
            if(*q == '\0') bFin = true;
            *p = '\0';
            
            //firstly fill name of the spell
            if(EQ(sname,"empty"))
            {
                strcpy(sname, ln2);
            }
            else
            {
                //one by one check current spell
                int cur = 0;
                if(EQ(ln2,"a")) cur = 0;
                else if(EQ(ln2,"f")) cur = 1;
                else if(EQ(ln2,"s")) cur = 2;
                else if(EQ(ln2,"i")) cur = 3;
                else if(EQ(ln2,"r")) cur = 4;
                curlen++;
                
                if(cur == (int)combo[curlen-1])
                {
                    if(curlen == comboCurLength)
                    {
                        if(bFin == false)
                        {
                            bMatch = true;
                            goto offCycle;
                        }
                        else
                        {
                            //spell casted!
                            bMatch = true;
                            
                            //memorize casted combo
                            castedCombo.clear();
                            for(int jk=0;jk < comboCurLength;jk++)
                            {
                                castedCombo.push_back(combo[jk]);
                            }
                            
                            comboCurLength = 0;
                            bComboReady = true;
                            if(sname[0] == '#')
                            {
                                sprintf(comboSpell, "[%s]", (char*)(sname+1));
                                bImmediatelyCast = true;
                            }
                            else
                            {
                                sprintf(comboSpell, "[%s]", sname);
                            }
                            
                            //add spelltext and underlay
                            [spellText removeAllFrames];
                            [spellText addFrameWithImage:[CUtil getTextTexture:[NSString stringWithCString:comboSpell encoding:NSUTF8StringEncoding] withFont:@"helvetica" withSize:12 withColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:255] ofSize:CGSizeMake(200.f, 20.f)]];
                            [spellText setFrame:0];
                            

                            goto offCycle;
                        }
                    }
                }
                else
                {
                    break;
                }
                
            }
        }
    }
    
offCycle:
    
    if(!bMatch)
    {
        //NSLog(@"Spell failed!");
        comboCurLength = 0;
    }
    else
    {
        if(bImmediatelyCast)
        {
            [self castCurrentSpell:GLKVector2Make(0, 0)];
        }
        
    }
    free(file);
    
}

-(void)castCurrentSpell:(GLKVector2)pt
{
    int i;
    
    if(bComboReady)
    {
        if(EQ(comboSpell,"[JUMP]"))
        {
            if(!player->bInAir)
            {
                player->physx_body->ApplyForceToCenter(b2Vec2(0.f,60.f));
                player->bInAir = true;
                player->AnimPlay("Cast2");
            }
        }
        else if(EQ(comboSpell,"[FIREBALL]"))
        {
            //add projectile
            CProjectile* proj = new CProjectile;
            proj->initProjectile(PROJ_FIREBALL, player);
            proj->x = player->x;
            proj->y = player->y+player->boxHeight/2;
            [self AddPhysxObject:(CObject*)proj];
            
            //calculate spell's speed
            GLKVector2 spd;
            GLKVector2 screenCoords = GLKVector2Make(player->y/camera.scale-camera.realY,player->x/camera.scale-camera.realX);
            spd = GLKVector2Make(pt.y-screenCoords.y,pt.x-screenCoords.x);
            spd = GLKVector2Normalize(spd);
            spd.x = spd.x*5; spd.y = spd.y*5;
            
            proj->physx_body->SetLinearVelocity(b2Vec2(spd.x, spd.y));
            proj->AnimPlay("Fly");
            projectiles.push_back(proj);
            
            if(!player->bInAir)
                player->AnimPlay("Cast3");
            else
                player->AnimPlay("JumpCast");
        }
        else if(EQ(comboSpell,"[STONEFIST]"))
        {
            //add projectile
            CProjectile* proj = new CProjectile;
            proj->initProjectile(PROJ_STONEFIST, player);
            proj->x = player->x;
            proj->y = player->y+player->boxHeight/2;
            [self AddPhysxObject:(CObject*)proj];
            
            //calculate spell's speed
            GLKVector2 spd;
            GLKVector2 screenCoords = GLKVector2Make(player->y/camera.scale-camera.realY,player->x/camera.scale-camera.realX);
            spd = GLKVector2Make(pt.y-screenCoords.y,pt.x-screenCoords.x);
            spd = GLKVector2Normalize(spd);
            spd.x = spd.x*5; spd.y = spd.y*5;

            proj->physx_body->SetLinearVelocity(b2Vec2(spd.x, spd.y));
            projectiles.push_back(proj);
            
            if(!player->bInAir)
                player->AnimPlay("Cast3");
            else
                player->AnimPlay("JumpCast");
        }
        else if(EQ(comboSpell,"[STONEWALL]"))
        {
            //add projectile
            b2Vec2 worldCoords;
            worldCoords.x = (camera.realX + pt.y*camera.scale)/PTM_RATIO;
            worldCoords.y = (camera.realY + pt.x*camera.scale)/PTM_RATIO;
            
            myRayCastCallback callback;
            callback.addIgnore(1, (ObjType[]){TRG,PRO});
            world->RayCast(&callback, worldCoords, b2Vec2(worldCoords.x,worldCoords.y - 600));
            
            if(callback.m_fixture != NULL)
            {
                CObject* obj = (CObject*)callback.m_fixture->GetUserData();
                
                if(obj->getType() == PHY)
                {
                    CProjectile* proj = new CProjectile;
                    proj->initProjectile(PROJ_STONEWALL, NULL);
                    proj->x = worldCoords.x*PTM_RATIO;
                    proj->y = (worldCoords.y-600*callback.m_fraction)*PTM_RATIO;
                    [self AddPhysxObject:(CObject*)proj];
                    
                    proj->physx_body->SetLinearVelocity(b2Vec2(0, 0));
                    projectiles.push_back(proj);
                    
                    if(!player->bInAir)
                        player->AnimPlay("Cast3");
                    else
                        player->AnimPlay("JumpCast");
                }
                else
                {
                    player->AnimPlay("CastFail");
                }
            }
        }
        else if(EQ(comboSpell,"[LIGHTNING]"))
        {
            //raycast test
            b2Vec2 worldCoords;
            b2Vec2 playerPos = player->physx_body->GetPosition();
            worldCoords.x = (camera.realX + pt.y*camera.scale)/PTM_RATIO;
            worldCoords.y = (camera.realY + pt.x*camera.scale)/PTM_RATIO;
            
            GLKVector2 diff = GLKVector2Make(worldCoords.x - playerPos.x, worldCoords.y - playerPos.y);
            diff = GLKVector2Normalize(diff);
            diff.x *= 500; diff.y *= 500;
            worldCoords.x = playerPos.x + diff.x;
            worldCoords.y = playerPos.y + diff.y;
            
            myRayCastCallback callback;
            callback.addIgnore(1,(ObjType[]){TRG});
            world->RayCast(&callback, playerPos, worldCoords);
            
            
            //get lightning end point
            b2Vec2 vector;
            if(callback.m_fixture != NULL)
            {
                CObject* targ = (CObject*)callback.m_fixture->GetUserData();
                vector = b2Vec2(
                    playerPos.x + diff.x*callback.m_fraction,
                    playerPos.y + diff.y*callback.m_fraction
                );
                vector.x = vector.x*PTM_RATIO;
                vector.y = vector.y*PTM_RATIO;
                
                
                //enemy reaction
                if(targ->getType() == CHR)
                {
                    targ->health -= 25;
                    targ->AnimPlay("Hurt");
                    if(!EQ(targ->getName(),"player")) targ->bShowHealth = true;
                    if(targ->health <= 0)
                    {
                        targ->health = 0;
                        targ->AnimPlay("Die");
                    }
                }
                else if(EQ(targ->getName(),"fireball"))
                {
                    targ->AnimPlay("Blow");
                    targ->bDead = true;
                    targ->DeleteAfterDelay(0.4f);
                }
            }
            else
            {
                vector = worldCoords;
                vector.x = vector.x*PTM_RATIO;
                vector.y = vector.y*PTM_RATIO;
            }
            
            //generate lightning decal
            float emitX, emitY;
            emitX = (player->x+player->boxWidth/2);
            emitY = (player->y+player->boxHeight/2);
            float offset_x = GLKVector2Distance(GLKVector2Make(emitX,emitY), GLKVector2Make(vector.x, vector.y));
            
            CObject* lightning_obj = [self AddObjectFromSpells:"LIGHTNING" toX: emitX toY:emitY];
            float angle = atan2(vector.y - emitY, vector.x-emitX);
            
            int lightningSizeX = GLKVector2Length(GLKVector2Make(vector.x-emitX, vector.y - emitY));
            [lightning_obj->sprite setSizeX:lightningSizeX sizeY:lightning_obj->sprite.height];
            [lightning_obj->sprite setRotation:angle];
            [lightning_obj->sprite setRotationPivot:GLKVector2Make(0,lightning_obj->sprite.height/2)];
            lightning_obj->DeleteAfterDelay(0.4);
            lightning_obj->AnimPlay("Fly");
            
            if(!player->bInAir)
                player->AnimPlay("Cast1");
            else
                player->AnimPlay("JumpCast");
                
        }
        else if(EQ(comboSpell,"[BURST]"))
        {
            //add projectile
            CProjectile* proj = new CProjectile;
            proj->initProjectile(PROJ_BURST, player);
            proj->x = player->x+player->boxWidth/2;
            proj->y = player->y-proj->boxHeight;
            proj->ConnectToCasterWithOffset(b2Vec2(0, -proj->boxHeight*0.9));
            [self AddPhysxObject:(CObject*)proj];
            
            proj->DeleteAfterDelay(0.5);
            proj->AnimPlay("Fly");
            projectiles.push_back(proj);
            
            player->physx_body->ApplyForceToCenter(b2Vec2(0.f,90.f));
            player->bInAir = true;
            player->AnimPlay("Cast2");
            
        }
        else if(EQ(comboSpell,"[ICESHIELD]"))
        {
            //add projectile
            CProjectile* proj = new CProjectile;
            proj->initProjectile(PROJ_ICESHIELD, player);
            proj->x = player->x+(player->boxWidth-proj->boxWidth)/2.f;
            proj->y = player->y+(player->boxHeight-proj->boxHeight)/2.f;
            proj->ConnectToCasterWithOffset(b2Vec2((player->boxWidth-proj->boxWidth)/2.f, (player->boxHeight-proj->boxHeight)/2.f));
            [self AddPhysxObject:(CObject*)proj];
            
            proj->DeleteAfterDelay(1.5f);
            proj->AnimPlay("idle");
            projectiles.push_back(proj);
            
            player->AnimPlay("Cast1");
            player->immobilizeFor(1.5f);
        }
        else if(EQ(comboSpell,"[FIRESHIELD]"))
        {
            //add projectile
            CProjectile* proj = new CProjectile;
            proj->initProjectile(PROJ_FIRESHIELD, player);
            proj->x = player->x+(player->boxWidth-proj->boxWidth)/2.f;
            proj->y = player->y+(player->boxHeight-proj->boxHeight)/2.f;
            proj->ConnectToCasterWithOffset(b2Vec2((player->boxWidth-proj->boxWidth)/2.f, (player->boxHeight-proj->boxHeight)/2.f));
            [self AddPhysxObject:(CObject*)proj];
            
            proj->DeleteAfterDelay(1.5f);
            proj->AnimPlay("idle");
            projectiles.push_back(proj);
            
            player->AnimPlay("Cast1");
            player->immobilizeFor(1.5f);
        }
        else
        {
            NSLog(@"Don't know how to cast %s", comboSpell);
        }
        
        bComboReady = false;
    }
    else
    {
        comboCurLength = 0;
    }
}


-(void)castSpell:(char *)spellname By:(CObject *)chr to:(GLKVector2)pt
{
    if(EQ(spellname,"[FIREBALL]"))
    {
        CProjectile* proj = new CProjectile;
        proj->initProjectile(PROJ_FIREBALL, chr);
        proj->x = chr->x;
        proj->y = chr->y + chr->boxHeight/2;
        [self AddPhysxObject:(CObject*)proj];
        
        //calculate spell's speed
        GLKVector2 spd;
        spd = GLKVector2Make(pt.x-chr->x,pt.y-chr->y);
        spd = GLKVector2Normalize(spd);
        spd.x = spd.x*5; spd.y = spd.y*5;
        
        proj->physx_body->SetLinearVelocity(b2Vec2(spd.x, spd.y));
        
        proj->AnimPlay("Fly");
        projectiles.push_back(proj);
    }
    else if(EQ(spellname, "[KICK]"))
    {
        CProjectile* proj = new CProjectile;
        proj->initProjectile(PROJ_KICK, chr);
        proj->x = chr->x + chr->orientation()*proj->boxWidth;
        proj->y = chr->y;
        
        [self AddPhysxObject:(CObject*)proj];
        
        proj->DeleteAfterDelay(0.5f);
        projectiles.push_back(proj);
        
        chr->immobilizeFor(0.5f);
    }
}

//----------------------------------------------------



//---------------------------------------------------------
// Name: F R A M E   M O V E
// Desc:
//---------------------------------------------------------
-(BOOL)IsCollisionObject:(CObject*)obj
{
    if(obj->getType() == CHR ||
       obj->getType() == PHY ||
       obj->getType() == ITM ||
       obj->getType() == TRG ||
       obj->getType() == PRO
       ) return true;
    else return false;
}

-(void)ProcessCommand:(char *)command
{
    int i;
	vector<char*>* mas = explode(" ", command);
    
	//animation
	if(EQ(mas->at(0),"play"))
	{
		CObject* obj = [self getObjectByName:mas->at(1)];
		if(obj == NULL) { printf("Error: no such object: %s\n", mas->at(1)); goto ProcessCommandEnd;}
        
		obj->AnimPlay(mas->at(2));
	}
    
	//tween
	else if(EQ(mas->at(0),"goto"))
	{
		
		if(EQ(mas->at(1),"camera"))
		{
            if(mas->size() == 5)
            {
                float time = floatval(mas->at(4));
                float destinX = floatval(mas->at(2));
                float destinY = floatval(mas->at(3));
                float speedXl = (destinX - camera.x)/time;
                float speedYl = (destinY - camera.y)/time;
                
                [self AddCameraTween:GLKVector2Make(speedXl, speedYl) dest:GLKVector2Make(destinX, destinY)];
                [self performSelector:@selector(endtween) withObject:self afterDelay:time];
                bCameraTweening = true;
                bCameraFollow = false;
            }
            else
            {
                camera.x = floatval(mas->at(2));
                camera.y = floatval(mas->at(3));
            }
		}
		else
		{
			CObject* obj = [self getObjectByName:mas->at(1)];
			if(obj == NULL) { printf("Error: no such object: %s\n", mas->at(1)); goto ProcessCommandEnd; }
            
			float time = floatval(mas->at(4));
			float destinX = floatval(mas->at(2));
			float destinY = floatval(mas->at(3));
			float speedXl = (destinX - obj->x)/time;
			float speedYl = (destinY - obj->y)/time;
            
            [self AddMotionTween:obj speed:GLKVector2Make(speedXl, speedYl) dest:GLKVector2Make(destinX, destinY) time:time];
		}
	}
    
	//activate deactivate
	else if(EQ(mas->at(0),"activate"))
	{
		CObject* obj = [self getObjectByName:mas->at(1)];
		if(obj == NULL) { printf("Error: no such object: %s\n", mas->at(1)); goto ProcessCommandEnd;}
        
		obj->active = true;
	}
	else if(EQ(mas->at(0),"deactivate"))
	{
		CObject* obj = [self getObjectByName:mas->at(1)];
		if(obj == NULL) { printf("Error: no such object: %s\n", mas->at(1)); goto ProcessCommandEnd;}
        
		obj->active = false;
	}
    
	//showbuttons hidebuttons
	else if(EQ(mas->at(0),"showbuttons"))
	{
		bShowButtons = true;
	}
	else if(EQ(mas->at(0),"hidebuttons"))
	{
		bShowButtons = false;
	}
    
	//showstripes hidestripes
	else if(EQ(mas->at(0),"showstripes"))
	{
        bShowStripes = true;
	}
	else if(EQ(mas->at(0),"hidestripes"))
	{
        bShowStripes = false;
	}
    
	//blackin blackout
	else if(EQ(mas->at(0),"blackin"))
	{
        bBlackin = true;
		bBlackout = false;
		fBlackAlpha = 0;
		[sprBlack setTransparency:fBlackAlpha];
        
	}
	else if(EQ(mas->at(0),"blackout"))
	{
		bBlackout = true;
		bBlackin = false;
		fBlackAlpha = 1;
		[sprBlack setTransparency:fBlackAlpha];
        
	}
    
	//stopcontrol
	else if(EQ(mas->at(0),"stopcontrol"))
	{
		bControl = false;
	}
	else if(EQ(mas->at(0),"startcontrol"))
	{
		bControl = true;
	}
    
	//camerafollow
	else if(EQ(mas->at(0),"stopcamerafollow"))
	{
		bCameraFollow = false;
	}
	else if(EQ(mas->at(0),"startcamerafollow"))
	{
		bCameraFollow = true;
	}
    
	//screenset screenon screenoff
	else if(EQ(mas->at(0),"screenset"))
	{
        [sprScreens[0] setTexture:mas->at(1)];
	}
	else if(EQ(mas->at(0),"screenon"))
	{
        bScreenOn = true;
	}
	else if(EQ(mas->at(0),"screenoff"))
	{
        bScreenOn = false;
	}
    
	//showtext hidetext
	else if(EQ(mas->at(0),"showtext"))
	{
		char str[512] = "";
		int sym_cnt = 0;
		for(i=1; i<mas->size(); i++)
		{
			sym_cnt += strlen(mas->at(i));
			/*if(sym_cnt > 50)
            {
				JOIN_DEL("\n", str,"");
                sym_cnt = 0;
			}*/
            JOIN_DEL(" ", str, mas->at(i));
		}
        
        [sprText removeAllFrames];
        [sprText addFrameWithImage:[CUtil getTextTexture:[NSString stringWithCString:str encoding:NSUTF8StringEncoding] withFont:@"helvetica" withSize:18 withColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:255] ofSize:CGSizeMake(440.f, 50.f)]];
        [sprText setFrame:0];
        
        bShowText = true;
	}
	else if(EQ(mas->at(0),"hidetext"))
	{
        bShowText = false;
	}
    
    else if(EQ(mas->at(0),"spawn"))
	{
        int ix,iy;
        ix = intval(mas->at(2));
        iy = intval(mas->at(3));
        [self AddObjectFromCollection:mas->at(1) toX:ix toY:iy];
	}
    
	//load level
	else if(EQ(mas->at(0),"loadlevel"))
	{
        NSString* str = [CUtil getAssetN:[NSString stringWithCString:mas->at(1) encoding:NSUTF8StringEncoding]];
        [self loadLevel:str];
	}
    
ProcessCommandEnd:
    
	for(i=0;i < mas->size(); i++) free(mas->at(i));
	mas->clear();
	free(mas);
	return;
}



-(void)endtween
{
    bCameraTweening = false;
}


-(void)onBtnPressed:(int)bid
{
    b2Vec2 velocity;
    switch(bid)
	{
        case 0:
            [self addToCombo:0];
            break;
            
        case 1:
            [self addToCombo:1];
            break;
            
        case 2:
            [self addToCombo:2];
            break;
            
        case 3:
            [self addToCombo:3];
            break;
            
        case 4:
            [self addToCombo:4];
            break;
            
            
            // MENU
        case 10: //left
            break;
        case 11: //right

            break;
	}
}

//---------------------------
// Name: update
// Desc: main update loop
//---------------------------

-(void)update:(NSTimeInterval)dt
{
    dt = 1.f/30.f;
    
    int i,j;
    
    
    // menu
    if(bMenu)
    {
        return;
    }
    
    
    // scriptmanager

    scriptMan.FrameMove(dt*1000.f);
        
    char str[256];
    while(scriptMan.GetCommandFromStack(str) != -1)
    {
        fprintf(stderr,"stack command: %s", str);
        [self ProcessCommand:str];
    }

    
    //gui
    
    //blackin blackout
	if(bBlackout)
	{
		fBlackAlpha -= 0.03f;
		if(fBlackAlpha <= 0)
		{
			bBlackout = false;
			fBlackAlpha = 0;
		}
        
		[sprBlack setTransparency:fBlackAlpha];
	}
	else if(bBlackin)
	{
		fBlackAlpha += 0.03f;
		if(fBlackAlpha >= 1.f)
		{
			bBlackin = false;
			fBlackAlpha = 1.f;
		}
        
		[sprBlack setTransparency:fBlackAlpha];
	}
    
    
    //----------------------------------
	// C O N T R O L S    and    A I
	
	if(bControl && !player->bDead && !player->isImmobilized())
	{
		[self update_player_control:dt];
	}
    
    for(i=0;i<objects.size();i++)
    {
        if(objects[i]->getAIType() != -1 && !objects[i]->bDead && !objects[i]->isImmobilized())
        {
            [self AIControl:objects[i]];
        }
        
        if(objects[i]->bShowHealth)
        {
            lifebar_time = 2.f;
            [lifebar setSizeX:(float)((float)objects[i]->health/(float)objects[i]->maxHealth*162.f) sizeY:lifebar.height];
            objects[i]->bShowHealth = false;
        }
    }
    

    
    //-------------------
    // P H Y S I C S
    
    //gravity
    world->Step(dt, 10, 10);
    
    for (i=0; i<objects.size(); i++)
    {
        if(objects[i]->physx_body != NULL)
        {
            b2Body* b = objects[i]->physx_body;
            
            CGPoint newCenter = CGPointMake(b->GetPosition().x*PTM_RATIO-objects[i]->boxWidth/2, b->GetPosition().y*PTM_RATIO-objects[i]->boxHeight/2);
            objects[i]->x = newCenter.x;
            objects[i]->y = newCenter.y;
            [objects[i]->sprite setRotation:b->GetAngle()];
        }
    }
    
    for (i=0; i<projectiles.size(); i++)
    {
        if(projectiles[i]->physx_body != NULL)
        {
            b2Body* b = projectiles[i]->physx_body;
            
            
            if(projectiles[i]->bConnectedToCaster)
            {
                // from obj to physx
                
                CProjectile* proj = projectiles[i];
                
                b2Vec2 newpos = b2Vec2((proj->x + proj->boxWidth*0.5f)/PTM_RATIO, (proj->y + proj->boxHeight*0.5f)/PTM_RATIO);
                float newrot = proj->rotation;
                
                b->SetTransform(newpos, newrot);
            }
            else
            {
                // from physx to obj
                
                CGPoint newCenter = CGPointMake(b->GetPosition().x*PTM_RATIO-projectiles[i]->boxWidth/2, b->GetPosition().y*PTM_RATIO-projectiles[i]->boxHeight/2);
                projectiles[i]->x = newCenter.x;
                projectiles[i]->y = newCenter.y;
                [projectiles[i]->sprite setRotation:b->GetAngle()];
            }
        }
    }
    
        
    
    //---------------------------
	// A F T E R   P H Y S I C S
    
	//triggers
	for(i=0;i<objects.size();i++)
	{
		if(objects[i]->getType() == TRG && (!objects[i]->bTriggeronce || !objects[i]->bTriggered) && objects[i]->active)
		{
			if(objects[i]->bEntered && !objects[i]->bColliding)
			{
				objects[i]->bEntered = false;
				
				scriptMan.ExecuteByName(objects[i]->onenter);
			}
            else if(objects[i]->bLeft && !objects[i]->bColliding)
            {
                objects[i]->bTriggered = true;
                objects[i]->bLeft = false;
                
                scriptMan.ExecuteByName(objects[i]->onleave);
            }
		}
	}
    
    
    // camera stuff
    
    if(bCameraFollow)
    {
        [self update_camera_follow:dt];
    }
    if(bCameraTweening)
	{
		camera.x += cam_speedX*dt;
		camera.y += cam_speedY*dt;
	}
    [camera update];
    
    
    
    //-------------------------------
    // L O G I C   M O V E M E N T
    
    // tween move
	for(i=0;i<tweens.size();i++)
	{
		if(tweens[i].FrameMove(1.f/30.f) == 1)
		{
			tweens.erase( tweens.begin() + i);
			i--;
		}
	}
    for(i=0;i<objects.size();i++) objects[i]->FrameMove(dt);
    
    for(i=0;i<projectiles.size();i++)
		projectiles[i]->FrameMove(dt);
    
    
    
    // etc
    
    if(lifebar_time > 0) lifebar_time -= dt;
    
    
    //-----------------
	// C L E A N U P
    
	for(i=0;i<objects.size();i++)
	{
		if(objects[i]->toDelete)
		{
            if(objects[i]->physx_body != NULL)
                world->DestroyBody(objects[i]->physx_body);
            
			objects.erase(objects.begin()+i);
			if(i <= playerIndex)
            {
                playerIndex--;
                player = objects[playerIndex];
            }
			i--;
		}
        else if(objects[i]->toDeletePhysXObject)
        {
            if(objects[i]->physx_body != NULL)
                world->DestroyBody(objects[i]->physx_body);
        }
	}
    
    for(i=0;i<projectiles.size();i++)
	{
		if(projectiles[i]->toDelete)
		{
            if(projectiles[i]->physx_body != NULL)
                world->DestroyBody(projectiles[i]->physx_body);
            
			projectiles.erase(projectiles.begin()+i);
			i--;
		}
        else if(projectiles[i]->toDeletePhysXObject)
        {
            if(projectiles[i]->physx_body != NULL)
                world->DestroyBody(projectiles[i]->physx_body);
        }
	}
    
    for(i=0;i<particles.size();i++)
    {
        if(particles[i]->toDelete)
        {            
            particles.erase(particles.begin()+i);
            i--;
        }
    }
    
    
}


-(void)update_player_control:(NSTimeInterval)dt
{
    //controls coordinates
    float tx = tilt;
    float q = 1.f;
    float speedx;
    
    
    // depending on orientation
    if(tx > 0) q = 1.f;
    else q = -1.f;
    tx = fabs(tx);
    
    if(tx < 2.8) tx = 2.8;
    speedx = fabs(3.12-tx);
    if(speedx < 0.05) speedx = 0;
    speedx *= dt*400.f;
    
    
    // anim & 2 speed mode
    
    if(q > 0 && speedx > 0.6) player->sprite.bReflectX = true;
    else if(q < 0 && speedx > 0.6) player->sprite.bReflectX = false;
    
    if(speedx > 4.0)
    {
        speedx = 3.0f;
        if(!player->bInAir) player->AnimPlay("Run");
        else player->AnimPlay("Jump");
    }
    else if(speedx > 1.8)
    {
        speedx = 1.4f;
        if(!player->bInAir) player->AnimPlay("Walk");
        else player->AnimPlay("Jump");
    }
    else
    {
        speedx = 0;
        if(!player->bInAir)
        {
            if(bComboReady) player->AnimPlay("ReadyStand");
            else player->AnimPlay("Stand");
        }
        else player->AnimPlay("Jump");
    }
    
    speedx *= q;
    
    player->physx_body->SetLinearVelocity(b2Vec2(-speedx,player->physx_body->GetLinearVelocity().y));
    
    if(player->y < -300)
        [self loadLevel:sLevelName];
    
    //player->physx_body->ApplyForceToCenter(b2Vec2(-speedx,0));
    //if(player->x > camera_max_x) player->x = camera_max_x;
    //else if(player->x < camera_min_x) player->x = camera_min_x;
}


-(void)update_camera_follow:(NSTimeInterval)dt
{
    //-------------------------
    //floating camera block
    int i;
    float maxCamSpd = 27;
    float maxScaleSpd = 0.03;
    
    GLKVector2 cameraGoto;
    float cameraGotoScale = 1.f;
    float cameraGotoScaleY = 1.f;
    
    if(player->sprite.bReflectX == true)
        cameraGoto.x = player->x - 150*camera.scale;
    else
        cameraGoto.x = player->x + 140*camera.scale;
    
    cameraGoto.y = player->y*0.7f + 140*camera.scale;
    if(cameraGoto.y < player->y + 40*camera.scale)
        cameraGoto.y = player->y + 40*camera.scale;
    
    
    //analyzing scale and offset of camera
    vector<CObject*> closestObj;
    float minDistX = 0;
    float maxDistX = 0;
    float minDistY = 0;
    float maxDistY = 0;
    float centermassX = 0;
    for(i=0;i<objects.size();i++)
    {
        if(objects[i]->getType() != CHR || EQ(objects[i]->getName(),"player") || objects[i]->bDead) continue;
        if(fabs(objects[i]->x - player->x) < 400)
        {
            closestObj.push_back(objects[i]);
            centermassX += objects[i]->x;
        }
    }
    if(closestObj.size() > 0)
    {
        centermassX += player->x*closestObj.size();
        centermassX = centermassX/(closestObj.size()*2);
        
        for(i=0;i<closestObj.size();i++)
        {
            if(closestObj[i]->x - centermassX < minDistX)
                minDistX = closestObj[i]->x - centermassX;
            if(closestObj[i]->x - centermassX > maxDistX)
                maxDistX = closestObj[i]->x - centermassX;
            if(closestObj[i]->y - player->y < minDistY)
                minDistY = closestObj[i]->y - player->y;
            if(closestObj[i]->y - player->y > maxDistY)
                maxDistY = closestObj[i]->y - player->y;
        }
        
        // scale decision
        
        //X
        if(maxDistX - minDistX > 360) cameraGotoScale = (maxDistX - minDistX)/360.f;
        else if(maxDistX > 170) cameraGotoScale = (maxDistX)/170.f;
        else if(minDistX < -150) cameraGotoScale = fabs(minDistX)/150.f;
        else cameraGotoScale = 1.f;
        if(cameraGotoScale > 1.3f) cameraGotoScale = 1.3f;
        
        //Y
        if(maxDistY - minDistY > 200) cameraGotoScaleY = (maxDistY - minDistY)/200.f;
        else cameraGotoScaleY = 1.f;
        if(cameraGotoScaleY > 1.3f) cameraGotoScaleY = 1.3f;
        
        if(minDistY/cameraGotoScaleY < -65) cameraGoto.y -= -65 - minDistY/cameraGotoScaleY;
        if(maxDistY/cameraGotoScaleY > 135) cameraGoto.y += maxDistY/cameraGotoScaleY - 135;
        
        //RES
        if(cameraGotoScaleY > cameraGotoScale) cameraGotoScale = cameraGotoScaleY;
        
        //position decision
        cameraGoto.x = centermassX;
        
        closestObj.clear();
    }
    
    // slow scale
    float diffScale = camera.scale - cameraGotoScale;
    if(fabs(diffScale) < maxScaleSpd) maxScaleSpd = fabs(diffScale);
    if(diffScale > 0) camera.scale -= maxScaleSpd;
    else if(diffScale < 0) camera.scale += maxScaleSpd;
    
    // slow start
    float cameraSpd = camera.x-cameraGoto.x;
    if(cameraSpd < -maxCamSpd) cameraSpd = -maxCamSpd;
    else if(cameraSpd > maxCamSpd) cameraSpd = maxCamSpd;
    
    
    if(signof(camera.speed.x) != signof(cameraSpd))
        camera.speed = GLKVector2Make(0,camera.speed.y);
    if(fabs(camera.speed.x) > fabs(cameraSpd) || fabs(cameraSpd) < maxCamSpd)
        camera.speed = GLKVector2Make(cameraSpd, camera.speed.y);
    else camera.speed = GLKVector2Make(camera.speed.x + 2 * signof(cameraSpd), camera.speed.y);
    
    cameraSpd = camera.y-cameraGoto.y;
    if(cameraSpd < -maxCamSpd) cameraSpd = -maxCamSpd;
    else if(cameraSpd > maxCamSpd) cameraSpd = maxCamSpd;
    
    
    if(signof(camera.speed.y) != signof(cameraSpd))
        camera.speed = GLKVector2Make(camera.speed.x,0);
    if(fabs(camera.speed.y) > fabs(cameraSpd) || fabs(cameraSpd) < maxCamSpd)
        camera.speed = GLKVector2Make(camera.speed.x, cameraSpd);
    else camera.speed = GLKVector2Make(camera.speed.x, camera.speed.y + 2 * signof(cameraSpd));
    
    
    camera.x -= camera.speed.x;
    camera.y -= camera.speed.y;
    
    
    //camera limits
    
    if(camera.x < 240*camera.scale) camera.x = 240*camera.scale;
    if(camera.x > cameraMax*camera.scale) camera.x = cameraMax*camera.scale;
    
    if(camera.y < 180*camera.scale) camera.y = 180*camera.scale;
}



-(void)AIControl:(CObject *)obj
{
    int i;
    
    //--------
    //planning phase
    
    aiAction current = obj->aiGetCurrentAction();
    
    switch(obj->getAIType())
    {
        case AITypeTestEnemy:
            
            //facing
            int orientation = obj->x - player->x;
            if(orientation > 0) obj->sprite.bReflectX = true;
            else obj->sprite.bReflectX = false;
                        
            //planning
            float dist = fabs(player->x - obj->x);
            if(dist > 550)
            {
                obj->aiClearActions();
                obj->aiAddAction("moveto",0,player);
            }
            else if(dist < 80)
            {
                obj->aiClearActions();
                obj->aiAddAction("cast [KICK]",0,player);
            }
            else
            {
                if(EQ(current.name,"none"))
                {
                    obj->aiAddAction("wait", 3);
                    if(bControl) obj->aiAddAction("cast [FIREBALL]",0, player);
                }
            }
            
            break;
    }
    
    
    //--------
    //execution phase
    
    vector<char*>* mas = explode(" ",current.name);
    
    if(EQ(mas->at(0),"none") || EQ(mas->at(0),"wait"))
    {
        //do nothing actually
        obj->AnimPlay("Stand");
    }
    else if(EQ(mas->at(0),"cast"))
    {            
        GLKVector2 trg;
        if(current.target != NULL) trg = GLKVector2Make(current.target->x,current.target->y);
        else trg = current.vDest;
        
        [self castSpell:mas->at(1) By:obj to:trg];
        
        obj->AnimPlay("Cast3");
    }
    else if(EQ(mas->at(0),"moveto"))
    {
        GLKVector2 tcoord;
        
        //moveto object
        if(current.target != NULL)
            tcoord = GLKVector2Make(current.target->x, current.target->y);
        else //moveto coord
            tcoord = current.vDest;
        
        float tspd;
        int orientation = obj->x - tcoord.x;
        if(orientation > 0) tspd = 1.8f;
        else tspd = -1.8f;
        
        obj->physx_body->SetLinearVelocity(b2Vec2(-tspd,obj->physx_body->GetLinearVelocity().y));
        
        obj->AnimPlay("Walk");
    }
            
    
    
    //cleanup
    for(i=0;i < mas->size(); i++) free(mas->at(i));
	mas->clear();
	free(mas);
    
}


-(void)Physics:(CObject*)a with:(CObject*)b
{
    vec2* diff = CCollision::getCollision(&(a->box), &(b->box));
    
    if(diff != NULL)
    {
                
        //--------------------
		// R E A C T I O N S
		
		// movement
        
		if((a->getType()==CHR || a->getType()==ITM) && (b->getType()==CHR || b->getType()==ITM))
		{
			diff->x = diff->x/2.f;
			diff->y = diff->y/2.f;
		}
		if((a->getType()==CHR || a->getType()==ITM) && (b->getType() == PHY || b->getType()==ITM || b->getType()==CHR))
		{
			a->x += diff->x;
			a->y += diff->y;
			if(diff->x > 0 && a->speedX < 0) a->speedX = 0;
			if(diff->x < 0 && a->speedX > 0) a->speedX = 0;
			if(diff->y > 0 && a->speedY < 0) a->speedY = 0;
			if(diff->y < 0 && a->speedY > 0) a->speedY = 0;
			a->UpdateAABB();
		}
		if((b->getType()==CHR || b->getType()==ITM) && (a->getType() == PHY || a->getType()==ITM || a->getType()==CHR))
		{
			b->x -= diff->x;
			b->y -= diff->y;
			if(diff->x > 0 && a->speedX < 0) a->speedX = 0;
			if(diff->x < 0 && a->speedX > 0) a->speedX = 0;
			if(diff->y > 0 && a->speedY < 0) a->speedY = 0;
			if(diff->y < 0 && a->speedY > 0) a->speedY = 0;
			b->UpdateAABB();
		}
        
        
		//reaction triggers
        
		if( a->getType()==TRG && !(a->bTriggeronce && a->bTriggered) && EQ(b->getName(),"player"))
		{
			a->bColliding = true;
			if(!a->bEntered)
			{
				a->bEntered = true;
				scriptMan.ExecuteByName(a->onenter);
			}
		}
		else if( b->getType()==TRG && !(b->bTriggeronce && b->bTriggered) && EQ(a->getName(),"player"))
		{
			b->bColliding = true;
			if(!b->bEntered)
			{
				b->bEntered = true;
				scriptMan.ExecuteByName(b->onenter);
			}
		}
        
        
		//damage
        /*
		if( a->getType()==PRO && b->getType()==CHR && !EQ(a->parent,b->getName()))
		{
			b->active = false;
			a->toDelete = true;
		}
		else if( a->getType()==CHR && b->getType()==PRO && !EQ(b->parent,a->getName()))
		{
			a->active = false;
			b->toDelete = true;
		}*/
    }
    
    free(diff);
    
    return;
}



//---------------------------------------------------------
// Name: R E N D E R
// Desc:
//---------------------------------------------------------
-(void)render
{
    int i;
    
    glClearColor(1.f, 0.f, 0.f, 0.f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    //render objects
    
    //resort object
    sort(objects.begin(), objects.end(), CObjectSort);
    
    //render
    for(i=0;i<objects.size();i++)
    {
        if(!objects[i]->active) continue;
        
        objects[i]->Render(camera);
    }
    
    for(i=0;i<projectiles.size();i++)
    {
        //if(!projectiles[i]->active) continue;
        
        projectiles[i]->Render(camera);
    }
    
    
    // D E B U G
    //render physx - for DEBUG means
    for(i=0;i<objects.size();i++)
    {
        if(!objects[i]->active) continue;
        
        if(objects[i]->physx_body != NULL)
        {
            b2Body* b = objects[i]->physx_body;
            
            CGPoint newCenter = CGPointMake(b->GetPosition().x*PTM_RATIO-objects[i]->boxWidth/2, b->GetPosition().y*PTM_RATIO-objects[i]->boxHeight/2);
            
            GLKVector2 bcenter = GLKVector2Make(newCenter.x, newCenter.y);
            GLKVector2 bsize = GLKVector2Make(objects[i]->boxWidth, objects[i]->boxHeight);
            [objects[i]->sprite renderBoxWithScale:camera.scale camX:camera.realX*objects[i]->cameraQ camY:camera.realY*objects[i]->cameraQ boxCenter:bcenter boxSizes:bsize];
        }
    }
    for(i=0;i<projectiles.size();i++)
    {
        if(!projectiles[i]->active) continue;
        
        if(projectiles[i]->physx_body != NULL)
        {
            b2Body* b = projectiles[i]->physx_body;
            
            CGPoint newCenter = CGPointMake(b->GetPosition().x*PTM_RATIO-projectiles[i]->boxWidth/2, b->GetPosition().y*PTM_RATIO-projectiles[i]->boxHeight/2);
            
            GLKVector2 bcenter = GLKVector2Make(newCenter.x, newCenter.y);
            GLKVector2 bsize = GLKVector2Make(projectiles[i]->boxWidth, projectiles[i]->boxHeight);
            [projectiles[i]->sprite renderBoxWithScale:camera.scale camX:camera.realX*projectiles[i]->cameraQ camY:camera.realY*projectiles[i]->cameraQ boxCenter:bcenter boxSizes:bsize];
        }
    }
    
    
    //render mennu etc    
    if(bShowButtons)
    {
        [player_lifebar_underlay renderAbsolute];
        
        [player_lifebar setSizeX:player_lifebar.width sizeY:((float)player->health/(float)player->maxHealth)*320.f];
        [player_lifebar renderAbsolute];
        
        for(i=0; i < sprButtons.size(); i++)
        {
            if(i > buttonsAllowed) break;
            [sprButtons[i] renderAbsolute];
        }
    }
    
    if(lifebar_time > 0)
    {
        [lifebar_underlay renderAbsolute];
        [lifebar renderAbsolute];
    }
    
    if(bShowStripes)
    {
        [sprStripes renderAbsolute];
    }
    
    if(bShowText)
    {
        [sprText renderAbsolute];
    }
    
    if(bScreenOn)
    {
        for(i=0;i<sprScreens.size();i++)
            [sprScreens[i] renderAbsolute];
    }
    
    //icons
    float coordY = 2;
    float coordX;
    CSprite* curico;
    for(i=0;i<comboCurLength;i++)
    {
        coordX = 80 + 25*i;
        
        curico = spellIcons[(int)combo[i]];
        
        [curico setPosition:GLKVector2Make(coordX, coordY)];
        [curico renderAbsolute];
    }
    if(bComboReady)
    {
        for(i=0;i<castedCombo.size();i++)
        {
            coordX = 80 + 25*i;
            
            curico = spellIcons[(int)castedCombo[i]];
            
            [curico setPosition:GLKVector2Make(coordX, coordY)];
            [curico renderAbsolute];
        }
        
        [spellText setPosition:GLKVector2Make(80+25*castedCombo.size(), 3)];
        [spellText renderAbsolute];
    }
    
    
    [sprBlack renderAbsolute];
    
}




//---------------------------------------------------------
// Name: I N I T I A L I Z A T I O N
// Desc:
//---------------------------------------------------------
-(id)init
{
    self = [super init];
    
    bMenu = false;
    
    
    //physx init
    b2Vec2 gravity;
    gravity.Set(0.f, -9.81f);
    
    world = new b2World(gravity);
    world->SetContinuousPhysics(true);
    world->SetAllowSleeping(true);
    contListener = new myContactListener;
    world->SetContactListener(contListener);
    
    
    //vars init
    camera = [[CCamera alloc] init];
    camera.x = 0;
    camera.y = 0;
    camera.scale = 1.f;
    [camera update];
    
    bCameraFollow = false;
    bCameraTweening = false;
    
    bComboReady = false;
    comboCurLength = 0;
    
    
    //menu, screens etc init
    bBlackin = false;
    bBlackout = false;
    sprBlack = [CSprite createSpriteWithWidth:480.f height:320.f];
    [sprBlack setTransparency:0.0f];
    [sprBlack setPosition:GLKVector2Make(0, 0)];
    
    bShowStripes = false;
    sprStripes = [CSprite createSpriteWithWidth:480.f height:320.f];
    [sprStripes setPosition:GLKVector2Make(0, 0)];
    [sprStripes setTexture:"Images/black_stripes.png"];
    
    bScreenOn = false;
    CSprite* sprTemp = [CSprite createSpriteWithWidth:480.f height:320.f];
    sprScreens.push_back(sprTemp);
    
    bShowText = false;
    sprText = [CSprite createSpriteWithWidth:480.f height:50.f];
    [sprText setPosition:GLKVector2Make(20.f, 270.f)];

    CSprite* icon_air = [CSprite createSpriteWithWidth:20.f height:20.f];
    [icon_air setPosition:GLKVector2Make(0, 0)];
    [icon_air setTexture:"Images/icon_air.png"];
    CSprite* icon_fire = [CSprite createSpriteWithWidth:20.f height:20.f];
    [icon_fire setPosition:GLKVector2Make(0, 0)];
    [icon_fire setTexture:"Images/icon_fire.png"];
    CSprite* icon_stone = [CSprite createSpriteWithWidth:20.f height:20.f];
    [icon_stone setPosition:GLKVector2Make(0, 0)];
    [icon_stone setTexture:"Images/icon_stone.png"];
    CSprite* icon_ice = [CSprite createSpriteWithWidth:20.f height:20.f];
    [icon_ice setPosition:GLKVector2Make(0, 0)];
    [icon_ice setTexture:"Images/icon_ice.png"];
    CSprite* icon_arcane = [CSprite createSpriteWithWidth:20.f height:20.f];
    [icon_arcane setPosition:GLKVector2Make(0, 0)];
    [icon_arcane setTexture:"Images/icon_arcane.png"];
    
    spellIcons.push_back(icon_air);
    spellIcons.push_back(icon_fire);
    spellIcons.push_back(icon_stone);
    spellIcons.push_back(icon_ice);
    spellIcons.push_back(icon_arcane);
    
    spellText = [CSprite createSpriteWithWidth:200 height:20];
    [spellText setPosition:GLKVector2Make(80, 3)];
    
    
    player_lifebar_underlay = [CSprite createSpriteWithWidth:101 height:320];
    [player_lifebar_underlay setPosition:GLKVector2Make(0,0)];
    [player_lifebar_underlay setTexture:"Images/spell_underlay.png"];
    player_lifebar = [CSprite createSpriteWithWidth:15 height:320];
    [player_lifebar setPosition:GLKVector2Make(3,0)];
    [player_lifebar setTexture:"Images/player_lb.png"];
    
    lifebar_time = -1;
    lifebar = [CSprite createSpriteWithWidth:162 height:17];
    [lifebar setPosition:GLKVector2Make(180,300)];
    [lifebar setTexture:"Images/lifebar.png"];
    lifebar_underlay = [CSprite createSpriteWithWidth:162 height:17];
    [lifebar_underlay setPosition:GLKVector2Make(180,300)];
    [lifebar_underlay setTexture:"Images/lifebar_underlay.png"];
    
    //level init
    NSString* str = [CUtil getAssetN:@"levels/lev1-1.lev"];
    [self loadLevel:str];

    
    [self performSelector:@selector(initButtons)];
    
    return self;
}
-(void)initButtons
{
    //buttons init
    bShowButtons = false;
    
    CSprite* firstbutton = [CSprite createSpriteWithWidth:60 height:60];
    [firstbutton addFrame:"Images/btn_air.png"];
    [firstbutton addFrame:"Images/btn_air_down.png"];
    [firstbutton setFrame:0];
    [firstbutton setPosition:GLKVector2Make(10, 0)];
    sprButtons.push_back(firstbutton);
    vButtons.push_back(GLKVector4Make(0, 0, 60, 60));
    
    firstbutton = [CSprite createSpriteWithWidth:60 height:60];
    [firstbutton addFrame:"Images/btn_fire.png"];
    [firstbutton addFrame:"Images/btn_fire_down.png"];
    [firstbutton setFrame:0];
    [firstbutton setPosition:GLKVector2Make(10, 65)];
    sprButtons.push_back(firstbutton);
    vButtons.push_back(GLKVector4Make(0, 65, 60, 125));
    
    firstbutton = [CSprite createSpriteWithWidth:60 height:60];
    [firstbutton addFrame:"Images/btn_stone.png"];
    [firstbutton addFrame:"Images/btn_stone_down.png"];
    [firstbutton setFrame:0];
    [firstbutton setPosition:GLKVector2Make(10, 130)];
    sprButtons.push_back(firstbutton);
    vButtons.push_back(GLKVector4Make(0, 130, 60, 190));
    
    firstbutton = [CSprite createSpriteWithWidth:60 height:60];
    [firstbutton addFrame:"Images/btn_ice.png"];
    [firstbutton addFrame:"Images/btn_ice_down.png"];
    [firstbutton setFrame:0];
    [firstbutton setPosition:GLKVector2Make(10, 195)];
    sprButtons.push_back(firstbutton);
    vButtons.push_back(GLKVector4Make(0, 195, 60, 255));
    
    firstbutton = [CSprite createSpriteWithWidth:60 height:60];
    [firstbutton addFrame:"Images/btn_arcane.png"];
    [firstbutton addFrame:"Images/btn_arcane_down.png"];
    [firstbutton setFrame:0];
    [firstbutton setPosition:GLKVector2Make(10, 260)];
    sprButtons.push_back(firstbutton);
    vButtons.push_back(GLKVector4Make(0, 260, 60, 320));
}



-(void)ClearLevel
{
    int i;
    
    for(i=0;i<objects.size();i++)
	{
        if(objects[i]->physx_body != NULL)
            world->DestroyBody(objects[i]->physx_body);
        
        objects.erase(objects.begin()+i);
        if(i <= playerIndex)
        {
            playerIndex--;
            player = objects[playerIndex];
        }
        i--;
	}
    
    for(i=0;i<projectiles.size();i++)
	{
        if(projectiles[i]->physx_body != NULL)
            world->DestroyBody(projectiles[i]->physx_body);
        
        projectiles.erase(projectiles.begin()+i);
        i--;
	}
    
    for(i=0;i<particles.size();i++)
    {
        particles.erase(particles.begin()+i);
        i--;
    }
}


// load level from .lev file
-(void)loadLevel:(NSString *)filepath
{
    //cleanup old objects
    [self ClearLevel];
    
    sLevelName = [[NSString alloc] initWithString:filepath];
    
    //init new level
    char* file = GetFile((char*)[filepath cStringUsingEncoding:NSUTF8StringEncoding]);
    
    char* desc = GetBlock("[CONFIG]",file);
    
    char scriptname[64];
    memset(scriptname,0,64);
    GetParam("script", desc, scriptname);
    
    int i = -1;
    GetParam("spellsallow", desc, &i);
    if(i == -1) buttonsAllowed = 5;
    else buttonsAllowed = i;
    
    if(!GetParam("cameraMax", desc, &cameraMax))
        cameraMax = 99999.f;
    
    //init objects
    
    vector<BLOCK>* blocks = GetBlocks(file);
    for(int i=1;i<blocks->size();i++)
    {
        //init object
        CObject* newobj = new CObject;
        newobj->Init(blocks->at(i).string);
        
        objects.push_back(newobj);
        if(EQ(objects[i-1]->getName(),"player"))
        {
            playerIndex = i-1;
            player = objects[playerIndex];
        }
        
        [self AddPhysxObject:newobj];
        
        newobj->AnimPlay("Walk");        
    }
    blocks->clear();
    free(blocks);
    
    
    //init script
    char* scriptfile = GetFile((char*)[[CUtil getAssetC:scriptname] cStringUsingEncoding:NSUTF8StringEncoding]);
    scriptMan.LoadScripts(scriptfile);
    free(scriptfile);
    
    free(desc);
    free(file);
}


//------------------------------------------------
// Desc: adds object right after the player object
//
//
-(CObject*)AddObject:(char *)desc toX:(int)ix Y:(int)iy
{
    //init object
    CObject* newobj = new CObject;
    newobj->Init(desc);
    newobj->x = ix;
    newobj->y = iy;
    newobj->zindex = 100;
    
    [self AddPhysxObject:newobj];
    
    newobj->AnimPlay("Walk");
    
    
    //add new object right after player - new object will always be in main layer
    for(int i=0;i<objects.size();i++)
    {
        if(EQ(objects[i]->getName(),"player"))
        {
            objects.insert(objects.begin()+(i+1), newobj);
            return newobj;
        }
    }
    
    NSLog(@"Error! Object hasn't been loaded.");
    return NULL;
}

-(CObject*)AddObjectFromCollection:(char*)name toX:(int)ix toY:(int)iy
{
    char* file = GetFile((char*)[[CUtil getAssetN:@"system/chars.cfg"] cStringUsingEncoding:NSUTF8StringEncoding]);
    char str[64];
    sprintf(str,"[%s]",name);
    char* desc = GetBlock(str,file);
    
    CObject* res = [self AddObject:desc toX:ix Y:iy];
    
    free(desc);
    free(file);
    return res;
}

-(CObject*)AddObjectFromSpells:(char*)name toX:(int)ix toY:(int)iy
{
    char* file = GetFile((char*)[[CUtil getAssetN:@"system/spells.cfg"] cStringUsingEncoding:NSUTF8StringEncoding]);
    char str[64];
    sprintf(str,"[%s]",name);
    char* desc = GetBlock(str,file);
    
    CObject* res = [self AddObject:desc toX:ix Y:iy];
    
    free(desc);
    free(file);
    return res;
}

-(void)RemoveObject:(CObject *)obj
{
    obj->toDelete = true;
}


//----------------------------------------------
// P H Y S X

-(void)AddPhysxObject:(CObject *)obj
{
    if(obj->getType() == PRO || obj->getType() == ITM || obj->getType() == CHR || obj->getType() == PHY || obj->getType() == TRG)
    {
    
        b2BodyDef bodyDef;
        bodyDef.angle = obj->rotation;
        bodyDef.position.Set((obj->x + obj->boxWidth*0.5f)/PTM_RATIO, (obj->y + obj->boxHeight*0.5f)/PTM_RATIO);
        b2Body* body = world->CreateBody(&bodyDef);
        

        //box
        b2PolygonShape box;
        box.SetAsBox(obj->boxWidth*0.5f/PTM_RATIO, obj->boxHeight*0.5f/PTM_RATIO);
        
        //dynamic addition
        if(obj->getType() == CHR)
        {
            // for characters - create weird shape
            //  __
            // |  |
            //  \/
            //
            
            float bw = obj->boxWidth*0.5f/PTM_RATIO;
            float bh = obj->boxHeight*0.5f/PTM_RATIO;
            b2PolygonShape customShape;
            b2Vec2 vMass[5] = {
                b2Vec2(-bw/2, bh), b2Vec2(-bw/2,-bh/2),
                b2Vec2(0,-bh),
                b2Vec2(bw/2,-bh/2), b2Vec2(bw/2,bh)
            };
            customShape.Set(vMass, 5);
            
            b2FixtureDef fixDef;
            
            fixDef.shape = &customShape;
            fixDef.density = 1.f;//1.f*PTM_RATIO;
            fixDef.friction = 0.9f;
            fixDef.userData = obj;
            
            body->CreateFixture(&fixDef);
            body->SetType(b2_dynamicBody);
            
            body->SetFixedRotation(true);
        }
        else if(obj->getType() == ITM)
        {
            b2FixtureDef fixDef;
            
            fixDef.shape = &box;
            fixDef.density = 1.f;//1.f*PTM_RATIO;
            fixDef.friction = 0.9f;
            fixDef.userData = obj;

            body->CreateFixture(&fixDef);
            body->SetType(b2_dynamicBody);
                    
        }
        else if(obj->getType() == PRO)
        {
            [self UpdateBody:body FromProjectile:(CProjectile*)obj];
        }
        else if(obj->getType() == TRG)
        {
            b2FixtureDef fixDef;
            
            fixDef.shape = &box;
            fixDef.isSensor = true;
            fixDef.userData = obj;
            
            body->CreateFixture(&fixDef);
            body->SetType(b2_staticBody);
        }
        else
        {
            b2FixtureDef fixDef;
            fixDef.shape = &box;
            fixDef.userData = obj;
            
            body->CreateFixture(&fixDef);
        }
        
        //add objects
        //physx_bodies.push_back(body);
        obj->physx_body = body;
    }
}


-(void)DeletePhysxObject:(CObject *)obj
{
    if(obj->physx_body != NULL)
    {
        world->DestroyBody(obj->physx_body);
        obj->physx_body = NULL;
    }
}

-(void)UpdateBody:(b2Body*)body FromProjectile:(CProjectile*)proj
{
    b2PolygonShape box;
    box.SetAsBox((proj->box.ux-proj->box.lx)*0.5f/PTM_RATIO, (proj->box.uy-proj->box.ly)*0.5f/PTM_RATIO);
    b2CircleShape circle;
    circle.m_radius = (proj->box.ux-proj->box.lx)*0.5f/PTM_RATIO;
    
    b2FixtureDef fixDef;
    
    //create physx obj based on spell
    switch (proj->getType()) {
            
        case PROJ_FIREBALL:
            
            fixDef.shape = &circle;
            fixDef.density = 1.f;//1.f*PTM_RATIO;
            fixDef.friction = 0.5f;
            fixDef.userData = proj;
            fixDef.restitution = 1.f;
            
            body->CreateFixture(&fixDef);
            body->SetType(b2_dynamicBody);
            body->SetGravityScale(0.3);
            
            break;
            
            
        case PROJ_STONEFIST:
            
            fixDef.shape = &circle;
            fixDef.density = 100.f;//1.f*PTM_RATIO;
            fixDef.friction = 0.5f;
            fixDef.userData = proj;
            fixDef.restitution = 0.1f;
            
            body->CreateFixture(&fixDef);
            body->SetType(b2_dynamicBody);
            body->SetGravityScale(0.8);
            
            break;
            
        case PROJ_BURST:
            
            fixDef.shape = &circle;
            fixDef.density = 1.f;
            fixDef.friction = 0;
            fixDef.userData = proj;
            fixDef.isSensor = true;
            
            body->CreateFixture(&fixDef);
            body->SetType(b2_staticBody);
            
            break;
            
        case PROJ_ICESHIELD:
            
            fixDef.shape = &circle;
            fixDef.density = 1.f;
            fixDef.friction = 0;
            fixDef.userData = proj;
            fixDef.isSensor = true;
            
            body->CreateFixture(&fixDef);
            body->SetType(b2_staticBody);
            
            break;
            
        case PROJ_FIRESHIELD:
            
            fixDef.shape = &circle;
            fixDef.density = 1.f;
            fixDef.friction = 0;
            fixDef.userData = proj;
            fixDef.isSensor = true;
            
            body->CreateFixture(&fixDef);
            body->SetType(b2_staticBody);
            
            break;
         
        case PROJ_STONEWALL:
            
            fixDef.shape = &box;
            fixDef.density = 100.f;
            fixDef.friction = 0;
            fixDef.restitution = 0.f;
            fixDef.userData = proj;
            
            body->CreateFixture(&fixDef);
            body->SetType(b2_staticBody);
            body->SetFixedRotation(true);
            
            break;
            
        case PROJ_KICK:
            
            fixDef.shape = &box;
            fixDef.density = 1.f;
            fixDef.friction = 0;
            fixDef.userData = proj;
            fixDef.isSensor = true;
            
            body->CreateFixture(&fixDef);
            body->SetType(b2_staticBody);
            
            break;
            
        default:
            break;
    }
    
    
    
}


//----------------------------------------------
//----------------------------------------------





//----------------------------------------------
// W O R K

-(NSString*)getrootpath
{
    NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docDir = [arrayPaths objectAtIndex:0];    
    return docDir;
}

-(CObject*)getObjectByName:(char *)name
{
    int i;
    for(i=0;i<objects.size();i++)
    {
        if(EQ(objects[i]->getName(),name)) return objects[i];
    }
    return NULL;
}

-(void)AddCameraTween:(GLKVector2)speed dest:(GLKVector2)dest
{
    cam_speedX = speed.x;
	cam_speedY = speed.y;
	cam_destX = dest.x;
	cam_destY = dest.y;
    
	bCameraTweening = true;
	return;
}

-(void)AddMotionTween:(CObject *)obj speed:(GLKVector2)speed dest:(GLKVector2)dest time:(float)time
{
    CMotionTween tween = CMotionTween(obj,speed.x,speed.y,dest.x,dest.y,time);
	tweens.push_back(tween);
	return;
}

@end
