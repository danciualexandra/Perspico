.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf:proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Proiect Perspico",0
area_width EQU 640
area_height EQU 480
area DD 0
tabel_start_x0 DD 160
tabel_start_y0 DD 20
latura_w equ 100
latura_h equ 100
verifica_afara DD 0





matrice DB -16,3,6,7
        DB 11,14,15,12
		DB 10,5,1,4
		DB 13,8,2,9
		
format DB "%d %d",10,0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
x dd ?
y dd ?

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

 
 
 
click_tabla proc
	;verificam daca am dat click in tabla de joc
	mov esi, edx
	cmp ebx, 160
	jl afara
	mov eax, 3
	mov ecx, 100
	mul ecx
	add eax, 160
	cmp ebx, eax
	jge afara
	mov edx, esi
	cmp edx, 20
	jl afara
	mov eax, 3
	mov ecx, 100
	mul ecx
	add eax, 20
	mov edx, esi
	cmp edx, eax
	jge afara
	mov eax, 1
	mov verifica_afara, eax       
	jmp afara_tabla
afara:
	mov eax, 0
	mov verifica_afara, eax
afara_tabla:
	ret
click_tabla endp

make_move proc
	
	mov eax , y
	mov ebx , 4
	mul ebx
	add eax , x
	
	;Check upper box
	
	
	
	mov ebx , eax
	sub ebx , 4
	
	cmp ebx , 0
	jl skip1
	
	
	mov cl , matrice[ebx]
	
	cmp cl , -16
	jne skip1
	
	mov ch , matrice[eax]
	
	mov matrice[ebx] , ch
	mov matrice[eax] , cl
	
	skip1:
	
	
	mov ebx , eax
	sub ebx , 1
	
	cmp ebx , 0
	jl skip2
	
	
	mov cl , matrice[ebx]
	
	cmp cl , -16
	jne skip2
	
	mov ch , matrice[eax]
	
	mov matrice[ebx] , ch
	mov matrice[eax] , cl
	
	skip2:
	
	
	mov ebx , eax
	add ebx , 4
	
	cmp ebx , 15
	jg skip3
	
	
	mov cl , matrice[ebx]
	
	cmp cl , -16
	jne skip3
	
	mov ch , matrice[eax]
	
	mov matrice[ebx] , ch
	mov matrice[eax] , cl
	
	skip3:
	
	mov ebx , eax
	add ebx , 1
	
	cmp ebx , 15
	jg skip4
	
	
	mov cl , matrice[ebx]
	
	cmp cl , -16
	jne skip4
	
	mov ch , matrice[eax]
	
	mov matrice[ebx] , ch
	mov matrice[eax] , cl
	
	skip4:
	ret
	
make_move endp

transform proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax ,[ebp +arg1]
	sub eax , 160
	xor edx,edx
	mov ebx,100
	div ebx
	mov x,eax
	
	mov eax ,[ebp +arg2]
	sub eax , 20
	xor edx,edx
	mov ebx,100
	div ebx
	mov y,eax
	
	
	popa
	mov esp, ebp
	pop ebp
	ret
transform endp
 
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp
   

   
   
; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

;adaugaaaaaat 
fill_value proc
	push ebp
	mov ebp, esp

	xor ebx ,ebx
	mov eax, [ebp+arg1]
	shl eax, 2
	add eax, [ebp+arg2]
	mov ebx, 1
	mov bl, matrice[eax]

	cmp bl , 10
	jge greate_than_10
	
	add bl , '0'
	
	mov eax , [ebp + arg2]
	mov ecx , 100
	mul ecx
	add eax , 230
	
	push eax
	
	mov eax , [ebp + arg1]
	mov ecx , 100
	mul ecx
	add eax , 60
	pop ecx
	
	make_text_macro ebx , area , ecx , eax
	sub ecx , 10
	make_text_macro ' ' , area , ecx , eax
	add ecx , 20
	make_text_macro ' ' , area , ecx , eax
	
	mov esp, ebp
	pop ebp
	ret
	
	greate_than_10:
	
	mov eax , ebx
	mov ebx , 10
	xor edx , edx
	div ebx
	mov ebx , edx
	add ebx , '0'
	
	mov eax , [ebp + arg2]
	mov ecx , 100
	mul ecx
	add eax , 235
	
	push eax
	
	mov eax , [ebp + arg1]
	mov ecx , 100
	mul ecx
	add eax , 60
	pop ecx
	
	make_text_macro ebx , area , ecx , eax
	sub ecx , 10
	make_text_macro '1' , area , ecx , eax
	

	mov esp, ebp
	pop ebp
	ret
fill_value endp

draw_grid macro

;punem primul elem din matrice
push 0
push 0
call fill_value
add esp, 8


;al doilea elem din matrice
push 1
push 0
call fill_value
add esp,8

;al treilea elem din matrice
push 2
push 0
call fill_value
add esp,8

;al patrulea elem din matrice
push 3
push 0
call fill_value
add esp,8

;linia a doua
push 0
push 1
call fill_value
add esp,8

sub ebx,'0'
mov eax,ebx
mov edx,0
mov ebx,10
div ebx

add eax,'0'
add edx,'0'



push 1
push 1
call fill_value
add esp,8

sub ebx,'0'
mov eax,ebx
mov edx,0
mov ebx,10
div ebx

add eax,'0'
add edx,'0'


  
push 2
push 1
call fill_value
add esp,8 
 
sub ebx,'0'
mov eax,ebx
mov edx,0
mov ebx,10
div ebx

add eax,'0'
add edx,'0'


push 3
push 1
call fill_value
add esp,8 
 
sub ebx,'0'
mov eax,ebx
mov edx,0
mov ebx,10
div ebx

add eax,'0'
add edx,'0'


push 0
push 2
call fill_value
add esp,8 
 
sub ebx,'0'
mov eax,ebx
mov edx,0
mov ebx,10
div ebx

add eax,'0'
add edx,'0'



push 1
push 2
call fill_value
add esp,8

 
push 2
push 2
call fill_value
add esp,8


push 3
push 2
call fill_value
add esp,8


push 0
push 3
call fill_value
add esp,8 
 
sub ebx,'0'
mov eax,ebx
mov edx,0
mov ebx,10
div ebx

add eax,'0'
add edx,'0'


push 1
push 3
call fill_value
add esp, 8


push 2
push 3
call fill_value
add esp, 8


push 3
push 3
call fill_value
add esp, 8

endm


; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	

	
	make_text_macro 'P',area,20,90
	make_text_macro 'E',area,20,110
	make_text_macro 'R',area,20,130
	make_text_macro 'S',area,20,150
	make_text_macro 'P',area,20,170
	make_text_macro 'I',area,20,190
	make_text_macro 'C',area,20,210
	make_text_macro 'O',area,20,230
	
	;make_text_macro '9',area,230,70
	;make_text_macro '3',area,330,70
	;make_text_macro '6',area,430,70
	;make_text_macro '7',area,530,70
	;make_text_macro '1',area,230,170
	;make_text_macro '1',area,240,170
	;make_text_macro '1',area,330,170
	;make_text_macro '4',area,340,170
	;make_text_macro '1',area,430,170
	;make_text_macro '5',area,440,170
	;make_text_macro '1',area,530,170
	;make_text_macro '2',area,540,170
	;make_text_macro '1',area,230,270
	;make_text_macro '0',area,240,270
	;make_text_macro '5',area,330,270
	;make_text_macro '1',area,430,270
	;make_text_macro '4',area,530,270
	;make_text_macro '1',area,230,370
	;make_text_macro '3',area,240,370
	;make_text_macro '8',area,330,370
	;make_text_macro '2',area,430,370
	;make_text_macro '0',area,530,370

	


	
;prima linie orizontala a chenarului
	mov eax,area_width
	mov ebx,20
	mul ebx
	mov ebx,160
	add eax,ebx
	shl eax,2
	mov ebx,area
	add eax,ebx
	mov ecx,400
	l0:
	mov dword ptr [eax+ecx*4], 0000000
	loop l0	
	
;a doua linie orizontala a chenarului
	mov eax,area_width
	mov ebx,120
	mul ebx
	mov ebx,160
	add eax,ebx
	shl eax,2
	mov ebx,area
	add eax,ebx
	mov ecx,400
	l1:
	mov dword ptr [eax+ecx*4], 0000000
	loop l1
	
	;a doua linie orizontala a chenarului
	mov eax,area_width
	mov ebx,220
	mul ebx
	mov ebx,160
	add eax,ebx
	shl eax,2
	mov ebx,area
	add eax,ebx
	mov ecx,400
	l2:
	mov dword ptr [eax+ecx*4], 0000000
	loop l2
	
	;a 3 a linie orizontala a chenarului
	mov eax,area_width
	mov ebx,320
	mul ebx
	mov ebx,160
	add eax,ebx
	shl eax,2
	mov ebx,area
	add eax,ebx
	mov ecx,400
	l3:
	mov dword ptr [eax+ecx*4], 0000000
	loop l3
	
	;a 4 a linie orizontala a chenarului
	mov eax,area_width
	mov ebx,420
	mul ebx
	mov ebx,160
	add eax,ebx
	shl eax,2
	mov ebx,area
	add eax,ebx
	mov ecx,400
	
	l4:
	mov dword ptr [eax+ecx*4], 0000000
	loop l4
	
	
	
	;prima linie verticala
	mov eax,area_width
	mov ebx,20
	mul ebx
	mov ebx,160
	add eax,ebx
	shl eax,2
	mov ebx,area
	add eax,ebx
	mov ecx,400
	mov ebx,eax
	l5:
	mov eax,area_width
	mul ecx
	mov dword ptr[ebx+eax*4], 0000000
	loop l5
	
	;a doua linie verticala
	mov eax,area_width
	mov ebx,20
	mul ebx
	mov ebx,260
	add eax,ebx
	shl eax,2
	mov ebx,area
	add eax,ebx
	mov ecx,400
	mov ebx,eax
	l6:
	mov eax,area_width
	mul ecx
	mov dword ptr[ebx+eax*4], 0000000
	loop l6
	
	;a treia linie verticala
	mov eax,area_width
	mov ebx,20
	mul ebx
	mov ebx,360
	add eax,ebx
	shl eax,2
	mov ebx,area
	add eax,ebx
	mov ecx,400
	mov ebx,eax
	l7:
	mov eax,area_width
	mul ecx
	mov dword ptr[ebx+eax*4], 0000000
	loop l7
	
	;a patra linie verticala
	mov eax,area_width
	mov ebx,20
	mul ebx
	mov ebx,460
	add eax,ebx
	shl eax,2
	mov ebx,area
	add eax,ebx
	mov ecx,400
	mov ebx,eax
	l8:
	mov eax,area_width
	mul ecx
	mov dword ptr[ebx+eax*4], 0000000
	loop l8

	;a cincea linie verticala
	mov eax,area_width
	mov ebx,20
	mul ebx
	mov ebx,560
	add eax,ebx
	shl eax,2
	mov ebx,area
	add eax,ebx
	mov ecx,400
	mov ebx,eax
	l9:
	mov eax,area_width
	mul ecx
	mov dword ptr[ebx+eax*4], 0000000
	loop l9
	draw_grid
	
jmp final_draw
evt_click:
	
	mov eax , [ebp + arg2]
	mov ebx , [ebp + arg3]
	
	push ebx
	push eax
	call transform
	add esp , 8
	
	push y
	push x
	push offset format
	call printf
	add esp , 12
	
	call make_move
	
	draw_grid

evt_timer:
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:



	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
