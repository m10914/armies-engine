//-------------------------------------------------------------
// script language SPELL v0.1
//
// Desc:
// get scripts from files like:
//
//[MAIN]
//var i int 0
//var str string test0 test1 test2
//execute INTRO_1
//#
//
//[INTRO_1]
//stopcontrol
//play player Walk
//timer 4 INTRO_2
//#
//
//...
//
// Supported Syntax:
//
// [*] - optional argument
// (*/*/*...) - or
// ----------------------------------------------------
// var var_name (int/float/string) init_value
// set var_name (expr)
// execute block_name
// timer seconds block_to_execute
// if var_name operator expr block_to_execute
// else block_to_execute
// ---------------------------------------------------
//
// Additional Commands:
//
// made to simplify scripting
// ---------------------------------------------------
// goto (obj_name/camera) coordx coordy time [block_to_execute]
// ---------------------------------------------------
//
// Suggested External Syntax:
// 
// (used in DragonSPELL Engine)
// ---------------------------------------------------
// play obj_name anim_name
// showbuttons
// hidebuttons
// showstripes
// hidestripes
// blackin
// blackout
// stopcontrol
// startcontrol
// stopcamerafollow
// startcamerafollow
// screenset path_to_img
// screenon
// screenoff
// loadlevel path_to_level
// ---------------------------------------------------


#pragma once

#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>

#include "LH_strings.h"


#define DELIMITER 1
#define VARIABLE  2
#define NUMBER    3

//#define SHOW_DEBUG_INFO

class CScript;
class CExpression;
class CScriptVar;
class CEvent;
class CTimer;


// this struct is used
// for store scripts
typedef struct{
    char code[512];
    char name[64];
} SCRIPT;

// this struct is used
// for external communications with
// scriptmanager
typedef struct{
    char code[128];
} COMMAND;


//types of variables
enum VARTYPE {
    VAR_STRING,
    VAR_INT,
    VAR_FLOAT
};

//--------------------------------------------
// Name: CScript
// Desc: this is base ScriptManager class,
//       the only one u need to use in our program
//--------------------------------------------
class CScript
{
protected:
    vector<SCRIPT> scripts;
    vector<CScriptVar> vars;
    vector<CEvent> events;
    vector<CTimer> timers;
    vector<COMMAND> comm_stack;

    bool bElse;
public:

    //basic
    int LoadScripts(char* str);
    int Execute(char* str);
	int ExecuteByName(char* str);
    int FrameMove(float msec);
	int Release();

    //for external using
    int CatchEvent(char* str);
    float GetNumericVarValueByName(char* str);
    CScriptVar* GetVarByName(char* str);

    int GetCommandFromStack(char* out);


protected:
    int PutCommandToStack(char* in);

    int ProcessCommand(char* str);

    SCRIPT GetScriptByName(char* str);
    int GetVarIndexByName(char* str);

    float Calc(char* expr);
    bool IfExpressionTrue(float val1, char* op, float val2);

};


//-------
// Events
class CEvent
{
public:

    char name[64];
    char scriptname[64];

};

class CTimer
{
public:
    float msec;
    char code[64];
};

class CExpression
{
protected:
    char* prog;
    char token[80];
    char tok_type;

    CScript* scr;

    void eval_exp(double *answer), eval_exp2(double *answer);
    void eval_exp3(double *answer), eval_exp4(double *answer);
    void eval_exp5(double *answer), eval_exp6(double *answer);
    void atom(double *answer);
    void get_token(void), putback(void);
    void serror(int error);
    int isdelim(char c);

public:
    float Calc(char* str, CScript* scrIn = NULL);
};

//---------------
// vars
class CScriptVar
{
public:
    VARTYPE type;
    char name[256];
    float fVal;
    int iVal;
    char sVal[256];

    void Init(char* nameIn, char* typeIn, char* initVal);
    void* getVal();
    void setVal(int val) { iVal = val; return; }
    void setVal(float val) { fVal = val; return; }
    void setVal(char* str) { strcpy(sVal,str); return; }
};





