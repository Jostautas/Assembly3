.model small

.stack 100h

.data
	mnemonika1	db "PUSH offset word ptr [$"
	mnemonika2	db "], $"
	mnemonika3	db ", [$"
	mnemonika4	db "]=$"
	mnemonika5	db ", $"
	stekas		db ", pirmas steko zodis $"
	enteris		db 10, 13, "$"

	s_bx	db "bx$"
	s_si	db "si$"
	s_di	db "di$"
	s_bp	db "bp$"

	baitas1	db ?
	baitas2 db ?
	baitas3 db ?
	baitas4 db ?

.code
  Pradzia:
	MOV	ax, @data
	MOV	ds, ax

	MOV	ax, 0
	MOV	es, ax		;i es isirasome 0, nes pertraukimu vektoriu lentele yra segmente, kurio pradzios adresas yra 00000
	
	; Issisaugome tikra pertraukimo apdorojimo proceduros adresa, kad programos gale galetume ji atstatyti
	PUSH	es:[4]
	PUSH	es:[6]
	
	MOV	word ptr es:[4], offset ApdorokPertr	;i pertraukimu vektoriu lentele irasome pertraukimo apdorojimo proceduros poslinki nuo kodo segmento pradzios
	MOV	es:[6], cs				;i pertraukimu vektoriu lentele irasome pertraukimo apdorojimo proceduros segmenta
	
	PUSHF			;Issisaugome SF reiksme testavimo pradzioje
	PUSHF			;Issisaugome SF kad galetume ja isimti ir nustatyti TF
	POP ax			;Isimame SF reiksme i TF
	OR ax, 100h		;Nustatome TF=1
	PUSH ax			;Idedame pakoreguota reiksme
	POPF			;Iimame pakoreguota reiksme i SF; Nuo cia TF=1
	NOP			;Pirmas pertraukimas kyla ne pries sia komanda, o po jos; todel tiesiog viena komanda nieko nedarome

	;************************************************************

	MOV	ax, bx
	MOV	ax, cs
	MOV	al, 22h
	PUSH offset word ptr [bx]			; mod = 00
	PUSH offset word ptr [bx+035h]			; mod = 01
	PUSH offset word ptr [bx+08415h]		; mod = 10
	INC bx
	DEC bx

	;***************************************************************

	POP bx			; isvalom kas buvo ipopinta
	POP bx
	POP bx

	POPF			;Istraukiame is steko testavimo pradzioje buvusia SF reiksme
				;Kadangi tada TF buvo lygi 0, tai tokiu budu numusame TF
	
; Atstatom tikra pertraukimo apdorojimo programos adresa pertraukimu vektoriuje
	POP	es:[6]
	POP	es:[4]

	MOV	ah, 4Ch
	MOV	al, 0
	INT	21h

PROC ApdorokPertr

	POP si
	POP di
	PUSH di
	PUSH si

	;Idedam registru reiksmes i steka
	PUSH	ax
	PUSH	dx
	PUSH	bp
	PUSH	es
	PUSH	ds
	PUSH	bx

	;Nustatom DS reiksme, jei pertraukima iskviestu kita programa
	MOV	ax, @data
	MOV	ds, ax

	;Susidedam masininio kodo baitus i atminti
	MOV ax, cs:[si]
	MOV bx, cs:[si+2]

	MOV baitas1, al		; OPK baitas
	MOV baitas2, ah		; adresavimo baitas
	MOV baitas3, bl		; poslinkio baitas
	MOV baitas4, bh		; poslinkio baitas

	CMP al, 0FFh
	JNE Pabaiga

	AND ah, 38h	; uzmaskuojam visus bitus isskyrus reg
	CMP ah, 30h	; ziurim ar reg = 110
	JNE Pabaiga


	JMP Spausdink

	;Atstatome registru reiksmes ir iseiname is pertraukimo apdorojimo proceduros
Pabaiga:
	POP bx
	POP ds
	POP es
	POP bp
	POP	dx
	POP	ax
	IRET			;pabaigoje butina naudoti grizimo is pertraukimo apdorojimo proceduros komanda IRET
				
Spausdink:

	;Spausdinam "CS:IP"
	MOV ax, di ;spausdinam CS
	CALL printAX
	
	MOV ah, 2
	MOV dl, ":"
	INT 21h
		
	MOV ax, si ;spausdinam IP
	CALL printAX
	
	CALL printSpace
	
	;Spausdinam masininio kodo baitus
	MOV ah, baitas1
	MOV al, baitas2
	CALL printAX
	
	CALL printSpace
	
	MOV ah, 9
	MOV dx, offset mnemonika1
	INT 21h

	AND al, 0C0h	;Uzmaskuoja visus bitus isskyrus pirmus du - mod

	CMP al, 0h	;Ar mod yra 00
	JE mod00

	CMP al, 40h	;Ar mod yra 01
	JE mod01_1

	CMP al, 80h	;Ar mod yra 10
	JE mod10_1

	JMP Pabaiga

;****************************************************
mod00:
	MOV al, baitas2

	AND al, 7h	;Tikrinam paskutinius 3 bitus - r/m

	CMP al, 0h
	JE j_rm000

	CMP al, 1h
	JE j_rm001

	CMP al, 2h
	JE j_rm010

	CMP al, 3h
	JE j_rm011

	CMP al, 4h
	JE j_rm100

	CMP al, 5h
	JE j_rm101

	CMP al, 7h
	JE j_rm111

	JMP Pabaiga

	mod01_1:
		JMP mod01
	mod10_1:
		JMP mod10_2

	;***************************************************************
j_rm000:
	call rm000
	JMP print_stekas

j_rm001:
	call rm001
	JMP print_stekas

j_rm010:
	call rm010
	JMP print_stekas

j_rm011:
	call rm011
	JMP print_stekas

j_rm100:
	call rm100
	JMP print_stekas

j_rm101:
	call rm101
	JMP print_stekas
	
j_rm111:
	call rm111
	JMP print_stekas	

;*****************************************************
mod01:
	MOV al, baitas2

	AND al, 7h	;Tikrinam paskutinius 3 bitus - r/m

	CMP al, 0h
	JE j_rm0002

	CMP al, 1h
	JE j_rm0012

	CMP al, 2h
	JE j_rm0102

	CMP al, 3h
	JE j_rm0112

	CMP al, 4h
	JE j_rm1002

	CMP al, 5h
	JE j_rm1012

	CMP al, 6h
	JE j_rm1102

	CMP al, 7h
	JE j_rm1112
	
	JMP Pabaiga

	mod10_2:
		JMP mod10

j_rm0002:
	call rm0002
	JMP print_stekas
j_rm0012:
	call rm0012
	JMP print_stekas
j_rm0102:
	call rm0102
	JMP print_stekas
j_rm0112:
	call rm0112
	JMP print_stekas
j_rm1002:
	call rm1002
	JMP print_stekas
j_rm1012:
	call rm1012
	JMP print_stekas
j_rm1102:
	call rm1102
	JMP print_stekas
j_rm1112:
	call rm1112
	JMP print_stekas
;*****************************************************
mod10:
	MOV al, baitas2

	AND al, 7h	;Tikrinam paskutinius 3 bitus - r/m

	CMP al, 0h
	JE j_rm0003

	CMP al, 1h
	JE j_rm0013

	CMP al, 2h
	JE j_rm0103

	CMP al, 3h
	JE j_rm0113

	CMP al, 4h
	JE j_rm1003

	CMP al, 5h
	JE j_rm1013

	CMP al, 6h
	JE j_rm1103

	CMP al, 7h
	JE j_rm1113
	
	JMP Pabaiga

j_rm0003:
	call rm0003
	JMP print_stekas
j_rm0013:
	call rm0013
	JMP print_stekas
j_rm0103:
	call rm0103
	JMP print_stekas
j_rm0113:
	call rm0113
	JMP print_stekas
j_rm1003:
	call rm1003
	JMP print_stekas
j_rm1013:
	call rm1013
	JMP print_stekas
j_rm1103:
	call rm1103
	JMP print_stekas
j_rm1113:
	call rm1113
	JMP print_stekas

;*****************************************************
print_stekas:
	mov ah, 9
	mov dx, offset stekas
	int 21h

	MOV ax, [ss:0FCh] ;Steko pradzia - 100h. 100-4baitai  = FCs
	call printAX

	mov ah, 09h
	mov dx, offset enteris
	INT 21h
	
	JMP Pabaiga
	
ApdorokPertr ENDP

rm000:
	PUSH ax
	PUSH dx

	;Print "[bx+si], "
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bx =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bx
	CALL printAX

	;Print "[bx]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bx]
	CALL printAX
	MOV ah, 09h
	MOV dx, offset mnemonika5
	INT 21h

	;Print "si =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, si
	CALL printAL

	;Print "[si]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [si]
	CALL printAX
	
	POP dx
	POP ax

RET
rm001:
	PUSH ax
	PUSH dx

	;Print "[bx+di], "
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bx =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bx
	CALL printAX

	;Print "[bx]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bx]
	CALL printAX
	MOV ah, 09h
	MOV dx, offset mnemonika5
	INT 21h

	;Print "di =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, di
	CALL printAL

	;Print "[di]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [di]
	CALL printAX
	
	POP dx
	POP ax
RET
rm010:
	PUSH ax
	PUSH dx

	;Print "[bp+si], "
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bp =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bp
	CALL printAX

	;Print "[bp]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bp]
	CALL printAX
	MOV ah, 09h
	MOV dx, offset mnemonika5
	INT 21h

	;Print "si =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, si
	CALL printAL

	;Print "[si]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [si]
	CALL printAX
	
	POP dx
	POP ax
RET
rm011:
	PUSH ax
	PUSH dx

	;Print "[bp+di], "
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bp =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bp
	CALL printAX

	;Print "[bp]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bp]
	CALL printAX
	MOV ah, 09h
	MOV dx, offset mnemonika5
	INT 21h

	;Print "di =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, si
	CALL printAL

	;Print "[di]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [di]
	CALL printAX
	
	POP dx
	POP ax
RET
rm100:
	PUSH ax
	PUSH dx

	;Print "[si], "
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "si =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, si
	CALL printAX

	;Print "[si]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [si]
	CALL printAX

	POP dx
	POP ax
RET
rm101:
	PUSH ax
	PUSH dx

	;Print "[di], "
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "di =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, di
	CALL printAX

	;Print "[di]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [di]
	CALL printAX

	POP dx
	POP ax
RET
rm111:
	PUSH ax
	PUSH dx

	;Print "[bx], "
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bx =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bx
	CALL printAX

	;Print "[bx]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bx]
	CALL printAX

	POP dx
	POP ax
RET
;*****************************************************
rm0002:
	PUSH ax
	PUSH dx

	;Print "[bx+si+_ _h], "
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bx =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bx
	CALL printAX

	;Print "[bx]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bx]
	CALL printAX
	MOV ah, 09h
	MOV dx, offset mnemonika5
	INT 21h

	;Print "si =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, si
	CALL printAL

	;Print "[si]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [si]
	CALL printAX
	
	POP dx
	POP ax

RET
rm0012:
	PUSH ax
	PUSH dx

	;Print "[bx+di+_ _h], "
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bx =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bx
	CALL printAX

	;Print "[bx]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bx]
	CALL printAX
	MOV ah, 09h
	MOV dx, offset mnemonika5
	INT 21h

	;Print "di =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, di
	CALL printAL

	;Print "[di]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [di]
	CALL printAX
	
	POP dx
	POP ax
RET
rm0102:
	PUSH ax
	PUSH dx

	;Print "[bp+si+_ _h], "
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bp =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bp
	CALL printAX

	;Print "[bp]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bp]
	CALL printAX
	MOV ah, 09h
	MOV dx, offset mnemonika5
	INT 21h

	;Print "si =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, si
	CALL printAL

	;Print "[si]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [si]
	CALL printAX
	
	POP dx
	POP ax
RET
rm0112:
	PUSH ax
	PUSH dx

	;Print "[bp+di+_ _h], "
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bp =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bp
	CALL printAX

	;Print "[bp]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bp]
	CALL printAX
	MOV ah, 09h
	MOV dx, offset mnemonika5
	INT 21h

	;Print "di =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, si
	CALL printAL

	;Print "[di]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [di]
	CALL printAX
	
	POP dx
	POP ax
RET
rm1002:
	PUSH ax
	PUSH dx

	;Print "[si+_ _h], "
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "si =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, si
	CALL printAX

	;Print "[si]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [si]
	CALL printAX

	POP dx
	POP ax
RET
rm1012:
	PUSH ax
	PUSH dx

	;Print "[di+_ _h], "
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "di =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, di
	CALL printAX

	;Print "[di]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [di]
	CALL printAX

	POP dx
	POP ax
RET
rm1102:
	PUSH ax
	PUSH dx

	;Print "[bp+_ _h], "
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bp =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bp
	CALL printAX

	;Print "[bp]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bp]
	CALL printAX

	POP dx
	POP ax
RET
rm1112:
	PUSH ax
	PUSH dx

	;Print "[bx+_ _h], "
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h
	

	;Print "bx =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bx
	CALL printAX

	;Print "[bx]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bx]
	CALL printAX

	POP dx
	POP ax
RET
;******************************************************
rm0003:
	PUSH ax
	PUSH dx

	;Print "[bx+si+_ _ _ _h], "
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas4
	CALL printAL
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bx =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bx
	CALL printAX

	;Print "[bx]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bx]
	CALL printAX
	MOV ah, 09h
	MOV dx, offset mnemonika5
	INT 21h

	;Print "si =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, si
	CALL printAL

	;Print "[si]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [si]
	CALL printAX
	
	POP dx
	POP ax

RET
rm0013:
	PUSH ax
	PUSH dx

	;Print "[bx+di+_ _ _ _h], "
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas4
	CALL printAL
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bx =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bx
	CALL printAX

	;Print "[bx]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bx]
	CALL printAX
	MOV ah, 09h
	MOV dx, offset mnemonika5
	INT 21h

	;Print "di =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, di
	CALL printAL

	;Print "[di]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [di]
	CALL printAX
	
	POP dx
	POP ax
RET
rm0103:
	PUSH ax
	PUSH dx

	;Print "[bp+si+_ _ _ _h], "
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas4
	CALL printAL
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bp =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bp
	CALL printAX

	;Print "[bp]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bp]
	CALL printAX
	MOV ah, 09h
	MOV dx, offset mnemonika5
	INT 21h

	;Print "si =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, si
	CALL printAL

	;Print "[si]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [si]
	CALL printAX
	
	POP dx
	POP ax
RET
rm0113:
	PUSH ax
	PUSH dx

	;Print "[bp+di+_ _ _ _h], "
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas4
	CALL printAL
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bp =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bp
	CALL printAX

	;Print "[bp]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bp]
	CALL printAX
	MOV ah, 09h
	MOV dx, offset mnemonika5
	INT 21h

	;Print "di =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, si
	CALL printAL

	;Print "[di]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [di]
	CALL printAX
	
	POP dx
	POP ax
RET
rm1003:
	PUSH ax
	PUSH dx

	;Print "[si+_ _ _ _h], "
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas4
	CALL printAL
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "si =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, si
	CALL printAX

	;Print "[si]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_si
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [si]
	CALL printAX

	POP dx
	POP ax
RET
rm1013:
	PUSH ax
	PUSH dx

	;Print "[di+_ _ _ _h], "
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas4
	CALL printAL
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "di =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, di
	CALL printAX

	;Print "[di]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_di
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [di]
	CALL printAX

	POP dx
	POP ax
RET
rm1103:
	PUSH ax
	PUSH dx

	;Print "[bp+_ _ _ _h], "
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas4
	CALL printAL
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h

	;Print "bp =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bp
	CALL printAX

	;Print "[bp]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bp
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bp]
	CALL printAX

	POP dx
	POP ax
RET
rm1113:
	PUSH ax
	PUSH dx

	;Print "[bx+_ _ _ _h], "
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "+"
	INT 21h
	MOV al, baitas4
	CALL printAL
	MOV al, baitas3
	CALL printAL
	MOV ah, 02h
	MOV dl, "h"
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika2
	INT 21h
	

	;Print "bx =_ _ _ _"
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 02h
	MOV dl, "="
	INT 21h
	MOV ax, bx
	CALL printAX

	;Print "[bx]=_ _ _ _, "
	MOV ah, 09h
	MOV dx, offset mnemonika3
	INT 21h
	MOV ah, 09h
	MOV dx, offset s_bx
	INT 21h
	MOV ah, 09h
	MOV dx, offset mnemonika4
	INT 21h
	MOV ax, offset word ptr [bx]
	CALL printAX

	POP dx
	POP ax
RET
;******************************************************
printAX:
	push ax
	mov al, ah
	call printAL
	pop ax
	call printAL
RET

printSpace:
	push ax
	push dx
	mov ah, 2
	mov dl, " "
	int 21h
	pop dx
	pop ax
RET

printEnter:
	push ax
	push dx
	mov ah, 9
	mov dx, offset enteris
	int 21h
	pop dx
	pop ax
RET

printAL:
	push ax
	push cx
		push ax
		mov cl, 4
		shr al, cl
		call printHexSkaitmuo
		pop ax
		call printHexSkaitmuo
	pop cx
	pop ax
RET

;Spausdina hex skaitmeni pagal AL jaunesniji pusbaiti (4 jaunesnieji bitai - > AL=72, tai 0010)
printHexSkaitmuo:
	push ax
	push dx
	
	and al, 0Fh ;nunulinam vyresniji pusbaiti AND al, 00001111b
	cmp al, 9
	jbe PrintHexSkaitmuo_0_9
	jmp PrintHexSkaitmuo_A_F
	
	PrintHexSkaitmuo_A_F: 
	sub al, 10 ;10-15 ===> 0-5
	add al, 41h
	mov dl, al
	mov ah, 2; spausdiname simboli (A-F) is DL'o
	int 21h
	jmp PrintHexSkaitmuo_grizti
	
	
	PrintHexSkaitmuo_0_9: ;0-9
	mov dl, al
	add dl, 30h
	mov ah, 2 ;spausdiname simboli (0-9) is DL'o
	int 21h
	jmp printHexSkaitmuo_grizti
	
	printHexSkaitmuo_grizti:
	pop dx
	pop ax
RET

END Pradzia
