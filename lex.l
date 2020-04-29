/* Standard c includes need + yacc files */

%{   
	#include <stdlib.h>
	#include <stdio.h>
	#include "y.tab.h"
	#include<string.h>
	void yyerror (char *s);
	int yylineno;
	int yylex();
%}

/* Tokens for the mock c language */
%%	
;                       						return SEMICOLON;
"*"												return MULTIPLY;
"/"												return DIVIDE;
"+"												return PLUS;
"-"												return MINUS;
"="												return ASSIGN;
"bool"				    						return BOOL;
"int"											return INT;
"float"											return FLOAT;
"char"											return CHAR;
"string"										return STRING;
"false"											return FALSE;
"true"											return TRUE;


[0-9]+											{yylval.IntValue = atoi(yytext); return INTEGER;}
[0-9]+\.[0-9]+									{yylval.FloatValue = atof(yytext); return FLOATNUMBER;}
\".*\"											{yylval.StringValue=strdup(yytext);return TEXT;} 
\'.?\'											{yylval.CharValue=strdup(yytext);return CHARACTER;}
[a-zA-Z][_a-zA-Z0-9]*							{yylval.Identifier=strdup(yytext);return IDENTIFIER;} 
[\t  ]+											;                                                 
[\n]											{yylineno = yylineno+1;}
.                                               {yyerror("Wrong_Token");} 
%% 


/* calling the main function */

int yywrap (void) {
	return 1;
}