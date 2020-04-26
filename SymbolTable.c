#include"SymbolTable.h"


char* idtype[10] = { "Integer", "Float", "Char", "String", "Bool", "ConstIntger", "ConstFloat", "ConstChar", "ConstString", "ConstBool" };
struct SymbolNode * ListTop = NULL;
struct SymbolData* setSymbol(int rType, int rValue, bool rUsed,char* Identifyier)
{
	struct SymbolData *data = (struct SymbolData*) malloc(sizeof(struct SymbolData));
	data->Type = rType;
	data->Initilzation = rValue;
	data->Used = rUsed;
	data->IdentifierName = Identifyier;

	
	return data;
}
void pushSymbol(int index, struct SymbolData *data) {
	//--Insert from Begining 
	struct SymbolNode *mySymbolNode = (struct SymbolNode*) malloc(sizeof(struct SymbolNode));
	mySymbolNode->ID = index;
	mySymbolNode->DATA = data;
	mySymbolNode->Next = ListTop;
	ListTop = mySymbolNode;
}
/*
SymbolNode* getSymbolNODE() {
	if (!ListTop)return NULL;
	SymbolNode * SymbolPtr = ListTop;
	// Move The head then
	ListTop = ListTop->Next;
	return SymbolPtr;
}*/


int countNODE()
{
	int mCount = 0;
	SymbolNode * Walker = ListTop;
	while (Walker)
	{
		mCount++;
		Walker = Walker->Next;
	}
	return mCount;
}

bool isEmpty()
{
	return (ListTop == NULL) ? true : false;
}

SymbolData * getSymbol(int rID)
{
	int mCount = 0;
	SymbolNode * Walker = ListTop;
	while (Walker)
	{
		if (Walker->ID == rID)
		{
			return Walker->DATA;
		}
	}
	return NULL;
}

void printList(SymbolNode*rHead)
{
	// Base case  
	if (rHead == NULL)
		return;

	// print the list after head node  
	printList(rHead->Next);

	// After everything else is printed, print head  
//	cout << rHead->DATA->BracesScope << " ";
}

void setTOKENNAME(int ID, char * Value)
{
	SymbolData*rData = getSymbol(ID);
	strcpy_s(rData->IdentifierName,sizeof(Value), Value);
}

void setUsed(int rID)
{
	SymbolData *S = getSymbol(rID);
	if (!S)
	S->Used = true;
}

void setInitilization(int rID)
{
	SymbolData *S = getSymbol(rID);
	if (!S)
	S->Initilzation = true;
}
SymbolNode *  getID(char * Identifiyer)
{
	SymbolNode * Walker = ListTop;
	//start from the beginning

	while (Walker)
	{
		if ((strcmp(Identifiyer, Walker->DATA->IdentifierName)==0 ))
		{
			return Walker;
		}

		Walker = Walker->Next;
	}
	return NULL;
}
bool CheckIDENTIFYER(char * ID)
{
	SymbolNode * Walker = ListTop;

	//start from the beginning
	while (Walker)
	{
		if (strcmp(ID, Walker->DATA->IdentifierName) == 0)
		{
			return true;
		}
		Walker = Walker->Next;
	}

	return-false;

}
void PrintSymbolTable(FILE*F)
{
	printUsed(F);
	printNotUsed(F);
	printInitilized(F);
	printNotInit(F);
	
}
int getSymbolType(char * rID)
{
	SymbolNode * Walker = ListTop;
	while (Walker)
	{
		if (strcmp(rID, Walker->DATA->IdentifierName) == 0)//&& Walker->DATA->BracesScope <=rBraceSCope)
		{
			return Walker->DATA->Type;
		}

		Walker = Walker->Next;
	}
	return -1;

}
void DestroyList()
{
	SymbolNode * Walker = ListTop;
	while (Walker)
	{
		SymbolNode *rD = Walker;
		Walker = Walker->Next;
		free (rD);
	}
}
void printUsed(FILE *f)
{
	SymbolNode * Walker = ListTop;
	fprintf(f, "Used Identifiers :- \n");
	while (Walker)
	{
		if (Walker->DATA->Used)
		{
			fprintf(f, "%s of type %s \n", Walker->DATA->IdentifierName, idtype[Walker->DATA->Type]);
			fprintf(f, "%s of type %s\n", Walker->DATA->IdentifierName, idtype[Walker->DATA->Type]);
		}
		Walker = Walker->Next;
	}

	fprintf(f, "\n");
}
void printNotUsed(FILE *f)
{
	SymbolNode * Walker = ListTop;
	fprintf(f, "UnUsed Identifiers :- \n");
	while (Walker)
	{
		if (!(Walker->DATA->Used))
		{
			fprintf(f, "%s of type %s \n", Walker->DATA->IdentifierName, idtype[Walker->DATA->Type]);
		}
		Walker = Walker->Next;
	}

	fprintf(f, "\n");
}
void printInitilized(FILE *f)
{
	SymbolNode * Walker = ListTop;
	fprintf(f, "Initilized Identifiers :- \n");
	while (Walker)
	{
		if (Walker->DATA->Initilzation)
		{
			fprintf(f, "%s of type %s \n", Walker->DATA->IdentifierName, idtype[Walker->DATA->Type]);
		}
		Walker = Walker->Next;
	}

	fprintf(f, "\n");
}
void printNotInit(FILE *f)
{
	SymbolNode * Walker = ListTop;
	fprintf(f, "UnInitilized Identifiers :- \n");
	while (Walker)
	{
		if (!(Walker->DATA->Initilzation))
		{
			
			fprintf(f, "%s of type %s\n", Walker->DATA->IdentifierName, idtype[Walker->DATA->Type]);
			
		}
		Walker = Walker->Next;
	}

	fprintf(f, "\n");
}
//-----------------------------------------------------------------------------------------------------
QuadNode*TopPtr = NULL;
void setQuad(int Op, char* Arg1, char* Arg2,char*Result,int rID)
{
	struct QuadData *data = (struct QuadData*) malloc(sizeof(struct QuadData));
	data->OpCode = Op;
	data->Arg1 = Arg1;
	data->Arg2 = Arg2;
	data->Result = Result;
	InsertQuadruple(data, rID); // insert in list 
	return ;
}
void InsertQuadruple(QuadData*rD, int ID)
{
	if (!TopPtr)
	{
	struct QuadNode *mySymbolNode = (struct QuadNode*) malloc(sizeof(struct QuadNode));
	TopPtr = mySymbolNode;
	mySymbolNode->ID = ID;
	mySymbolNode->DATA = rD;
	TopPtr->Next = NULL;
	return;
	}
	struct QuadNode *Walker = TopPtr;
	while (Walker->Next)
		Walker = Walker->Next;// get last Node
	struct QuadNode *mySymbolNode = (struct QuadNode*) malloc(sizeof(struct QuadNode));
	mySymbolNode->ID = ID;
	mySymbolNode->DATA = rD;
	mySymbolNode->Next = NULL;
	Walker->Next = mySymbolNode; // insert on end "Queue"
}
void PrintQuadList(FILE * f)
{
	struct QuadNode *Walker = TopPtr;
	while (Walker)
	{
		fprintf(f, " OpCode: %d  Arg1:%s  Arg2: %s Result:%s \n", Walker->DATA->OpCode, Walker->DATA->Arg1, Walker->DATA->Arg2, Walker->DATA->Result);
		Walker = Walker->Next;
	}
}
//-------------------------------------------------------------------Quad Functions
QuadNode*getTOP()
{
	return TopPtr;
}
Reg CheckReg();
void SetReg(Reg x);
void ResetReg();
Reg reg[7];
char* CurlyBraces[7];




