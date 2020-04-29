#include<stdio.h>
#include<stdlib.h>
#include<stdbool.h>
#include<string.h> 
#pragma warning (disable : 4996)
#define DECLARE_ 0
#define ASSIGN_ 1
#define ADD_ 2
#define MINUS_ 3
#define MULTIPLY_ 4
#define DIVIDE_ 5



typedef struct Complex {
	int Type;
	char*  Value;
} Complex;

typedef struct SymbolData
{
	int Type;						
	bool Initialized;				
	bool Used;					
	char * Value;				
	char * IdentifierName;		
}SymbolData;


typedef struct SymbolNode {
	struct SymbolData * DATA;
	int ID;					
	struct SymbolNode *Next;
} SymbolNode;


struct SymbolData* SetSymbol(int type, int init, bool used, char * name);
void PushSymbol(int ID, struct SymbolData * data);

struct SymbolData* GetSymbol(int ID);
void SetUsed(int ID);
void SetInitialized(int ID);

SymbolNode * GetID(char * Identifier);
bool CheckIdentifier(char * ID);
int GetSymbolType(char*ID);

void PrintSymbolTable(FILE*F);

void DestroyList();

typedef struct Reg
{
	char* reg;
	char* var;
	int used;
}Reg;
typedef struct QuadData
{
	int operation;	
	char*Arg1;
	char*Arg2;
	char*Result;

}QuadData;
typedef struct QuadNode {
	struct QuadData * DATA;
	int ID;		
	struct QuadNode *Next;
} QuadNode;

void InsertQuadruple(QuadData*rD, int ID);
void SetQuadriple(int Op, char* Arg1, char* Arg2, char*Result, int ID);
void PrintQuadList(FILE * f);
QuadNode*GetTOP();