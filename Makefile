YFLAGS = -d
 
PROGRAM = interp
 
OBJS = y.tab.o lex.yy.o
 
SRCS = y.tab.c lex.yy.c
 
CC = gcc 
 
all:	$(PROGRAM)
 
.c.o:	$(SRCS)
	$(CC) -c $*.c -o $@ -O

y.tab.c:	int.y
	yacc $(YFLAGS) int.y

lex.yy.c:	tok.l 
	lex tok.l

interp:	$(OBJS)
	$(CC) $(OBJS)  -o $@ -lfl 

clean:	
	rm -f $(OBJS) core *~ \#* *.o $(PROGRAM) \
	lex.yy.* y.tab.*