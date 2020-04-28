%start compilerstart
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
	void ThrowError(char *Message, char *rVar);							
	void CreateID(int type , char*rName,int rID);					
	void  getIdentifier(char*rName);								
	void usedIDENTIFIER(char*rName );					   				
	char * conctanteStr(char* str1,char*str2);						
	bool CheckTypeIdentifier(int LeftType,int RightType,char* Right);	
	char* Types[5] = { "Integer", "Float", "Char", "String", "Bool" };
	bool TempIsUsed=false;
	int TempCounter=0;
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
%type <X> EqualGroup expression DataTypes
%%
// All Capital Letters are terminals Tokens else are non terminals 
compilerstart	: 
		startProgram
		;
	
startProgram : startProgram stmt  
		|
		;
		
stmt:  type IDENTIFIER SEMICOLON {

			// 1 type // 2 Identifier 
			CreateID($1,$2,IDCount++);
			printf("Declaration\n");
			setQuad(0," "," ",$2,QuadCount++);
		}

		| IDENTIFIER ASSIGN expression SEMICOLON
		{

			if(getSymbolType($1)==$3->Type)
			{
				getIdentifier($1);
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

			CreateID($1,$2,IDCount++);
			if(CheckTypeIdentifier(getSymbolType($2),$4->Type,$2))
			{
				getIdentifier($2);// setValue here 
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
					char*str2=conctanteStr(str1,Types[getSymbolType($2)]);
				}
			}
type: INT 	{$$=0;}
	| FLOAT {$$=1;}
	| CHAR  {$$=2;}
	| STRING{$$=3;}
	| BOOL	{$$=4;}
	;	
expression:	DataTypes{{$$=$1;}}
DataTypes:EqualGroup{$$=$1;}
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

EqualGroup:   FLOATNUMBER                     {
												$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
												$$->Type=1;				
												char c[3] = {};
												sprintf(c,"%f",$1);

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
		| EqualGroup PLUS	EqualGroup        {
												if($1->Type==$3->Type)
												{
													$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
													$$->Type=$1->Type;// the result has the same type 
													$$->Value=TempArr[TempCounter];
													setQuad(3,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
													TempIsUsed=true;
												
												}
												else 
													ThrowError("Conflict dataTypes in Addition \n "," ");
												}
		| EqualGroup MINUS EqualGroup        {
												if($1->Type==$3->Type)
												{
													$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
													$$->Type=$1->Type;// the result has the same type 
													$$->Value=TempArr[TempCounter];
													setQuad(4,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
													TempIsUsed=true;
												
												}
												else 
													ThrowError("Conflict dataTypes in Subtraction \n "," ");
												}

// GENERATE  QUAD HERE 
%% 
void CreateID(int type , char*rName,int rID)
{
	// checks if the identifier is repeated or not 
	if(CheckIdentifier(rName))
	ThrowError("Already Declared IDENTIFIER with Name ",rName);

	else
	{
		SymbolData* rSymbol=setSymbol(type,0,false,rName);
		pushSymbol(rID,rSymbol);
		printf("Symbol is created with Name %s \n",rName);
	}
}
// check if the identifier exist in the linked list (Sympol table)
void getIdentifier(char*rName)
{
	SymbolNode * rSymbol=getID(rName);
	if(!rSymbol)

	ThrowError("Not Declared Identifier with Name \n ",rName);
	else
	{
		rSymbol->DATA->Initialized=true;
	}
}
void usedIDENTIFIER(char*rName)
{
	SymbolNode * rSymbol=getID(rName);
	if(!rSymbol)
	ThrowError("Not Declared Identifier with Name \n ",rName);
	else
	{
		printf("IDENTIFIER with Name is Used %s \n",rName);
		if(!rSymbol->DATA->Initialized)printf("Warning :IDENTIFIER with Name %s is not Initilized and is being used.  \n",rName);// don't quit just a warning
		rSymbol->DATA->Used=true;
	}
}
bool CheckTypeIdentifier(int LeftType,int RightType,char* Right)
{
	bool correct = ((LeftType==RightType))?true:false;  
	return correct;
}
void ThrowError(char *Message, char *rVar)
{
	fclose(inFile);
	inFile = fopen("output.txt","w");
	fprintf(inFile, "Syntax Error Could not parse quadruples\n");
 	fprintf(inFile, "line number: %d %s : %s\n", yylineno,Message,rVar);
	printf("line number: %d %s : %s\n", yylineno,Message,rVar);
	fclose(outSymbol);
	remove("Symbols.txt");
	outSymbol = fopen("Symbols.txt","w");
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
	

	outFile=fopen("output.txt","w");
	FILE *TestQuad=fopen("quadraples.txt","w");
	outSymbol=fopen("symbols.txt","w");
	if(!yyparse()) {
		printf("\nParsing complete\n");
		PrintSymbolTable(outSymbol);
		DestroyList();
		PrintQuadList(TestQuad);
		QuadNode*R=getTOP();
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