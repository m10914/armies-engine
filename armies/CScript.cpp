//
//  CScript.cpp
//  armies
//
//  Created by Дмитрий Заборовский on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "CScript.h"






//---------------------------------------------------
//
//  M  E  T  H  O  D  S
//
//---------------------------------------------------

void CScriptVar::Init(char* nameIn, char* typeIn, char* initVal)
{
    if(EQ(typeIn,"int"))
    {
        type = VAR_INT;
        strcpy(name,nameIn);
        iVal = intval(initVal);
    }
    else if(EQ(typeIn,"string"))
    {
        type = VAR_STRING;
        strcpy(name,nameIn);
        strcpy(sVal, initVal);
    }
    else if(EQ(typeIn,"float"))
    {
        type = VAR_FLOAT;
        strcpy(name,nameIn);
        iVal = floatval(initVal);
    }
    
}

void* CScriptVar::getVal()
{
    switch(type)
    {
        case VAR_STRING:
            return sVal;
        case VAR_INT:
            return &iVal;
        case VAR_FLOAT:
            return &fVal;
    }
}


//-----------------------------------------------------
// Name: LoadScripts
// Desc: input - a very big string with all scripts
//-----------------------------------------------------
int CScript::LoadScripts(char* str)
{
    int i;//,j;
    int mainIndex;
    
    //delete old ones
    scripts.clear();
    
    //a little part of initialization
    bElse = false;
    
    //load all other blocks
    vector<BLOCK>* blocks = GetBlocks(str);
    
    for(i=0;i<blocks->size();i++)
    {
        if(EQ((blocks->at(i)).name,"MAIN"))
            mainIndex = i;
        
        SCRIPT scr;
        strcpy(scr.code,(blocks->at(i)).string);
        strcpy(scr.name,(blocks->at(i)).name);
        
        scripts.push_back(scr);
    }
    
    //execute main
    Execute((blocks->at(mainIndex)).string);
    
	blocks->clear();
	free(blocks);
    
    return 0;
}

int CScript::Release()
{
	scripts.clear();
    vars.clear();
    events.clear();
    timers.clear();;
    comm_stack.clear();
    
	return 0;
}

int CScript::PutCommandToStack(char* in)
{
    if(in==NULL) return 1;
    
    COMMAND cmd;
    strcpy(cmd.code,in);
    
    comm_stack.push_back(cmd);
    return 0;
}

int CScript::GetCommandFromStack(char* out)
{
    if(comm_stack.empty()) return -1;
    
    COMMAND cmd;
    cmd = comm_stack[comm_stack.size()-1];
    comm_stack.pop_back();
    
    strcpy(out,cmd.code);
    
    return 0;
}


int CScript::GetVarIndexByName(char* str)
{
    int i;
    for(i=0;i<vars.size();i++)
    {
        if(EQ(vars[i].name,str)) return i;
    }
    
    return -1;
}

SCRIPT CScript::GetScriptByName(char* str)
{
    int i;
    for(i=0;i<scripts.size();i++)
    {
        if(EQ(scripts[i].name,str)) return scripts[i];
    }
    
    SCRIPT scr;
    strcpy(scr.name,"ERROR");
    return scr;
}


int CScript::Execute(char* str)
{
    int i;
    vector<char*>* commands = GetStrings(str);
    
    for(i=0; i < commands->size(); i++)
    {
#ifdef SHOW_DEBUG_INFO
        printf("Executing: %s\n", commands->at(i));
#endif
        ProcessCommand(commands->at(i));
    }
    
	//cleanup
	for(i=0;i<commands->size();i++) free(commands->at(i));
	commands->clear();
	free(commands);
    
    return 0;
}

int CScript::FrameMove(float msec)
{
    int i;
    
    //timers
    for(i=0; i < timers.size(); i++)
    {
        timers[i].msec -= msec;
        if(timers[i].msec <= 0)
        {
            SCRIPT timerscript = GetScriptByName(timers[i].code);
            
            if(EQ(timerscript.name,"ERROR"))
                printf("Error: script %s not found\n", timers[i].code);
            else
                Execute(timerscript.code);
            
            timers.erase( timers.begin() + i);
            i--;
        }
    }
    
    //vars
#ifdef SHOW_DEBUG_INFO
    for(i = 0; i < vars.size(); i++)
    {
        switch(vars[i].type)
        {
            case VAR_INT:
                printf("%s:int: %d \n",vars[i].name,vars[i].iVal);
                break;
            case VAR_FLOAT:
                printf("%s:float: %f\n",vars[i].name,vars[i].fVal);
                break;
            case VAR_STRING:
                printf("%s:string: %s\n",vars[i].name,vars[i].sVal);
                break;
        }
    }
#endif
    
    return 0;
}

bool CScript::IfExpressionTrue(float val1, char* op, float val2)
{
    if(EQ(op,"<"))
    {
        if(val1 < val2) return true;
        else return false;
    }
    else if(EQ(op,"<="))
    {
        if(val1 <= val2) return true;
        else return false;
    }
    else if(EQ(op,"=="))
    {
        if(val1 == val2) return true;
        else return false;
    }
    else if(EQ(op,">="))
    {
        if(val1 >= val2) return true;
        else return false;
    }
    else if(EQ(op,">"))
    {
        if(val1 > val2) return true;
        else return false;
    }
    else
    {
        printf("Error: undefined operatior in IF statement\n");
        return false;
    }
}

int CScript::ExecuteByName(char* str)
{
	SCRIPT curscript = GetScriptByName(str);
    if(EQ(curscript.name,"ERROR"))
    {
        printf("Error: script %s not found\n", str);
        return 1;
    }
    Execute(curscript.code);
    
	return 0;
}

//-----------------------------------------------------
// Name: ProcessCommand
// Desc: main function of all app
//-----------------------------------------------------
int CScript::ProcessCommand(char* str)
{
    int i;
    
	//printf("%s\n",str);
    char cDelimiter[128] = " ";
    vector<char*>* mas = explode(cDelimiter, str);
    
    // execute script name
    if(EQ(mas->at(0),"execute"))
    {
        SCRIPT curscript = GetScriptByName(mas->at(1));
        if(EQ(curscript.name,"ERROR"))
        {
            printf("Error: script %s not found\n", mas->at(1));
            return 1;
        }
        Execute(curscript.code);
    }
    
    //set var
    else if(EQ(mas->at(0),"set"))
    {
        int varInd = GetVarIndexByName(mas->at(1));
        char string[128];
        int iResVal;
        float fResVal;
        
        switch(vars[varInd].type)
        {
            case VAR_INT:
                
                memset(string,0,128);
                for(i=2;i<mas->size();i++)
                {
                    JOIN(string,mas->at(i));
                }
                iResVal = (int)Calc(string);
                vars[varInd].setVal(iResVal);
                
                break;
                
            case VAR_FLOAT:
                
                memset(string,0,128);
                for(i=2;i<mas->size();i++)
                {
                    JOIN(string,mas->at(i));
                }
                fResVal = Calc(string);
                vars[varInd].setVal(fResVal);
                
                break;
                
            case VAR_STRING:
                
                memset(string,0,128);
                for(i=2;i<mas->size();i++)
                {
                    JOIN_DEL(" ",string,mas->at(i));
                }
                vars[varInd].setVal(string);
                
                break;
        }
    }
    
    //declare var
    else if(EQ(mas->at(0),"var"))
    {
        CScriptVar newvar;
        char string[128];
        memset(string,0,128);
        for(i=3;i<mas->size();i++)
        {
            JOIN_DEL(" ",string,mas->at(i));
        }
        
        newvar.Init(mas->at(1), mas->at(2), string);
        
        vars.push_back(newvar);
    }
    
    //if else statement
    else if(EQ(mas->at(0), "if"))
    {
        int index = GetVarIndexByName(mas->at(1));
        if(index == -1) { printf("Error: variable %s undefined",mas->at(1)); return 1; }
        
        CScriptVar var = vars[index];
        
        //get float value of variable
        float var_val;
        if(var.type == VAR_INT)
        {
            int* iValue = (int*)var.getVal();
            var_val = (float)(*iValue);
        }
        else if(var.type == VAR_FLOAT)
        {
            float* fValue = (float*)var.getVal();
            var_val = *fValue;
        }
        else
        {
            printf("Error: wrong type of variable %s\n",mas->at(1));
            goto ProcessCommandEnd;
        }
        
        //calculate expression
        char expression[512];
        memset(expression,0,512);
        for(i=3;i<mas->size()-1;i++) JOIN(expression, mas->at(i));
        
        float expr_val;
        expr_val = Calc(expression);
        
        bool statement = IfExpressionTrue(var_val,mas->at(2),expr_val);
        
        if(statement == true)
        {
            SCRIPT curscript = GetScriptByName(mas->at(mas->size() - 1));
            if(EQ(curscript.name,"ERROR"))
            {
                printf("Error: script %s not found\n", mas->at(6));
                goto ProcessCommandEnd;
            }
            //printf("Executing: %s\n", curscript.code);
            Execute(curscript.code);
            
            bElse = false;
        }
        else
        {
            bElse = true;
        }
    }
    //play animation
    else if(EQ(mas->at(0),"else"))
    {
        if(bElse)
        {
            SCRIPT curscript = GetScriptByName(mas->at(1));
            if(EQ(curscript.name,"ERROR"))
            {
                printf("Error: script %s not found\n", mas->at(1));
                goto ProcessCommandEnd;
            }
            Execute(curscript.code);
        }
    }
    
    else if(EQ(mas->at(0),"goto"))
    {
        PutCommandToStack(str);
        
        //create appropriate timer
        if(mas->size() > 5)
		{
			int seconds = intval(mas->at(4));
            
			CTimer timer;
			strcpy(timer.code,mas->at(5));
			timer.msec = seconds*1000;
            
			timers.push_back(timer);
		}
    }
    
    else if(EQ(mas->at(0),"timer"))
    {
        int seconds = intval(mas->at(1));
        
        CTimer timer;
        strcpy(timer.code,mas->at(2));
        timer.msec = seconds*1000;
        
        timers.push_back(timer);
    }
    
    else if(EQ(mas->at(0),"//"))
    {
        //comment
        goto ProcessCommandEnd;
    }
    
    else
    {
#ifdef SHOW_DEBUG_INFO
        printf("External or unknown script command, pushing to stack: %s\n", str);
#endif
        
        PutCommandToStack(str);
        goto ProcessCommandEnd;
    }
    
    
ProcessCommandEnd:
	for(i=0;i < mas->size(); i++) free(mas->at(i));
	mas->clear();
	free(mas);
	return 0;
    
}

CScriptVar* CScript::GetVarByName(char* str)
{
    int index;
    
    index = GetVarIndexByName(str);
    if(index == -1) return NULL;
    
    return &(vars[GetVarIndexByName(str)]);
}

float CScript::GetNumericVarValueByName(char* str)
{
    int* iVal;
    float* fVal;
    
    CScriptVar var = vars[GetVarIndexByName(str)];
    void* res = var.getVal();
    

        if(var.type==VAR_INT)
        {
            iVal = (int*)(res);
            return (float)(*iVal);
        }
        else if(var.type == VAR_FLOAT)
        {
            fVal = (float*)(res);
            return *fVal;
        }
    
    return -1;
}


float CScript::Calc(char* expr)
{
    //printf("expr: %s\n", expr);
    static CExpression calcer;
    return calcer.Calc(expr, this);
}

int CScript::CatchEvent(char* str)
{
    return 0;
}


//-----------------------------------------------------------------------------------------------------
// CExpression methods
//
// this method is using following sequence:
// 1st function - breaks the expression into additions and subtrations
// 2st function - multiply/devide
// 3rd - powering
// 4th - unary - and +
// 5th - of something is in breckets, then call 1st function, else atom
//
// then we call main function once again




float CExpression::Calc(char* str, CScript* scrIn)
{
    scr = scrIn;
    
    //prog = (char*)malloc(512*sizeof(char));//(new char[512];
    //strcpy(expression,str);
    //printf(" - %s - ",str);
    prog = str;
    
    double answer;
    eval_exp(&answer);
    
    //printf(" - %s - ",str);
    return (float)answer;
}

//entry point
void CExpression::eval_exp(double *answer)
{
    get_token();
    if(!*token)
    {
        serror(2);
        return;
    }
    eval_exp2(answer);
    
    if(*token) serror(0); //last lexem - zero
}

//addition, subtraction
void CExpression::eval_exp2(double *answer)
{
    char op;
    double temp;
    
    eval_exp3(answer);
    while((op = *token) == '+' || op == '-')
    {
        get_token();
        eval_exp3(&temp);
        switch(op)
        {
                
            case '-':
                *answer = *answer - temp;
                break;
                
            case '+':
                *answer = *answer + temp;
                break;
        }
    }
}

//multiplying, division
void CExpression::eval_exp3(double *answer)
{
    char op;
    double temp;
    
    eval_exp4(answer);
    while((op = *token) == '*' || op == '/' || op == '%')
    {
        get_token();
        
        eval_exp4(&temp);
        
        switch(op)
        {
                
            case '*':
                *answer = *answer * temp;
                break;
                
            case '/':
                if(temp == 0.0)
                {
                    serror(3); //dividing zero
                    *answer = 0.0;
                }
                else *answer = *answer / temp;
                break;
                
            case '%':
                *answer = (int) *answer % (int) temp;
                break;
        }
    }
}

//powering
void CExpression::eval_exp4(double *answer)
{
    double temp, ex;
    int t;
    
    eval_exp5(answer);
    
    if(*token == '^')
    {
        get_token();
        eval_exp4(&temp);
        ex = *answer;
        
        if(temp==0.0)
        {
            *answer = 1.0;
            return;
        }
        
        for(t=temp-1; t>0; --t)
            *answer = (*answer) * (double)ex;
    }
}

//multiplying unary - and +
void CExpression::eval_exp5(double *answer)
{
    char op;
    op = 0;
    
    if((tok_type == DELIMITER) && (*token=='+' || *token == '-'))
    {
        op = *token;
        get_token();
    }
    
    eval_exp6(answer);
    
    if(op == '-') *answer = -(*answer);
}

//calculating expr in brackets
void CExpression::eval_exp6(double *answer)
{
    if(*token == '(')
    {
        get_token();
        eval_exp2(answer);
        
        if(*token != ')')
            serror(1);
        get_token();
    }
    else
        atom(answer);
}

//getting value in brackets
void CExpression::atom(double *answer)
{
    if(tok_type == NUMBER)
    {
        *answer = atof(token);
        get_token();
        return;
    }
    else if(tok_type == VARIABLE)
    {
        //here get var value
        *answer = scr->GetNumericVarValueByName(token);
        get_token();
        return;
    }
    
    serror(0);  //syntax error
}

//put lexem into output stream
void CExpression::putback(void)
{
    char *t;
    
    t = token;
    for(; *t; t++) prog--;
}

//error msg
void CExpression::serror(int error)
{
    /*static char *e[]= {
        "Syntax error",
        "Unbalanced brackets",
        "No expression",
        "Separation zero"
    };
    printf("%s\n", e[error]);
     */
    if(error == 0) printf("Syntax error");
    else if(error == 1) printf("Unbalanced brackets");
    else if(error == 2) printf("No expr");
    else if(error == 3) printf("Separation zero");
    else printf("Unknown error");
    
}

//return if lexem
void CExpression::get_token(void)
{
    register char *temp;
    
    tok_type = 0;
    temp = token;
    *temp = '\0';
    
    if(!*prog) return; //end of expression
    while(isspace(*prog)) ++prog; //skip spaces, tabs etc
    
    
    if(strchr("+-*/%^=()", *prog))
    {
        tok_type = DELIMITER;
        //jump to next symbol
        *temp++ = *prog++;
    }
    
    else if(isalpha(*prog))
    {
        while(!isdelim(*prog)) *temp++ = *prog++;
        tok_type = VARIABLE;
    }
    
    else if(isdigit(*prog))
    {
        while(!isdelim(*prog)) *temp++ = *prog++;
        tok_type = NUMBER;
    }
    
    *temp = '\0';
}

//is delimiter
int CExpression::isdelim(char c)
{
    if(strchr(" +-/*%^=()", c) || c==9 || c=='\r' || c==0)
        return 1;
    else
        return 0;
}



