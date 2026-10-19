/**
 * @file token.h
 * @author Franz Korf, HAW Hamburg
 * @date Mar 2016
 * @brief This file stores all token returned by the scanner.
 */

#ifndef EXC_H
#define EXC_H

#define STACK_OVERFLOW_EXCEPTION 1     //!< Token for an int number
#define STACK_UNDERFLOW_EXCEPTION 2       //!< Token for + operator
#define INT_OVERFLOW_EXCEPTION   3  //!< Token for - operator

#endif