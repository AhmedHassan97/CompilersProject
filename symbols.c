#include"symbols.h"


char* idtype[5] = { "Integer", "Float", "Char", "String", "Bool"};
struct SymbolNode * ListHead = NULL;
struct SymbolData* SetSymbol(int Type, int Value, bool Used,char* Identifier)
{
	struct SymbolData *data = (struct SymbolData*) malloc(sizeof(struct SymbolData));
	data->Type = Type;
	data->Initialized = Value;
	data->Used = Used;
	data->IdentifierName = Identifier;
	
	return data;
}
void PushSymbol(int index, struct SymbolData * data) {
	//--Insert from Begining 
	struct SymbolNode *SymbolNode = (struct SymbolNode*) malloc(sizeof(struct SymbolNode));
	SymbolNode->ID = index;
	SymbolNode->DATA = data;
	SymbolNode->Next = ListHead;
	ListHead = SymbolNode;
}


int countNODE()
{
	int mCount = 0;
	SymbolNode * Traveler = ListHead;
	while (Traveler)
	{
		mCount++;
		Traveler = Traveler->Next;
	}
	return mCount;
}

bool isEmpty()
{
	return (ListHead == NULL) ? true : false;
}

SymbolData * GetSymbol(int ID)
{
	int mCount = 0;
	SymbolNode * Traveler = ListHead;
	while (Traveler)
	{
		if (Traveler->ID == ID)
		{
			return Traveler->DATA;
		}
	}
	return NULL;
}

void PrintList(SymbolNode*Head)
{

	if (Head == NULL)
		return;
	PrintList(Head->Next);
}

void SetTokenName(int ID, char * Value)
{
	SymbolData*Data = GetSymbol(ID);
	strcpy(Data->IdentifierName,Value);
}

void SetUsed(int ID)
{
	SymbolData *S = GetSymbol(ID);
	if (!S)
	S->Used = true;
}

void SetInitialized(int ID)
{
	SymbolData *S = GetSymbol(ID);
	if (!S)
	S->Initialized = true;
}
SymbolNode *  GetID(char * Identifier)
{
	SymbolNode * Traveler = ListHead;


	while (Traveler)
	{
		if ((strcmp(Identifier, Traveler->DATA->IdentifierName)==0 ))
		{
			return Traveler;
		}

		Traveler = Traveler->Next;
	}
	return NULL;
}
bool CheckIdentifier(char * ID)
{
	SymbolNode * Traveler = ListHead;

	//start from the beginning
	while (Traveler)
	{
		if (strcmp(ID, Traveler->DATA->IdentifierName) == 0)
		{
			return true;
		}
		Traveler = Traveler->Next;
	}

	return-false;

}
void PrintSymbolTable(FILE*F)
{
	SymbolNode * Traveler = ListHead;

	while (Traveler)
	{
		if (Traveler->DATA->Used)
		{
			fprintf(F, "%s of type %s is Used \n", Traveler->DATA->IdentifierName, idtype[Traveler->DATA->Type]);

		}
		if (!(Traveler->DATA->Used))
		{
			fprintf(F, "%s of type %s is Unused\n", Traveler->DATA->IdentifierName, idtype[Traveler->DATA->Type]);
		}
		Traveler = Traveler->Next;
	}

	Traveler = ListHead;

	while (Traveler)
	{
		if (Traveler->DATA->Initialized)
		{
			fprintf(F, "%s of type %s is initialized\n", Traveler->DATA->IdentifierName, idtype[Traveler->DATA->Type]);
		}
		if (!(Traveler->DATA->Initialized))
		{
			
			fprintf(F, "%s of type %s is not initialized\n", Traveler->DATA->IdentifierName, idtype[Traveler->DATA->Type]);
			
		}
		Traveler = Traveler->Next;
	}

	
	
}
int GetSymbolType(char * ID)
{
	SymbolNode * Traveler = ListHead;
	while (Traveler)
	{
		if (strcmp(ID, Traveler->DATA->IdentifierName) == 0)
		{
			return Traveler->DATA->Type;
		}

		Traveler = Traveler->Next;
	}
	return -1;

}
void DestroyList()
{
	SymbolNode * Traveler = ListHead;
	while (Traveler)
	{
		SymbolNode *D = Traveler;
		Traveler = Traveler->Next;
		free (D);
	}
}


//-----------------------------------------------------------------------------------------------------
QuadNode*TopPtr = NULL;
void SetQuadriple(int Op, char* Arg1, char* Arg2,char*Result,int ID)
{
	struct QuadData *data = (struct QuadData*) malloc(sizeof(struct QuadData));
	data->operation = Op;
	data->Arg1 = Arg1;
	data->Arg2 = Arg2;
	data->Result = Result;
	InsertQuadruple(data, ID); // insert in list 
	return ;
}
void InsertQuadruple(QuadData*D, int ID)
{
	if (!TopPtr)
	{
	struct QuadNode *mySymbolNode = (struct QuadNode*) malloc(sizeof(struct QuadNode));
	TopPtr = mySymbolNode;
	mySymbolNode->ID = ID;
	mySymbolNode->DATA = D;
	TopPtr->Next = NULL;
	return;
	}
	struct QuadNode *Traveler = TopPtr;
	while (Traveler->Next)
		Traveler = Traveler->Next;// get last Node
	struct QuadNode *mySymbolNode = (struct QuadNode*) malloc(sizeof(struct QuadNode));
	mySymbolNode->ID = ID;
	mySymbolNode->DATA = D;
	mySymbolNode->Next = NULL;
	Traveler->Next = mySymbolNode; // insert on end "Queue"
}
void PrintQuadList(FILE * f)
{
	struct QuadNode *Traveler = TopPtr;
	char* oper;
	while (Traveler)
	{
		if(Traveler->DATA->operation == 0 )
		{
			oper = "declare";
		}
		else if(Traveler->DATA->operation == 1 )
		{
			oper = "assign";
		}
		else if(Traveler->DATA->operation == 2 )
		{
			oper = "add";
		}
		else if(Traveler->DATA->operation == 3 )
		{
			oper = "subtract";
		}
		else if(Traveler->DATA->operation == 4 )
		{
			oper = "multiply";
		}
		else if(Traveler->DATA->operation == 5 )
		{
			oper = "divide";
		}
		fprintf(f, " operation: %s  first_operand:%s  second_operand: %s result:%s \n", oper, Traveler->DATA->Arg1, Traveler->DATA->Arg2, Traveler->DATA->Result);
		Traveler = Traveler->Next;
	}
}
//-------------------------------------------------------------------Quad Functions
QuadNode*GetTOP()
{
	return TopPtr;
}
Reg CheckReg();
void SetReg(Reg x);
void ResetReg();
Reg reg[7];





