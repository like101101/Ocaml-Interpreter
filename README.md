# Ocaml-Interpreter

An interpreter in Ocaml that reading strings as code and execute by the following grammer and semantics

# Grammer 
1 Constants

digit ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 letter ::= a-z | A-Z

int ::= [−] digit { digit }

bool ::= <true> | <false>
  
name ::= letter{letter | digit | _ |  ́}
  
string ::= "{ ASCII \" }"
  
const ::= int | bool | string | name | <unit>

2 Programs
  
prog ::= coms
  
com ::= Push const | Pop | Swap | Log
  
| Add | Sub | Mul | Div | Rem | Neg coms ::= com ; {com ; }
  
3 Values
  
val ::= int | bool | string | unit
  
4 Error Codes
  
For part 1 you will need to support the following error codes
  
0 1 2 3
  
no error
  
type error
  
too few elements on stack div by 0
  
For this part, throwing an exception results in the program exiting immediately with with the given error code.


