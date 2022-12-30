#!/bin/bash
flags="ivclnhs"
flags_arg="ef"
test_count=0
search_str_priv='privet'
search_str_nomatch='school'
search_string_lera='lera'
num_test=1
# 1. Флаги по одному без флагов с аргументами
for (( i=1; i<${#flags}; i++ ));
do
    grep -"${flags:$i:1}" privet test.txt >> original.txt
    ./s21_grep -"${flags:$i:1}" privet test.txt >> my.txt
    result=$(diff original.txt my.txt)
    if [ $? -eq 1 ]
    then
        echo "ERROR occured with flags ${flags:$i:1} in test $num_test"
    else
        test_count=$(( test_count + 1 ))
    fi
    rm original.txt my.txt
done


# 2. Добавление на каждой итерации одного флага без аргумента(один файл)
num_test=$(( num_test + 1 ))
flags_to_test="ivcnhs"
for (( i=1; i<${#flags_to_test}; i++ )); do
    current_flags=${flags_to_test:0:$i}
    grep -$current_flags privet test.txt >> original.txt
    ./s21_grep -$current_flags privet test.txt >> my.txt
    result=$(diff original.txt my.txt)
    if [ $? -eq 1 ]
    then
        echo "ERROR occured with flags $current_flags in test $num_test"
    else
        test_count=$(( test_count + 1 ))
    fi
    rm original.txt my.txt
done


# 3. Добавление на каждой итерации одного флага без аргумента(два файла)
num_test=$(( num_test + 1 ))
flags_to_test="ivlnhs"
for (( i=1; i<${#flags_to_test}; i++ )); do
    current_flags=${flags_to_test:0:$i}
    grep -$current_flags privet test.txt template.txt >> original.txt
    ./s21_grep -$current_flags privet test.txt template.txt >> my.txt
    result=$(diff original.txt my.txt)
    if [ $? -eq 1 ]
    then
        echo "ERROR occured with flags $current_flags in test $num_test"
    else
        test_count=$(( test_count + 1 ))
    fi
    rm original.txt my.txt
done

# 4. Комбинации флагов без аргументов 
num_test=$(( num_test + 1 ))
flags_to_test="ivlnhs"
for (( i=1; i<5; i++ )); do
    rand1=$[$RANDOM % ${#flags_to_test}]
    sym=${flags_to_test:$rand1:1}
    for (( j=1; j<5; j++ )); do
        rand2=$[$RANDOM % ${#flags_to_test}]
        string=${flags_to_test:0:$rand2}
        current_flags="${sym}${string}"
        grep -$current_flags privet test.txt template.txt >> original.txt
        ./s21_grep -$current_flags privet test.txt template.txt >> my.txt
        result=$(diff original.txt my.txt)
        if [ $? -eq 1 ]
        then
            echo "ERROR occured with flags $current_flags in test $num_test"
        else
            test_count=$(( test_count + 1 ))
        fi
        rm original.txt my.txt
    done
done

# 5. Комбинации флагов без аргументов 
num_test=$(( num_test + 1 ))
flags_to_test="ivcnhs"
for (( i=1; i<5; i++ )); do
    rand1=$[$RANDOM % ${#flags_to_test}]
    sym=${flags_to_test:$rand1:1}
    for (( j=1; j<5; j++ )); do
        rand2=$[$RANDOM % ${#flags_to_test}]
        string=${flags_to_test:0:$rand2}
        current_flags="${sym}${string}"
        grep -$current_flags privet test.txt template.txt >> original.txt
        ./s21_grep -$current_flags privet test.txt template.txt >> my.txt
        result=$(diff original.txt my.txt)
        if [ $? -eq 1 ]
        then
            echo "ERROR occured with flags $current_flags in test $num_test"
        else
            test_count=$(( test_count + 1 ))
        fi
        rm original.txt my.txt
    done
done


# 6. Комбинации для флага -e c одним аргументом (-epriv)
num_test=$(( num_test + 1 ))
flags_to_test="ivcnhs"
for (( i=1; i<5; i++ )); do
    rand1=$[$RANDOM % ${#flags_to_test}]
    sym=${flags_to_test:$rand1:1}
    for (( j=1; j<5; j++ )); do
        rand2=$[$RANDOM % ${#flags_to_test}]
        string=${flags_to_test:0:$rand2}
        current_flags="${sym}${string}"
        grep -$current_flags "-e$search_str_priv" test.txt template.txt >> original.txt
        ./s21_grep -$current_flags "-e$search_str_priv" test.txt template.txt >> my.txt
        result=$(diff original.txt my.txt)
        if [ $? -eq 1 ]
        then
            echo "ERROR occured with flags $current_flags in test $num_test"
        else
            test_count=$(( test_count + 1 ))
        fi
        rm original.txt my.txt
    done
done


# 5. Комбинации для флага -e c двумя аргументами (-e priv lera)
num_test=$(( num_test + 1 ))
flags_to_test="ivlnhs"
for (( i=1; i<5; i++ )); do
    rand1=$[$RANDOM % ${#flags_to_test}]
    sym=${flags_to_test:$rand1:1}
    for (( j=1; j<5; j++ )); do
        rand2=$[$RANDOM % ${#flags_to_test}]
        string=${flags_to_test:0:$rand2}
        current_flags="${sym}${string}"
        grep -$current_flags "-e $search_str_priv" -e$search_string_lera test.txt template.txt >> original.txt
        ./s21_grep -$current_flags "-e $search_str_priv" -e$search_string_lera test.txt template.txt >> my.txt
        result=$(diff original.txt my.txt)
        if [ $? -eq 1 ]
        then
            echo "ERROR occured with flags $current_flags in test $num_test"
        else
            test_count=$(( test_count + 1 ))
        fi
        rm original.txt my.txt
    done
done


# 8. Комбинации для флага -e c одним(no match)
num_test=$(( num_test + 1 ))
flags_to_test="ivcnhs"
for (( i=1; i<5; i++ )); do
    rand1=$[$RANDOM % ${#flags_to_test}]
    sym=${flags_to_test:$rand1:1}
    for (( j=1; j<5; j++ )); do
        rand2=$[$RANDOM % ${#flags_to_test}]
        string=${flags_to_test:0:$rand2}
        current_flags="${sym}${string}"
        grep -$current_flags "-e $search_string_nomatch" test.txt template.txt >> original.txt
        ./s21_grep -$current_flags "-e $search_string_nomatch" test.txt template.txt >> my.txt
        result=$(diff original.txt my.txt)
        if [ $? -eq 1 ]
        then
            echo "ERROR occured with flags $current_flags in test $num_test"
        else
            test_count=$(( test_count + 1 ))
        fi
        rm original.txt my.txt
    done
done

# 9. Комбинации для флага -e и -f
num_test=$(( num_test + 1 ))
flags_to_test="ivcnhs"
for (( i=1; i<5; i++ )); do
    rand1=$[$RANDOM % ${#flags_to_test}]
    sym=${flags_to_test:$rand1:1}
    for (( j=1; j<5; j++ )); do
        rand2=$[$RANDOM % ${#flags_to_test}]
        string=${flags_to_test:0:$rand2}
        current_flags="${sym}${string}"
        grep -$current_flags "-e privet" test.txt -f template.txt >> original.txt
        ./s21_grep -$current_flags "-e privet" test.txt -f template.txt >> my.txt
        result=$(diff original.txt my.txt)
        if [ $? -eq 1 ]
        then
            echo "ERROR occured with flags $current_flags in test $num_test"
        else
            test_count=$(( test_count + 1 ))
        fi
        rm original.txt my.txt
    done
done


# 10. Тест регулярных выражений
num_test=$(( num_test + 1 ))
grep -n "-e [^p]" test.txt -f template.txt >> original.txt
./s21_grep -n "-e [^p]" test.txt -f template.txt >> my.txt
result=$(diff original.txt my.txt)
if [ $? -eq 1 ]
then
    echo "ERROR occured with flags $current_flags in test $num_test"
else
    test_count=$(( test_count + 1 ))
fi
rm original.txt my.txt


num_test=$(( num_test + 1 ))
grep -n "-e [.u]" test.txt >> original.txt
./s21_grep -n "-e [.u]" test.txt >> my.txt
result=$(diff original.txt my.txt)
if [ $? -eq 1 ]
then
    echo "ERROR occured with flags $current_flags in test $num_test"
else
    test_count=$(( test_count + 1 ))
fi
rm original.txt my.txt

echo "Success tests $test_count"