Armies Engine
========

#### !!! for internal use only !!! ####

Armies Engine is a iOs 2d-engine, based on OpenGL. It includes some solutions for basic game building.

* CCamera.h/.mm - Special class for 3d camera
* CMotionTween.h/.mm - Special class for motion tweens, with timers and event handlers
* CSprite.h/.mm - class, responsible for storing vertex buffers and textures for specific object
* CObjects.h/.mm - class, responsible for in-game objects, which are characters, items, triggers, physics and projectiles.
* CProjectile.h/.mm - CObject extension for projectiles, such as bullets, fireballs etc.
* CScript.h/.cpp - library, responsible for SPELL script language integration

* CAABB.h/.m - deprecated
* CCollision.h/.cpp - deprecated