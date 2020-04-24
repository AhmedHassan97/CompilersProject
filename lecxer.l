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
"="												return ASSIGN;
"bool"				    						return BOOL;
"int"											return INT;
"float"											return FLOAT;
"char"											return CHAR;
"string"										return STRING;
"const"                 						return CONST;
"false"											return FALSE;
"true"											return TRUE;

[0-9]+											{yylval.ivalue = atoi(yytext); return INTEGER;}
[0-9]+\.[0-9]+									{yylval.fvalue = atof(yytext); return FLOATNUMBER;}
\".*\"											{yylval.StringValue=strdup(yytext);return TEXT;} 
\'.?\'											{yylval.ChValue=strdup(yytext);return CHARACTER;}
[a-zA-Z][_a-zA-Z0-9]*							{yylval.ID=strdup(yytext);return IDENTIFIER;} 
[\t  ]+											;      /*To ignore the white space*/                                            
[\n]											{yylineno = yylineno+1;}
.                                               {yyerror("UnExpectedToken");}
%% 
int yywrap (void) {
	return 1;
}