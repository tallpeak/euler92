;; time_fbcd.asm
;; By Aaron W. West 2013-12-20 tallpeak@hotmail.com

ITERATIONS = 10000

; timing is consistently around 216 for fbstp regardless of the size of the number (not including printf %x conversion)
; timing is around 230 for div for 9 digits or 460+ for 18 digits
; timing is around 42 to 76 cycles for utoa_mul with 9 to 18 digits
; timing is around 230+ cycles for 9 digits for _itoa, similar to div loop
;
format PE64 console
entry start

include 'C:\dev\fasmw\INCLUDE\WIN64a.INC' ; win64a?
;include 'C:\dev\fasmw\INCLUDE\API\KERNEL32.INC' ; win64a?
;SetConsoleWindowInfo
;SetConsoleScreenBufferSize
macro timer_save timer {
	RDTSC
	shl rdx,32
	;mov eax,eax     ; zero top 32 bits
	or  rax,rdx
	mov qword[timer],rax ;avoiding the stack incase we don't pair these properly
}

macro timer_elapsed timer {
	RDTSC
	shl rdx,32
	;mov eax,eax     ; this seems unnecessary
	or  rax,rdx
	sub rax,qword[timer]
}

UPPERLIMIT = 10000000		; add up to two 0s; you can compute up to a billion

section '.text' code readable executable

  start:
	;sub     rsp,8*5         ; reserve stack for API use and make stack dqword aligned
	;http://board.flatassembler.net/topic.php?t=1953
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov [hStdOut], rax

	;stdcall WINDOW, [hStdOut], 80,50
	;mov rcx,[hStdOut]
	;mov rdx,80
	;mov r8,50
	;call WINDOW

	;invoke SetConsoleScreenBufferSize, [handle], dword [coord]
	;test eax, eax
	;jz .error


	mov [counter],ITERATIONS	 ; iterations to run (one line per iteration)
	lea rcx,[headerline]	 ; a header so that people can see what I'm timing
	call [printf]
loop1:

; first time floating point bcd store and pop instruction
	timer_save T0

	mov rax,123456789 ;012345678 ; 18 digit max
	mov qword[ildvalue],rax
	fild qword[ildvalue]
	fbstp tword[ildvalue]

	timer_elapsed T0

	lea rcx,[formattime_hex]
	mov rdx,rax
	movzx r8,word[ildvalue+8]
	mov r9,qword[ildvalue]
	call [printf]

; now time my utoa with multiply by reciprocal method

	timer_save T0

	mov rax,123456789
	lea rdi, [utoabuf+23]
	;call donothing ; 18 cycles
	call utoa_mul ; 45 cycles , so 27 really

	timer_elapsed T0

	;lea rcx,[formattime_string]
	;mov rdx,rax
	;mov r8,rdi
	;call [printf]
	invoke printf,formattime_string,rax,rdi

; now time utoa with division method
	timer_save T0

	mov rax,123456789
	lea rdi, [utoabuf+23]
	call utoa_div

	timer_elapsed T0

	lea rcx,[formattime_string]
	mov rdx,rax
	mov r8,rdi
	call [printf]

; now time msvcrt _itoa
	timer_save T0

	mov rcx,123456787
	lea rdx,[utoabuf]
	mov r8,10 ; number base
	call [_itoa]

	timer_elapsed T0

	;lea rcx,[formattime_string]
	;mov rdx,rax
	;lea r8,[utoabuf]
	;call [printf]
	invoke printf,formattime_string,rax,utoabuf

	lea rcx,[newline]
	call [printf]


	dec [counter]
	jnz loop1

	invoke printf,press_enter
	call [getchar]
	call [ExitProcess]
	retq

utoa_div:
	mov rbx,rax ; digits in rbx
	mov rcx, 10
	mov [rdi],byte 0
u2a1:
	dec rdi
	mov rax, rbx
	xor rdx, rdx
	div rcx
	mov rbx, rax
	add rdx,'0'
	mov [rdi], dl
	or  rbx,rbx
	jnz u2a1
	retq

donothing: retq ; for timing the overhead

; multiplication-by-inverse version
; divmod10 can be implemented in two multiplies, so let's try it
utoa_mul:
utoa:
	mov rbx, rax
	mov rcx, 0x199999999999999a  ;Text.Printf.printf"%x"$(2^64+9)`div`10
	mov rsi, 10
	mov [rdi],byte 0
u2am1:
	mov rax, rbx
	mul rcx      ; rax contains modulus in high bits, rdx = div
	mov rbx, rdx ; save div back to rbx
	mul rsi      ; now rdx = modulus (last digit, 0 to 9)
	or  rdx, '0'
	dec rdi
	mov [rdi], dl
	or  rbx, rbx
	jnz u2am1
	retq

;crashes:
WINDOW:
;------------------------------------------------------------
; 
;proc WINDOW uses rcx rdx, handle, x, y
;   Usage: 
;       stdcall WINDOW, output_handle, cols, rows 
;   Returns: 
;       EAX = zero on success, else -1. 
; 
;------------------------------------------------------------ 
	;local coord COORD
	;local rect SMALL_RECT

	;cmp [x], MIN_COLS 
	;jb .error 
	;cmp [y], MIN_ROWS 
	;jb .error 
	;cmp [x], MAX_COLS 
	;ja .error 
	;cmp [y], MAX_ROWS 
	;ja .error 

	mov r11,rcx
	or r11, r11 ; [handle]
	jz .error
	mov [handle],r11

	jmp .skipestimate
	; Get the largest size we can size the console window to. 
	invoke GetLargestConsoleWindowSize, [handle]
	mov dword[coord.X], eax

	mov [rect.Left], 0 
	mov [rect.Top], 0 
	mov [rect.Right], 1 
	mov [rect.Bottom], 1 

	; Set window size to 1,1 in order to set any buffer size. 
	invoke SetConsoleWindowInfo, [handle], TRUE, addr rect.Left
	test eax, eax 
	jz .error 

	; rect.Right = min(x, coord.X) - 1) 
	mov rax, rdx
	movzx ecx, word [coord.X] 
	sub ecx, eax 
	sbb edx, edx 
	and ecx, edx 
	add eax, ecx 
	dec eax 
	mov [rect.Right], rax

	; rect.Bottom = min(y, coord.Y) - 1) 
	mov rax, r8
	movzx ecx, word [coord.Y] 
	sub ecx, eax 
	sbb edx, edx 
	and ecx, edx 
	add eax, ecx 
	dec eax 
	mov [rect.Bottom], rax

	; Define the new console buffer size. 
	mov rax, rdx
	mov [coord.X], ax
	mov rax, r8
	mov [coord.Y], ax

;.skipestimate:
	mov rcx,80
	mov rdx,50
	mov [coord.X],cx
	mov [coord.Y],dx
	;mov r12,80*65536+25
	; Set console screen buffer size.
	mov r12,80*25
	invoke SetConsoleScreenBufferSize, [handle], r12 ;dword [coord.X] ; [handle]=[handle]
	test eax, eax 
	jz .error 
	retq


.skipestimate:
	; Set console screen buffer's window size and position.
	invoke SetConsoleWindowInfo, [handle], TRUE, addr rect.Left  ; [handle]=[handle]
	test eax, eax 
	jz .error 

	xor eax, eax 
	retq

.error:
	mov eax, -1 
	retq
;endp


section '.data' data readable writeable
;; 20 bytes per number because (length $ show $ 2^64) == 20
  T0 dq 0
  counter dq 100
  utoabuf rb 24
  ildvalue dt 0.0
  formatdecimal db '%d',9,0
  formatstring db '%s',9,0
  formattime_string db '%3d %10s  ',0
  formattime_hex db '%3d %llx%llx  ',0
  headerline db 'RDTSC clock timings and output for integer to decimal routines',10
	    db 'Fbstp/output   utoa_mul/output  utoa_div/output  itoa/output',10,0
  newline db 10,0
  press_enter db 'Press enter to continue.',0
  _caption db 'Win64 assembly',0
  align 8
  hStdOut dq 0
 handle dq 0
 struct coord
      X dw ?
      Y dw ?
 ends
 struct rect
	Left dq 0
	Top dq 0
	Right dq 79
	Bottom dq 49
 ends


section '.idata' import data readable
  library kernel32, 'kernel32.dll', \
	  msvcrt,   'msvcrt.dll'
  import kernel32, ExitProcess, 'ExitProcess', GetStdHandle, 'GetStdHandle', SetConsoleScreenBufferSize, 'SetConsoleScreenBufferSize', \
	 SetConsoleWindowInfo, 'SetConsoleWindowInfo', GetLargestConsoleWindowSize, 'GetLargestConsoleWindowSize'
  import msvcrt, printf, 'printf', getchar, 'getchar', _itoa, '_itoa'

  kernel_name db 'KERNEL32.DLL',0
  user_name db 'USER32.DLL',0
;;EOF