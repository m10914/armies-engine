//
//  CObject.m
//  armies
//
//  Created by Дмитрий Заборовский on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "CObject.h"



//---------------------------------------------------------------------
// Name: class aiAction
// Desc:
//---------------------------------------------------------------------

aiAction::aiAction()
{
    sprintf(name,"none");
    fElapsedTime = 0;
    vDest = GLKVector2Make(0,0);
    target = NULL;
}


//for simple
aiAction::aiAction(char* nname, float ffElapsedTime)
{
    sprintf(name,"%s",nname);
    fElapsedTime = ffElapsedTime;
    vDest = GLKVector2Make(0,0);
    target = NULL;
}


//for coordinate-based
aiAction::aiAction(char* nname, float ffElapsedTime, GLKVector2 vvDest)
{
    sprintf(name,"%s",nname);
    fElapsedTime = ffElapsedTime;
    vDest = vvDest;
    target = NULL;
}

//for object-based
aiAction::aiAction(char* nname, float ffElapsedTime, CObject* ttarget)
{
    sprintf(name,"%s",nname);
    fElapsedTime = ffElapsedTime;
    target = ttarget;
    vDest = GLKVector2Make(0,0);
}

void aiAction::operator =(aiAction act)
{
    sprintf(name,"%s",act.name);
    vDest = act.vDest;
    fElapsedTime = act.fElapsedTime;
    target = act.target;
}











//------------------------------------------------------
// class: CObject
//

bool CObjectSort (CObject* a,CObject* b)
{
    return (a->zindex < b->zindex);
}


int CObject::Init(char* block)
{
	int i;
	float f;
	char str[512];
    char* actBlock;
    bool bFromLibrary = false;
    char* file, *desc;
    
    
	//basic params init
    //----------------
    aitype = -1;
    aiActionTime = 0;
    
    immobilizeTime = -1;
    
    rotation = 0;
    zindex = 0;
    
    physx_body = NULL;
    
    sprite = [[CSprite alloc] init];
    
	active = true;
    
	speedX = 0;
	speedY = 0;
    
	bEntered = false;
    bLeft = false;
	bTriggered = false;
	bTriggeronce = false;
    bInAir = false;
    
    bDead = false;
    
	toDelete = false;
    toDeletePhysXObject = false;
    
    secondsToDelete = -1;
    
    
    
	//pasing config
    
    if(!GetParam("x",block,&i)) return 1;
	x = i;
    
	if(!GetParam("y",block,&i)) return 1;
	y = i;
    
	if(!GetParam("z",block,&f)) return 1;
	cameraQ = f;
    
    if(!GetParam("zindex",block,&f)) zindex = 0;
	zindex = f;
    
    if(GetParam("rotation",block,&f))
        rotation = -f/180.f*3.14f;
    if(GetParam("Rotation",block,&f))
        rotation = -f/180.f*3.14f;
    
    if(GetParam("Active",block,str))
    {
        if(EQ(str,"true")) active = true;
        else active = false;
    }
    
    
    // from library or from this file
    if(GetParam("FromLibrary", block, str))
    {
        bFromLibrary = true;
        
        file = GetFile((char*)[[CUtil getAssetN:@"system/chars.cfg"] cStringUsingEncoding:NSUTF8StringEncoding]);
        char newname[64];
        sprintf(newname,"[%s]",str);
        desc = GetBlock(newname,file);
        actBlock = desc;
    }
    else
    {
        actBlock = block;
    }
    
    
    //--------------
    if(!GetParam("Health", actBlock, &health))
    {
        health = 100;
    }
    maxHealth = health;
    
	if(!GetParam("Name",actBlock,str)) return 1;
    strcpy(name,str);
    
    if(!GetParam("Type",actBlock,str)) return 1;
    type = defineType(str);
    
    if(!GetParam("Graphics",actBlock,str)) return 1;
    
    sprite = [CSprite createSprite:[[NSString alloc ] initWithCString:str encoding:NSUTF8StringEncoding]];
    
    [sprite setRotation:rotation];
    
    
	//different types init
	switch(type)
	{
            //decoration
		case DEC:
			break;
            
            //physics
		case PHY:
            
			//init collision model
			if(!GetParam("bb",actBlock,str)) return 1;
			sscanf(str,"%d %d", &boxWidth, &boxHeight);
			UpdateAABB();
            
			break;
            
            
            //trigger
		case TRG:
            
			//init collision model
			if(!GetParam("bb",actBlock,str)) return 1;
			sscanf(str,"%d %d", &boxWidth, &boxHeight);
			UpdateAABB();
            
			if(!GetParam("onenter",actBlock,str)) return 1;
			strcpy(onenter,str);
            
			if(!GetParam("onleave",actBlock,str)) return 1;
			strcpy(onleave, str);
            
			if(!GetParam("triggeronce",actBlock,str)) return 1;
			if(EQ(str,"true")) bTriggeronce = true;
            
			break;
            
            
            //actor (character with no physix)
		case ACT:
			break;
            
            //character
		case CHR:
			
			//init collision model
			if(!GetParam("bb",actBlock,str)) return 1;
			sscanf(str,"%d %d", &boxWidth, &boxHeight);
			UpdateAABB();
            
            
			//init AI - not nessesary
			GetParam("ai",actBlock,&aitype);
            
			break;
            
            //projectile - bullet with physx
		case PRO:
            
			//init collision model
			if(!GetParam("bb",actBlock,str)) return 1;
			sscanf(str,"%d %d", &boxWidth, &boxHeight);
			UpdateAABB();
            
			break;
	}
    
    
    //cleanup
    if(bFromLibrary == true)
    {
        free(file);
        free(desc);
    }
    
    
	return 0;
}

int CObject::Render(CCamera* cam)
{
    [sprite setPosition:GLKVector2Make(x, y)];
    [sprite render:cam.scale camX:cam.realX camY:cam.realY cameraQ:cameraQ];
	return 0;
}

int CObject::FrameMove(float dt)
{	
	bColliding = false;
    
    if(secondsToDelete != -1)
    {
        secondsToDelete -= dt;
        if(secondsToDelete < 0)
        {
            toDelete = true;
        }
    }
    
    if(aitype != -1)
        aiFrameMove(dt);
    
    if(immobilizeTime > 0)
    {
        immobilizeTime -= dt;
    }
    
	return 0;
}

int CObject::DeleteAfterDelay(float delay)
{
    secondsToDelete = delay;
    return 0;
}

int CObject::UpdateAABB()
{
	box.lx = x;
	box.ux = x+boxWidth;
	box.ly = y;
	box.uy = y+boxHeight;
    
	return 1;
}


int CObject::AnimPlay(char* str, BOOL breakIfSame)
{
    //for char
    if(EQ(str,"Die") || EQ(str,"Dead"))
    {
        bDead = true;
    }
    
	[sprite playAnim:str breakIfSame:breakIfSame];
    
    return 0;
}




//------------------------------------
//   A  I   block


void CObject::aiFrameMove(float dt)
{
    //decision to extract new action
    bool bGetAction = false;
    
    if(!EQ(aiCurrentAction.name,"none"))
    {
        aiActionTime += dt;
                
        if(aiCurrentAction.fElapsedTime > 0)
        {
            if(aiCurrentAction.fElapsedTime < aiActionTime)
                bGetAction = true;
        }
        else
        {
            bGetAction = true;
        }
    }
    else
    {
        bGetAction = true;
    }
    
    //NSLog(@"\n%1.4f: %1.4f\n%d\n%s %1.4f",dt,aiActionTime,(int)aiActions.size(),aiCurrentAction.name,aiCurrentAction.fElapsedTime);
    
    //get new action
    if(bGetAction)
    {
        if(aiActions.size() == 0)
        {
            aiClearActions();
            aiActionTime = 0;
        }
        else
        {
            aiCurrentAction = aiActions.at(0);
            aiActionTime = 0;
            aiActions.erase(aiActions.begin());
        }
    }
    
}

void CObject::aiAddAction(aiAction action)
{
    aiActions.push_back(action);
}
void CObject::aiAddAction(char* name, float fElapsedTime)
{
    aiAction newaction = aiAction(name,fElapsedTime);
    aiActions.push_back(newaction);
}
void CObject::aiAddAction(char* name, float fElapsedTime, GLKVector2 vTarget)
{
    aiAction newaction = aiAction(name,fElapsedTime,vTarget);
    aiActions.push_back(newaction);
}
void CObject::aiAddAction(char* name, float fElapsedTime, CObject* oTarget)
{
    aiAction newaction = aiAction(name,fElapsedTime,oTarget);
    aiActions.push_back(newaction);
}


void CObject::aiClearActions()
{
    aiActions.clear();
    sprintf(aiCurrentAction.name, "none");
}


//------------------------------------








//----------------------------------------------
// P R O T E C T E D   M E T H O D S
//----------------------------------------------
ObjType CObject::defineType(char* string)
{
	if(EQ(string,"DEC")) return DEC;
	else if(EQ(string,"PHY")) return PHY;
	else if(EQ(string,"ACT")) return ACT;
	else if(EQ(string,"ITM")) return ITM;
	else if(EQ(string,"TRG")) return TRG;
	else if(EQ(string,"PRO")) return PRO;
	else if(EQ(string,"PAR")) return PAR;
	else return CHR;
}