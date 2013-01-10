//
//  LH_strings.cpp
//  armies
//
//  Created by Дмитрий Заборовский on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "LH_strings.h"



//---------------------------
// file.cpp


char* GetFile(char* filepath)
{
    FILE* file = fopen(filepath,"r");
    if(file==NULL) return NULL;
    
    char* bigstring = new char[1024*5];
    memset(bigstring, 0, 1024*5);
    char* c,f;
    for(f=fgetc(file), c = bigstring; f != EOF; f = fgetc(file))
    {
        *c = f;
        c++;
    }
    
    fclose(file);
    return bigstring;
}


void dw_sleep(int msec)
{
    int i,j;
    
    i = (int)time(NULL);
    j = (int)time(NULL);
    for(;j<i+msec;)
    {
        j = (int)time(NULL);
    }
}

int intval(char* str)
{
	int a;
	sscanf(str,"%d",&a);
	return a;
}

float floatval(char* str)
{
    float f;
    sscanf(str,"%f",&f);
    return f;
}

char** explode(char* delimiter, char* source, int* num)
{
    char *c,*d;
    //int i,j;
    
    //char* str[100];
    char** dest = (char**)malloc(100*sizeof(char*));
    int numStr=0;
    
    
    dest[0] = new char[256];
    d = dest[0];
    
    bool tabsymbols = false;
    for(c=source; *c != '\0'; c++)
    {
        //printf("symbol: %c\n", *c);
        if(*c==' ' || *c=='\t')
        {
            tabsymbols = true;
        }
        else
        {
            if(tabsymbols)
            {
                //next block
                *d = '\0';
                numStr++;
                dest[numStr] = new char[256];
                d = dest[numStr];
                tabsymbols = false;
            }
            
            *d = *c;
            d++;
        }
    }
    *d = '\0';
    
    /*for(i=0; i<=numStr; i++)
     {
     printf("%s\n",dest[i]);
     }*/
    *num = numStr+1;
    
    return dest;
}

vector<char*>* explode(char* delimiter, char* string)
{
    vector<char*>* vec = new vector<char*>;
    char* c;
    char* g;
    char temp[256];
	memset(temp,0,256);
    //int i=0;
    
    g = temp;
    c = string;
    for(;*c != '\0'; c++)
    {
		if(*c == '\r' || *c == '\n') continue;
        if(*c == *delimiter)
        {
            *g = '\0';
            char* temp2 = new char[strlen(temp)+1];
            strcpy(temp2,temp);
            
            vec->push_back(temp2);
            
            g = temp;
			memset(temp,0,256);
        }
        else
        {
            *g = *c;
            g++;
        }
    }
    
    *g = '\0';
	char* temp3 = new char[strlen(temp)+1];
    strcpy(temp3,temp);
    vec->push_back(temp3);
    
    /*for(i=0;i<vec->size();i++)
     {
     printf("%s\n", vec->at(i));
     }*/
    
    return vec;
}

char* FindWord(char* handle, char* haystack)
{
	int i;//,j;
	char* c = haystack;
	char* t;
	char* memorize;
	char* result = new char[512];
    
	for(;*c != '\0'; c++)
	{
		if(*c == *handle)
		{
			memorize = c;
			t = handle;
			for(i=0; i< strlen(handle); i++)
			{
				if(*c != *t) break;
				c++;
				t++;
			}
            
			if(i==strlen(handle) && (*c == ' ' || *c == '\0' || *c == '\n'))
			{
				//found
				c = memorize;
				t = result;
				for(;*c != '\0' && *c != '\n' && *c != '\r'; c++, t++) *t = *c;
				*t = '\0';
				return result;
			}
			else
			{
				c = memorize;
				t = NULL;
			}
		}
        else while(*c != '\0' && *c != '\n' && *c != '\r') c++;
	}
    
	delete [] result;
	return NULL;
}

# // ÒËÌÚ‡ÍÒËÒ ·ÎÓÍ‡:
# // [block]
# // asd asd
# // asd asd
# // #


char* GetBlock(char* handle, char* haystack)
{
	int i;//,j;
	char* c = haystack;
	char* t;
	char* memorize;
	char* result = new char[512];
    
	for(;*c != '\0'; c++)
	{
		if(*c == *handle)
		{
			memorize = c;
			t = handle;
			for(i=0; i< strlen(handle); i++)
			{
				if(*c != *t) break;
				c++;
				t++;
			}
            
			if(i==strlen(handle))
			{
				//found
				c = memorize;
				t = result;
				for(;*c != '\0'&& *c != '#'; c++, t++) *t = *c;
				*t = '\0';
				return result;
			}
			else
			{
				c = memorize;
				t = NULL;
			}
		}
	}
    
	delete [] result;
	return NULL;
}



vector<BLOCK>* GetBlocks(char* haystack)
{
    
    char* c;
    char* g;
    char* d;
    //char* memorize;
    char str[512];
    char name[64];
    bool inblock = false;
    
    vector<BLOCK>* blocks = new vector<BLOCK>;
    //memset(str,0,512);
    //memset(name,0,512);
    
    for(c = haystack; *c != '\0'; c++)
    {
        if(!inblock)
        {
            if(*c == '/')
            {
                while(*c != '\n' && *c != '\0') c++;
                continue;
            }
            if(*c == '[')
            {
                inblock = true;
                memset(name,0,64);
                g = name;
                c++;
                
                while(*c != ']' && *c != '\0')
                {
                    *g++ = *c++;
                }
                
                c++; //skip \n
                *g = '\0';
                d = str;
            }
        }
        else //if(inblock)
        {
            if((*c == '\n' && *(c+1)=='#') || *c== '#')
            {
                *d = '\0';
                
                //enblock
                BLOCK blk;
                strcpy(blk.name,name);
                strcpy(blk.string,str);
                
                
                blocks->push_back(blk);
                
                inblock = false;
            }
            else
            {
                *d = *c;
                d++;
            }
        }
    }
    
    return blocks;
    
}

bool GetParam(char* name, char* haystack, int* out)
{
	char* str;
	char** mas;
	int i;
    char cDelimiter[5] = " ";
    
	if(!(str = FindWord(name, haystack))) return false;
	mas = explode(cDelimiter, str, &i);
	if(i < 2) { free(mas); free(str); return false; }
    
	sscanf(mas[1],"%d",out);
    
    free(mas);
    free(str);
	return true;
}

bool GetParam(char* name, char* haystack, float* out)
{
	char* str;
	char** mas;
	int i;
    char cDelimiter[5] = " ";
    
	if(!(str = FindWord(name, haystack))) return false;
	mas = explode(cDelimiter, str, &i);
	if(i < 2) { free(str); return false; }
    
	sscanf(mas[1],"%f",out);
    
    free(mas);
    free(str);
	return true;
}

bool GetParam(char* name, char* haystack, char* out)
{
	char* str;
    char* ptr;
	//int i;
	char* c;
    
	if(!(str = FindWord(name, haystack))) return false;
    
	for(c = str; *c != ' ' && *c != '\0'; c++) continue;
	c++;
    
	ptr = c;
	strcpy(out,ptr);
    
    free(str);
	return true;
}

char* GetString(char* haystack, int num)
{
	char *c, *g;
	char* str = new char[512];
	memset(str,0,512);
    
	int i=0;
	bool write = false;
    
	if(num==0) write=true;
	g = str;
    
	for(c=haystack;*c != '\0'; c++)
	{
		if(*c=='\n')
		{
			i++;
			if(i==num)
			{
				write = true;
				continue;
			}
			else if(i > num)
			{
				*g = '\0';
				break;
			}
		}
        
		if(write)
		{
			*g = *c;
			g++;
		}
	}
    
	if(!write || strlen(str) <= 2) return NULL;
	else return str;
}

vector<char*>* GetStrings(char* haystack)
{
    vector<char*>* strings = new vector<char*>;
    char* temp;
    char* c;
    char* d;
    char str[512];
    memset(str,0,512);
    
    d = str;
	c = haystack;
	while(*c == '\n') c++;
    for(; *c != '\0'; c++)
    {
        if(*c == '\n')
        {
            *d = '\0';
            temp = new char[strlen(str)+1];
            strcpy(temp,str);
            strings->push_back(temp);
            d = str;
        }
        else
        {
            *d = *c;
            d++;
        }
        
    }
    
    *d = '\0';
    temp = new char[strlen(str)+1];
    strcpy(temp,str);
    
    strings->push_back(temp);
    d = str;
    
    return strings;
}
