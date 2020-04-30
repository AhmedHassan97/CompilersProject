%start startcode

// Semi colon token
%token SEMICOLON

// Arethmetic operations tokens
%token PLUS
%token MINUS
%token DIVIDE
%token MULTIPLY

// Assign token
%token ASSIGN

// Type identifiers tokens
%token BOOL
%token INT
%token FLOAT
%token CHAR
%token STRING

// Boolean tokens
%token FALSE
%token TRUE

// Associativity
%left ASSIGN
%left PLUS MINUS 
%left DIVIDE MULTIPLY


%{ 	

	#include <stdio.h>
	#include <stdlib.h>
	#include <stdarg.h>
	#include <string.h>	
	#include"symbols.h"
    
    // Used to tokenize (yylex) and find errors (yyerror)
	int yyerror(char *);
	int yylex(void);

    // Keeps count of lines 
	int yylineno;

    // Identifier and quadriples count in the parsed file
	int IdentifiersCount=0;
	int QuadriplesCount=0;

    // Files that will be used in the compiler
	FILE * WriteFile;
	FILE * ReadFile;
	FILE * SymbolsFile;

    // A function that prints error message in file and on console
	void ThrowError(char *Message1, char *Message2);							
	
    // A function that creates indentifier
    void CreateIdentifier(int Type , char*Name,int ID);

    // A function that gets identifier by Name					
	void  GetIdentifier(char*Name);		

    // A function that uses an identifier and throws error if necessary					
	void UseIdentifier(char*Name );					   	

    // A function that merges 2 strings and return the merged string
	char * MergeStrings(char* string1,char*string2);						
	
    // A function that checks type matching
    bool CheckTypeIdentifier(int LeftType,int RightType);	
	
    // An array that holds all types of supported type identifiers
    char* Types[5] = { "Integer", "Float", "Char", "String", "Bool" };
    
    // A bool to mark usage of extra space
	bool Extra=false;

    // A counter of how many extra space are used
	int ExtraCounter=0;
%}


%union
{
    int IntValue;                
    float FloatValue;             
    char * StringValue;           
    char * CharValue;              
    char * Identifier ;                 
    int* Statement;
    struct Complex * Complex;
};

%token <IntValue>       INTEGER 
%token <FloatValue>     FLOATNUMBER 
%token <StringValue>    TEXT 
%token <CharValue>      CHARACTER 
%token <Identifier>     IDENTIFIER

%type <IntValue> type   
%type <Statement> statement
%type <Complex> sametype expression datatypes

%%



    startcode:   startcode statement  | ;

    statement:  type IDENTIFIER SEMICOLON            
                {

                    // $1 type // $2 Identifier 
                    CreateIdentifier($1,$2,IdentifiersCount++);
                    printf("Declaration \n");
                    SetQuadriple(0," "," ",$2,QuadriplesCount++);
                }


                |   IDENTIFIER ASSIGN expression SEMICOLON
                {

                    if(GetSymbolType($1)==$3->Type)
                    {
                        GetIdentifier($1);
                        printf("Assignment\n");
                        
                        if(Extra)
                        {
                            char str[10];
                            sprintf(str, "%d", ExtraCounter-1);
                            SetQuadriple(1,MergeStrings("ExtraSpace",str)," ",$1,QuadriplesCount++);
                        }
                        else
                        { 
                            SetQuadriple(1,$3->Value," ",$1,QuadriplesCount++);
                        }
                        Extra=0;
                        Extra=false;
                    }
                    else 
                    {
                        if(GetSymbolType($1)==-1)
                        {
                            char*str1=MergeStrings($1,"Is not a c type");
                            ThrowError("",str1);
                        }
                    }
                }     

                |   type IDENTIFIER ASSIGN expression	SEMICOLON
		        {

                    CreateIdentifier($1,$2,IdentifiersCount++);
                    if(CheckTypeIdentifier(GetSymbolType($2),$4->Type))
                    {
                        GetIdentifier($2);
                        SetQuadriple(0," "," ",$2,QuadriplesCount++);
                        if(Extra)
                        {	
                            char str[10];
                            sprintf(str, "%d", ExtraCounter-1);			
                            SetQuadriple(1,MergeStrings("ExtraSpace",str)," ",$2,QuadriplesCount++);
                        }
                        else 
                        { 
                            SetQuadriple(1,$4->Value," ",$2,QuadriplesCount++);
                        }
                        
                        printf("Declaration and Assignment\n");
                        ExtraCounter=0;
                        Extra=false;
                    }
                    else
                    {
                        char*str1=MergeStrings($2," is of type ");
                        char*str2=MergeStrings(str1,Types[GetSymbolType($2)]);
                        ThrowError("type mismatch ",str2);
                    }
			    }

                ;

    type:   INT 	
            {
                $$=0;
            }
	        
            | FLOAT 
            {
                $$=1;
            }
	
            | CHAR  
            {
                $$=2;
            }
	        
            | STRING
            {
                $$=3;
            }
	
            | BOOL	
            {
                $$=4;
            }
        	;	
    sametype: FLOATNUMBER                    
                {
                    $$=(struct Complex*) malloc(sizeof(struct Complex));
                    $$->Type=1;				
                    char c[3] = {};
                    sprintf(c,"%f",$1);
                    $$->Value=c;
                }

                | INTEGER		                      
                {
                    $$=(struct Complex*) malloc(sizeof(struct Complex));
                    $$->Type=0;					
                    char c[3] = {}; 
                    sprintf(c,"%d",$1);
                    $$->Value=strdup(c);
                }

                | IDENTIFIER         
                {
                    $$=(struct Complex*) malloc(sizeof(struct Complex));
                    $$->Type=GetSymbolType($1);
                    $$->Value=$1;
                    UseIdentifier($1);
                }

                | sametype PLUS	sametype   
                {
                    if($1->Type==$3->Type)
                    {
                        $$=(struct Complex*) malloc(sizeof(struct Complex));
                        $$->Type=$1->Type;
                        char str[10];
                        sprintf(str, "%d", ExtraCounter);	
                        $$->Value=MergeStrings("ExtraSpace",str);
                        SetQuadriple(2,$1->Value,$3->Value,MergeStrings("ExtraSpace",str),QuadriplesCount++);
                        ExtraCounter++;
                        Extra=true;
                    
                    }
                    else 
                    {
                        ThrowError("type mismatch "," addition operands ");
                    }
                }

                | sametype MINUS sametype   
                {
                    if($1->Type==$3->Type)
                    {
                        $$=(struct Complex*) malloc(sizeof(struct Complex));
                        $$->Type=$1->Type;
                        char str[10];
                        sprintf(str, "%d", ExtraCounter);	
                        $$->Value=MergeStrings("ExtraSpace",str);
                        SetQuadriple(3,$1->Value,$3->Value,MergeStrings("ExtraSpace",str),QuadriplesCount++);
                        ExtraCounter++;
                        Extra=true;
                    
                    }
                    else 
                    {
                        ThrowError("type mismatch "," subtracion operands ");
                    }
                }

                | sametype MULTIPLY sametype   
                {
                    if($1->Type==$3->Type)
                    {
                        $$=(struct Complex*) malloc(sizeof(struct Complex));
                        $$->Type=$1->Type;
                        char str[10];
                        sprintf(str, "%d", ExtraCounter);	
                        $$->Value=MergeStrings("ExtraSpace",str);
                        SetQuadriple(4,$1->Value,$3->Value,MergeStrings("ExtraSpace",str),QuadriplesCount++);
                        ExtraCounter++;
                        Extra=true;
                    
                    }
                    else 
                    {
                        ThrowError("type mismatch "," multiplication operands ");
                    }
                }
                
                | sametype DIVIDE sametype   
                {
                    if($1->Type==$3->Type)
                    {
                        $$=(struct Complex*) malloc(sizeof(struct Complex));
                        $$->Type=$1->Type;
                        char str[10];
                        sprintf(str, "%d", ExtraCounter);	
                        $$->Value=MergeStrings("ExtraSpace",str);
                        SetQuadriple(5,$1->Value,$3->Value,MergeStrings("ExtraSpace",str),QuadriplesCount++);
                        ExtraCounter++;
                        Extra=true;
                    
                    }
                    else 
                    {
                        ThrowError("type mismatch "," division operands ");
                    }
                }
                ;

    expression: datatypes
                {
                        $$=$1;
                }
                ;

    datatypes:  sametype
                {
                    $$=$1;
                }

		        | CHARACTER 			
                {
                
                    $$=(struct Complex*) malloc(sizeof(struct Complex));
                    $$->Type=2;					
                    $$->Value=strdup($1);
                }

                | FALSE 						
                {										
                    $$=(struct Complex*) malloc(sizeof(struct Complex));
                    $$->Type=4;					
                    $$->Value=strdup("FALSE");
                }

                | TRUE
                {							
                    $$=(struct Complex*) malloc(sizeof(struct Complex));
                    $$->Type=4;					
                    $$->Value=strdup("TRUE");
                }
                	
                | TEXT 					
                {            
                    $$=(struct Complex*) malloc(sizeof(struct Complex));
                    $$->Type=3;					
                    $$->Value=strdup($1);
                }
                ;

%%


void CreateIdentifier(int type , char*Name,int ID)
{

	if(CheckIdentifier(Name))
	{
        ThrowError("Already declared identifier ",Name);
    }
	else
	{
		SymbolData* Symbol=SetSymbol(type,0,false,Name);
		PushSymbol(ID,Symbol);
		printf("Symbol is created :  %s \n",Name);
	}
}

void GetIdentifier(char*Name)
{
	SymbolNode * Symbol = GetID(Name);
	if(!Symbol)
    {
	    ThrowError("Not declared identifier : ",Name);
    }
    else
	{
		Symbol->DATA->Initialized=true;
	}
}

void UseIdentifier(char*Name)
{
	SymbolNode * Symbol= GetID(Name);
	if(!Symbol)
	ThrowError("Not declared identifier : ",Name);
	else
	{
		printf("Identifier  %s  is Used \n",Name);
		if(!Symbol->DATA->Initialized)
        {
            ThrowError("","Uninitialized variable used");
        }
        Symbol->DATA->Used=true;
	}
}

bool CheckTypeIdentifier(int LeftType,int RightType)
{
	return (((LeftType==RightType))?true:false);
}

void ThrowError(char *Message1, char *Message2)
{

	ReadFile = fopen("output.txt","a");
 	fprintf(ReadFile, "line number: %d %s : %s\n", yylineno,Message1,Message2);
	printf("line number: %d %s : %s\n", yylineno,Message1,Message2);

};

int yyerror(char *s) 
{  
    int lineno=++yylineno;
    fprintf(stderr, "line number : %d %s\n", lineno,s);  
    return 0;
}

char * MergeStrings(char* string1,char*string2)
{  
      char * string3 = (char *) malloc(1 + strlen(string1)+ strlen(string2) );
      strcpy(string3, string1);	  
      strcat(string3, string2);
	  return string3;
}

 int main(void) {
	


	FILE * TestQuad =fopen("quads.txt","w");
	FILE * quadri =fopen("quadriples.txt","w");
	SymbolsFile=fopen("symbols.txt","w");
	if(!yyparse()) {
		printf("\nParsing complete\n");
		PrintSymbolTable(SymbolsFile);
		DestroyList();
		PrintQuadList(TestQuad);
		PrintQuadriples(quadri);
        fclose(quadri);
        fclose(SymbolsFile);
        fclose(TestQuad);

        exit(0);
	}
	else {
		printf("\nParsing failed\n %d",yylineno);
       		PrintSymbolTable(SymbolsFile);
		DestroyList();
		PrintQuadList(TestQuad);
		PrintQuadriples(quadri);
        fclose(quadri);
        fclose(SymbolsFile);
        fclose(TestQuad);

		return 0;
	}

    return 0;
}
