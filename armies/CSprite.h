//
//  EEShape.h
//  bricks
//
//  Created by Дмитрий Заборовский on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#include "LH_strings.h"
#import "CUtil.h"

#define ANIM_CYCLE -1


typedef struct {
	char name[32];
	int start;
	int end;
	char action[128];
} AnimSet;

@interface CSprite : NSObject
{
    GLKVector2 vert[4];
    GLKVector2 texcoord[4];
    NSMutableArray* frames;
    GLKBaseEffect* effect;
    bool bTileX;
    bool bTileY;
    int width;
    int height;
    
    GLKVector2 pos;
    float rot;
    GLKVector2 rotPivot;
    
    vector<AnimSet> as;
	int numAnimSets;
	int curAS;
    float FPS;
    
    //animation stuff
    NSTimer* animTimer;
    int curframe;
    int startframe;
    int endframe;
    float delay;
    int attheend;
    
    //transparency
    float fAlpha;
    BOOL bForceAlpha;

}


@property (readonly) int numVertices;
@property (readonly) GLKVector2* vertices;
@property (readonly) GLKVector2* texcoord;
@property (nonatomic) GLKVector2 position;
@property (nonatomic) float rotation;
@property (nonatomic) bool bReflectX;
@property (nonatomic) bool bReflectY;

-(int)height;
-(int)width;

-(id)init;

-(void)renderBoxWithScale:(float)scale camX:(float)camX camY:(float)camY boxCenter:(GLKVector2)boxCenter boxSizes:(GLKVector2)boxSizes;
-(void)render:(float)scale camX:(float)camX camY:(float)camY cameraQ:(float)camQ;
-(void)renderAbsolute;
-(void)basicRendering;


-(void)setSizeX:(float)sizeX sizeY:(float)sizeY;
-(void)setTransparency:(float)transparency;
-(void)setRotationPivot:(GLKVector2)i_rotPivot;

//for dynamic
-(void)addFrame:(char *)imagePath;
-(void)addFrameWithImage:(UIImage*)image;
-(void)setFrame:(int)i;
-(void)removeFrame:(int)i;
-(void)removeAllFrames;

//for static
-(void)setTexture:(char*)texturePath;

-(void)playAnim:(char*)animname breakIfSame:(BOOL)break_if_same;
-(void)playAnimForce:(char*)animname;
-(void)setAnimationStart:(int)startFr end:(int)endFr withDelay:(float)del atEnd:(int)wtd;



+(CSprite*)createSprite:(NSString *)name;
+(CSprite*)createSpriteFromFile:(NSString*)filepath;
+(CSprite*)createSpriteWithWidth:(float)width height:(float)height;

@end
