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

all: clean s21_cat s21_grep


s21_cat: s21_cat.o
	$(CC0) $(LDFLAGS) cat/s21_cat.o -o cat/s21_cat

s21_grep: s21_grep.o
	$(CC0) $(LDFLAGS) grep/s21_grep.o -o grep/s21_grep


s21_grep.o: grep/s21_grep.c
	$(CC0) $(LDFLAGS) -c -o grep/s21_grep.o grep/s21_grep.c

s21_cat.o: cat/s21_cat.c
	$(CC1) $(LDFLAGS) -c -o cat/s21_cat.o cat/s21_cat.c
	
clean:
	rm -rf cat/s21_cat grep/s21_grep cat/*.o grep/*.o cat/*.out grep/*.out fizz *.gc* *.info report

style:
	python ../materials/linters/cpplint.py cat/*.c cat/*.h grep/*.c grep/*.h
