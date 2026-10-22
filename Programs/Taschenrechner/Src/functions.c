/**
 * @file functions.c
 * @author Milan Lingner, HAW Hamburg
 * @date Oct 2016
 *
 * @brief This module implements basic arithmetic functions with a stack.
 */

#include "scanner.h"
#include "display.h"
#include "keypad.h"
#include "token.h"
#include "stack.h"
#include "exceptions.h"

int plus(){
    if(getPointer() < 2){
        return STACK_UNDERFLOW_EXCEPTION;
    }
    int first = pop();
    int second = pop();
    int erg = first + second;
    return push(erg);
}

int minus(){
    if(getPointer() < 2){
        return STACK_UNDERFLOW_EXCEPTION;
    }
    int first = pop();
    int second = pop();
    int erg = second - first;
    return push(erg);
}

int mult(){
    if(getPointer() < 2){
        return STACK_UNDERFLOW_EXCEPTION;
    }
    int first = pop();
    int second = pop();
    int erg = second * first;
    return push(erg);
}

int div(){
    if(getPointer() < 2){
        return STACK_UNDERFLOW_EXCEPTION;
    }
    int first = pop();
    int second = pop();
    int erg = second / first;
    return push(erg);
}

int print(){
    if(getPointer() < 0){
        return STACK_UNDERFLOW_EXCEPTION;
    }
    print_stdout(char *getItem(getPointer()));
    return 0;
}

int printAll(){
    if(getPointer() < 2){
        return STACK_UNDERFLOW_EXCEPTION;
    }
    
    for(int i = 0; i < 3; i++){

    }
    print_stdout(char *erg);
    return 0;
}
int swap(){
    int first = pop();
    int second = pop();
    int a = 0;
    if(int a = push(second)){
        return  push(first);
    }
    return 
}
int clear(){
    clear_stack();
}

