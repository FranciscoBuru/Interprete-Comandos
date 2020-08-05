Se programó un intérprete de comandos usando Bison y Lex. 
Se incluye un makefile para compilarlo.

|----------------------------------------------------------|
|							   |
|    .d88888b  oo              .88888.                     |
|    88.    '                 d8'   8b                     |
|    `Y88888b. dP .d8888b.    88     88 88d888b. .d8888b.  |
|          `8b 88 Y8ooooo.    88     88 88'  `88 Y8ooooo.  |
|    d8'   .8P 88       88 dP Y8.   .8P 88.  .88       88  |
|     Y88888P  dP `88888P' 88  `8888P'  88Y888P' `88888P'  |
|                                       88                 |
|                                       dP                 |
|----------------------------------------------------------|



Es importante notar que denotamos al comando "2>&1 | " con el símbolo "*".
El cambio de notación anterior pretende facilitar las pruebas.
Se implementaron los soguientes comandos:
	
	Denotamos A [comando] B a la estructura general de un comando

	[&] BG - Manda a background la ejecución.
	[|] PIPE - manda stdout de A a stdin de B.
	[2>] RSE - manda stderr de A al archivo especificado por B.
	[>] RS - manda stdout de A al archivo especificado por B.
	[2>&1 |] RSES PIPE  - manda stdout y stderr de A a stdin de B.

Para ejecutar el intérprete se necesita Bison 3.4.1, descargar los archivos
int.y, lex.yy.c, Makefile, tok.l, ytab.c y ytab.h del repositorio y ejecutar
el comando make en el dirctorio. Después del make se ejecuta ./interp para
iniciar el intérprete. Se puede salir del intérprete al esctibir "exit" y 
presionar enter.
A continuación se muestran algunos ejemplos de ejecuciones que se probaron y
funcionan bien. (Recordar que [2>&1 |] es denotado por [*]).

Denotamos [A-Z] como programas ejecutables y [a-z] como archivos.
-> A 
-> A &
-> A > a
-> A 2> A
-> A | B
-> A | B & 
-> A | B > a
-> A * B > a
-> A | B 2> a
-> A | B 2> a &
-> A | B | C 
-> A | B | C &
-> A | B | C > a
-> A | B | C 2> b
-> A * B * C | D | E > A
-> A * B * C * D 2> a
-> A | B * C | D * E > a

Nota: si se ejecuta A|B & y A necesita stdin entonces se ignora el &
