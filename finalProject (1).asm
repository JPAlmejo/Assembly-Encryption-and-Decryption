TITLE Final Project     (finalProject.asm)

;// Author: John Perez Almejo
;// Last Modified: 3-16-2021
;// OSU email address: perezalj@oregonstate.edu
;// Course number/section: CS271 
;// Assignment Number:  FINAL               Due Date: 3-17-2021
;// Description: Implement three modes that take in 3 parameters. 1st mode takes two operands, adds them together, and stores the sum third parameter. Second mode takes a string and encrypts it. Third mode takes an encrypted string and decrypts it.

INCLUDE Irvine32.inc

.code
;==============================================================
;compute: Chooses the correct mode
;recieves: 3 parameters. operand1, operand2, OFFSET dest. OR OFFSET message, OFFSET Key, and OFFSET dest. 
;returns: None
;precondition: None
;postcondition: checks value inside dest and chooses the corresponding mode
;registers Changed: EAX
;===============================================================

compute		PROC
;Setup the stack
 
    PUSH    EBP
    MOV     EBP, ESP
    
    ;Check Contents of dest in order to choose the correct mode
    MOV     EAX, [EBP+8]
    MOV     EAX, [EAX]
    CMP     EAX, -1
    JE      encryptionMode
    CMP     EAX, -2
    JE      decryptionMode
    JMP     decoyMode

;returns from compute after decryption mode is finished doing its thing
return:
;leave compute
	POP		EBP
	RET		12

;calls for decoy PROC
decoyMode:
	push   [EBP+14] ;EBP+14
	push   [EBP+12]	;EBP+12
	push   [EBP+8] ;EBP+8 dest
	call   decoy
	JMP		return


;calls for encryption PROC after pushing parameters
encryptionMode:
    PUSH   [EBP+16]  ;EBP+16
    PUSH   [EBP+12]     ;EBP+12
    PUSH   [EBP+8]      ;ebp+8
    CALL   encryption
    JMP    return

;calls for decryption PROC after pushing parameters
decryptionMode:
    PUSH   [EBP+16]  ;Key
    PUSH   [EBP+12]  ;Message
    PUSH   [EBP+8]   ;Dest
    CALL   decryption
    JMP    return


compute		ENDP

;==============================================================
;decoy: takes two operands and adds them together
;recieves: PUSH operand1, PUSH operand2, PUSH OFFSET dest 
;returns: None
;precondition: None
;postcondition: stores the sum of both operands in dest
;registers Changed: EAX, EBX
;===============================================================
decoy		proc
	PUSH	EBP
	MOV		EBP, ESP
	;move the operands into position for deduction
	xor		eax, eax
	MOV		AX, [EBP+14]
	MOVSX	EAX, AX 

	MOV		BX, [EBP+12]
	MOVSX	EBX, BX

	ADD		EAX, EBX
	MOV		EBX, [EBP+8]
	MOV		[EBX], EAX

	POP		ebp
	RET		12
decoy		endp

;==============================================================
;encryption: takes a string and encrypts its contents
;recieves: [EBP+16], [EBP+12], [EBP+8]
;returns: None
;precondition: None
;postcondition: iterates through the given string and subtracts 97 from each character. Takes the subtracted value and uses it to find the correct encrpyted letter to replace it with. It then exchanges the characters in order to encrypt the string
;registers Changed: EAX, EBX, EDX, ESI ,EDI
;===============================================================

encryption  PROC
    ;setup stack frame
    PUSH    EBP
    MOV     EBP, ESP
    ;zero everything out and setup counter
    MOV     EDX, 0
    MOV     EBX, 0
    MOV     EAX, 0

    ;setup arrays in appropiate registers
    MOV     EDI, [EBP+16]
    MOV     ESI, [ebp+12]

;beginning of the actual encryption part
TOP:
    ;checks for null character but also stores character into eax for comparisons
    MOV     EAX, [ESI] ;beginning index
    cmp     AL, 32
    JE      next
    CMP     AL, 0
    JE      exitEncryption

    ;checks for lower limit character. 'a' = 97
lowerCheck:
    CMP     AL, 97
    JGE     upperCheck
    JL      next
    ;checks for upper limit character. 'z' = 122
upperCheck:
    CMP     AL, 122
    JLE     findPos

findPos:
    SUB     AL, 97

    ;move contents of AL to BL and extend in order to get offset for EDI
    MOV     BL, AL
    MOVSX   EBX, BL

    ;Move contents of [EDI+offset] into ESI
    MOV     AL, [EDI+EBX]
    MOVSX   EAX, AL 
    XCHG     [ESI], AL
    JMP     next

;loop back to the top and encrypt the next value
next:
    INC     ESI
    JMP    TOP

;leaves encryption PROC
exitEncryption:
    POP     EBP
    RET     12
encryption  ENDP


;==============================================================
;decryption: takes a string and decrypts its contents
;recieves: [EBP+16], [EBP+12], [EBP+8]
;returns: None
;precondition: None
;postcondition: iterates through the given string and subtracts 99 from each character. Takes the subtracted value and uses it to find the correct decrpyted letter to replace it with. It then exchanges the characters in order to decrypt the string
;registers Changed: EAX, EBX, EDX, ESI ,EDI
;===============================================================

decryption  PROC
    ;setup stack frame
    PUSH    EBP
    MOV     EBP, ESP
    ;zero everything out and setup counter
    MOV     EDX, 0
    MOV     EBX, 0
    MOV     EAX, 0

    ;setup arrays in appropiate registers
    MOV     EDI, [EBP+16]   ;KEY
    MOV     ESI, [ebp+12]   ;message


TOP:
    ;checks for null character but also stores character into eax for comparisons
    MOV     EAX, [ESI] ;Stores contents of ESI into EAX
    cmp     AL, 32
    JE      next
    CMP     AL, 0
    JE      exitDecryption

    ;checks for special cases
specialCheck:
    CMP     AL, 97
    JE      SpecialPosA
    CMP     AL, 98
    JE      SpecialPosBC
    CMP     AL, 99
    JE      SpecialPosBC
    CMP     AL, 100
    JE      SpecialPosDF
    CMP     AL, 101
    JE      SpecialPosE
    CMP     AL, 102
    JE      SpecialPosDF
    CMP     AL, 103
    JE      SpecialPosG
    JMP      lowerCheck

;this checks for special characters that may otherwise throw off the the index positioning of the key array
;*************************************************************
SpecialPosA:
    SUB     AL, 73
    jmp     exchange
SpecialPosBC:
    SUB     AL, 95
    JMP     exchange   
SpecialPosDF:
    SUB     AL, 100
    JMP     exchange
SpecialPosE:
    SUB     AL, 76
    JMP     exchange
SpecialPosG:
    SUB     AL, 102
    JMP     exchange
;*************************************************************

;checks for lower limit character. 'a' = 97
lowerCheck:
    CMP     AL, 97
    JGE     upperCheck
    JL      next

;checks for upper limit character. 'z' = 122
upperCheck:
    CMP     AL, 122
    JLE     findPos

;finds position of appropiate letter in the key
findPos:
    SUB     AL, 99

;move contents of AL to BL and extend in order to get offset for EDI
exchange:
    MOV     BL, AL
    MOVSX   EBX, BL

    ;Move contents of [EDI+offset] into ESI
    MOV     AL, [EDI+EBX]
    MOVSX   EAX, AL 
    XCHG     [ESI], AL
    JMP     next

;Loop back to the top and decrypt the next value in the string
next:
    INC     ESI
    JMP    TOP

;Returns from the decryption PROC    
exitDecryption:
    POP     EBP
    RET     12
decryption  ENDP

