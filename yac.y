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
// Tokens for booleans
	%token FALSE
	%token TRUE

	%token PLUS
	%token MINUS
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
	void  getIDENTIFIER(char*rName);						//--  set Symbol Value to be Initilized. 
	void usedIDENTIFIER(char*rName );					    //--  set that Symbol is Used as a RHS in any operation 
	char * conctanteStr(char* str1,char*str2);							//--  a function to conctante two strings 
	bool checktypeIDENTIFER(int LeftType,int RightType,char* Right);	//--  Check Left and Right hand side in Assigment operation;
	char* idtypeString[10] = { "Integer", "Float", "Char", "String", "Bool" };
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
%type <dummy> stmt
%type <X> equalFamily expression DataTypes
%%
// All Capital Letters are terminals Tokens else are non terminals 
mystart	: 
		startProgram
		;
	
startProgram : startProgram stmt  
		|
		;
		
stmt:  type IDENTIFIER SEMICOLON %prec IFX{
			// $$=NULL;
			// 1 type // 2 Identifier 
			CreateID($1,$2,IDCount++);
			printf("Declaration\n");
			setQuad(0," "," ",$2,QuadCount++);
		}

		| IDENTIFIER ASSIGN expression SEMICOLON
		{
			// $$=NULL;
			if(getSymbolType($1)==$3->Type)
			{
				getIDENTIFIER($1);
				printf("Assignment\n");
				if(TempIsUsed){
					setQuad(1,TempArr[TempCounter-1]," ",$1,QuadCount++);
				}
				else{ 
					setQuad(1,$3->Value," ",$1,QuadCount++);
				}
				TempCounter=0;
				TempIsUsed=false;
			}
			else 
			{
			ThrowError("Error: Syntax Error"," ");
			}
		}          				 
		| type IDENTIFIER ASSIGN expression	SEMICOLON
		{
			// $$=NULL;
			CreateID($1,$2,IDCount++);
			if(checktypeIDENTIFER(getSymbolType($2),$4->Type,$2))
			{
				getIDENTIFIER($2);// setValue here 
				setQuad(0," "," ",$2,QuadCount++);// Create  first IDENTIFIER
					if(TempIsUsed)
						setQuad(1,TempArr[TempCounter-1]," ",$2,QuadCount++);
					else 
						setQuad(1,$4->Value," ",$2,QuadCount++);
				printf("Declaration and Assignment\n");
						TempCounter=0;
						TempIsUsed=false;
			}
			else
				{
					char*str1=conctanteStr($2," of Type ");
					char*str2=conctanteStr(str1,idtypeString[getSymbolType($2)]);
				}
			}
type: INT 	{$$=0;}
	| FLOAT {$$=1;}
	| CHAR  {$$=2;}
	| STRING{$$=3;}
	| BOOL	{$$=4;}
	;	
expression:	DataTypes{{$$=$1;}}
DataTypes:equalFamily{$$=$1;}
		| CHARACTER 					{
											
												$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
												$$->Type=2;					
												$$->Value=strdup($1);
										}
		| FALSE 						{
											
												$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
												$$->Type=4;					
												$$->Value=strdup("FALSE");
										}
	    | TRUE							{
											
												$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
												$$->Type=4;					
												$$->Value=strdup("TRUE");
										}
		| TEXT 							{
											
												$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
												$$->Type=3;					
												$$->Value=strdup($1);
										}
		;	

equalFamily:   FLOATNUMBER                     {
												$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
												$$->Type=1;				
												char c[3] = {};
												sprintf(c,"%f",$1);
													//gcvt($1,6,c);
													$$->Value=c;
											   }
		| INTEGER		                       {
												$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
												$$->Type=0;					
												char c[3] = {}; 
												sprintf(c,"%d",$1);
												$$->Value=strdup(c);
											   }
		| IDENTIFIER                           {$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));$$->Type=getSymbolType($1);$$->Value=$1;usedIDENTIFIER($1);}
		| equalFamily PLUS	equalFamily        {
												if($1->Type==$3->Type)
												{
													$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
													$$->Type=$1->Type;// the result has the same type 
													$$->Value=TempArr[TempCounter];// store  the Result in TEMP 
													setQuad(10,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
													TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
												
												}
												else 
													ThrowError("Conflict dataTypes in Addition \n "," ");
												}
		| equalFamily MINUS equalFamily        {
												if($1->Type==$3->Type)
												{
													$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
													$$->Type=$1->Type;// the result has the same type 
													$$->Value=TempArr[TempCounter];// store  the Result in TEMP 
													setQuad(11,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
													TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
												
												}
												else 
													ThrowError("Conflict dataTypes in Subtraction \n "," ");
												}

// GENERATE  QUAD HERE 
%% 
void CreateID(int type , char*rName,int rID)
{
	// checks if the identifier is repeated or not 
	if(CheckIDENTIFYER(rName))
	ThrowError("Already Declared IDENTIFIER with Name ",rName);
	//printf("IDENTIFIER with Name %s is Already Declared \n",rName);
	else
	{
		SymbolData* rSymbol=setSymbol(type,0,false,rName);
		pushSymbol(rID,rSymbol);
		printf("Symbol is created with Name %s \n",rName);
	}
}
// check if the identifier exist in the linked list (Sympol table)
void getIDENTIFIER(char*rName)
{
	SymbolNode * rSymbol=getID(rName);
	if(!rSymbol)
	//printf("IDENTIFIER with Name %s is not Declared with this scope\n",rName);
	ThrowError("Not Declared Identifiyer with Name \n ",rName);
	else
	{
		rSymbol->DATA->Initilzation=true;
	}
}
void usedIDENTIFIER(char*rName)
{
	SymbolNode * rSymbol=getID(rName);
	if(!rSymbol)
	ThrowError("Not Declared Identifiyer with Name \n ",rName);
	else
	{
		printf("IDENTIFIER with Name is Used %s \n",rName);
		if(!rSymbol->DATA->Initilzation)printf("Warning :IDENTIFIER with Name %s is not Initilized and is being used.  \n",rName);// don't quit just a warning
		rSymbol->DATA->Used=true;
	}
}
bool checktypeIDENTIFER(int LeftType,int RightType,char* Right)
{
	bool correct = ((LeftType==RightType))?true:false;  
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
char * conctanteStr(char* str1,char*str2)
 {  
      char * str3 = (char *) malloc(1 + strlen(str1)+ strlen(str2) );
      strcpy(str3, str1);	  
      strcat(str3, str2);
	return str3;
 
 }
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