#include<stdio.h>
#include<stdlib.h>
#include<stdbool.h>
#include<string.h> 
#pragma warning (disable : 4996)
//QUADRABLES
#define DECLARE_ "declare"
#define ASSIGN_ "assign"
#define ADD_ "add"
#define MINUS_ "minus"


typedef struct TypeAndValue {
	int Type;
	char*  Value;
} TypeAndValue;

typedef struct SymbolData
{
	int Type;						//type of the token
	bool Initialized;				//symbol Initilzed a or not 
	bool Used;						//used or not
	char * Value;					//representing the value of assigned token
	char * IdentifierName;			//The name of Varible
}SymbolData;
//-------------------------------------------------Linked List Node -------------------------------
typedef struct SymbolNode {
	struct SymbolData * DATA;
	int ID;							// representing the ID of the Symbol 
	struct SymbolNode *Next;
} SymbolNode;
//---------------------------------------- Needed Functions with the Linked List------------------
struct SymbolData* setSymbol(int type, int init, bool used, char * name);// Get a Symbol Entity
void pushSymbol(int ID, struct SymbolData * data);// to Insert a node in list

struct SymbolData* getSymbol(int rID);// Return a Symbol Entity given his ID in LIST
void setUsed(int rID);
void setInitilization(int rID);

SymbolNode * getID(char * Identifier);// given Variable NAME AND SCOPE return ID
bool CheckIdentifier(char * ID);	 //check wether identifier is defined before or not
int getSymbolType(char*rID);

void PrintSymbolTable(FILE*F);

//----------------------------------------------------------------------------------------------
void DestroyList();
//---------------------------------------QUADRABLES
typedef struct Reg
{
	char* reg;
	char* var;
	int used;
}Reg;
typedef struct QuadData
{
	int operation;		//representing the type of the token or Function
	char*Arg1;
	char*Arg2;
	char*Result;

}QuadData;
typedef struct QuadNode {
	struct QuadData * DATA;
	int ID;			//representing the ID of the Symbol 
	struct QuadNode *Next;
} QuadNode;
void InsertQuadruple(QuadData*rD, int ID);
void setQuad(int Op, char* Arg1, char* Arg2, char*Result, int rID);
void PrintQuadList(FILE * f);
QuadNode*getTOP();