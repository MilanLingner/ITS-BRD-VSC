/**
 * @file functions.c
 * @author Milan Lingner, HAW Hamburg
 * @date Oct 2016
 *
 * @brief This module implements basic arithmetic functions with a stack.
 */

#include "display.h"
#include "exception.h"
#include "keypad.h"
#include "token.h"
#include "stack.h"
#include "exceptions.h"
#include "scanner.h"



int plus(){
    if(getPointer() < 2){
        return UNDERFLOW;
    }
    int first = pop();
    int second = pop();
    int erg = first + second;
    return push(erg);
}

int minus(){
    if(getPointer() < 2){
        return UNDERFLOW;
    }
    int first = pop();
    int second = pop();
    int erg = second - first;
    return push(erg);
}

int mult(){
    if(getPointer() < 2){
        return UNDERFLOW;
    }
    int first = pop();
    int second = pop();
    int erg = second * first;
    return push(erg);
}

int div(){
    if(getPointer() < 2){
        return UNDERFLOW;
    }
    int first = pop();
    int second = pop();
    int erg = second / first;
    return push(erg);
}

int print(){
    if(getPointer() < 0){
        return UNDERFLOW;
    }
    print_stdout((char* )&getItem(getPointer()));
    return 0;
}

int printAll(){
    if(getPointer() < 2){
        return UNDERFLOW;
    }
    for(int i = 0; i < 3; i++){
        print_stdout((char*)&getItem(getPointer())-i);
    }
    return 0;
}
int swap(){
    int first = pop();
    int second = pop();
    int a = 0;
    if(a = push(second)){
        return  push(first);
    }
    return 
}
int clear(){
    clear_stack();
}

