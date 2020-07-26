
%{ 
#define YYSTYPE char *

#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

%}

%%

"*" { return RSES; }
">"  { return RS;}
"2>" { return RSE;}
"|"  { return PIPE;}
"&"  { return BG;}
[^><\&\|\ \t\n]* { yylval = strdup(yytext); return NOMBRE; };
[\ \t] ;
"\n" { return NL; }
"exit\n" { return EXIT; }

%%
/*
int main(int argc, char *argv[]) { 
  yyin = fopen(argv[1], "r"); 
  yylex(); 
  fclose(yyin); 
} 
*/