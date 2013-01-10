//
//  CUtil.m
//  armies
//
//  Created by Дмитрий Заборовский on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CUtil.h"

@implementation CUtil


//-------------
// little helpers

+(NSString*)getAssetN:(NSString*)path
{
    int i;
    vector<char*>* str = explode("/", (char*)[path cStringUsingEncoding:NSUTF8StringEncoding]);
    
    NSString* dir = [[NSString alloc] initWithFormat:@"assets/"];
    for(i=0;i<str->size()-2;i++)
    {
        dir = [dir stringByAppendingFormat:@"%@/",[[NSString alloc] initWithCString:str->at(i) encoding:NSUTF8StringEncoding]];
    }
    dir = [dir stringByAppendingFormat:@"%@",[[NSString alloc] initWithCString:str->at(i) encoding:NSUTF8StringEncoding]];
    NSString* filename = [[NSString alloc] initWithCString:str->at(str->size()-1) encoding:NSUTF8StringEncoding];
    
    for(int i=0;i<str->size();i++) free(str->at(i));
    str->clear();
    free(str);
    
    NSString* temp = [[NSBundle mainBundle] pathForResource:filename ofType:nil inDirectory:dir];
    return temp;
}

+(NSString*)getAssetC:(char*)path
{
    return [self getAssetN:[[NSString alloc] initWithCString:path encoding:NSUTF8StringEncoding]];
}


+(UIImage*)getTextTexture:(NSString*)text withFont:(NSString *)fontname withSize:(int)size withColor:(UIColor *)color ofSize:(CGSize)rect
{
    UIFont* font;
    CGContext*context;
    void* data;
        
    font = [UIFont fontWithName:fontname size:size];
    
    UIGraphicsBeginImageContext(CGSizeMake(rect.width, rect.height));
    context = UIGraphicsGetCurrentContext();
    
    CGContextSetGrayFillColor(context, 1.f, 1.f);
    CGContextTranslateCTM(context, 0.f, 1.f);
    //CGContextScaleCTM(context, 1.f, -1.f);
    
    float r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    CGContextSetRGBFillColor(context, r, g, b, a);
    
    UIGraphicsPushContext(context);
    [text drawInRect:CGRectMake(0, 0, rect.width, rect.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    UIGraphicsPopContext();
    
    UIImage* layerImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRelease(context);
    
    return layerImage;
}



@end
