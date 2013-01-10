
#pragma once

#import "CSprite.h"
#include "CCollision.h"
#include "CCamera.h"
#include "LH_strings.h"
#import "CUtil.h"
#import "Box2D/Box2D.h"


enum ObjType {
	DEC, //only decoration - no animation or physics
	PHY, //only physics - no sprites
	ACT, //only animation - no physics
	CHR, //character - animation & physics
	ITM, //item - moveable object
	TRG, //trigger
	PRO, //projectile - with collision & animation
	PAR, //particle - with no collision
};

enum TriggerState {
    FREE,
    ONENTER,
    INSIDE,
    ONLEAVE,
};

class CObject;



//special sorting function
bool CObjectSort (CObject* a,CObject* b);


//-------------------
// special class for actions

class aiAction {

public:
    char name[32];
    float fElapsedTime;
    GLKVector2 vDest;
    CObject* target;
    
    
    //default
    aiAction();
    
    //for simple
    aiAction(char* nname, float ffElapsedTime);
    
    //for coordinate-based
    aiAction(char* nname, float ffElapsedTime, GLKVector2 vvDest);

    //for object-based
    aiAction(char* nname, float ffElapsedTime, CObject* ttarget);

    void operator =(aiAction act);
};



//------------------------------------------------
// Name: CObject
// Desc: universal class for all in-game objects
//------------------------------------------------
class CObject
{
public:
		
	bool active;
	int health;
    int maxHealth;

	float x,y;
	float cameraQ;
    float zindex;
	float speedX, speedY;
	AABB box;
	int boxWidth, boxHeight;
    float rotation;

    b2Body* physx_body;
    
    CSprite* sprite;
    
	char parent[64];

	//--------------------
	// EVENTS

	char onenter[64];
	char onleave[64];
	char ondie[64];
	char onhit[64];
	char onuse[64];
	char onsight[64];

	bool bColliding;
	bool bEntered;
    bool bLeft;
	bool bTriggered;
	bool bTriggeronce;
    bool bInAir;
    bool bDead;
    bool bShowHealth;
    
    TriggerState triggerState;

	bool toDelete;
    bool toDeletePhysXObject;
    float secondsToDelete;
    
    float immobilizeTime;
    bool isImmobilized() {if(immobilizeTime > 0) return true; else return false;};
    void immobilizeFor(float time) { immobilizeTime = time; };
	//--------------------

    
    
	int Init(char* block);
	int FrameMove(float dt);
	int UpdateAABB();
	int Render(CCamera* cam);
	int AnimPlay(char* str, BOOL breakIfSame=false);
    int DeleteAfterDelay(float delay);
    
    
	//gets
	char* getName() { return name; }
	ObjType getType() { return type; }
	bool IsActive() { return active; }
    int getAIType() { return aitype; }
    int orientation() { if(sprite.bReflectX) return -1; else return 1; }
    
    
    //ai stuff
    float aiActionTime;
    aiAction aiCurrentAction;
    vector<aiAction> aiActions;
    void aiAddAction(aiAction action);
    void aiAddAction(char* name, float fElapsedTime);
    void aiAddAction(char* name, float fElapsedTime, GLKVector2 vTarget);
    void aiAddAction(char* name, float fElapsedTime, CObject* oTarget);
    void aiClearActions();
    void aiFrameMove(float dt);
    aiAction aiGetCurrentAction() { return aiCurrentAction; }
    
    
protected:

	// VARS
	
	char name[64];
	ObjType type;
	
	int aitype;

	// functions

	ObjType defineType(char* string);

};
