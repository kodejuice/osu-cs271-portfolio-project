TITLE Designing low-level I/O procedures        (Proj6_biereags.asm)
; Author: Sochima Biereagu
; Last Modified: 10/06/2023
; OSU email address: biereags@oregonstate.edu
; Course number/section: CS 271 Section 400
; Project Number: 6          Due Date: 11/06/2023
; Description: This program allows a user to input a list of signed integers (positive or negative whole numbers),
;  performs a summation and average calculation on these numbers, and displays these results to the user.

INCLUDE Irvine32.INC

; Constants
MAX_SIZE        EQU 32
ARRAY_SIZE      EQU 10
MAX_NUM         EQU 2147483647

.data
    introStr    BYTE "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 10,
            "Written by: Sheperd Cooper", 10, 10,
            "Please provide 10 signed decimal integers.",10,
            "Each number needs to be small enough to fit inside a 32 bit register.",
            " After you have finished inputting the raw numbers I will display",
            " a list of the integers, their sum, and their average value.", 10, 10, 0
    inputVal                SDWORD ?
    numberArray             SDWORD ARRAY_SIZE dup(0)
    totalSum                SDWORD 0
    inputPrompt             BYTE "Please enter a signed number: ", 0
    errorMsgPrompt          BYTE "ERROR: You did not enter a signed number or your number was too big.", 10, "Please try again: ", 0
    displayNumbersPrompt    BYTE 10, "You entered the following numbers: ", 10, 0
    displaySumPrompt        BYTE "The sum of these numbers is: ", 0
    displayAvgPrompt        BYTE "The truncated average is: ", 0
    thanksPrompt            BYTE 10, 10, "Thanks for playing! ", 0
    comma                   BYTE ", ", 0
	newline 				BYTE 10, 0

; mDisplayString: Macro to print a string to the console
mDisplayString MACRO str
    PUSH EDX
    MOV     EDX, str ; move address of string to EDX
    CALL    WriteString     ; call WriteString to print the string
    POP EDX
ENDM

; mGetString: Macro to read a string from user
mGetString MACRO prompt, str, len
    PUSH EDX
    PUSH EAX
    MOV     EDX, prompt     ; move address of prompt to EDX
    CALL    WriteString     ; call WriteString to print the prompt
    MOV     EDX, str        ; move address of string to EDX
    MOV     ECX, MAX_SIZE   ; move size to ECX
    CALL    ReadString      ; call ReadString to get input from the user
    MOV     len, EAX        ; move the length of the string to len
    POP EAX
    POP EDX
ENDM


.code

; --------------------------------------------------------
; ReadVal: Procedure to get input from user and validate it
; The procedure prompts the user for input, checks if it's a 
; valid signed number, and if not, displays an error message and reprompts.
; The result is then stored in memory.
; 
; Preconditions: Arguments must be placed on stack
; Postconditions: The number from the user is stored in memory
; 
; Arguments:
; [EBP+16]: input prompt
; [EBP+12]: error message prompt
; [EBP+8]: inputVal address
; 
; Returns: None
; --------------------------------------------------------
ReadVal PROC
    LOCAL    inputString[MAX_SIZE]:BYTE

    ; Preserve registers
    PUSHAD

    MOV     EBX, [EBP+16]		; input prompt
    MOV     EDX, [EBP+12]		; error message prompt
    MOV     EDI, [EBP+8]		; inputVal address
    LEA		ESI, inputString	; input string array

GetInput:
    ; Use the mGetString macro to get input from the user
    mGetString  EBX, ESI, ECX
    JMP         ConvertString

GetInputAfterError:
    ; Use mGetString macro to get input from the user when previous input is invalid
    mGetString  EDX, ESI, ECX

ConvertString:
    PUSH ESI
    PUSH ECX
    CALL    atoi    ; convert string to number
                    ; result stored in EBX
                    ; if error occured, EAX is set to 1
    CMP     EAX, 1
    JE      GetInputAfterError

    MOV     [EDI], EBX  ; move converted number to memory

    POPAD
    RET 12 ; Return
ReadVal ENDP


; --------------------------------------------------------
; atoi: Procedure to convert ascii input to integer 
; This procedure takes a string and its length as arguments and converts the string to an integer.
; It returns the integer value in EBX.
; If there is an error during conversion (for example, if the string contains non-numeric characters),
; the procedure sets EAX to 1. If the string starts with '-' the result will be negated, '+' is just skipped.
;
; Preconditions: Arguments must be placed on stack
; Postconditions: none
;
; Arguments:
; [EBP+12+12]: start of string
; [EBP+8+12]: length of string
; 
; Returns: EAX, EBX
; --------------------------------------------------------
atoi PROC USES EDX ESI ECX
    PUSH EBP
    MOV  EBP, ESP

    MOV     ESI, [EBP+12+12]   ; start of string
    MOV     ECX, [EBP+8+12]    ; length of string

    MOV     EDX, 1          ; negative multiplier
    XOR     EAX, EAX        ; error indicator
    XOR     EBX, EBX        ; result

    ; check signs
checkSigns:
    LODSB
    CMP     AL, 0           ; if end of string, exit
    JE      atoi_done
    CMP     AL, '-'
    JNE     notNegative
    NEG     EDX             ; negate multiplier
    JMP     atoi_loop
notNegative:
    CMP     AL, '+'
    JE      atoi_loop        ; if positive sign, skip
    JNE     convert_digit   ; probably a digit, try converting

atoi_loop:
    LODSB
    CMP     AL, 0           ; if end of string, exit
    JE      atoi_done

convert_digit:
    ; check if it's a digit
    CMP     AL, '0'
    JB      atoi_error
    CMP     AL, '9'
    JA      atoi_error

    ; convert ascii to integer
    SUB     AL, '0'
    IMUL    EBX, 10
    ADD     EBX, EAX

    ; check if number is within bounds
    CMP     EBX, MAX_NUM
    JA      atoi_error

    LOOP    atoi_loop
    JMP     atoi_done

atoi_error:
    MOV     EAX, 1      ; indicate error
    JMP     atoi_exit

atoi_done:
	IMUL    EBX, EDX    ; muliplier
    MOV     EAX, 0      ; no error

atoi_exit:
    POP EBP
    RET 8       ; Return
atoi ENDP


; --------------------------------------------------------
; WriteVal: Procedure for converting integer to string and displaying it
; This procedure takes an integer and the address of a string as arguments. 
; It then converts the integer to a string and displays it to the user.
;
; Preconditions: address of display string placed on stack
; Postconditions: none
;
; Arguments:
; [EBP + 12]: the number
; [EBP + 8]: address of display string
; 
; Returns: None
; --------------------------------------------------------
WriteVal PROC
    LOCAL    numberString[MAX_SIZE]:BYTE
    PUSHAD

    ; get parameters from stack
    MOV     EAX, [EBP + 8] ; the number
    LEA     EDI, numberString

    PUSH    EAX
    PUSH    EDI
    ; convert integer to string
    CALL    itoa

    ; display the string
    mDisplayString EDI

    POPAD
    RET 4
WriteVal ENDP


; --------------------------------------------------------
; itoa: Procedure to convert integer to ascii string
; This procedure takes an integer and the address of a string as arguments and converts the integer into an ASCII string.
; If the integer is negative, it converts the absolute value of the integer to a string and adds a negative sign to the front.
;
; Preconditions: Arguments must be placed on stack
; Postconditions: none
;
; Arguments:
; [EBP + 12]: the number
; [EBP + 8]: address of display string
;
; Returns: none
; --------------------------------------------------------
itoa PROC
    LOCAL    isNegative:WORD
    PUSHAD

    ; get parameters from stack
    MOV     EAX, [EBP + 12] ; the number
    MOV     ESI, [EBP + 8]  ; address of display string
    MOV     EDI, ESI  		; copy of string address

    ; convert integer to ascii
    MOV     EBX, 10             ; base 10
    ADD     ESI, 11             ; move to end of string
    MOV     BYTE PTR [ESI], 0   ; null terminator
    MOV     isNegative, 0		; false (initially)

    ; check if number is negative
    CMP     EAX, 0
    JL      negative
    JGE     itoa_loop

negative:
    ; if negative, set isNegative and negate number
    MOV     isNegative, 1
    NEG     EAX

itoa_loop:
    XOR     EDX, EDX
    DIV     EBX                 ; divide EAX by 10
    ADD     EDX, 30h            ; convert remainder to ascii
    DEC     ESI                 ; point to previous char
    MOV     [ESI], DL           ; store ascii char
    TEST    EAX, EAX
    JNZ     itoa_loop           ; if quotient is not zero, repeat

    ; if number is negative, add negative sign
    CMP     isNegative, 1
    JNE     itoa_done

    DEC     ESI
    MOV     BYTE PTR [ESI], '-'

itoa_done:
    ; move converted string to start of passed string
    ; start of converted string already in ESI
    ; start of destination string (passed on stack) in EDI
    MOV     ECX, 12

move_string:
    LODSB
    STOSB
    LOOP move_string

    POPAD
    RET 8
itoa ENDP


; --------------------------------------------------------
; main: Procedure to run the main program flow
;
; Arguments: None
; Returns: None
; --------------------------------------------------------
main PROC
    ; Display introduction
    mDisplayString OFFSET introStr

    MOV     ECX, ARRAY_SIZE
    MOV     EDI, OFFSET numberArray
    MOV     ESI, EDI

    ; Get 10 numbers
get_number:
    PUSH    OFFSET inputPrompt
    PUSH    OFFSET errorMsgPrompt
    PUSH    OFFSET inputVal
    CALL    ReadVal

    ; add number to total sum
	MOV     EAX, inputVal
    ADD     totalSum, EAX

    ; add number to array
    MOV     [EDI], EAX
    ADD     EDI, 4

    LOOP    get_number

    ; Display numbers
    MOV     ECX, ARRAY_SIZE
    mDisplayString OFFSET displayNumbersPrompt

display_numbers:
    PUSH    [ESI]
    CALL    WriteVal
    ADD		ESI, 4

    CMP     ECX, 1
    JE      display_sum

    mDisplayString  OFFSET comma
    LOOP            display_numbers

display_sum:
    mDisplayString  OFFSET newline
    mDisplayString  OFFSET displaySumPrompt
    PUSH            totalSum
    CALL            WriteVal

dsiplay_avergae:
    mDisplayString OFFSET newline
    mDisplayString OFFSET displayAvgPrompt

    ; Calculate the rounded integer average
    MOV     EAX, totalSum
    MOV		ECX, 10
    CDQ
    IDIV    ECX
    PUSH    EAX
    CALL    WriteVal

ExitProgram:
    mDisplayString OFFSET thanksPrompt
    INVOKE  ExitProcess, 0
main ENDP

END main
