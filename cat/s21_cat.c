#include "s21_cat.h"

int main(int argc, char **argv) {
    int res = 0;
    while (1) {
        if (argc > 1 && !res) {
            res = get_options(argv);
            if (!res) {
                int files_count = 0, count = 1;
                while (argv[count]) {
                    if (argv[count][0] != '\0')
                        files_count++;
                    count++;
                }
                if (files_count) {
                    res = read_files(argv);
                    break;
                }
            } else {
                printf("s21_cat: неверный ключ\n");
                break;
            }
        }
    }
    return res;
}

int get_options(char **argv) {
    int count = 1, res = 0;
    while (argv[count] && !res) {
        if (argv[count][0] == '-' && argv[count][1] != '-') {
            int len = strlen(argv[count]);
            for (int i = 1; i < len; i++) {
                res = choose_option(argv[count][i]);
            }
            memset(argv[count], '\0', strlen(argv[count]));
        } else if (argv[count][0] == '-' && argv[count][1] == '-') {
            res = choose_gnu_option(argv[count]);
            memset(argv[count], '\0', strlen(argv[count]));
        }
        count++;
    }
    return res;
}

int choose_option(char arg_char) {
    int res = 0;
    if (arg_char == 'b')
        set_option(0);
    else if (arg_char == 'e')
        set_option(1);
    else if (arg_char == 'n')
        set_option(2);
    else if (arg_char == 's')
        set_option(3);
    else if (arg_char == 't')
        set_option(4);
    else if (arg_char == 'E')
        set_option(6);
    else if (arg_char == 'T')
        set_option(9);
    if (!strchr("bensstET", arg_char))
        res = 1;
    return res;
}

int choose_gnu_option(char* gnu_arg) {
    int res = 0;
    if (strcmp(gnu_arg, "--number-nonblank") == 0)
        set_option(5);
    else if (strcmp(gnu_arg, "--number") == 0)
        set_option(7);
    else if (strcmp(gnu_arg, "--squeeze-blank") == 0)
        set_option(8);
    if (!is_set(5) && !is_set(7) && !is_set(8))
        res = 1;
    return res;
}

void set_option(int bit_number) {
    int mask =  1 << bit_number;
    options |= mask;
}

short is_set(short bit_number) {
    short mask =  1 << bit_number;
    short masked_n = options & mask;
    return masked_n >> bit_number;
}

int read_files(char **argv) {
    FILE *file;
    int count = 1, row_counter = 0, res = 0;
    while (argv[count]) {
        if (argv[count][0] != '\0') {
            file = fopen(argv[count], "r");
            if (file) {
                row_counter += print_single_file(file, row_counter);
                fclose(file);
            } else {
                printf("s21_cat: %s: Нет такого файла или каталога\n", argv[count]);
                res = 1;
            }
        }
        count++;
    }
    return res;
}

int print_single_file(FILE *file, int row_counter) {
    char c;
    char mas[1024], temp[5];
    mas[0] = '\0';
    short EOL = 0, last_empty_line = 0;
    int count = 0, current_counter = row_counter;
    while ((c = fgetc(file)) != EOF) {
        if (!count) {
            if (c == '\n' && (is_set(3) || is_set(8))) {
                if (!last_empty_line) {
                    last_empty_line++;
                    print_number(c, &current_counter);
                    if (is_set(1) || is_set(6))
                        printf("$");
                    printf("\n");
                }
                continue;
            }
            print_number(c, &current_counter);
        }
        if (c == '\n') {
            linefeed(c, temp);
            EOL = 1;
        } else if (c == '\t') {
            tab(c, temp);
        } else if ((c <= 31 || c == 127) && (is_set(1) || is_set(4))) {
            non_printable_characters(c, temp);
        } else {
            temp[0] = c;
            temp[1] = '\0';
        }
        count++;
        strcat(mas, temp);
        if (EOL) {
            printf("%s\n", mas);
            last_empty_line = 0;
            EOL = 0;
            mas[0] = '\0';
            count = 0;
        }
    }
    printf("%s", mas);
    #ifdef __APPLE__
        current_counter = 0;
    #endif
    return current_counter;
}

void print_number(char ch, int *counter) {
    if (ch != '\n' && (is_set(0) || is_set(5))) {
        *counter = *counter + 1;
        printf("%6d\t", *counter);
    } else if ((is_set(2) || is_set(7)) && !is_set(0) && !is_set(5)) {
         *counter = *counter + 1;
        printf("%6d\t", *counter);
    }
}


void linefeed(char c, char *temp) {
    if (is_set(1) || is_set(6)) {
        temp[0] = '$';
        temp[1] = '\0';
    } else {
        temp[0] = '\0';
    }
}

void tab(char c, char *temp) {
    if (is_set(4) || is_set(9)) {
        temp[0] = '^';
        temp[1] = 'I';
        temp[2] = '\0';
    } else {
        temp[0] = '\t';
        temp[1] = '\0';
    }
}

void non_printable_characters(char c, char *temp) {
    if (is_set(1) || is_set(4)) {
        if ((c >= 0  && c <= 31)) {
            temp[0] = '^';
            temp[1] = c + 64;
            temp[2] = '\0';
        } else if (c == 127) {
            temp[0] = '^';
            temp[1] = '?';
            temp[2] = '\0';
        } else if (c > -97 && c != -1) {
            #ifdef __linux__
                temp[0] = 'M';
                temp[1] = '-';
                temp[2] = c + 128;
                temp[3] = '\0';
            #else
                default_fill(temp, c);
            #endif
        } else if (c == -1) {
            #ifdef __linux__
                temp[0] = 'M';
                temp[1] = '-';
                temp[2] = '^';
                temp[3] = c + 128;
                temp[4] = '\0';
            #else
                default_fill(temp, c);
            #endif
        } else {
            #ifdef __linux__
                temp[0] = 'M';
                temp[1] = '-';
                temp[2] = '^';
                temp[3] = c + 192;
                temp[4] = '\0';
            #else
               default_fill(temp, c);
            #endif
        }
    } else {
       default_fill(temp, c);
    }
}

void default_fill(char *temp, char c) {
    temp[0] = c;
    temp[1] = '\0';
}
