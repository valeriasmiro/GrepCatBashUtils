#ifndef SRC_CAT_S21_CAT_H_
#define SRC_CAT_S21_CAT_H_
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static short options = 0;


int get_options(char **argv);
int read_files(char **argv);
int print_single_file(FILE *file, int row_counter);
void print_number(char ch, int *counter);
void linefeed(char c, char *temp);
void tab(char c, char *temp);
void non_printable_characters(char c, char *temp);
int choose_option(char arg_char);
int choose_gnu_option(char* gnu_arg);
void set_option(int bit_number);
short is_set(short bit_number);
void default_fill(char *temp, char c);
#endif  // SRC_CAT_S21_CAT_H_
