#include "quad.h"

using namespace std;

typedef struct Reg
{
	string reg;
	string var;
	int used;
}Reg;
typedef struct QuadData
{
	int OpCode;	//					representing the type of the token or Function
	char*Arg1;
	char*Arg2;
	char*Result;

}QuadData;
typedef struct QuadNode {
	struct QuadData * DATA;
	int ID;// representing the ID of the Symbol 
	struct QuadNode *Next;
} QuadNode;

Reg CheckReg();
void SetReg(Reg x);
void ResetReg();
vector<Reg> reg;
vector<string> output;
void ExctractQuad(QuadNode* head)
{
	QuadNode*ptr=head;
	Reg free;
	while(ptr != NULL)
	{
		switch (ptr->DATA->OpCode)
		{
		case DECLARE:
			 free = CheckReg();
			if(ptr->DATA->Arg1 == " " && ptr->DATA->Arg2 == " ")
			{
				output.push_back("MOV "+free.reg+","+"NULL");
				output.push_back("MOV "+(string)ptr->DATA->Result+","+free.var);
			} else if(ptr->DATA->Arg1 != " ") {
				output.push_back("MOV "+free.reg+","+(string)ptr->DATA->Arg1);
				output.push_back("MOV "+(string)ptr->DATA->Result+","+free.var);
			}else if(ptr->DATA->Arg2 != " ") {
				output.push_back("MOV "+free.reg+","+(string)ptr->DATA->Arg2);
				output.push_back("MOV "+(string)ptr->DATA->Result+","+free.var);	
			}
			free.used++;
			free.var=ptr->DATA->Result;
			SetReg(free);
			ptr = ptr->Next;
			break;
		case ASSIGN:
			break;
		default:
			break;
		}
	}
}
void ResetReg()
{
	for(int i=0;i<reg.size();i++)
	{
		Reg x;
		x.reg = "R"+i;
		x.var = "0";
		x.used = 0;
	}
}
void SetReg(Reg x)
{
	for(int i=0;i<reg.size();i++)
	{
		if(reg.at(i).reg == x.reg)
		{
			reg.at(i).used = x.used;
			reg.at(i).var = x.var;
		}
	}
}
Reg CheckReg()
{
	Reg min = reg.at(0);
	if(min.var == "0")
	{
		return min;
	}
	else
	{
		for(int i=0;i<reg.size();i++)
		{
			if(reg.at(i).var == "0")
			{
				return reg.at(i);
			}
			else if(reg.at(i).used <= min.used)
			{
				min=reg.at(i);
			}
		}
		return min;
	}
}
int main()
{
	QuadNode *p;
	QuadNode x;
	x.DATA->OpCode=0;
	x.DATA->Arg1=" ";
	x.DATA->Result="x";
	x.DATA->Arg2=" ";
	*p=x;
	ExctractQuad(p);
	for(int i=0;i<output.size();i++)
	{
		cout<<output.at(i)<<endl;;
	}
	system("PAUSE");
	return 0;
}