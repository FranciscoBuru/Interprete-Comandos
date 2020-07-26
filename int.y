/*Primero van las declaraciones las declaraciones*/
/*Prologo de bison*/

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <unistd.h> /* for fork */
  #include <sys/types.h> /* for pid_t */
  #include <sys/wait.h> /* for wait */
  #include <fcntl.h>  /* Para Archivos*/
  #define YYSTYPE char* 
  char cadena_comando[256];
  extern int yylex();
  void yyerror(const char *s);

  #define YYDEBUG 1

  int isBack = 0;
  void inBack();

  
  void ejecuta(char* s, int i);
  void prueba(char* s, int i);
  int hayEspera = 0;
  int tipoOper;
  int operAnt;
  int operSig;
  int operPend;
  char anterior[15];
  int numPipes = 6;
  int paso = 0;
  int fds[6][2];
  int esPrimero = 0;



%}
/*
  Notas:
    Los operadores son > , 2> , 2>&1 y | Estos siempre
    se ponen entre un ejexutable y un archivo

*/


/*Declaraciones de bison*/



%token PIPE RS RSE RSES NOMBRE NL BG EXIT


/*reglas de la gramatica*/

%%

lista_comandos: /* nothing */
	| lista_comandos NL 
	| lista_comandos comandos NL


comandos: comando {ejecuta($1,0);}
        | comando BG {inBack(); ejecuta($1,1);}  
        | comando PIPE { prueba($1,4); } comandos
        | comando RS { prueba($1,2); } comandos
        | comando RSE { prueba($1,3); } comandos
        | comando RSES { prueba($1,5); } comandos
        ;

comando: NOMBRE { strcpy(cadena_comando,$1); $$=cadena_comando;} 
         | comando NOMBRE { printf(cadena_comando,"%s%s",cadena_comando,$2);$$=cadena_comando; }
         | EXIT {printf("\nHasta Luego!\n");exit(0);} 
         ;
 
%%

/*acaban reglas de gramatica*/


#include <stdio.h>
char *progname;
 
/*Controlling function*/

int main( int argc, char *argv[] )
{
  printf("\n");
  printf("\n");
  printf("    .d88888b  oo              .88888.                     \n");
  printf("    88.    ""'                 d8'   8b                    \n");
  printf("    `Y88888b. dP .d8888b.    88     88 88d888b. .d8888b.  \n");
  printf("          `8b 88 Y8ooooo.    88     88 88'  `88 Y8ooooo.  \n");
  printf("    d8'   .8P 88       88 dP Y8.   .8P 88.  .88       88  \n");
  printf("     Y88888P  dP `88888P' 88  `8888P'  88Y888P' `88888P'  \n");
  printf("                                       88                 \n");
  printf("                                       dP                 \n"); 
  printf("\n");
  printf("Intérprete listo, comienze a ejecutar. \n");
  printf("-> ");

  //yydebug = 1;
  //int fds[numPipes][2];
  int i;
  for(i ; i<numPipes; i++){
    if(pipe(fds[i]) < 0){
      return 0;
    }
  }
  progname = argv[0];
  yyparse();
  return 0;
}

/*Error reporting routine*/


void yyerror (const char * s )
{
  fprintf( stderr ,"%s: %s\n" , progname , s );
}

void inBack(){
  isBack=1;
}

void prueba(char* s, int i){
  if(hayEspera == 1){
    tipoOper = i;
    operSig = i;
    ejecuta(s,2); 
  }else{
    hayEspera = 1;
    strcpy(anterior, s);
    tipoOper = i;
    operPend = i;
  } 
}

void ejecuta(char* s, int k){
  pid_t pid, pid3, pid2;
  if(tipoOper == 2 || tipoOper == 3){
    if(operSig == 0){
      pid3 = fork();
      if(pid3 == 0){
        int arch = open(s, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
        dup2(arch,tipoOper - 1);
        char *args[]={anterior,NULL};
        execv(args[0],args);
      }else{
        waitpid(pid3,0,0);
      }
    }else if(operSig == 2 || operSig == 3){
      if(operPend == 4 || operPend == 5){
        paso = paso + 1;
        if(paso == 1){
          pid = fork();
          if(pid == 0){
            pid2 = fork();
            if(pid2 == 0){
              if(operPend == 5){
                dup2(fds[0][1],2);
              }
              dup2(fds[0][1],1);
              char *args[]={anterior,NULL};
              execv(args[0],args);
            }else{
              //dup2(fds[paso-1][0],0);
              int arch = open("aux.txt", O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
              dup2(arch,operSig -1);
              char *args[]={s,NULL};
              execv(args[0],args);
              close(arch);
              waitpid(pid2,0,0);
            }
          }else{
            waitpid(pid,0,0);
            }
        }else{
          pid = fork();
          if(pid == 0){
            dup2(fds[paso-1][0],0);
            remove("aux.txt");
            int arch = open("aux.txt", O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
            //if(operPend == 5){
            //    dup2(1,2);
            //}
            dup2(arch,operSig -1);
            char *args[]={s,NULL};
            execv(args[0],args);
            close(arch);
          }else{
            waitpid(pid,0,0);
          }
        }
      }
    }
  }
  else if(tipoOper == 0){
    if(operPend != 0){
      if( (operPend == 4 && operAnt == 4) || (operPend == 5 && operAnt == 5) ){
        paso = paso + 1;
        pid = fork();
        if(pid == 0){
          dup2(fds[paso-1][0],0);
          char *args[]={s,NULL};
          execv(args[0],args);
        }else{
          if(isBack == 0){
            waitpid(pid,0,0);
          }
        }
      }else if(operAnt == 2 || operAnt == 3){
        if(rename("aux.txt",s) != 0){
          printf("Error al renombrar, output guardado en archivo aux");
        }
      }
    }else{
      pid = fork();
      if(pid == 0){
        char *args[]={s,NULL};
        execv(args[0],args);
      }else if (isBack == 0){
        waitpid(pid,0,0);
        printf("Esperé a que acabara\n");
      }else{
        printf("Lo mandamos a background, en algún momento va a imprimir aqui.\n");
      }
    }
  }
  else if(tipoOper == 4 || tipoOper == 5){
    if(paso == 0){
      paso = 1;
      pid = fork();
      if(pid == 0){
        pid2=fork();
        if(pid2==0){
          if(operPend == 5){
            dup2(fds[0][1],2);
          }
          dup2(fds[0][1],1);
          char *args[]={anterior,NULL};
          execv(args[0],args);
        }else{  
          dup2(fds[0][0],0);
          if( operSig == 4 || operSig == 5){
            if(operSig == 5){
              dup2(fds[1][1],2);
            }
            dup2(fds[1][1],1);
          }
          char *args[]={s,NULL};
          execv(args[0],args);
          if(isBack != 1){
            waitpid(pid,0,0);
          }
        }
      }
      if(isBack != 1){
        waitpid(pid,0,0);
      }
    }else{
      paso = paso + 1;
      pid = fork();
      if(pid == 0){
        dup2(fds[paso-1][0],0);
        if( operSig == 4 || operSig == 5){
          if(operSig == 5){
            dup2(fds[paso][1],2);
          }
          dup2(fds[paso][1],1);
        }
        char *args[]={s,NULL};
        execv(args[0],args);
      }else{
        waitpid(pid,0,0);
      }
    }
  }
  if(k == 0 || k == 1){
    printf("Comando ejecutado\n");
    printf("-> ");
    paso = 0;
    operAnt = 0;
    operPend = 0;
    operSig = 0;
    tipoOper = 0;
    isBack = 0;
    hayEspera = 0;
  }
  //Limpio
  operAnt = tipoOper;
  operPend = operSig;
  tipoOper = 0;
  esPrimero = 1;
}