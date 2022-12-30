#include "s21_grep.h"


int main(int argc, char **argv) {
    int error = 0;
    while (1) {
        set_option(6);
        set_option(7);
        if (!error) {
            error = get_options(argv);
            if (!error) {
                error = get_option_args(argv);
                if (!error && nregexes == 0) {
                    error = get_template_string(argv);
                }
                if (!error) {
                    file_struct file_s = get_file_struct(argv);
                    if (file_s.count != 0 && nregexes != 0) {
                        if (file_s.count == 1) {
                            reset_option(6);
                        }
                        error = file_handler(argv, file_s.first);
                        break;
                    } else if (file_s.count == 0 && nregexes != 0) {
                        error = -1;
                    } else {
                        printf("Usage: s21_grep [OPTION]… template [FILE]…\n");
                        error = 2;
                        break;
                    }
                } else {
                    error = 2;
                    break;
                }
            } else {
                printf("s21_grep: invalid option\n");
                break;
                error = 2;
            }
        }
    }
    return error;
}


void reset_option(int number) {
    int mask = ~(1 << number);
    options &= mask;
}

void set_option(int number) {
    int mask =  1 << number;
    options |= mask;
}

int is_set(int number) {
    int mask =  1 << number;
    int mask_bit = options & mask;
    return mask_bit >> number;
}

int get_options(char **argv) {
    int error = 0, count = 1, check = 0;
    while (argv[count] && !error) {
        if (argv[count][0] == '-') {
            int len = strlen(argv[count]), i = 1;
            for (; i < len; i++) {
                check = choose_option_grep(argv[count][i], count);
                if (check == -1 || check) {
                    if (check == -1)
                        error = 1;
                    break;
                }
            }
            if (!check)
                memset(argv[count], '\0', strlen(argv[count]));
        }
        count++;
    }
    return error;
}

int choose_option_grep(char arg_char, int count) {
    int error = 0;
    if (arg_char == 'e') {
        set_option(0);
        option_args[noption_args++] = count;
        error = 1;
    } else if (arg_char == 'i') {
        set_option(1);
        reflags |= REG_ICASE;
    } else if (arg_char == 'v') {
        set_option(2);
    } else if (arg_char == 'c') {
        set_option(3);
    } else if (arg_char == 'l') {
        set_option(4);
    } else if (arg_char == 'n') {
        set_option(5);
    } else if (arg_char == 'h') {
        reset_option(6);
    } else if (arg_char == 's') {
        reset_option(7);
    } else if (arg_char == 'f') {
        set_option(8);
        option_args[noption_args++] = count;
        error = 1;
     } else if (arg_char == 'o') {
        set_option(9);
     }
    if (!strchr("eivclnhsfo", arg_char))
        error = -1;
    return error;
}

int get_option_args(char **argv) {
    int error = 0;
    for (int i = 0; i < noption_args; i++) {
        char *string = strpbrk(argv[option_args[i]], "ef");
        if (*string == 'e') {
            string++;
            if (*string != '\0') {
                error = regcomp(&regexes[nregexes++], string, reflags);
                memset(argv[option_args[i]], '\0', strlen(argv[option_args[i]]));
            } else if (argv[++option_args[i]]) {
                memset(argv[option_args[i] - 1], '\0', strlen(argv[option_args[i] - 1]));
                error = regcomp(&regexes[nregexes++], argv[option_args[i]], reflags);
                memset(argv[option_args[i]], '\0', strlen(argv[option_args[i]]));
            } else  {
                error = 1;
                printf("s21_grep: ключ должен использоваться с аргументом — «e»\n");
                memset(argv[--option_args[i]], '\0', strlen(argv[--option_args[i]]));
            }
        }
        if (*string == 'f') {
            string++;
            char filename[100];
            filename[0] = '\0';
            FILE *fp;
            if (*string != '\0') {
                strcpy(filename, string);
                memset(argv[option_args[i]], '\0', strlen(argv[option_args[i]]));
            } else if (argv[++option_args[i]]) {
                memset(argv[option_args[i] - 1], '\0', strlen(argv[option_args[i] - 1]));
                strcpy(filename, argv[option_args[i]]);
                memset(argv[option_args[i]], '\0', strlen(argv[option_args[i]]));
            } else  {
                error = 1;
                printf("s21_grep: ключ должен использоваться с аргументом — «f»\n");
                memset(argv[--option_args[i]], '\0', strlen(argv[--option_args[i]]));
            }
            fp = fopen(filename, "r");
            if (fp) {
                char line[2048];
                while (fgets(line, 2048, fp) != NULL) {
                    if (line[strlen(line) - 1] == '\n' && line[strlen(line) - 1] != EOF)
                        line[strlen(line) - 1] = '\0';
                    error = regcomp(&regexes[nregexes++], line, reflags);
                }
                fclose(fp);
            }
        }
    }
    return error;
}


int get_template_string(char **argv) {
    int error = 0;
    int count = 1;
    while (argv[count]) {
        if (argv[count][0] != '\0') {
            error = regcomp(&regexes[nregexes++], argv[count], reflags);
            memset(argv[count], '\0', strlen(argv[count]));
            break;
        }
        count++;
    }
    return error;
}


file_struct get_file_struct(char **argv) {
    file_struct res;
    int error = 0, count = 1;
    while (argv[count] && argv[count][0] == '\0') {
        count++;
    }
    res.first = count;
    res.count = 0;
    while (argv[count] && argv[count][0] != '\0') {
        res.count++, count++;
    }
    return res;
}


int file_handler(char **argv, int number) {
    int error = 0;
    FILE *fp;
    while (argv[number]) {
        if (argv[number][0] != '\0') {
            if ((fp = fopen(argv[number], "r")) != NULL) {
                error = grep_file(fp, argv[number]);
                fclose(fp);
            } else {
                error = 1;
                if (is_set(7))
                    printf("s21_grep: %s: No such file or directory\n", argv[number]);
            }
        }
        number++;
    }
    return error;
}

int grep_file(FILE *fp, char *filename) {
    char print_string[1024];
    int error = 0;
    char line[2048];
    int match_count = 0, line_num = 0, reg_count = 0;
    while (fgets(line, 2048, fp) != NULL) {
        line_num++;
        if (line[strlen(line) - 1] == '\n' && line[strlen(line) - 1] != EOF)
            line[strlen(line) - 1] = '\0';
        for (int i = 0; i < nregexes; i++) {
            error = regexec(&regexes[i], line, 0, NULL, 0);
            if ((error == 0 && !is_set(2)) || (error == REG_NOMATCH && is_set(2))) {
                reg_count++;
                if ((!is_set(2))) {
                    match_count++;
                    break;
                }
            }
        }
        if ((reg_count == nregexes) && is_set(2)) {
            match_count++;
        }
        if (((reg_count == nregexes && is_set(2)) || (!is_set(2) && reg_count)) && !is_set(3) && !is_set(4)) {
            char *new_line = get_temp_line(line, filename, line_num);
            printf("%s\n", new_line);
            free(new_line);
        }
        reg_count = 0;
    }
    print_grep(match_count, filename);
    return 0;
}


char* get_temp_line(char line[], char* filename, int line_num) {
    char *error = (char*)malloc(sizeof(char) * strlen(line) + 200);
    char *temp = (char*)malloc(100 * sizeof(char));
    temp[0] = '\0';
    error[0] = '\0';
    if (is_set(6)) {
        sprintf(temp, "%s:", filename);
    }
    if (is_set(5)) {
        char *tmp = (char*)malloc(20 * sizeof(char));
        sprintf(tmp, "%d:", line_num);
        strcat(temp, tmp);
        free(tmp);
    }
    sprintf(error, "%s", temp);
    strcat(error, line);
    free(temp);
    return error;
}

void print_grep(int match_count, char *filename) {
    if (is_set(3) || is_set(4)) {
        char *print_string = (char*)malloc(100 * sizeof(char));
        print_string[0] = '\0';
        if (is_set(4) && match_count > 0) {
            sprintf(print_string, "%s\n", filename);
        } else {
            if (is_set(6) && !is_set(4)) {
                sprintf(print_string, "%s:", filename);
            }
            if (is_set(3)) {
                char *tmp = (char*)malloc(20 * sizeof(char));
                sprintf(tmp, "%d\n", match_count);
                strcat(print_string, tmp);
                free(tmp);
            }
        }
        printf("%s", print_string);
        free(print_string);
    }
}
