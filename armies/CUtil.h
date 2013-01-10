//
//  CUtil.h
//  armies
//
//  Created by Дмитрий Заборовский on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "LH_strings.h"


@interface CUtil : NSObject
{
    
}

//help funcs

+(NSString*)getAssetN:(NSString*)path;
+(NSString*)getAssetC:(char*)path;
+(UIImage*)getTextTexture:(NSString*)text withFont:(NSString *)fontname withSize:(int)size withColor:(UIColor *)color ofSize:(CGSize)rect;

@end
