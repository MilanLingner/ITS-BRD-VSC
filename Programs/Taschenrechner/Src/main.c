/**
 ******************************************************************************
 * @file    main.c
 * @author  Franz Korf
 * @brief   Kleines Testprogramm fuer neu erstelle Fonts.
 ******************************************************************************
 */
/* Includes ------------------------------------------------------------------*/

#include "scanner.h"
#include "display.h"
#include "keypad.h"
#include "token.h"
#include "stack.h"
#include "scanner.h"



int main(void) {
   init_display();
   make_keypad();
   while (true) {
      T_token ein = nextToken();
      switch(ein.tok) {
         case NUMBER:
            ifpush();
         case PLUS:
            plus();
            break;       
         case MINUS:  
            minus();
            break;    
         case MULT:  
            mult();
            break;     
         case DIV:  
            div();
            break;
         case PRT:
            print();
            break;
         case SWAP:
            swap();
            break;
         case PRT_ALL:
            printAll();
            break;
         case CLEAR:
            clear();
            break;
         case DOUBLE:
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
