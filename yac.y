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
	void CreateID(int type , char*rName,int rID,int ScopeNum);			// -- Create a Symbol given its type and Name 
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
%type <dummy> stmt  increments forExpression  function  caseExpression 
%type <dummy>  blockScope manyStatements scopeOpen scopeClose 

%type <X> equalFamily expression DataTypes booleanExpression callFunction
%%
// All Capital Letters are terminals Tokens else are non terminals 
mystart	: 
		startProgram
		;
	
startProgram :      startProgram stmt  
		|
		;
		
stmt:   type IDENTIFIER SEMICOLON	%prec IFX                 				{
																				$$=NULL;
																				CreateID($1,$2,IDCount++,SCOPE_Number);
																				printf("Declaration\n");
																				setQuad(0," "," ",$2,QuadCount++);
																			}

		| IDENTIFIER ASSIGN expression SEMICOLON	          				{
																				$$=NULL;
																		
																			if(getSymbolType($1)==$3->Type || (getSymbolType($1)-5)==$3->Type)
																				{
																				
																					getIDENTIFIER($1,SCOPE_Number);
																					printf("Assignment\n");
																					if(TempIsUsed)
																					setQuad(1,TempArr[TempCounter-1]," ",$1,QuadCount++);
																					else setQuad(1,$3->Value," ",$1,QuadCount++);
																					TempCounter=0;
																					TempIsUsed=false;
																				}
																			else 
																				{
																					if(getSymbolType($1)==-1)
																					{
																					char*str1=conctanteStr($1," Has No Declread Type ");
																					ThrowError("",str1);
																					}
																					char*str1=conctanteStr($1," of Type");
												
																					char* str2=conctanteStr(str1,idtypeString[getSymbolType($1)]);
																			
																				ThrowError("Error: incompatible types ",str2);
																				}
																			}

		| type IDENTIFIER ASSIGN expression	SEMICOLON	      				{
																			$$=NULL;
																			CreateID($1,$2,IDCount++,SCOPE_Number);
																			if(checktypeIDENTIFER(getSymbolType($2),$4->Type,$2))
																			{
																			getIDENTIFIER($2,SCOPE_Number);// setValue here 
																			setQuad(0," "," ",$2,QuadCount++);// Create  first IDENTIFIER
																				if(TempIsUsed)
																					setQuad(1,TempArr[TempCounter-1]," ",$2,QuadCount++);
																					else setQuad(1,$4->Value," ",$2,QuadCount++);
																			printf("Declaration and Assignment\n");
																					TempCounter=0;
																				TempIsUsed=false;
																			}
																			else
																				{
																					char*str1=conctanteStr($2," of Type ");
																					char* str2=conctanteStr(str1,idtypeString[getSymbolType($2)]);
												
																				ThrowError("Error: incompatible types ",str2);
																				}
																			}

		| CONST type IDENTIFIER ASSIGN expression SEMICOLON   				{
																				$$=NULL;
																				CreateID($2+5,$3,IDCount++,SCOPE_Number);
																			if(checktypeIDENTIFER(getSymbolType($3),$5->Type,$3))
																			{
																				printf("weee\n");
																				//getIDENTIFIER($3,SCOPE_Number);// setValue here 
																				setQuad(0," "," ",$3,QuadCount++);// Create  first IDENTIFIER
																				if(TempIsUsed)
																					setQuad(1,TempArr[TempCounter-1]," ",$3,QuadCount++);
																					else setQuad(1,$5->Value," ",$3,QuadCount++);
																					printf("Constant assignment\n");
																					TempCounter=0;
																					TempIsUsed=false;
																			}
																			else
																				{
																					char*str1=conctanteStr($3," of Type ");
																					char* str2=conctanteStr(str1,idtypeString[getSymbolType($3)]);
																			
																				ThrowError("Error: incompatible types ",str2);
																				}
																			;}

		
		| WHILE ORBRACKET whileQuad CRBRACKET  stmt							{$$=NULL;char c[3] = {};gcvt(SCOPE_Number,6,c);setQuad(90,c,"OpenWhile","CloseWhile",QuadCount++);printf("While loop\n");}// need to check type to booealen

		| DO dowhileQuad blockScope WHILE ORBRACKET expression CRBRACKET SEMICOLON		{$$=NULL;printf("Do while\n");setQuad(91,""," ","CloseDoWhile",QuadCount++);}// need to check type to booealen

		| FOR ORBRACKET INT  create  SEMICOLON forQuad
		  forExpression CRBRACKET
		  blockScope											  			{$$=NULL;printf("For loop\n");setQuad(92,"","OpenForLoop","CloseForLoop",QuadCount++);}//  TO-DO check types on expression must int 

		
		| IF ORBRACKET ifQuad  CRBRACKET  blockScope %prec IFX 			{$$=NULL;printf("If statement\n");setQuad(60,"IF ","CloseIF","",QuadCount++);}

		| IF ORBRACKET ifQuad  CRBRACKET blockScope ELSE  elseQuad	{$$=NULL;printf("If-Elsestatement\n");setQuad(81,"IF ","CloseELSE","",QuadCount++);}

		| SWITCH ORBRACKET switchQuad CRBRACKET switchScope      			{$$=NULL;printf("Switch case\n");setQuad(72,"IF ","ENDSWITCH","",QuadCount++);}

		
		| PRINT expression 	SEMICOLON	                        				{$$=NULL;printf("Print\n");setQuad(62,"Print","",$2->Value,QuadCount++);}
		
		|  function	                                            		      {$$=NULL;printf("Function Body\n");setQuad(101,"RET","","",QuadCount++);}
		|callFunction	                                    			      {$$=NULL;setQuad(63,"FunctionCall",$1->Value,"",QuadCount++);printf("Function Call\n");}
		|IDENTIFIER ASSIGN callFunction	                                      {
                $$=NULL;
                if(checktypeIDENTIFER(getSymbolType($1),$3->Type,$1))
                {
                    getIDENTIFIER($1,SCOPE_Number);
                    setQuad(63,"FunctionCall",$3->Value,"",QuadCount++);
                    printf("Function Call\n");}
                else 
                {
                    char*str1=conctanteStr($1," of Type");
                    char* str2=conctanteStr(str1,idtypeString[getSymbolType($1)]);
            
                    ThrowError("Error: incompatible types ",str2);
                }
            }
|type IDENTIFIER ASSIGN callFunction	                              {	
        $$=NULL;
        CreateID($1,$2,IDCount++,SCOPE_Number);
        if(checktypeIDENTIFER(getSymbolType($2),$4->Type,$2))
        {

            getIDENTIFIER($2,SCOPE_Number);// setValue here 
            printf("Function Call\n");
        }
        else
        {
            char*str1=conctanteStr($2," of Type ");
            char* str2=conctanteStr(str1,idtypeString[getSymbolType($2)]);

        ThrowError("Error: incompatible types ",str2);
        }
    }

		| blockScope															{$$=NULL;printf("New  block\n");}
		|increments SEMICOLON													{$$=NULL;}			
		
		;
create :IDENTIFIER ASSIGN INTEGER{CreateID(0,$1 ,IDCount++,SCOPE_Number+1);getIDENTIFIER($1,SCOPE_Number);char c[3] = {};sprintf(c,"%d",$3);setQuad(1,c," ",$1,QuadCount++);}; 			// a rule to create IDENTIFIER in For Loop  
function : type IDENTIFIER ORBRACKET resetCounter argList CRBRACKET OCBRACKET scopeOpen funcQuad manyStatements RETURN  expression  SEMICOLON   CCBRACKET scopeClose  
        {
            $$=NULL;
            if($1 !=$12->Type)//check return types 
            {
                ThrowError("Error: incompatible return types of Function ",$2);
            }
            else
            {
                CreateFunction($1,$2,IDCount++,SCOPE_Number,ArgCounter,FuncArgTypes);
                
                printf("function\n");
            }
        }// create a function symbol 
	   ;
callFunction: IDENTIFIER ORBRACKET resetCounter callList CRBRACKET SEMICOLON// To-DO check here
        {
            $$->Type=getSymbolType($1);
            $$->Value=$1;
            int num =checkArgType(ArgCounter,FuncArgTypes,$1,SCOPE_Number);
            if(num==-25)
            {
                ThrowError("Error: undefined Function With Name ",$1);
            }
            else if(num== 0)
            {
                ThrowError("Error: mismatch argument number of function ",$1);
            }
            else if(num ==-1)
            {
                ThrowError("Error: incompatible types of Function ",$1);
            }
        }
			;

callList:   IDENTIFIER COMMA callList {usedIDENTIFIER($1,SCOPE_Number); FuncArgTypes[ArgCounter++]=getSymbolType($1);}
	      |  IDENTIFIER   {usedIDENTIFIER($1,SCOPE_Number);  FuncArgTypes[ArgCounter++]=getSymbolType($1);}
		  | // it can be empty for print functions maybe
	;		
resetCounter: {ArgCounter=0;};
argList:  type IDENTIFIER COMMA argList {CreateID($1,$2,IDCount++,SCOPE_Number+1);setQuad(0," "," ",$2,QuadCount++); FuncArgTypes[ArgCounter++]=$1;}// bec the scope is yet not incremeneted
	      | type IDENTIFIER 		    {CreateID($1,$2,IDCount++,SCOPE_Number+1);setQuad(0," "," ",$2,QuadCount++); FuncArgTypes[ArgCounter++]=$1;}// bec the scope is yet not incremeneted
		  |                              // it can be empty for print functions maybe 
		  //TO DO check if func(int x ,) accept parsing? 
	;


blockScope:	 OCBRACKET scopeOpen manyStatements CCBRACKET scopeClose								{$$=NULL;printf("blockScope\n");}
			| OCBRACKET scopeOpen CCBRACKET scopeClose												{$$=NULL;}
		;

switchScope:  OCBRACKET scopeOpen caseExpression CCBRACKET	scopeClose				   			 {printf("Switch Case block\n");}
		;
scopeOpen :{$$=NULL; SCOPE_Number++;}
scopeClose :{$$=NULL;DeadSymbols(SCOPE_Number); SCOPE_Number--;}		
manyStatements:  stmt 				{$$=$1;} 
        | manyStatements stmt 		{$$=NULL;}

type:   INT {$$=0;}
	| FLOAT {$$=1;}
	| CHAR  {$$=2;}
	| STRING{$$=3;}
	| BOOL	{$$=4;}
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
		| IDENTIFIER                           {$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));$$->Type=getSymbolType($1);$$->Value=$1;usedIDENTIFIER($1,SCOPE_Number);}
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
		| equalFamily MULTIPLY equalFamily     {
												if($1->Type==$3->Type)
												{
													$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
													$$->Type=$1->Type;// the result has the same type 
													$$->Value=TempArr[TempCounter];// store  the Result in TEMP 
													setQuad(12,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
													TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
												
												}
												else 
													ThrowError("Conflict dataTypes in Multiply \n "," ");
												}
		| equalFamily  DIVIDE	equalFamily    
												{
												if($1->Type==$3->Type)
												{
													if(!($3->Value))ThrowError("Error Dividing by Zero  \n "," ");
													$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
													$$->Type=$1->Type;// the result has the same type 
													$$->Value=TempArr[TempCounter];// store  the Result in TEMP 
													setQuad(13,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
													TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
												
												}
												else 
													ThrowError("Conflict dataTypes in Multiply \n "," ");
												}
		| equalFamily  REM	equalFamily       
												{
													if($1->Type==$3->Type)
												{
													$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
													$$->Type=$1->Type;// the result has the same type 
													$$->Value=TempArr[TempCounter];// store  the Result in TEMP 
													setQuad(14,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
													TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
												
												}
												else 
													ThrowError("Conflict dataTypes in Reminder \n "," ");
												}
		| IDENTIFIER INC                       {$$->Type=getSymbolType($1);$$->Value=$1;usedIDENTIFIER($1,SCOPE_Number);setQuad(15,"INC","INC",$1,QuadCount++);}// getSymbolType
		| IDENTIFIER DEC                       {$$->Type=getSymbolType($1);$$->Value=$1;usedIDENTIFIER($1,SCOPE_Number);setQuad(16,"DEC","DEC",$1,QuadCount++);}
		| ORBRACKET equalFamily CRBRACKET       {$$=$2;}
		;

increments: IDENTIFIER  INC            			 	 {$$=NULL;usedIDENTIFIER($1,SCOPE_Number);setQuad(15,"INC","INC",$1,QuadCount++);}// CREATE QUAD HERE 
		| IDENTIFIER DEC               			     {$$=NULL;usedIDENTIFIER($1,SCOPE_Number);setQuad(16,"DEC","DEC",$1,QuadCount++);}
		;


forExpression : increments                 {$$=NULL;}
				;
		 
booleanExpression: expression AND expression          {
										
														//if($1->Type!=$3->Type) 
														//	ThrowError("Conflict dataTypes in AND Operation \n "," "); 
														//{
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[TempCounter];// store  the Result in TEMP 
															setQuad(25,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
															TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
													//	}
														}
															
			| expression OR expression             	{
													//	if($1->Type!=$3->Type) 
													//		ThrowError("Conflict dataTypes in OR Operation \n "," "); 
													//	{
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[TempCounter];// store  the Result in TEMP 
															setQuad(26,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
															TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
														;// }
														}
			| NOT expression                        {
														
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
															$$->Type=$2->Type;// the result has the same type 
															$$->Value=TempArr[TempCounter];// store  the Result in TEMP 
															setQuad(27,$2->Value," ",TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
															TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
														
														}
			| DataTypes GREATERTHAN DataTypes         {
														if($1->Type!=$3->Type) 
															ThrowError("Conflict dataTypes in GREATERTHAN Operation \n "," "); 
														{
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[TempCounter];// store  the Result in TEMP 
															setQuad(28,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
															TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
														 }
														}
			| DataTypes LESSTHAN DataTypes            {
														if($1->Type!=$3->Type) 
															ThrowError("Conflict dataTypes in LESSTHAN Operation \n "," "); 
														{
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[TempCounter];// store  the Result in TEMP 
															setQuad(29,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
															TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
														; }
														}
			| DataTypes GREATERTHANOREQUAL DataTypes  {
														if($1->Type!=$3->Type) 
															ThrowError("Conflict dataTypes in GREATERTHANOREQUAL Operation \n "," "); 
														{
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[TempCounter];// store  the Result in TEMP 
															setQuad(30,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
															TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
														; }
														}
			| DataTypes LESSTHANOREQUAL DataTypes     {
														if($1->Type!=$3->Type) 
															ThrowError("Conflict dataTypes in LESSTHANOREQUAL Operation \n "," "); 
														{
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[TempCounter];// store  the Result in TEMP 
															setQuad(31,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
															TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
														; }
														}
			| DataTypes NOTEQUAL DataTypes              {
														if($1->Type!=$3->Type) 
															ThrowError("Conflict dataTypes in NOTEQUAL Operation \n "," "); 
														{
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[TempCounter];// store  the Result in TEMP 
															setQuad(32,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
															TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
														; }
														}
			| DataTypes EQUALEQUAL DataTypes            {
														if($1->Type!=$3->Type) 
															ThrowError("Conflict dataTypes in EQUALEQUAL Operation \n "," "); 
														{
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[TempCounter];// store  the Result in TEMP 
															setQuad(33,$1->Value,$3->Value,TempArr[TempCounter++],QuadCount++);//Generate ADD Quadrable 
															TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
														; }
														}
			| ORBRACKET booleanExpression CRBRACKET   {$$=$2;}
			;
			
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

expression:	DataTypes{{$$=$1;}}
		| booleanExpression{{$$=$1; }} ;
// GENERATE  QUAD HERE 
caseExpression:	DEFAULT COLON{setQuad(71,""," ","DEFAULTCase",QuadCount++);}manyStatements BREAK SEMICOLON    		     {$$=NULL;printf(" Case Statment\n");}	 	 // with default and must end with default statment                    
			  | CASE INTEGER COLON{char c[3] = {}; sprintf(c,"%d",$2); setQuad(70,c,"case",SwitchValue,QuadCount++);} manyStatements BREAK SEMICOLON caseExpression 	 {$$=NULL;printf(" Case Statment\n");}	 	// without default
		      ;

		   
		   
whileQuad:expression{char c[3] = {};sprintf(c,"%f",SCOPE_Number);setQuad(20,c,$1->Value,"OpenWhile",QuadCount++);}
dowhileQuad:{char c[3] = {};sprintf(c,"%f",SCOPE_Number);setQuad(22,c," ","OpenDoWhile",QuadCount++);}
forQuad:expression SEMICOLON{char c[3] = {};sprintf(c,"%f",SCOPE_Number);setQuad(21,c,$1->Value,"OpenForLoop",QuadCount++);}
funcQuad:{char c[3] = {};sprintf(c,"%f",SCOPE_Number);setQuad(100,c," ","FuncBody Begin ",QuadCount++);}
switchQuad:IDENTIFIER{SwitchValue=strdup($1);setQuad(61,"SwitchStart","",$1,QuadCount++);usedIDENTIFIER($1,SCOPE_Number);}
ifQuad:expression {setQuad(60,"IF ","OpenIF","",QuadCount++);}
elseQuad:{setQuad(80,"else","n","",QuadCount++);}blockScope
		   
%% 
void CreateID(int type , char*rName,int rID,int ScopeNum)
{
	if(CheckIDENTIFYER(rName))
	ThrowError("Already Declared IDENTIFIER with Name ",rName);
	//printf("IDENTIFIER with Name %s is Already Declared \n",rName);
	else
	{
		bool isConstant=(type>4)?true:false;
		SymbolData* rSymbol=setSymbol(type,0,false,0,rName,!isConstant,ScopeNum);
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
void CreateFunction(int type , char*rName,int rID,int ScopeNum,int rArgCounter,int *ArrOfTypes)
{
	if(CheckIDENTIFYER(rName))
	ThrowError("Already Declared IDENTIFIER with Name ",rName);
	//printf("IDENTIFIER with Name %s is Already Declared \n",rName);
	else
	{
		bool isConstant=(type>4)?true:false;// constant function ? XD
		SymbolData* rSymbol=setSymbol(type,0,false,0,rName,!isConstant,ScopeNum);
		if(isConstant)
		{
			rSymbol->Initilzation=true;
			setFuncArg(rArgCounter,ArrOfTypes,rSymbol);
			pushSymbol(rID,rSymbol);
			printf("Constant Symbol Function is created with Name %s \n",rName);	
		}
		else 
		{
			setFuncArg(rArgCounter,ArrOfTypes,rSymbol);
			pushSymbol(rID,rSymbol);
			printf(" Symbol Function is created with Name %s \n",rName);
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