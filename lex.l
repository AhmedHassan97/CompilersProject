%{   
	#include <stdlib.h>
	#include <stdio.h>
	#include "y.tab.h"
	#include<string.h>
	void yyerror (char *s);
	int yylineno;
	int yylex();
%}

%%	
;                       						return SEMICOLON;
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

[0-9]+											{yylval.IntgerValue = atoi(yytext); return INTEGER;}
[0-9]+\.[0-9]+									{yylval.FloatValue = atof(yytext); return FLOATNUMBER;}
\".*\"											{yylval.StringValue=strdup(yytext);return TEXT;} 
\'.?\'											{yylval.ChValue=strdup(yytext);return CHARACTER;}
[a-zA-Z][_a-zA-Z0-9]*							{yylval.ID=strdup(yytext);return IDENTIFIER;} 
[\t  ]+											;      /*To ignore the white space*/                                            
[\n]											{yylineno = yylineno+1;}
.                                               {yyerror("Wrong_Token");}/*if anything other than the above tokens is entered an error message appears */ 
%% 
int yywrap (void) {
	return 1;
}