#!/bin/bash
flags="benst"
test_count=0
num_test=1
# 1. Флаги по одному без флагов с аргументами
for (( i=1; i<${#flags}; i++ ));
do
    cat -"${flags:$i:1}" test.txt >> original.txt
    ./s21_cat -"${flags:$i:1}"  test.txt >> my.txt
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
flags_to_test="benst"
for (( i=1; i<${#flags_to_test}; i++ )); do
    current_flags=${flags_to_test:0:$i}
    cat -$current_flags test.txt >> original.txt
    ./s21_cat -$current_flags test.txt >> my.txt
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
flags_to_test="benst"
for (( i=1; i<${#flags_to_test}; i++ )); do
    current_flags=${flags_to_test:0:$i}
    cat -$current_flags test.txt template.txt >> original.txt
    ./s21_cat -$current_flags test.txt template.txt >> my.txt
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
flags_to_test="benst"
for (( i=1; i<8; i++ )); do
    rand1=$[$RANDOM % ${#flags_to_test}]
    sym=${flags_to_test:$rand1:1}
    for (( j=1; j<8; j++ )); do
        rand2=$[$RANDOM % ${#flags_to_test}]
        string=${flags_to_test:0:$rand2}
        current_flags="${sym}${string}"
        cat -$current_flags  test.txt template.txt >> original.txt
        ./s21_cat -$current_flags  test.txt template.txt >> my.txt
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

# 5. GNU options тест
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    num_test=$(( num_test + 1 ))
    flags=("number" "squeeze-blank" "number-nonblank")
    for str in ${flags[@]}; do
        cat --$str test.txt >> original.txt
        ./s21_cat --$str test.txt >> my.txt
        result=$(diff original.txt my.txt)
        if [ $? -eq 1 ]
        then
            echo "ERROR occured with flags $str in test $num_test"
        else
            test_count=$(( test_count + 1 ))
        fi
        rm original.txt my.txt
    done
fi

# 6. Комбинация GNU options
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    num_test=$(( num_test + 1 ))
    flags=("squeeze-blank" "number-nonblank")
    for i in "${!flags[@]}"; do
        str=${flags[$i]}
        cat --$str "--number" test.txt >> original.txt
        ./s21_cat --$str "--number" test.txt >> my.txt
        result=$(diff original.txt my.txt)
        if [ $? -eq 1 ]
        then
            echo "ERROR occured with flags $str in test $num_test"
        else
            test_count=$(( test_count + 1 ))
        fi
        rm original.txt my.txt
    done
    cat --squeeze-blank --number --number-nonblank test.txt >> original.txt
    ./s21_cat --squeeze-blank --number --number-nonblank test.txt >> my.txt
    result=$(diff original.txt my.txt)
    if [ $? -eq 1 ]
    then
        echo "ERROR occured with flags $str in test $num_test"
    else
        test_count=$(( test_count + 1 ))
    fi
    rm original.txt my.txt
fi

# 7. Комбинация GNU и обычных опций по одному
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    num_test=$(( num_test + 1 ))
    gnu=("number" "squeeze-blank" "number-nonblank")
    flags="benst"
    for (( i=1; i<20; i++ )); do
        rand1=$[$RANDOM % ${#flags}]
        rand2=$[$RANDOM % ${#gnu[@]}]
        sym=${flags:$rand1:1}
        string=${gnu[$rand2]}
        #echo "sym $sym string $string"
        cat -$sym --$string test.txt template.txt >> original.txt
        ./s21_cat -$sym --$string test.txt template.txt >> my.txt
        result=$(diff original.txt my.txt)
        if [ $? -eq 1 ]
        then
            echo "ERROR occured with flags $sym and gnu $string in test $num_test"
        else
            test_count=$(( test_count + 1 ))
        fi
        rm original.txt my.txt
    done
fi

# 8. Комбинация GNU и обычных опций
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    num_test=$(( num_test + 1 ))
    gnu=("number" "squeeze-blank" "number-nonblank")
    flags="benst"
    for (( i=1; i<6; i++ )); do
        rand1=$[$RANDOM % ${#gnu[@]}]
        for (( j=1; j<6; j++ )); do
            rand2=$[$RANDOM % ${#flags}]
            gnu=${gnu[$rand1]}
            current_flags=${flags:0:$rand2 + 1}
            #echo "GNU $gnu flags $current_flags"
            cat -$current_flags --$gnu test.txt template.txt >> original.txt
            ./s21_cat -$current_flags --$gnu test.txt template.txt >> my.txt
            result=$(diff original.txt my.txt)
            if [ $? -eq 1 ]
            then
                echo "ERROR occured with flags $current_flags and gnu $gnu in test $num_test"
            else
                test_count=$(( test_count + 1 ))
            fi
            rm original.txt my.txt
        done
    done
fi

# 9. Комбинация GNU и обычных опций 2
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    num_test=$(( num_test + 1 ))
    gnu=("number" "squeeze-blank" "number-nonblank")
    flags="bEnsT"
    for (( i=1; i<6; i++ )); do
        rand1=$[$RANDOM % ${#gnu[@]}]
        for (( j=1; j<6; j++ )); do
            rand2=$[$RANDOM % ${#flags}]
            gnu=${gnu[$rand1]}
            current_flags=${flags:0:$rand2 + 1}
            #echo "GNU $gnu flags $current_flags"
            cat -$current_flags --$gnu test.txt template.txt >> original.txt
            ./s21_cat -$current_flags --$gnu test.txt template.txt >> my.txt
            result=$(diff original.txt my.txt)
            if [ $? -eq 1 ]
            then
                echo "ERROR occured with flags $current_flags and gnu $gnu in test $num_test"
            else
                test_count=$(( test_count + 1 ))
            fi
            rm original.txt my.txt
        done
    done
fi


echo "Success tests $test_count"