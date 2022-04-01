INCLUDE Irvine32.inc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.data

filehandle	dword		?
outfilename	byte		"Calculator Output.txt", 0

forEq	  byte		"=",NULL
n1		  byte	8 dup(?),0
n2		  byte	8 dup(?),0
opr		  byte	?,0

intN1	dword	?,0
intN2	dword	?,0
ans		dword	?,0
rem		dword	?,0
count	dword	?,0

NULL EQU 0
CR EQU 13
LF EQU 10
SPACE EQU 32
DOLLAR EQU 36
EQUALS EQU 61

printForN1   byte	CR, LF, "Enter N1: ", NULL			; check if there are even no. of characters
printForOpr  byte	CR, LF, "Enter operator: ", NULL			; check if there are even no. of characters
printForN2   byte	CR, LF, "Enter N2: ", NULL			; check if there are even no. of characters
printForAns  byte	CR, LF, "Ans = ", NULL
sAns		   byte	8 dup(?), CR, LF, CR, LF, NULL						; an array that holds 8 chars
printForRem  byte	"Remainder = ", NULL			
sRem	        byte	4 dup(?), CR, LF, CR, LF, NULL						; an array that holds 8 chars
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getInput PROC 
 lea esi,printForN1	
 call WriteLine 

 lea esi,n1 
 call ReadLine 
 lea esi,n1 
 call WriteLine
 	lea esi,n1 
	call WriteLineToFile
call addSpace

 lea esi,printForOpr
 call WriteLine 
 lea esi,opr 
 call ReadLine 
 lea esi,opr 
 call WriteLine
  	 lea esi,opr
	call WriteLineToFile
call addSpace

 lea esi,printForN2	
 call WriteLine 
 lea esi,n2 
 call ReadLine 
 lea esi,n2
 call WriteLine
   	 lea esi,n2
	call WriteLineToFile
call addSpace

call addEq

ret
getInput endP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ReadLine PROC 
; returns ecx = length of entered string

mov ecx,0
next: call ReadChar
cmp al,CR
je getOut
mov [esi],al
inc esi
;call Writechar
call WriteLineToFile
inc ecx
jmp next
getOut: ret
ReadLine endP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	WriteLineToFile PROC				
		nextChar: mov al,[esi]		
		cmp al,0		; sentinal value
		je exitNow
		mov eax,filehandle
		mov edx,esi				
		mov ecx,1
		call WriteToFile
		add esi,1
		jmp nextChar
	exitNow: ret
	WriteLineToFile endP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	WriteLine PROC				; deals with byte size ASCII char
		next: mov al,[esi]		; use al instead of eax, al is 8 bits (1 byte)
		cmp al,0			; sentinal value
		je outOfHere
		call Writechar
		inc esi				; +1 instead of +4 because esi has 1 byte data
		jmp next
	outOfHere: ret
	WriteLine endP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	blankOut PROC				; fill array with blanks
	mov al, ' '				; al = ' '
		goon: mov [esi],al		; array element = ' '
		inc esi				; next position
		dec ecx				; count--
		cmp ecx,0
		jne goon
	ret
	blankOut endP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ItoA PROC
	mov ebx,10				; divide by 10 to separate each digit
	again: cmp eax,0
		je outOfHere
          mov edx,0				; remainder register needs to be zero before every division
	     idiv ebx
	     add edx, '0'			; to convert a no. to ASCII char and dl has the ascii
	     dec esi				; esi points at the end of array at first due to blankOut
	     mov [esi],dl			; remainder (start from last digit)
	     jmp again
	outOfHere: ret
	ItoA endP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

operation PROC
pushad
mov eax,intN1
mov ebx,intN2
.if opr == '+'
	add eax,ebx
	mov ans,eax
.elseif opr == '-'
	sub eax,ebx
	mov ans,eax
.elseif opr == '*'
	imul eax,ebx
	mov ans,eax
.elseif opr == '/'
	mov edx,0
	idiv ebx
	mov ans,eax
	mov rem,edx
.endif
popad
ret
operation endP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

addSpace PROC
		mov al,' '	
		mov eax,filehandle
		mov edx,esi				
		mov ecx,1
		call WriteToFile	
	ret					
addSpace endP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

addEq PROC
		lea esi, forEq
		mov eax,filehandle
		mov edx,esi				
		mov ecx,1
		call WriteToFile
	ret					
addEq endP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	AtoI PROC 
; takes esi = ascii number
; returns ebx = int number
mov ebx, 0
mov eax, 0
doAgain:
	mov al,[esi]
	cmp al, '0'
	jl goOut
	cmp al, '9'
	jg goOut
	sub al, '0'  ;eax has digit
	imul ebx, 10
	add ebx, eax
	inc esi
	jmp doAgain
goOut: 
	ret
	AtoI endP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clearPrevInput PROC
;takes esi = address of the array where the read input is stored

xor eax,eax ;Write Zero
mov ecx,8 ;Size of the Array, in Bytes
mov edi,esi ;Location of Array start, in RAM
cld
rep stosb
ret
clearPrevInput endP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main PROC

comment!;;;;;;;;;;;;;;;;;;;
	lea esi, printSum	;; write to file syntax
	call WriteLineToFile;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
    call ReadChar		 ;
    mov [esi], al		 ; read char from keyboard syntax
     call Writechar		 ;
    call WriteLineToFile  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;!

;Open output file:----------

	lea edx,outfilename
	call CreateOutputFile
	mov filehandle,eax

mov ebx, 0
nextExp:

;-------------------------------------------------------------------------
pushad

call getInput

lea esi,n1
call AtoI
mov intN1, ebx
lea esi,n2
call AtoI
mov intN2, ebx

call operation

		mov ecx,8			  ; count = 8 for array to hold answer
		lea esi, sAns		  ; esi holds the address of the ans array 
		call blankOut		  ; fill array with blanks
		mov eax,ans		  ; ItoA deals with eax
		call ItoA			  ; convert to ASCII char
		lea esi, printForAns  ; points to output
		call writeLine
		lea esi, sAns         ; points to output
		call writeLine
		lea esi, sAns         ; points to output
		call WriteLineToFile 

		.if opr == '/'
			mov ecx,4			  ; count = 8 for array to hold answer
			lea esi, sRem         ; esi holds the address of the ans array 
			call blankOut		  ; fill array with blanks
			mov eax,rem	       ; ItoA deals with eax
			call ItoA			  ; convert to ASCII char
			lea esi, printForRem  ; points to output
			call writeLine
			lea esi, printForRem  ; points to output
			call WriteLineToFile
			lea esi, sRem         ; points to output
			call WriteLine 
			lea esi, sRem         ; points to output
			call WriteLineToFile 
		.endif
lea esi, n1
call clearPrevInput
lea esi, n2
call clearPrevInput
popad
;-------------------------------------------------------------------------
inc ebx
cmp ebx,8
jne nextExp

call DumpRegs
	exit
main ENDP

END main
