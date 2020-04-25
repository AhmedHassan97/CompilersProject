	// Our Tokens
    %token BOOL
	%token INT
	%token FLOAT
	%token CHAR
	%token STRING
	%token CONST

    %token FALSE
	%token TRUE

	%token FLOATNUMBER
	%token TEXT
	%token CHARACTER

    %left ASSIGN

    %{ 	
	#include <stdio.h>
	#include <stdlib.h>
	#include <stdarg.h>
	#include <string.h>	

	int yyerror(char *);
	int yylex(void);