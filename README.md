# OSU CS271 Portfolio Project Spring 2023

Introduction
============

This program, as the portfolio project for the class, represents the ultimate step up in complexity. 

This assignment aims to reinforce concepts related to string primitive instructions and macros such as:
- Designing, implementing, and invoking low-level I/O procedures
- Implementing and utilizing macros

What You Must Do
----------------

### Program Description

You are tasked with writing and testing a MASM program to carry out the following tasks (refer to the Requirements section for specifics on program modularization):

- Implement and test two macros for string processing. Utilize Irvine’s `ReadString` for user input and `WriteString` procedures for output display. The macros include:
    - `mGetString`: Display a prompt (input parameter, by reference), obtain the user’s keyboard input (output parameter, by reference). You may need to provide a count (input parameter, by value) for the length of the input string you can accommodate and a number of bytes read (output parameter, by reference) by the macro.
    - `mDisplayString`: Print the string stored in a specified memory location (input parameter, by reference).
- Implement and test two procedures for signed integers using string primitive instructions. The procedures are:
    - `ReadVal`: Use the `mGetString` macro to get user input in a string of digits, convert the string of ascii digits to its numeric value representation (SDWORD), validate the user's input, and store the value in a memory variable (output parameter, by reference).
    - `WriteVal`: Convert a numeric SDWORD value (input parameter, by value) to a string of ASCII digits and use the `mDisplayString` macro to print the ASCII representation of the SDWORD value.
- Write a test program in `main` which uses the `ReadVal` and `WriteVal` procedures to:
    - Obtain 10 valid integers from the user using `ReadVal` within a loop in `main`. Do not implement your counted loop within `ReadVal`.
    - Store these numeric values in an array.
    - Display the integers, their sum, and their truncated average.

### Program Requirements

The user's numeric input must be validated the hard way:

- Read the user's input as a string and convert the string to numeric form.
- If the user enters non-digits or anything other than signs (e.g. '+', '-'), or if the number exceeds the 32-bit register limit, display an error message and discard the number.
- If the user enters nothing (empty input), display an error and re-prompt.
- The functions `ReadInt`, `ReadDec`, `WriteInt`, and `WriteDec` are not allowed.
- `mDisplayString` must be used to display all strings.
- Conversion routines must use the LODSB and/or STOSB operators to deal with strings.
- All procedure parameters must be passed on the runtime stack using the STDCall calling convention. Strings must also be passed by reference.
- Prompts, identifying strings, and other memory locations must be passed by address to the macros.
- Registers used must be saved and restored by the called procedures and macros.
- The stack frame must be cleaned up by the called procedure.
- Procedures (except `main`) must not reference data segment variables by name. Violating this rule incurs a significant penalty. Some global constants (defined using EQU, =, or TEXTEQU and not redefined) are allowed.
- The program must use Register Indirect addressing or string primitives (e.g. STOSD) for integer (SDWORD) array elements, and Base+Offset addressing for accessing parameters on the runtime stack.
- Procedures may use local variables when appropriate.

### Notes

- You can assume that the total sum of the valid numbers will fit inside a 32-bit register for this assignment.
- The program will be tested with positive and negative values.
- When displaying the average, only display the integer part, i.e., drop/truncate any fractional part.

### Example Execution

User input in this example is in **bold**.

```shell
PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures 
Written by: Sheperd Cooper 
 
Please provide 10 signed decimal integers.  
Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value. 
 
Please enter an signed number: 156
Please enter an signed number: 51d6fd 
ERROR: You did not enter a signed number or your number was too big. 
Please try again: 34
Please enter a signed number: -186
Please enter a signed number: 115616148561615630 
ERROR: You did not enter a signed number or your number was too big. 
Please try again: -145
Please enter a signed number: 16
Please enter a signed number: +23
Please enter a signed number: 51 
Please enter a signed number: 0 
Please enter a signed number: 56
Please enter a signed number: 11 
 
You entered the following numbers: 
156, 34, -186, -145, 16, 23, 51, 0, 56, 11 
The sum of these numbers is: 16 
The truncated average is: 1 
 
Thanks for playing! 

```

