include 'emu8086.inc'

; ====================================================
; Program: Typing Speed and Accuracy Analyzer
; Description:
; - Displays a paragraph for the user to type.
; - Records the time taken.
; - Counts typed words and characters.
; - Compares typed input with original paragraph.
; - Displays typing accuracy as percentage of correct words.
; Author: Isha
; ====================================================

.model small
.stack 100h

.data
DisplayText db "The sky turned a soft shade of lavender as the sun dipped below the horizon.$"
TextLength dw ?
UserInput db 1000 dup(?)
newline db 0ah,0dh,'$'
msg_prompt db 0ah, 0dh, "Your input: $"
StartTime dw ?
EndTime dw ?
TimeTaken dw ?
CharCount dw ?
WordCount dw ?
CorrectWords dw 0

.code
main proc
    mov ax,@data
    mov ds,ax

    print "======================================================"  
    mov dx, offset newline
    mov ah, 09h
    int 21h 
    print "          Typing Speed and Accuracy Analyzer         " 
    mov dx, offset newline
    mov ah, 09h
    int 21h
    print "======================================================"  
    lea dx,newline
    mov ah,09h
    int 21h

    mov dx, offset newline
    mov ah, 09h
    int 21h

    mov dx,offset DisplayText
    mov ah,09h
    int 21h

    mov TextLength,0
    mov si,offset DisplayText
    mov cx,0

Text_Length_Counter:
    cmp byte ptr [si],'$'
    je Save_Length
    inc cx
    inc si
    jmp Text_Length_Counter

Save_Length:
    mov TextLength,cx

    lea dx,newline
    mov ah,09h
    int 21h

    mov WordCount,0
    mov CharCount,0

    xor si,si

    mov dx, offset msg_prompt
    mov ah, 09h
    int 21h

    mov ah,00h
    int 1ah
    mov StartTime,dx

InputLoop:
    mov ah,01h
    int 21h

    cmp al,13
    je EndInput

    mov UserInput[si],al
    cmp al,' '
    je CountWord

    inc si

    cmp si,1000
    jl InputLoop
    je EndInput

CountWord:
    inc WordCount
    inc si
    jmp InputLoop

EndInput:
    inc WordCount
    mov CharCount,si

    mov ah,00h
    int 1ah
    mov EndTime,dx

    mov ax,EndTime
    sub ax,StartTime
    mov TimeTaken,ax
    mov ax,TimeTaken
    mov cx,10
    mul cx
    mov cx,182
    div cx
    mov TimeTaken,ax

    mov dx,offset newline
    mov ah,09h
    int 21h

    print "Time in seconds: ",$
    mov ax, TimeTaken 
    call print_num

; ===== Accuracy Calculation Starts Here =====

    xor si, si               ; SI = pointer for DisplayText
    xor di, di               ; DI = pointer for UserInput
    xor cx, cx               ; CX = correct word count
    xor bx, bx               ; BX = general word counter

NextWordCheck:
    ; Skip spaces in original
    Word_Skip_Original:
        cmp DisplayText[si],' '
        je Skip_Space_Orig
        cmp DisplayText[si],'$'
        je Accuracy_Done
        jmp CheckInput

    Skip_Space_Orig:
        inc si
        jmp Word_Skip_Original

CheckInput:
    ; Skip spaces in user input
    Word_Skip_User:
        cmp UserInput[di],' '
        je Skip_Space_Input
        cmp di,CharCount
        jae Accuracy_Done
        jmp CompareWords

    Skip_Space_Input:
        inc di
        jmp Word_Skip_User

CompareWords:
    mov ah, DisplayText[si]
    mov al, UserInput[di]
    cmp ah, ' '
    je WordEndCheck
    cmp ah, '$'
    je WordEndCheck
    cmp di,CharCount
    jae WordEndCheck
    cmp ah, al
    jne WordMismatch

    inc si
    inc di
    jmp CompareWords

WordMismatch:
    ; Move to next space in both strings
    Skip_Orig_Word:
        cmp DisplayText[si],' '
        je EndWord_Orig
        cmp DisplayText[si],'$'
        je EndWord_Orig
        inc si
        jmp Skip_Orig_Word
    EndWord_Orig:

    Skip_User_Word:
        cmp UserInput[di],' '
        je EndWord_User
        cmp di,CharCount
        jae EndWord_User
        inc di
        jmp Skip_User_Word
    EndWord_User:

    inc bx
    jmp NextWordCheck

WordEndCheck:
    ; Word matches
    inc CorrectWords

    ; Skip to next word in both
    SkipEnd_Orig:
        cmp DisplayText[si],' '
        je EndSkipO
        cmp DisplayText[si],'$'
        je EndSkipO
        inc si
        jmp SkipEnd_Orig
    EndSkipO:

    SkipEnd_User:
        cmp UserInput[di],' '
        je EndSkipU
        cmp di,CharCount
        jae EndSkipU
        inc di
        jmp SkipEnd_User
    EndSkipU:

    inc bx
    jmp NextWordCheck

Accuracy_Done:
    

    mov dx, offset newline
    mov ah, 09h
    int 21h

    print "Correct words: ",$
    mov ax, CorrectWords
    call print_num

    lea dx,newline
    mov ah,09h
    int 21h

    print "Total words typed: ",$
    mov ax, WordCount
    call print_num

    lea dx,newline
    mov ah,09h
    int 21h

    print "Accuracy (%): ",$
    mov ax, CorrectWords
    mov cx, WordCount
    cmp cx,0
    je SkipAccuracy 
    mov bx, 100
    mul bx 
    div cx
                     
                     
SkipAccuracy:
    call print_num

Exit:
    mov ah,4ch
    int 21h

main endp
define_print_num
define_print_num_uns
end main
