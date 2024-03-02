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
;       PASSWORD - hash code of the correct password
;       RIGHT_PASSWORD - the value received by the flag_password variable if the password is correct
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


ComparePassword proc
                cmp dx, PASSWORD                                                        ; Password comparison
                jne @@not_equal                                                         ; If true, then change the value of the flag
                                                                                        ; Otherwise we exit the function
                mov dx, RIGHT_PASSWORD
                jmp @@exit
        
        @@not_equal:
                mov dx, WRONG_PASSWORD

        @@exit:
                ret
                endp


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Result function
; Info:
;       dx - a variable storing the value 1 if the password is correct and 0 if it is incorrect
;       WRONG_PASSWORD - the value received by the flag_password variable if the password is incorrect
;       msg_right_password - message displayed on screen if password is correct
;       msg_wrong_password - message displayed on screen if password is incorrect
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


PrintResult     proc
                cmp dx, WRONG_PASSWORD                                                  ; Comparing the flag value with the value if the password is incorrect
                je @@wrong_password

                PRINT_STR msg_right_password                                            ; Displaying a message that the password is correct
                jmp @@ret

        @@wrong_password:
                PRINT_STR msg_wrong_password                                            ; Displaying a message that the password is incorrect


        @@ret:
                ret
                endp


.data


len_buffer db 254                                                                       ; Maximum number per character to read

fact_len_buffer db 0                                                                    ; This variable will store the number of characters read from standard input

buffer db 40 dup(?)                                                                     ; This variable will point to the beginning of the line read from standard input

msg_hello db "Hello, enter your password: $"                                            ; Welcome message

msg_wrong_password db "Wrong password...$"                                              ; Message displayed on screen if password is incorrect

msg_right_password db "Right password!$"                                                ; Message displayed on screen if password is correct

end	Start