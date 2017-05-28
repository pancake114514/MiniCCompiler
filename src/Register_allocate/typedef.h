#ifndef TYPEDEF_H
#define TYPEDEF_H

#define iOP2	1
#define iOP1	2
#define iASS	3
#define iARRSET	4
#define iARRGET	5
#define iIF	6
#define iGOTO	7
#define iPARAM	8
#define iCALLVOID	9
#define iCALL 	10
#define iRETURN	11
#define iVAR	12
#define iGVAR   13
#define iNOOP	0

#include <string>
#include <vector>
#include <map>
#include "Eeyore.tab.hpp"
void yyerror(char *);
struct ins{
	int type;
	std::string arg1, arg2, arg3, arg4;
	std::string go_label; //要到达的 label
	ins() = default;
	
	ins(int _type, std::string _arg1 = "", std::string _arg2 = "", 
		std::string _arg3 = "", std::string _arg4 = ""): 
		type(_type), arg1(_arg1), arg2(_arg2), arg3(_arg3) ,arg4(_arg4){}
		
};

struct Function
{
	int arg_num;
	int stack_size;
	std::string f_name;
	Function(std::string _name, int _num);
};
Function* new_Function(std::string fun_name, int arg_num);
Function* get_Fun(std::string fun_name);

struct Variable
{
	bool isGlobal;
	bool isArray;//array变量不能修改。。。
	std::string v_name;//假如是全局变量，就给分配个新名字
	int spill_loc;//假如是局部变量，则有一个溢出到栈的对应位置
};
Variable* new_Var(std::string var_name, int isGlobal);
Variable* get_Var(std::string var_name);

#endif