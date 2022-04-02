# Ocaml-Interpreter

An interpreter in Ocaml that reading strings as code and execute by the following grammer and semantics

# Grammer 

#### 1.Constant ####

digit ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 letter ::= a-z | A-Z

int ::= [−] digit { digit }

bool ::= <true> | <false>
  
name ::= letter{letter | digit | _ |  ́}
  
string ::= "{ ASCII \" }"
  
const ::= int | bool | string | name | <unit>

#### 2.Programs ####
  
prog ::= coms
  
com ::= Push const | Pop | Swap | Log
  
| Add | Sub | Mul | Div | Rem | Neg | Cat
  
| And | Or | Not
  
| Eq
  
| Lte | Lt | Gte | Gt | Let
  
| Ask
  
| Begin coms End
  
| If coms Else coms End
  
| DefFun name name coms End | Call
  
| Throw
  
| Try coms Catch coms End
  
coms ::= com ; {com ; }
  
#### 3.Values ####
  
env ::= {name , val ; }
  
val ::= int | bool | string | unit | name | Fun env name name coms End

int values can be as imprecise as machine integers.
  
#### 4.Error Codes ####
  
0 no error
  
1 type error
  
2 too few elements on stack
  
3 div by 0
  
4 var not in scope
  
i user defined error

# Commands #
  
#### 1 Push ####

All const are pushed to the stack in the same way. Resolve the constant to the appropriate value and add it to the stack.

#### 2 Pop ####
  
The command Pop removes the top value from the stack. If the stack is empty, throw an exception with error code 2.
  
#### 3 Log ####
  
The Log command consumes the top value of the stack and adds its string representation to the output list. If the stack is empty, throw an exception with error code 2.

#### 4 Swap ####
  
The command Swap interchanges the top two elements in the stack
  
If there are fewer then 2 values on the stack, throw an exception with error code 2.

#### 5 Add ####
  
Add consumes the top two values in the stack, and pushes their addition to the stack. If there are fewer then 2 values on the stack, throw an exception with error code 2. If two top values in the stack are not integers, throw an exception with error code 1.

####6 Sub ####
  
Sub consumes the top two values in the stack, and pushes their subtraction to the stack. If there are fewer then 2 values on the stack, throw an exception with error code 2. If two top values in the stack are not integers, throw an exception with error code 1.
  
#### 7 Mul ####
  
Mul consumes the top two values in the stack, and pushes their multiplication to the stack. If there are fewer then 2 values on the stack, throw an exception with error code 2.
  
If two top values in the stack are not integers, throw an exception with error code 1.

#### 8 Div ####
  
Div consumes the top two values in the stack, and pushes their division to the stack.
  
If there are fewer then 2 values on the stack, throw an exception with error code 2. If two top values in the stack are not integers, throw an exception with error code 1. If the 2nd value of the stack is 0, throw an exception with error code 3.

#### 9 Rem ####
  
Rem consumes the top two values in the stack, and pushes their mod to the stack. Rem mimicks OCaml’s mod for dealing with negative behaviour.
  
If there are fewer then 2 values on the stack, throw an exception with error code 2. If two top values in the stack are not integers, throw an exception with error code 1. If the 2nd value of the stack is 0, throw an exception with error code 3.
  

#### 10 Neg ####
Neg consumes the top value of the stack, x, and pushes -x to the stack.
  
If stack is empty, throw an exception with error code 2.
  
If the top value on the stack is not an integer, throw an exception with error code 1.
  
#### 11 Cat ####
  
Cat consumes the top two values in the stack and if they are strings pushes a new string to the stack that appends the 2 strings together.
  
If there are fewer then 2 values on the stack, exit immediately with error code 2.
  
If the two top values in the stack are not strings, exit immediately with error code 1.
  
#### 12 And ####
  
And consumes the top two values in the stack, and pushes their conjunction to the stack.
  
If there are fewer then 2 values on the stack, throw an exception with error code 2.
  
If the two top values in the stack are not booleans, throw an exception with error code 1.
  
  
#### 13 Or ####
  
Or consumes the top two values in the stack, and pushes their disjunction to the stack.
  
If there are fewer then 2 values on the stack, throw an exception with error code 2.
  
If the two top values in the stack are not booleans, throw an exception with error code 1.
  
#### 14 Not ####
  
Not consumes the top value of the stack, and pushes it’s negation to the stack.
  
If the stack is empty, throw an exception with error code 2.
  
If the top value on the stack is not an boolean, throw an exception with error code 1.
  

#### 15 Eq ####

Eq consumes the top two values in the stack, and pushes true to the stack if they are equal integers and false if they are not equal integers.
  
If there are fewer then 2 values on the stack, throw an exception with error code 2.
  
If the two top values in the stack are not integers, throw an exception with error code 1. 
  
#### 16 Lte, Lt, Gte, Gt ####
  
Lt consumes the top two values in the stack, and pushes true on the stack if the top value is less then the bottom value
  
If there are fewer then 2 values on the stack, throw an exception with error code 2.
  
If the two top values in the stack are not integers, throw an exception with error code 1.

#### 17 Let ####

Let consumes a name and a value from the top of the stack, and associates the name with that value until the end of the scope.
  
If there are fewer then 2 values on the stack, throw an exception with error code 2. If the top value in the stack is not a name, throw an exception with error code 1.
   
#### 18 Ask ####
  
Ask consumes a name from the top of the stack and returns the associated value.
  
If the stack is empty, throw an exception with error code 2.
  
If the top value on the stack is not a name, throw an exception with error code 1. 
  
#### 19 Begin...End ####
  
A sequence of commands in a begin end block will be executed on a new empty stack with a copy of the current binding environment. When the commands finish, the top value from the stack will be pushed to the outer stack, and new bindings disregarded.
  
If stack is empty, throw an exception with error code 2.

#### 20 If...Else...End ####
  
The IfElse command will consume the top element of the stack. If that element is true it will execute the commands in the first branch, if false it will execute the commands in the else branch.
  
If stack is empty, throw an exception with error code 2.
  
If the top value on the stack is not a Boolean, throw an exception with error code 1. 
  
#Function declarations#

#### 1 Call ####
  
The Call command tries to consume an argument value and a function. Then it executes the commands in the function body in a fresh stack using the original environment with the function bound to fname and the value bound to the originally defined arg name, when the commands of the function are finished the top element is pushed to the calling stack.
  
If there are fewer then 2 values on the stack, throw an exception with error code 2.
  
If 2nd value on the stack is not a function, throw an exception with error code 1.
  
If after the function is finished running its stack is empty, throw an exception with error code 1.

#### 2 Throw ####
  
The throw command tries to read an integer off of the top of the stack. Then immediately throws an exception of that error code.
  
If stack is empty, immediately throw error code 2.
  
If the top value on the stack is not an integer, immediately throw error code 1. 
  
#### 3 TryCatch ####
  
Both user defined and built in errors can be recovered from with the TryCatch construct.
  
If no errors are thrown in the TryCatch construct then execution happens as normal, and the catch branch
is ignored.
  
If an exception is thrown from a command executed in a try catch block the catch commands are run with
the the original environment, and original stack with the error code pushed to the top. 
 
