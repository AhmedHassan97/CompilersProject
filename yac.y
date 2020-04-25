%start mystart



// Token for Semicolon
	%token SEMICOLON


// Tokens for assign
	%token ASSIGN



// Tokens for dataTypes
	%token BOOL
	%token INT
	%token FLOAT
	%token CHAR
	%token STRING
	%token CONST


// Tokens for booleans
	%token FALSE
	%token TRUE

	%token FLOATNUMBER
	%token TEXT
	%token CHARACTER

    
// Associativity
	%left ASSIGN
	
%{ 	

	#include <stdio.h>
	#include <stdlib.h>
	#include <stdarg.h>
	#include <string.h>	
	#include"SymbolTable.h"
    // for the error
	int yyerror(char *);
	int yylex(void);
    // for the number of lines 
	int yylineno;
	int IDCount=0;
	int QuadCount=0;
	// int SCOPE_Number=0;
	FILE * outFile;
	FILE * inFile;
	FILE *outSymbol;
	void ThrowError(char *Message, char *rVar);							//--  A Function to Terminate the Program and Report an Semantic Error
	void CreateID(int type , char*rName,int rID);			// -- Create a Symbol given its type and Name 
	void  getIDENTIFIER(char*rName,int ScopeNum);						//--  set Symbol Value to be Initilized. 
	void usedIDENTIFIER(char*rName,int ScopeNum );					    //--  set that Symbol is Used as a RHS in any operation 
	char * conctanteStr(char* str1,char*str2);							//--  a function to conctante two strings 
	bool checktypeIDENTIFER(int LeftType,int RightType,char* Right);	//--  Check Left and Right hand side in Assigment operation;
	char* idtypeString[10] = { "Integer", "Float", "Char", "String", "Bool", "ConstIntger", "ConstFloat", "ConstChar", "ConstString", "ConstBool" };
	int FuncArgTypes[10];												//Assuming Max 10 arguments 
	int ArgCounter=0;													//Argument Counter
	void CreateFunction(int type , char*rName,int rID,int ScopeNum,int rArgCounter,int *ArrOfTypes); // Create a Symbol For a Function
	char*RightHandSide[2]={"",""};
	int RightCount=0;
	bool manyExpressions=false;
	bool TempIsUsed=false;
	int TempCounter=0;
	char* SwitchValue;
	char*TempArr[16]={"Temp1","Temp2","Temp3","Temp4","TEMP5","TEMP6","TEMP7","TEMP8","TEMP9","TEMP10","TEMP11","TEMP12","TEMP13","TEMP14","TEMP15","TEMP16"};	
	%}
	%union {
    int IntgerValue;                 /* integer value */
	float FloatValue;               /* float Value */
    char * StringValue;              /* string value */
	char * ChValue;               /* character value */
	char * ID ;                    /*IDENTIFIER Value */
	int* dummy;
	struct TypeAndValue * X;
};
%token <IntgerValue> INTEGER 
%token <FloatValue> FLOATNUMBER 
%token <StringValue> TEXT 
%token <ChValue> CHARACTER 
%token <ID>     IDENTIFIER
%type <IntgerValue> type   

%type <X> equalFamily expression DataTypes booleanExpression callFunction
%%
// All Capital Letters are terminals Tokens else are non terminals 
mystart	: 
		startProgram
		;
	
startProgram : startProgram stmt  
		|
		;
		
stmt:  type IDENTIFIER SEMICOLON

		| IDENTIFIER ASSIGN expression SEMICOLON	          				
            
		| type IDENTIFIER ASSIGN expression	SEMICOLON	      				
            
		| CONST type IDENTIFIER ASSIGN expression SEMICOLON   								
		

type: INT {$$=0;}
	| FLOAT {$$=1;}
	| CHAR  {$$=2;}
	| STRING{$$=3;}
	| BOOL	{$$=4;}
	;

equalFamily: FLOATNUMBER                   
		| INTEGER		                 
		| IDENTIFIER                        
		;

expression:	DataTypes{{$$=$1;}}
		 ;

DataTypes:equalFamily{$$=$1;}
		| CHARACTER 					
		| FALSE 					
	    | TRUE							
		| TEXT 					
		;	
// GENERATE  QUAD HERE 
%% 
void CreateID(int type , char*rName,int rID)
{
	if(CheckIDENTIFYER(rName))
	ThrowError("Already Declared IDENTIFIER with Name ",rName);
	//printf("IDENTIFIER with Name %s is Already Declared \n",rName);
	else
	{
		bool isConstant=(type>4)?true:false;
		SymbolData* rSymbol=setSymbol(type,0,false,0,rName,!isConstant,1);
		if(isConstant)
		{
			rSymbol->Initilzation=true;
			pushSymbol(rID,rSymbol);
			printf("Constant Symbol is created with Name %s \n",rName);	
		}
		else 
		{
			pushSymbol(rID,rSymbol);
			printf(" Symbol is created with Name %s \n",rName);
		}
	}
}
void getIDENTIFIER(char*rName,int ScopeNum)
{
	SymbolNode * rSymbol=getID(rName, ScopeNum);
	if(!rSymbol)
	//printf("IDENTIFIER with Name %s is not Declared with this scope\n",rName);
	ThrowError("Not Declared in This Scope Identifiyer with Name \n ",rName);
	else
	{
		//printf("IDENTIFIER with Name is Initilized %s \n",rName);
		if(!rSymbol->DATA->Modifiable)
			ThrowError("Can't Modify a Constant Identifiyer with Name \n ",rName);
		else
			rSymbol->DATA->Initilzation=true;
	}
}
void usedIDENTIFIER(char*rName,int ScopeNum)
{
	SymbolNode * rSymbol=getID(rName, ScopeNum);
	if(!rSymbol)
	ThrowError("Not Declared in This Scope Identifiyer with Name \n ",rName);
	else
	{
		printf("IDENTIFIER with Name is Used %s \n",rName);
		if(!rSymbol->DATA->Initilzation)printf("Warning :IDENTIFIER with Name %s is not Initilized and is being used.  \n",rName);// don't quit just a warning
		rSymbol->DATA->Used=true;
	}
}
bool checktypeIDENTIFER(int LeftType,int RightType,char* Right)
{

	bool correct = ((LeftType==RightType) || (LeftType-5 ==RightType))?true:false; // here i check both constants types and types 
	return correct;

}
void ThrowError(char *Message, char *rVar)
{
	fclose(inFile);
	//int x = remove("output.txt");
	inFile = fopen("output.txt","w");
	fprintf(inFile, "Syntax Error Could not parse quadruples\n");
 	fprintf(inFile, "line number: %d %s : %s\n", yylineno,Message,rVar);
	printf("line number: %d %s : %s\n", yylineno,Message,rVar);
	fclose(outSymbol);
	remove("mySymbols.txt");
	outSymbol = fopen("mySymbols.txt","w");
	fprintf(outSymbol, "Syntax Error was Found\n");
 	fprintf(outSymbol, "line number: %d %s : %s\n", yylineno,Message,rVar);
 	exit(0);
};



 int yyerror(char *s) {  int lineno=++yylineno;   fprintf(stderr, "line number : %d %s\n", lineno,s);     return 0; }
 
 int main(void) {
	
	inFile = fopen("input.txt", "r");
	outFile=fopen("output.txt","w");
	FILE *TestQuad=fopen("Quad.txt","w");
	FILE *mCode=fopen("codeGENERATED.txt","w");
	outSymbol=fopen("mySymbols.txt","w");
	if(!yyparse()) {
		printf("\nParsing complete\n");
		PrintSymbolTable(outSymbol);
		DestroyList();
		PrintQuadList(TestQuad);
		QuadNode*R=getTOP();
		ExctractQuad(R,mCode);
		
		// -- TO-DO DestroyQuadList() to free allocated memory .. 
		fprintf(outFile,"Completed");
	}
	else {
		printf("\nParsing failed\n %d",yylineno);
		return 0;
	}
	
	fclose(inFile);
	fclose(outFile);
    return 0;
}