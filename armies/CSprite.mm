//
//  EEShape.m
//  bricks
//
//  Created by Дмитрий Заборовский on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CSprite.h"

@implementation CSprite
{
}

static NSMutableDictionary* texturesCollection;

@synthesize bReflectX,bReflectY;


//-------------------------
// some opengl stuff - don't mess with it

-(id)init
{
    //init static variables
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        texturesCollection = [[NSMutableDictionary alloc] init];
        
    });
    
    [super init];
    
    frames = [[NSMutableArray alloc] init];
    
    vert[0] = GLKVector2Make(0, 0);
    vert[1] = GLKVector2Make(0, 1);
    vert[2] = GLKVector2Make(1, 0);
    vert[3] = GLKVector2Make(1, 1);
    rotPivot = GLKVector2Make(0.5, 0.5);
    
    width = 1;
    height = 1;
    
    texcoord[0] = GLKVector2Make(0, 1);
    texcoord[1] = GLKVector2Make(1, 1);
    texcoord[2] = GLKVector2Make(0, 0);
    texcoord[3] = GLKVector2Make(1, 0);
    
    effect = [[GLKBaseEffect alloc] init];
    
    bTileX = false;
    bTileY = false;
    
    rot = 0;
    pos = GLKVector2Make(0, 0);
    
    //set some vars
    bForceAlpha = false;
    bReflectX = false;
    bReflectY = false;
    
    curAS = -1;
    
    
    return self;
}

-(int)numVertices { return 4; }
-(GLKVector2 *) vertices {
    return vert;
}
-(GLKVector2*) texcoord {
    return texcoord;
}
-(int)height {
    return height;
}
-(int)width {
    return width;
}



//---------------------------
// morph methods

-(void)setPosition:(GLKVector2)position{
    pos = position;
}
-(void)setRotation:(float)rotation{
    rot = rotation;
}
-(GLKVector2) position {
    return pos;
}
-(float) rotation {
    return rot;
}

-(void)setRotationPivot:(GLKVector2)i_rotPivot
{
    rotPivot = i_rotPivot;
}

-(void)setTransparency:(float)transparency
{
    bForceAlpha = true;
    fAlpha = transparency;
}

-(void)setSizeX:(float)sizeX sizeY:(float)sizeY
{    
    vert[0] = GLKVector2Make(0, 0);
    vert[1] = GLKVector2Make(sizeX, 0);
    vert[2] = GLKVector2Make(0, sizeY);
    vert[3] = GLKVector2Make(sizeX, sizeY);
    
    rotPivot = GLKVector2Make(sizeX/2, sizeY/2);
    
    width = sizeX;
    height = sizeY;
    
    //check if texture is tiling then retile
    if([frames count] > 0)
    {
        GLKTextureInfo* firsttexture = [frames objectAtIndex:0];
        
        if(bTileX)
        {
            //set x to tiling
            float xtilevalue = vert[1].x / firsttexture.width;
            texcoord[1] = GLKVector2Make(xtilevalue, texcoord[1].y);
            texcoord[3] = GLKVector2Make(xtilevalue, texcoord[3].y);
        }
        if(bTileY)
        {
            //set x to tiling
            float ytilevalue = vert[1].y / firsttexture.height;
            texcoord[1] = GLKVector2Make(texcoord[1].x, ytilevalue);
            texcoord[0] = GLKVector2Make(texcoord[0].x, ytilevalue);
        }
    }
}





//-----------------------------
// Render section



//func for debug means
-(void)renderBoxWithScale:(float)scale camX:(float)camX camY:(float)camY boxCenter:(GLKVector2)boxCenter boxSizes:(GLKVector2)boxSizes
{
    effect.transform.projectionMatrix = GLKMatrix4MakeOrtho((camY)*scale, (320.f+camY)*scale, (-480.f-camX)*scale, (-camX)*scale, 200.0f, -200.0f);
    
    
    effect.transform.modelviewMatrix = GLKMatrix4Identity;
    
    //effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(boxSizes.x,boxSizes.y,0), effect.transform.modelviewMatrix);
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeRotation(rot,0,0,1), effect.transform.modelviewMatrix);
    //effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-boxSizes.x,-boxSizes.y,0), effect.transform.modelviewMatrix);
    
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(boxCenter.x + boxSizes.x/2, boxCenter.y+boxSizes.y/2,0), effect.transform.modelviewMatrix);
    
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeRotation(-3.1415/2.f, 0, 0, 1), effect.transform.modelviewMatrix);
    
    
    [effect prepareToDraw];
    
    GLKVector2 quadVert[5] = {
        GLKVector2Make(-boxSizes.x/2, -boxSizes.y/2),
        GLKVector2Make(-boxSizes.x/2, boxSizes.y/2),
        GLKVector2Make(boxSizes.x/2, boxSizes.y/2),
        GLKVector2Make(boxSizes.x/2, -boxSizes.y/2),
        GLKVector2Make(-boxSizes.x/2, -boxSizes.y/2),
    };
    
    //geometry rendering

    glEnable(GL_BLEND);
    glBlendFunc(GL_CONSTANT_COLOR, GL_CONSTANT_COLOR);
    effect.useConstantColor = YES;
    effect.constantColor = GLKVector4Make(1,1,1,1);
    
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, quadVert);

    glDrawArrays(GL_LINE_STRIP, 0, 5);
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);

    
    glDisable(GL_BLEND);
}


-(void)render:(float)scale camX:(float)camX camY:(float)camY cameraQ:(float)camQ
{
    
    // P R O J  matrix
    
    camX = (camX+240.f)*scale*camQ/scale - 240.f;
    camY = (camY+160.f)*scale*camQ/scale - 160.f;
    
    effect.transform.projectionMatrix = GLKMatrix4MakeOrtho((camY)*scale, (320.f+camY)*scale, (-480.f-camX)*scale, (-camX)*scale, 200.0f, -200.0f);
    
    
    // T R A N S F O R M  matrix
    
    effect.transform.modelviewMatrix = GLKMatrix4Identity;
    
    //reflection
    if(bReflectX)
    {
        effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeScale(-1, 1, 1), effect.transform.modelviewMatrix);
        effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(vert[1].x, 0,0), effect.transform.modelviewMatrix);
    }
    if(bReflectY)
    {
        effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeScale(-1, 1, 1), effect.transform.modelviewMatrix);
        effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, -vert[2].y, 0), effect.transform.modelviewMatrix);
    }
    
    //rotate around center
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-rotPivot.x,-rotPivot.y,0), effect.transform.modelviewMatrix);
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeRotation(rot,0,0,1), effect.transform.modelviewMatrix);
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(rotPivot.x,rotPivot.y,0), effect.transform.modelviewMatrix);
    
    //translate to coords
    // - camera affection
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(pos.x, pos.y, 0), effect.transform.modelviewMatrix);
    
    //rotate according to screen align
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeRotation(-3.1415/2.f, 0, 0, 1), effect.transform.modelviewMatrix);
    
    
    [effect prepareToDraw];
        
    //render
    [self basicRendering];

}
-(void)renderAbsolute
{
    //hereby calc ortho proj for absolute position of sprite
    effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(0, 320.f, -480.f, 0, 200.0f, -200.0f);
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeRotation(rot,0,0,1),GLKMatrix4MakeTranslation(pos.x, pos.y,0));
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeRotation(-3.1415/2.f, 0, 0, 1), effect.transform.modelviewMatrix);
    
    [effect prepareToDraw];
    
    //render
    [self basicRendering];
}


-(void)basicRendering
{
    //blending
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    
    if(!bTileX && !bTileY)
    {
        glTexParameteri(effect.texture2d0.target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        glTexParameteri(effect.texture2d0.target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    }
    else
    {
        glTexParameteri(effect.texture2d0.target, GL_TEXTURE_WRAP_S, GL_REPEAT );
        glTexParameteri(effect.texture2d0.target, GL_TEXTURE_WRAP_T, GL_REPEAT );
    }
    
    if(bForceAlpha)
    {
        effect.useConstantColor = YES;
        effect.constantColor = GLKVector4Make(0,0,0,fAlpha);
    }
    else
    {
        effect.useConstantColor = NO;
        effect.constantColor = GLKVector4Make(0,0,0,0);
    }
        
    //geometry rendering    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, self.vertices);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, self.texcoord);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, self.numVertices);
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    
    //blending off
    glDisable(GL_BLEND);
}





//----------------------
// Animation section
//
// here how it works:
// 1. add frames with addFrame
// 2. set current frame with setFrame
// 3. set animations with setAnimationStart
//
//


-(void)setTexture:(char *)texturePath
{
    [self removeAllFrames];
    
    //NSString* picname = [CUtil getAssetC:texturePath];
    //UIImage* img = [UIImage imageWithContentsOfFile:picname];
    [self addFrame:texturePath];
    [self setFrame:0];
}




//---------------------------------
// Name: addFrame
// Desc: these two methods are responsible for loading frames
//       difference between tow of this is that addFrameWithimage isn't
//       using dictionary
//
-(void)addFrameWithImage:(UIImage *)image
{
    NSError* error;
    GLKTextureInfo* texture = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:&error];
    if( texture == nil )
    {
        NSLog(@"%@", error);
    }
    else
    {
        effect.texture2d0.enabled = GL_TRUE;
        effect.texture2d0.envMode = GLKTextureEnvModeReplace;
        effect.texture2d0.target = GLKTextureTarget2D;
        effect.texture2d0.name = texture.name;
        
        [frames addObject:texture];
    }
    
    return;
}

-(void)addFrame:(char *)texturePath
{
    NSString* picname = [CUtil getAssetC:texturePath];
    
    if(picname == nil || [picname length] == 0)
    {
        NSLog(@"Error loading %s",texturePath);
        return;
    }

    GLKTextureInfo* texture = [texturesCollection objectForKey:picname];
    if( texture == nil )
    {
        NSError* error;
        UIImage* image = [UIImage imageWithContentsOfFile:picname];
        
        texture = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:&error];
        
        if( texture == nil )
        {
            NSLog(@"%@", error);
            return;
        }
        else
        {
            [texturesCollection setValue:texture forKey:picname];
        }
        
    }
    
    effect.texture2d0.enabled = GL_TRUE;
    effect.texture2d0.envMode = GLKTextureEnvModeReplace;
    effect.texture2d0.target = GLKTextureTarget2D;
    effect.texture2d0.name = texture.name;
    
    [frames addObject:texture];
    
    return;
}


-(void)setFrame:(int)i
{
    GLKTextureInfo* tex = [frames objectAtIndex:i];
    effect.texture2d0.name = tex.name;
}

-(void)removeFrame:(int)i
{
    [frames removeObjectAtIndex:i];
}

-(void)removeAllFrames
{
    [frames removeAllObjects];
}


-(void)playAnim:(char*)animname breakIfSame:(BOOL)break_if_same
{
    int i;
    
    char* cn = as[curAS].name;
    
    
    //for characters animation
    if( EQ(cn,"Die") || EQ(cn,"Dead") ) return;
    if( (EQ(cn,"JumpCast") || EQ(cn,"Cast1") || EQ(cn,"Cast2") || EQ(cn,"Cast3") || EQ(cn,"CastFail") || EQ(cn,"Hurt")) && !EQ(animname,"Die")) return;
    if( EQ(animname,"Stand") && EQ(cn, "ReadyStand")) return;
    
    //for projectiles
    if( EQ(cn,"Blow") ) return;
    
    
	for(i=0;i<numAnimSets;i++)
	{
		if(EQ(as[i].name,animname))
		{
			if(!break_if_same && curAS == i) return;
            
			curAS = i;
            float realfps = 1.f/FPS;
			[self setAnimationStart:as[i].start end:as[i].end withDelay:realfps atEnd:0];
            break;
		}
	}
}

-(void)playAnimForce:(char *)animname
{
    int i;
    
    for(i=0;i<numAnimSets;i++)
	{
		if(EQ(as[i].name,animname))
		{
			curAS = i;
            float realfps = 1.f/FPS;
			[self setAnimationStart:as[i].start end:as[i].end withDelay:realfps atEnd:0];
            break;
		}
	}
}

-(void)setAnimationStart:(int)startFr end:(int)endFr withDelay:(float)del atEnd:(int)wtd
{
    startframe = startFr;
    endframe = endFr;
    delay = del;
    attheend = wtd;
    
    curframe = startframe;
    [self setFrame:curframe];
    
    if(animTimer != nil)
    {
        [animTimer invalidate];
        animTimer = nil;
    }
    animTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(animUpdate) userInfo:nil repeats:YES];
}

-(void)animUpdate
{
    curframe++;
    
    if(curframe > endframe)
    {
        if(!EQ(as[curAS].action,"none"))
        {
           [self playAnimForce:as[curAS].action];
        }
        else
        {
            curframe = startframe;
            [self setFrame:startframe];
        }
        
        /*if(attheend != ANIM_CYCLE)
        {
            curframe = attheend;
            [self setFrame:curframe];
            [animTimer invalidate];
            animTimer = nil;
        }
        else
        {
            curframe = startframe;
            [self setFrame:startframe];
        }*/
    }
    else
    {
        [self setFrame:curframe];
    }
}
                 



//this method creates sprite with some parameters
+(CSprite*)createSpriteWithWidth:(float)width height:(float)height
{
    CSprite* newsprite;
    newsprite = [[CSprite alloc] init];
    
    [newsprite setSizeX:width sizeY:height];
    
    return newsprite;
}



// this methods loads sprites from files .cfg, which describing animations etc

+(CSprite*)createSprite:(NSString *)name
{
    //NSString* str = [[NSString alloc] initWithFormat:@"assets/%@",name];
    //return [self createSpriteFromFile:str];
    return [self createSpriteFromFile:name];
}


+(CSprite*)createSpriteFromFile:(NSString*)filepath
{
    int i;
    char cpy[256];
    char* str;
    
    //get file
    NSString* helpstr = [[NSString alloc] initWithFormat:@"assets/%@",filepath];
    
    NSString* filepath2 = [[NSString alloc] initWithFormat:@"%@",[[NSBundle mainBundle] pathForResource:@"main.cfg" ofType:@"" inDirectory:helpstr]];
    char* file = GetFile((char*)[filepath2 cStringUsingEncoding:NSUTF8StringEncoding]);
    
    
    int NumOfFrames;
    GetParam("NumFrames", file, &NumOfFrames);
    
    //init sprite itself
    CSprite* newsprite;
    newsprite = [[CSprite alloc] init];
    
    char temppath[256];
    for(i=0;i<NumOfFrames;i++)
    {
        sprintf(temppath,"%s/%d.png",[filepath cStringUsingEncoding:NSUTF8StringEncoding],i);
        [newsprite addFrame:temppath];
    }
    
    if(NumOfFrames > 0)
    {
        GLKTextureInfo* firsttexture = [newsprite->frames objectAtIndex:0];
        
        //set sizes of sprite
        int texSizeX, texSizeY;
        if(!GetParam("size-x", file, &texSizeX)) texSizeX = firsttexture.width;
        if(!GetParam("size-y", file, &texSizeY)) texSizeY = firsttexture.height;
        
        if(GetParam("texture-tile-x", file, &i)) newsprite->bTileX = true;
        if(GetParam("texture-tile-y", file, &i)) newsprite->bTileY = true;
        
        [newsprite setSizeX:texSizeX sizeY:texSizeY];
    }
    
    
    //animsets
	GetParam("NumAnimSets", file, &newsprite->numAnimSets);
	//newsprite->as = new AnimSet[newsprite->numAnimSets];
	for(i=0;i<newsprite->numAnimSets;i++)
	{
        AnimSet as;
        
		sprintf(cpy,"AS%d",i);
		str = FindWord(cpy,file);
		sscanf(str,"%s %s %d %d %s", as.name, as.name, &as.start, &as.end, as.action);
        free(str);
        
        newsprite->as.push_back(as);
	}
    
    //frameskip
    GetParam("FrameRate", file, &newsprite->FPS);
    
    free(file);
    return newsprite;
}



@end
