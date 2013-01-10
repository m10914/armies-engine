//
//  CScene.h
//  armies
//
//  Created by Дмитрий Заборовский on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#pragma once

#import <vector>
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "CUtil.h"
#import "CSprite.h"
#import "CCamera.h"
#import "CScript.h"
#import "CObject.h"
#import "CProjectile.h"
#import "CCollision.h"
#import "LH_strings.h"
#import "CMotionTween.h"
#include "Box2D/Box2D.h"


#define PTM_RATIO 60.f

#define SCREEN_BOUND_X 2.f
#define SCREEN_BOUND_Y 2.7f

#define signof(a) a/fabs(a)

using namespace std;



//physx

class myContactListener : public b2ContactListener
{
public:
    void BeginContact(b2Contact* contact);
    void EndContact(b2Contact* contact);
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
};

class myRayCastCallback: public b2RayCastCallback
{
public:
    b2Fixture* m_fixture;
    b2Vec2 m_point;
    b2Vec2 m_normal;
    float32 m_fraction;
    
    ObjType ignoreList[15];
    int ignoreListSize;
    
    myRayCastCallback()
    {
        m_fixture = NULL;
    }
    
    
    void addIgnore(int iignoreListSize, ObjType* iignoreList)
    {
        ignoreListSize = iignoreListSize;
                
        for(int i=0;i<ignoreListSize;i++)
        {
            ignoreList[i] = iignoreList[i];
        }
    }
    
    
    float32 ReportFixture(b2Fixture* fixture, const b2Vec2& point, const b2Vec2& normal, float32 fraction)
    {
        CObject* targ = (CObject*)fixture->GetUserData();
        for(int i=0;i<ignoreListSize;i++)
        {
            if(targ->getType() == ignoreList[i]) return -1;
            else if(targ->bDead) return -1;
        }
            
        m_fixture = fixture;
        m_point = point;
        m_normal = normal;
        m_fraction = fraction;
        
        return fraction;
    }
    
};




enum SpellButton {
    SpellButtonAir = 0,
    SpellButtonFire = 1,
    SpellButtonIce = 2,
    SpellButtonEarth = 3,
    SpellButtonArcane = 4
};


enum AIType {
    AITypeTestEnemy = 0,
};



@interface CScene : NSObject
{    
    float tilt;
    
    CScript scriptMan;
    
    //physx
    b2World* world;
    vector<b2Body*> physx_bodies;
    myContactListener* contListener;
    
    
    //obj
    vector<CObject*> objects;
    vector<CMotionTween> tweens;
    vector<CProjectile*> projectiles;
    vector<CObject*> particles;
    
    //player
    int playerIndex;
    CObject* player;
    BOOL bControl;
    
    
    //camera stuff
    CCamera* camera;
    BOOL bCameraFollow;
    //------------
	// for camera tweening
	bool bCameraTweening;
	float cam_speedX, cam_speedY;
	float cam_destX, cam_destY;
	//------------
    
    
    //menu, screens, etc
    NSString* sLevelName;
    int buttonsAllowed;
    float cameraMax;
    
    CSprite* sprBlack;
    BOOL bBlackout, bBlackin;
    float fBlackAlpha;
    
    CSprite* sprStripes;
    BOOL bShowStripes;
    
    BOOL bScreenOn;
    vector<CSprite*> sprScreens;
    
    //lifebars
    float lifebar_time;
    CSprite* lifebar;
    CSprite* lifebar_underlay;
    
    CSprite* player_lifebar;
    CSprite* player_lifebar_underlay;
    
    
    //text
    BOOL bShowText;
    CSprite* sprText;
    
    //spell buttons
    BOOL bShowButtons;
    vector<GLKVector4> vButtons;
    vector<CSprite*> sprButtons;
    
    //icons
    vector<CSprite*> spellIcons;
    CSprite* spellText;
    vector<int> castedCombo;
    
    //spell system
    SpellButton combo[15];
    int comboCurLength;
    char comboSpell[64];
    bool bComboReady;
    
    
    //menu
    BOOL bMenu;
}


@property (nonatomic,retain) CCamera* camera;




-(id)init;
-(void)loadLevel:(NSString*)filepath;


-(void)update:(NSTimeInterval)dt;
-(void)update_camera_follow:(NSTimeInterval)dt;
-(void)update_player_control:(NSTimeInterval)dt;
-(void)AIControl:(CObject*)obj;

-(void)ClearLevel;

-(void)render;




//interactive func
-(void)fingerDown:(GLKVector2)location;
-(void)fingerUp:(GLKVector2)location;
-(void)fingerMove:(GLKVector2)prevLocation to:(GLKVector2)location;
-(void)tilt:(float)angle;
-(float)tilt;
-(void)onBtnPressed:(int)bid;
-(void)ProcessCommand:(char*)command;


//gameplay stuff
-(void)addToCombo:(int)buttonNum;
-(void)castCurrentSpell:(GLKVector2)pt;
-(void)castSpell:(char*)spellname By:(CObject*)chr to:(GLKVector2)pt;


//etc
-(BOOL)IsCollisionObject:(CObject*) obj;
-(void)Physics:(CObject*)a with:(CObject*)b;


//objects
-(CObject*)getObjectByName:(char*)name;
-(CObject*)AddObject:(char*)desc toX:(int)ix Y:(int)iy;
-(CObject*)AddObjectFromCollection:(char*)name toX:(int)ix toY:(int)iy;
-(CObject*)AddObjectFromSpells:(char*)name toX:(int)ix toY:(int)iy;
-(void)RemoveObject:(CObject*)obj;


//tweens
-(void)AddMotionTween:(CObject*)obj speed:(GLKVector2)speed dest:(GLKVector2)dest time:(float)time;
-(void)AddCameraTween:(GLKVector2)speed dest:(GLKVector2)dest;


//physx
-(void)AddPhysxObject:(CObject*)obj;
-(void)UpdateBody:(b2Body*)body FromProjectile:(CProjectile*)proj;
-(void)DeletePhysxObject:(CObject*)obj;


@end
