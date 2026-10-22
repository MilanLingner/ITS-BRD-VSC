/**
 ******************************************************************************
 * @file    main.c
 * @author  Franz Korf
 * @brief   Kleines Testprogramm fuer neu erstelle Fonts.
 ******************************************************************************
 */
/* Includes ------------------------------------------------------------------*/

#include "exception.h"
#include "scanner.h"
#include "display.h"
#include "keypad.h"
#include "token.h"
#include "stack.h"
#include "functions.h"




int main(void) {
   init_display();
   makeKeyPad();
   while (true) {
      T_token ein = next_token();
      switch(ein.tok) {
         case NUMBER:
            if(push()){
               return OVERFLOW;
            }
            break;
         case PLUS:
            if(plus()){
               return UNDERFLOW;
            }
            break;       
         case MINUS:  
            if(minus()){
               return UNDERFLOW;
            }
            break;    
         case MULT:  
            if(mult()){
               return UNDERFLOW;
            }
            break;     
         case DIV:  
            if(div()){
               return UNDERFLOW;
            }
            break;
         case PRT:
            if(print()){
               return UNDERFLOW;
            }
            print();
            break;
         case SWAP:
            if(swap()){
               return UNDERFLOW;
            }
            swap();
            break;
         case PRT_ALL:
            if(print_all()){
               return UNDERFLOW;
            }
            break;
         case CLEAR:
            clear();
            break;
         case DOUBLE:
            if(div()){
               return OVERFLOW;
            }
            doppeln();
            break;
         case UNEXPECTED:
            unexpected();
            break;
         case OVERFLOW:
            overflow();
            break;
         default:
            continue;
      }
   }
}

// EOF
