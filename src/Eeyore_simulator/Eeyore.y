%{
#include <stdio.h>
#include "typedef.h"
#include <vector>
#include <string>
#include <map>
using namespace std;

int yylex(void);
extern int yylineno;
void yyerror(char*);

bool isGlobal = true;
extern vector<ins> com_ins;
extern map<string, unsigned> label_table;
extern vector<int> global_ins;
inline void checkGlobal(unsigned long i);
%}

%union {
    char *vstr;
    int vint;
}

%token END 0
%token EOL
%token VAR
%token IF
%token GOTO
%token PARAM
%token CALL
%token RETURN
%token ENDT
%token <vstr>NUM
%token <vstr>SYMBOL
%token <vstr>LABEL
%token <vstr>FUNCTION
%token <vstr>OP
%token <vstr>LOGIOP

%type <vstr>RightValue
%type <vstr>OP2

%%
Program
	:	/* Empty */
	|	Program Statement FunctionDecl 
	|	Program FunctionDecl 
	|	Program Statement END
;
FunctionDecl
	:	FunctionName Statement FunctionEnd
;

FunctionName
	:	FUNCTION ':' EOL	{
		isGlobal = false;
		com_ins[yylineno - 1] = ins(iNOOP);
		label_table[$1] = yylineno - 1;
	}
;
FunctionEnd
	:	ENDT FUNCTION EOL 	{
		isGlobal = true;
		com_ins[yylineno - 1] = ins(iNOOP);
	}
;
Statement
	:	Expression
	|	Statement Expression 
;

RightValue
	:	SYMBOL	{$$ = $1;}
	|	NUM	{$$ = $1;}
;

OP2
	:	OP	{$$ = $1;}
	|	LOGIOP	{$$ = $1;}
;

Expression
	:	SYMBOL '=' RightValue OP2 RightValue EOL  {
			checkGlobal(yylineno);
			com_ins[yylineno - 1] = ins(iOP2, $1, $3, $4, $5);
		}
	|	SYMBOL '=' OP RightValue EOL  {
			checkGlobal(yylineno);
			com_ins[yylineno - 1] = ins(iOP1, $1, $3, $4);
		}
	|	SYMBOL '=' RightValue EOL  {
			checkGlobal(yylineno);
			com_ins[yylineno - 1] = ins(iASS, $1, $3);
		}
	|	SYMBOL '[' RightValue ']' '=' RightValue EOL  {
			checkGlobal(yylineno);
			com_ins[yylineno - 1] = ins(iARRSET, $1, $3, $6);
		}
	|	SYMBOL '=' SYMBOL '[' RightValue ']' EOL  {
			checkGlobal(yylineno);
			com_ins[yylineno - 1] = ins(iARRGET, $1, $3, $5);
		}
	|	IF RightValue LOGIOP RightValue GOTO LABEL EOL {
			com_ins[yylineno - 1] = ins(iIF, $2, $3, $4, $6);
		}  
	|	GOTO LABEL EOL  {
			com_ins[yylineno - 1] = ins(iGOTO, $2);
		}
	|	LABEL ':' EOL  {
			com_ins[yylineno - 1] = ins(iNOOP);
			label_table[$1] = yylineno - 1;
		}
	|	PARAM SYMBOL EOL {
			com_ins[yylineno - 1] = ins(iPARAM, $2);
		}  
	|	CALL FUNCTION NUM EOL {
			checkGlobal(yylineno);
			com_ins[yylineno - 1] = ins(iCALLVOID, $2, $3);
		} 
	|	SYMBOL '=' CALL FUNCTION NUM EOL {
			com_ins[yylineno - 1] = ins(iCALL, $1, $4, $5);
		}
	|	RETURN RightValue EOL  {
			com_ins[yylineno - 1] = ins(iRETURN, $2);
		}
	|	RETURN EOL {
			com_ins[yylineno - 1] = ins(iRETURN);
		}
	|	VAR SYMBOL {
			checkGlobal(yylineno);
			com_ins[yylineno - 1] = ins(iVAR, $2);
		}
	|	VAR NUM SYMBOL {
			checkGlobal(yylineno);
			com_ins[yylineno - 1] = ins(iVAR, $3, $2);
		}
	|	EOL	{
			com_ins[yylineno - 1] = ins(iNOOP);
		}
;
%%
void yyerror(char *s) {
	printf("%s\n", s);
}
inline void checkGlobal(unsigned long i){
	if(isGlobal)
		global_ins.push_back(i);
}