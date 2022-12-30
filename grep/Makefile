CC0=gcc
CC1=gcc
CFLAGS=-c
LDFLAGS= #-Wall -Wextra -Werror
OS := $(shell uname -s)

ifeq ($(OS), Darwin)
	CC1 += -D OS_MAC
else
	CC1 += -D OS_LINUX
endif

all: clean s21_grep


s21_grep: s21_grep.o 
	$(CC0) $(LDFLAGS) s21_grep.o -o s21_grep

s21_grep.o: s21_grep.c
	$(CC1) $(LDFLAGS) -c -o s21_grep.o s21_grep.c


test: clean s21_grep
	./test.sh
	
clean:
	rm -rf s21_grep s21_grep *.o  *.out  fizz *.gc* *.info report \
	my.txt original.txt my.txt original.txt *.o

style:
	python ../../materials/linters/cpplint.py *.c *.h

rebuild: clean all
