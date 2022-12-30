#ifndef SRC_GREP_S21_GREP_H_
#define SRC_GREP_S21_GREP_H_

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <regex.h>

/// <summary>
///  int options - хранит все опции в первых 10 битах
///  -e - 1 бит, -i - 2 бит и т.д. (in README order)
/// </summary>

typedef struct file_struct {
    int first;
    int count;
} file_struct;

static regex_t regexes[200];
static int reflags = REG_NOSUB;
static int nregexes = 0;
static int option_args[100];
static int noption_args = 0;
static int options = 0;

int choose_option_grep(char arg_char, int count);

int get_options(char **argv);
int file_handler(char **argv, int number);

int get_option_args(char **argv);
int get_template_string(char **argv);

int grep_file(FILE *fp, char* filename);
char*get_temp_line(char line[], char* filename, int line_num);
void print_grep(int match_count, char *filename);

file_struct get_file_struct(char **argv);

void set_option(int number);
void reset_option(int number);
int is_set(int number);
#endif  // SRC_GREP_S21_GREP_H_
