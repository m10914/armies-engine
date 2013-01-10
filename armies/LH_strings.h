//------------------------------
// LH_string
// build: 11-08-2011
// author: DW
// copyright LevelHard Studios 2011


#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include <time.h>

using namespace std;

#define EQ(a,b) !strcmp(a,b)
#define JOIN(a,b) sprintf(a,"%s%s",a,b)
#define JOIN_DEL(d,a,b) sprintf(a,"%s%s%s",a,d,b)

typedef struct{
    char name[64];
    char string[512];
} BLOCK;

char* GetFile(char* filepath);
char** explode(char* delimiter, char* source, int* num);
void dw_sleep(int msec);
int intval(char* str);
float floatval(char* str);
vector<char*>* explode(char* delimiter, char* string);
char* FindWord(char* handle, char* haystack);
char* GetBlock(char* handle, char* haystack);
vector<BLOCK>* GetBlocks(char* haystack);
bool GetParam(char* name, char* haystack, int* out);
bool GetParam(char* name, char* haystack, float* out);
bool GetParam(char* name, char* haystack, char* out);
char* GetString(char* haystack, int num);
vector<char*>* GetStrings(char* haystack);
