;; euler92_console.asm
;; By Aaron W. West 2013-11-22 tallpeak@hotmail.com
;; Run successfully in Flat Assembler 1.70.03 on Windows 2008R2 x64
;; Modified from Hello.asm
;; See http://flatassembler.net/
;; Timing1: 12.4 billion ticks @ 2.66 Ghz Q9400 (about 4.7 seconds)
;; Timing2: 5 billion ticks Core i7 820QM (about 1.6 seconds)
;; caching first 568 sumSquareDigits timings:
;; 4.2 billion / 2.1 billion cycles (respectively)

;;;  about 14.9 million clocks, min of 20, AMD FX-8350
;;;  or is it 25.8 million, ack, getting different #s after change to puts?
	
; after adding two types of caches, down to 0.23 seconds (Q9400@2.66ghz on one core)
; still not a combinatorial/analytic but rather a brute-force approach

;; see http://msdn.microsoft.com/en-us/library/windows/hardware/ff561499(v=vs.85).aspx
;; for a list of x64 registers

;; Note that I mostly avoided stack operations.
;; Perhaps I should have used a few more registers, too, if I knew
;; about r8 to r15 before I started

;; also:
;; http://www.tortall.net/projects/yasm/manual/html/objfmt-win64-exception.html
;; "The registers RAX, RCX, RDX, R8, R9, R10, R11 are volatile and can be freely used by a called function without preserving their values"
;; (I violated this rule for RBX, RSI, RDI; oops)

; Example of 64-bit PE program
; this might work?http://pastebin.com/3kywjBDY

UPPERLIMIT = 10000000		; add up to two 0s; you can compute up to a billion

format ELF64 executable 3
entry start

include './examples/elfexe/dynamic/import64.inc'

interpreter '/lib64/ld-linux-x86-64.so.2'
needed 'libc.so.6'
import puts
	;; printf,exit		

segment readable executable


  start:
	;sub     rsp,8*5         ; reserve stack for API use and make stack dqword aligned
	;push rbx
	;push rsi
	;push rdi
	;push r11
	;push r12
	;push r13
	;push r14
	;push r15
	;call    computeEuler92
	;pop r15
	;pop r14
	;pop r13
	;pop r12
	;pop r11
	;pop rdi
	;pop rsi
	;pop rbx

	mov   [loop1c],20
loop1:
	call	computeEuler92
	;; https://montcs.bloomu.edu/~bobmon/Code/Asm.and.C/Asm.Nasm/hello-printf-64.asm.html
	mov edi, _message; 64-bit ABI passing order starts w/ edi, esi, ...
        ;; mov edi, formatstring
        ;; mov eax, 0      ; printf is varargs, so EAX counts # of non-integer arguments being passed
	call [puts]

	;; invoke printf,formatstring,_message

	dec   [loop1c]
	jnz   loop1

	;invoke  WriteConsole,<invoke GetStdHandle,STD_OUTPUT_HANDLE>,hello,5,dummy,0

	;mov     r9d,0
	;lea     r8,[_caption]
	;lea     rdx,[_message]
	;mov     rcx,0
	;call    [MessageBoxA]

	;; call	[getchar]
	;; mov	ecx,eax

	;; xor rcx,rcx
	;; call	[ExitProcess]

	;; call [exit]
	;; retq

        mov ebx, 0      ; normal-exit code
        mov eax, 1      ; process-termination service
        int 0x80        ; linux kernel service
	
;; input: n = rax
;; output: sum(square(digits(eax)))
;    let mutable s = 0
;    let mutable x = n
;    while x > 0 do
;        s <- s + square(x % 10)
;        x <- x / 10
;    s
sumSquareDigits:
	mov rbx, rax   ; n (digits)
	xor rsi, rsi ; zero sum
	mov rcx,10 ; divisor = 10
ssdl1:
	xor rdx, rdx ; upper dividend = 0
	mov rax, rbx ; dividend = remaining digits
	div rcx ; extract a digit to rdx
	mov rbx, rax ; save remaining digits
	;mov rax, rdx ; multiplier=multiplicand=digit extracted(mod 10)
	;mul rax ; digit**2
; saves about a billion cycles using a lookup table
	add rsi, [sqdigits+rdx*8]  ; sum
	or rbx,rbx ; test
	jnz ssdl1
	mov rax,rsi ; return in rax
	retq

;; per http://www.mathblog.dk/project-euler-92-square-digits-number-chain/
;; cache the first 568 sumSquares
;; this reduces the timing from 11 billion cycles (4.2 seconds)
;; to 4.2 billion cycles (1.6 seconds) on Q9400
;; merely the speed of the non-memoized/non-cached scala!
;; cached scala was below a second!
makeSSDcache:
	mov rdi, 0
msc1:
	mov rax, rdi
	call sumSquareDigits
	mov [ssdcache+rdi*8],rax
	inc rdi
	cmp rdi, 1000
	jl  msc1
	retq
;;
ssd2:	cmp rax, 1000
	jae ssd3 ;; sumSquareDigits
	mov rax, [ssdcache+rax*8]
	retq
ssd3:	mov rcx, 1000
	xor rdx,rdx
	div ecx ; rdx = remainder, 0 to 999
	mov r8, [ssdcache+rdx*8]
	xor rdx,rdx
	div ecx   ;32-bit division is 2.2X faster!
	mov rdx, [ssdcache+rdx*8] ; remainder
	mov rax, [ssdcache+rax*8] ; quotient should be 0 to 10 because we only go to 10 million
	add rax,rdx
	add rax,r8
	retq


;4189374bc6a7ef ; printf "%x"$ 2^64`div`1000

ssdmul:
; optimize division using multiplication by inverse
	mov rcx, 004189374bc6a7f0h ; ghci>printf"%x"$toInteger$ceiling$2^64/1000
	mul rcx 		   ; rdx = div, rax*1000>>64 = remainder
	push rax	       ; r8 = remainder, needs scaling
	mov rax, rdx
	mul rcx 		   ; rdx=upper digits, rax=middle digits, need scaling
	mov rbx, [ssdcache+rdx*8]  ; lookup upper digits
	mov rcx, 1000		   ; for scaling
	mul rcx 		   ; rdx = middle digits
	add rbx, [ssdcache+rdx*8]
	pop rax
	mul rcx
	add rbx, [ssdcache+rdx*8]
	mov rax,rbx
	retq
	 ; 8581146 in 68.4 to 71 million clock cycles @ 3487Mhz, or about 20ms

; let rec termination x = if x = 1 || x = 89 then x
;                        else termination (sumSquareDigits x)
termination:
t1:
	cmp rax, 1
	jz  termdone
	cmp rax, 89
	jz  termdone
	call ssdmul ;; sumSquareDigits
	jmp t1
termdone:
	retq

clearSSDhistogram:
	lea rdi,[ssdhist]
	mov rcx,1000
	;shr rcx,1
	xor rax,rax
	cld
	rep stosq
	retq

makeSSDhistogram_mul:
	xor r9,r9
bh1:
	mov rax, r9
	;call ssd3  ; div: 201 to 205 million cycles
	call ssdmul ; 68 to 70 million cycles
	inc  qword[ssdhist+rax*8]
	inc  r9
	cmp  r9, UPPERLIMIT
	jl   bh1
	retq

; use nested loops to avoid division completely
; sumSquaredDigits(9876543) = ssd(9) + ssd(876) + ssd(543)
makeSSDhistogram_count:
	push r8
	push r9
	push r10
	push r11
	push rdx
	mov r9,9  ; millions
shcm:	mov r10,999 ; thousands
shct:	;mov r11,999 ; units
	lea r11,[ssdcache] ; let's count units forward, and unroll the loop a bit
	mov rbx, [ssdcache+r9*8]
	add rbx, [ssdcache+r10*8]
	lea rbx, [ssdhist+rbx*8]
	; DONT UNROLL TOO MUCH! loop buffer on Nehalem is 28 uops,
	; inc [mem]=3 so below is about 21 uops or less with 4x unroll
	; minimum TSC ~ 15830000 with 8x unroll (much slower!)
	; minimum TSC ~ 13920000 with 4x unroll (fastest)
	;unrolling the loop below 8X only gained about 4% speed, but about 20% with 4X unroll
	;jmp shcu
	;align 16        ; align 16 or more slows this way down!!! about 18 million cycles!
	lea r8,[after_ssdcache]	
shcu:	;mov rax,rbx       ; this is the "hot spot" of the program
	mov rax,[r11]	  ; it could be unrolled for minimal gains
	inc qword[rbx+rax*8]	 ; sse/avx vector instructions might yield up to 2:1 gains  probably using scatter/gather for the updates (gather 8 dwords, add 1 to each, scatter back)
	mov rax,[r11+8]
	inc qword[rbx+rax*8]
	mov rax,[r11+16]
	inc qword[rbx+rax*8]
	mov rax,[r11+24]
	inc qword[rbx+rax*8]

       ; mov rax,[r11+32]
       ; inc qword[rbx+rax*8]
       ; mov rax,[r11+40]
       ; inc qword[rbx+rax*8]
       ; mov rax,[r11+48]
       ; inc qword[rbx+rax*8]
       ; mov rax,[r11+56]
       ; inc qword[rbx+rax*8]

	;mov ymm1,[r11]
	;vpgatherqq ymm1, [rcx+ymm2*8] ,ymm3

	add r11,8*4 ; 8*8
	cmp r11,r8
	jb shcu
	sub r10,1
	jnc shct
	sub r9,1
	jnc shcm
	pop rdx
	pop r11
	pop r10
	pop r9
	pop r8
	retq
; 1.65 billion clocks for 1 billion using this procedure (~480ms), versus 5.5 seconds in a Scala worksheet
; 16.7 million clocks for 10 million using this proc (~5ms)

sumSSDhistogram:
	mov rdi,999 ;table index counter
	xor r9,r9 ; sum
sumh1:
	mov rax, rdi
	call termination
	cmp rax,89
	jnz sumhnot89
	add r9,[ssdhist+rdi*8]
sumhnot89:
	dec rdi
	jnz sumh1
	mov rax,r9
	retq

;pure brute-force
;// 4.5 seconds
;let countT89 () =
;    let mutable count = 0 in
;    for i = 1 to 10000000 do
;        if (termination i) = 89 then
;            count <- count + 1
;        else ()
;    count
;countT89:
;        mov qword [ct89], 0
;        mov qword [c89loop], 1
;c89l:
;        mov rax, [c89loop]
;        call termination
;
;        cmp  rax, 89
;        jnz  not89
;        inc qword [ct89]
;not89:
;        inc  qword[c89loop]
;        cmp  qword[c89loop], 10000000
;        jl   c89l
;        mov  rax, [ct89]
;        retq

;;      compute the value then convert to decimal in the buffer
computeEuler92:
	RDTSC
	mov [T0H],edx
	mov [T0L],eax
	call makeSSDcache
	;call countT89
	call clearSSDhistogram
	;call makeSSDhistogram_div
	;call makeSSDhistogram_mul
	call makeSSDhistogram_count
	call sumSSDhistogram
	push rax
	RDTSC
	mov [T1H],edx
	mov [T1L],eax
	pop rax
	lea rdi,[_messageRest] ; end of buffer
	call utoa

	;this is the hard way:
	;mov eax,[T1L]
	;mov edx,[T1H]
	;sub eax,[T0L]
	;sbb edx,[T0H]
;; for some strange reason, I couldn't seem to just "and rax, 0ffffffffh" with this assembler...
;; see http://board.flatassembler.net/topic.php?p=101848
	;shl rax, 32
	;shr rax, 32
	;"In 64-bit mode, all operations on 32-bit registers clear the upper dword"
	;mov eax,eax
	;shl rdx, 32
	;or  rax, rdx

	;This is the easy way:
	mov rax,qword[T1L]
	sub rax,qword[T0L]

	lea rdi,[TSCdisplayend]
	call utoa
	retq

utoa_div:
	mov rbx,rax ; digits in rbx
	mov rcx, 10
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

; multiplication-by-inverse version
; divmod10 can be implemented in two multiplies, so let's try it
utoa_mul:
utoa:
	mov rbx, rax
	mov rcx, 0x199999999999999a  ;Text.Printf.printf"%x"$(2^64+9)`div`10
	mov rsi, 10
u2am1:
	mov rax, rbx
	mul rcx      ; rax contains modulus in high bits, rdx = div
	mov rbx, rdx ; save div back to rbx
	mul rsi      ; now rdx = modulus (last digit, 0 to 9)
	or  dl, '0'
	dec rdi
	mov [rdi], dl
	or  rbx, rbx
	jnz u2am1
	retq






; some unused and broken (not converted to 64-bit) utoa routines:
;32-bit version is at:
;http://www.df.lth.se/~john_e/gems/gem003e.html
;
; ulong2ascii
;
; input:
;   rax = unsigned long to be converted to ASCIIZ string
;   rdi = pointer to character buffer which receives result (at least 21 chars)
;
; output:
;   none (buffer filled with numbers)
;
; destroys:
;   rax, rbx, rcx, rdx, rsi, rdi
;   rflags
;conversion to 64-bit is not complete; this will not work
;ulong2ascii:
;        mov     rcx,rax         ; save original argument
;        mov     rsi,89705f41h   ; 1e-9*2^61 rounded
;        mul     rsi             ; divide by 1e9 by mult. with recip.
;        add     rax,80000000h   ; round division result
;;       mov     rsi,0abcc7712h  ; 2^28/1e8 * 2^30 rounded up
;       adc     rdx,0           ; rdx<31:29> = argument / 1e9
;       mov     rax,rcx         ; restore original argument
;       shr     rdx,29          ; leading decimal digit, 0...4
;       mov     rcx,8           ; produce eight more digits
;       mov     rbx,rdx         ; flags whether non-zero digit seen yet
;       or      rdx,'0'         ; convert digit to ASCII
;       mov     [rdi],dl        ; store out to memory
;       cmp     rbx,1           ; first digit nonzero ? CY=0 : CY=1
;       sbb     rdi,-1          ; incr. pointer if first digit non-zero
  ;      imul    rbx,1000000000  ; multiply quotient digit by divisor
  ;      sub     rax,rbx         ; remainder after first digit
  ;      mul     rsi             ;  convert number < 1e9
  ;;      shld    rdx,rax, 2      ;   into fraction such
  ;      inc     rdx             ;    that 1.0 = 2^28
  ;      mov     rax,rdx         ; save result
  ;      shr     rax,28          ; next digit
  ;      and     rdx,0fffffffh   ; fraction part
  ;      or      rbx,rax         ; any non-zero yet ?
  ;      or      rax,'0'         ; convert digit to ASCII
;cvt_loop:
;        mov     [rdi],al        ; store digit out to memory
;        add     rdx,rdx         ; 2*fraction
;        cmp     rbx,1           ; any non-zero digit seen ? CY=0 : CY=1
;;       lea     rdx,[rdx*4+rdx] ; 10*fraction, new digit rax<31:28>,
;                               ; new fraction rax<27:0>
;       sbb     rdi,-1          ; incr. ptr if any non-zero digit seen
;       mov     rax,rdx         ; save result
;       shr     rax,28          ; next digit = integer part
;       and     rdx,0fffffffh   ; fraction part
;       or      rbx,rax         ; any non-zero digit yet ?
;       or      rax,'0'         ; convert digit to ASCII
;       dec     rcx             ; one more digit
;       jnz     cvt_loop        ; until all nine digits done
;       mov     [rdi],al        ; store last digit out to memory
;       mov     [byte ptr rdi+1],ah     ; place string end marker
  ;      retq


;;or this one
;char *dtoa(char *buf, unsigned long n)
;{
;        __asm {
;                mov ebx,[n]
;                mov eax,2814749767
;                mul ebx
;                shr ebx,1
;                xor ecx,ecx
;                mov edi,[buf]
;                add eax,ebx
;                adc ecx,edx
;               mov eax,100000
;               shr ecx,16              // ECX =3D high part
;               mov ebx,[n]             // Retrieve org. number
;;               imul eax,ecx            // High part * 100k
;               sub ebx,eax             // Remainder =3D Low part
;               mov eax,429497
;               mul ecx
;               mov ecx,eax
;               add dl,'0'
;               mov eax,429497
;               mov [edi],dl
  ;              mul ebx
  ;              mov ebx,eax
  ;;              add ecx,7
  ;              shr ecx,3
  ;              add dl,'0'
  ;              mov [edi+5],dl
  ;              add ebx,7
  ;              shr ebx,3
;               lea ecx,[ecx+ecx*4]
;               mov edx,ecx
;               and ecx,0fffffffh
;               shr edx,28
;                lea ebx,[ebx+ebx*4]
;               add dl,'0'
;                mov eax,ebx
;                shr eax,28
;               mov [edi+1],dl
;                and ebx,0fffffffh
;                add al,'0'
;                mov [edi+6],al
;               lea ecx,[ecx+ecx*4]
;                lea ebx,[ebx+ebx*4]
;               mov edx,ecx
;                 mov eax,ebx
;                and ecx,07ffffffh
;                shr edx,27
;                 and ebx,07ffffffh
;                 shr eax,27
;                add dl,'0'
;                 add al,'0'
;                mov [edi+2],dl
;                 mov [edi+7],al
;                lea ecx,[ecx+ecx*4]
;                 lea ebx,[ebx+ebx*4]
;                mov edx,ecx
;                 mov eax,ebx
;                and ecx,03ffffffh
;                shr edx,26
;                 and ebx,03ffffffh
;                 shr eax,26
;                add dl,'0'
;                 add al,'0'
  ;              mov [edi+3],dl
;                 mov [edi+8],al
;                lea ecx,[ecx+ecx*4]
;                shr ecx,25
;                 lea ebx,[ebx+ebx*4]
;                 shr ebx,25
;                add cl,'0'
;                 add bl,'0'
;                mov [edi+10],ah
;                mov [edi+4],cl
;                 mov [edi+9],bl
;;        }
;        return buf;
;from
;http://computer-programming-forum.com/46-asm/7aa4b50bce8dd985.htm


segment readable writeable
;; 20 bytes per number because (length $ show $ 2^64) == 20
dummy dq 1
formatstring db '%s',0
  hello db 'hello',0
  _caption db 'Win64 assembly euler#92',0
  _message db 'Euler92='
  _messageReturn db '                   0'
  _messageRest db '  TSC=                   0'
  TSCdisplayend db 0
;;13,10,'Divide TSC by your clock frequency to compute elapsed time'
;;        db 13,10,13,'Thank you for your time!',0

  sqdigits dq 0,1,4,9,16,25,36,49,64,81
  ct89 dq 0
  c89loop dq 0
  T0L dd 0
  T0H dd 0
  T1L dd 0
  T1H dd 0
  loop1c dq 10

;; ; experiments with AVX
;;   align 64
;;   z0 rq 8
;;   zones dq 1,1,1,1,1,1,1,1

  ;; align 64
  ssdcache rq 1000 ; ssd [0..999] fits in bytes
  after_ssdcache rq 0	
  ssdhist  rq 1000 ; histogram to store count of sumSquareDigits for 1..1000000


