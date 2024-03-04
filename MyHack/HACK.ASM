.model tiny
.286
.code
org 100h


PRINT_STR       macro str:REQ                                                           ; Macro for displaying the string str on the screen
                mov dx, offset str
                mov ah, 09h
                int 21h

                endm


LINE_FEED equ 0Ah                                                                       ; ASCII code for line feed

CARRIAGE_RETURN equ 0Dh                                                                 ; ASCII code for carriage return

RIGHT_PASSWORD equ 1                                                                    ; Value for the password flag if it is correct

WRONG_PASSWORD equ 0                                                                    ; Value for the password flag if it is incorrect

PASSWORD equ 1809h                                                                      ; Password hash code

LEN_OF_CANARY_VALUE equ 6h                                                              ; True canary string length

Start:
                Call Main
                jmp Exit

        Exit:                                                                           ; Exit the program
                mov ax, 4c00h
                int 21h


Main    proc
                Call ReadPassword                                                       ; Calling the password reading function

                Call NewLine                                                            ; Calling a function to go to the beginning of a new line
                
                Call HashPassword                                                       ; Calling the Password Hashing Function

                Call ComparePassword                                                    ; Calling the password comparison function

                Call PrintResult                                                        ; Calling the output function
                
                ret
                endp


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Function to read password from stream input
; Info:
;       AX - stores the function number for reading a line from stdin into a buffer
;       DX - stores the maximum number per character to read
;       msg_hello - welcome message 
;       len_buffer - maximum number per character to read
; Destr:
;       AX
;       DX
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


ReadPassword    proc
                PRINT_STR msg_hello                                                     ; Welcome message output

                mov dx, offset len_buffer
                mov ah, 0Ah
                int 21h                                                                 ; Reading password

                ret
                endp


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Function to go to the beginning of a new line
; Info:
;       AX - stores the function number for displaying one character on the screen
;       DX - stores the character printed to standard output
;       LINE_FEED - ASCII code for line feed
;       CARRIAGE_RETURN - ASCII code for carriage return
; Destr:
;       AX
;       DX
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


NewLine proc
                mov ah, 02h

                mov dx, LINE_FEED
                int 21h                                                                 ; Printing a newline character

                mov dx, CARRIAGE_RETURN
                int 21h                                                                 ; Printing a carriage return to the beginning of a line

                ret
                endp


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Password hashing function
; General formula: dx = dx + ASCII_CODE
; Info:
;       AX - used to temporarily store the value from the dx register
;       BX - stores a pointer to the password string
;       CX - stores a value with the password length
;       DX - stores the hash code value
;       buffer - variable pointing to the password string
;       fact_len_buffer - password length
; Destr:
;       AX
;       BX
;       CX
;       DX
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


HashPassword    proc
                mov bx, offset buffer
                mov cl, fact_len_buffer
                mov dx, 5381d                                                           ; this number gives a more uniform distribution of hash values

        @@hash_again:
                mov ax, 0
                mov al, byte ptr [bx]
                add dx, ax                                                             ; add the ascii code of the symbol to the hash

                inc bx                                                                  ; move to the next character of the password
                loop @@hash_again                                                       ; dx = dx + ASCII_CODE

                ret
                endp


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Password comparison function
; Entry:
;       DX - stores the password hash code
; Info:
;       AX - if the canary is true, then ax = 0
;       PASSWORD - hash code of the correct password
;       flag_password - a variable storing the value 1 if the password is correct and 0 if it is incorrect
;       RIGHT_PASSWORD - the value received by the flag_password variable if the password is correct
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


ComparePassword proc
                Call CanaryCheck                                                        ; Calling a function that checks the canary
                cmp ax, 0                                                               ; If the canary is true, then ax = 0
                jne @@not_equal

                cmp dx, PASSWORD                                                        ; Password comparison
                jne @@not_equal                                                         ; If true, then change the value of the flag
                                                                                        ; Otherwise we exit the function
                mov flag_password, RIGHT_PASSWORD
        
        @@not_equal:
                ret
                endp


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Function that checks the value of the canary
; Info:
;       canary_value - true meaning of canary
;       canary - the meaning of the canary at the moment
;       LEN_OF_CANARY_VALUE - true canary string length
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CanaryCheck     proc
                push offset canary_true_value
                push offset canary
                push LEN_OF_CANARY_VALUE

                Call MyMemCmp                                                           ; Compare the true and actual value of the canary

                cmp ax, 0
                je @@canary_right                                                       ; If the lines are different, then
                mov flag_password, WRONG_PASSWORD                                       ; Set the flag to 0 - the password is incorrect

        @@canary_right:
                ret
                endp


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; A function that compares the first n characters of two strings
; Entry:
;       SI (first arg) - pointer to first line
;       DI (second arg) - pointer to second line
;       CX (third arg ) - number of bytes compared
; Destr:
;       AX
;       CX
;       SI
;       DI
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

MyMemCmp	proc
		push bp
		mov bp, sp

		mov si, [bp + 8]                                                
		mov di, [bp + 6]
		mov cx, [bp + 4]

		mov ax, 0

        again:
		add al, [si]                                                            ; AL = AL + ASCII_CODE_SYMBOL_STR_1 - ASCII_CODE_SYMBOL_STR_2
		sub al, [di]

                inc si
                inc di
		loop again

		pop bp

		ret 6
		endp


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Result function
; Info:
;       flag_password - a variable storing the value 1 if the password is correct and 0 if it is incorrect
;       WRONG_PASSWORD - the value received by the flag_password variable if the password is incorrect
;       msg_right_password - message displayed on screen if password is correct
;       msg_wrong_password - message displayed on screen if password is incorrect
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


PrintResult     proc
                cmp flag_password, WRONG_PASSWORD                                       ; Comparing the flag value with the value if the password is incorrect
                je @@wrong_password

                PRINT_STR msg_right_password                                            ; Displaying a message that the password is correct
                jmp @@ret

        @@wrong_password:
                PRINT_STR msg_wrong_password                                            ; Displaying a message that the password is incorrect


        @@ret:
                ret
                endp


.data


canary_true_value db "canary"                                                           ; Correct meaning of canary

msg_hello db "Hello, enter your password: $"                                            ; Welcome message

msg_right_password db "Right password!$"                                                ; Message displayed on screen if password is correct

msg_wrong_password db "Wrong password...$"                                              ; Message displayed on screen if password is incorrect

len_buffer db 254                                                                       ; Maximum number per character to read

fact_len_buffer db 0                                                                    ; This variable will store the number of characters read from standard input

buffer db 10 dup(?)                                                                     ; This variable will point to the beginning of the line read from standard input

canary db "canary"                                                                      ; Canary responsible for preserving the password correctness flag

flag_password db WRONG_PASSWORD                                                         ; A variable storing the value 1 if the password is correct and 0 if it is incorrect (initially stores the value of the incorrect password)

end	Start