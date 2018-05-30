;; NumTo26Sys.asm
;; By Aaron W. West  tallpeak@hotmail.com
;; timing = about 175 clocks @ 2.66ghz i5-3320M
;;https://en.wikipedia.org/wiki/Time_Stamp_Counter

format PE64 console
entry start

include 'INCLUDE\WIN64a.INC' ; win64a?

section '.text' code readable executable

  start:
        mov   [loop1c],20
loop1:
        call   time_NumTo26Sys
        call   time_NumTo26Sys_fast
        invoke printf,formatstring,_message
        dec   [loop1c]
        jnz   loop1

        call    [getchar]
        mov     ecx,eax

        xor rcx,rcx
        call    [ExitProcess]
        retq

;;F#:
;let NumTo26Sys1(num:int) =
;    let mutable n = num
;    [| while n > 0 do
;        n <- n - 1
;        yield (char (n % 26 + 65))
;        n <- n / 26 |]
;    |> Array.rev
;    |> String

;; input: n = rax
;; output: rdi = pointer to end of output
NumTo26Sys:
        or rax,rax
        jle NumTo26Sys_exit
        dec rax
        xor rdx,rdx
        mov rbx,26
        div rbx
        add rdx,'A'
        mov [rdi],dl
        dec rdi
        cmp rdi,_message   ;; bounds check
        ja NumTo26Sys
NumTo26Sys_exit:
        retq


NumTo26Sys_fast:
        mov rbx, rax
        mov rcx, 0x09d89d89d89d89d9 ;Text.Printf.printf"%016x"$(2^64+25)`div`26
        push rsi
        mov rsi, 26
nt261:
        dec rbx
        mov rax, rbx
        mul rcx      ; rax contains modulus in high bits, rdx = div
        mov rbx, rdx ; save div back to rbx
        mul rsi      ; now rdx = modulus (last digit, 0 to 25)
        add  dl, 'A'
        dec rdi
        mov [rdi], dl
        or  rbx, rbx
        jg nt261

        pop rsi
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


;;      compute the value then convert to decimal in the buffer
time_NumTo26Sys:
        RDTSC
        mov [T0H],edx
        mov [T0L],eax

        push r11
        mov r11,1000000
    timingloop:
        mov rax,16384
        lea rdi,[_messageRest] ;; point to end of buffer
        call NumTo26Sys
        dec r11
        jnz timingloop
        pop r11

        push rax
        RDTSC
        mov [T1H],edx
        mov [T1L],eax
        pop rax

        ;This is the easy way:
        mov rax,qword[T1L]
        sub rax,qword[T0L]

        lea rdi,[TSCdisplayend1]
        call utoa

time_NumTo26Sys_fast:
        RDTSC
        mov [T0H],edx
        mov [T0L],eax

        push r11
        mov r11,1000000
    timingloop2:
        mov rax,16384
        lea rdi,[_messageRest2] ;; point to end of buffer
        call NumTo26Sys_fast
        dec r11
        jnz timingloop2
        pop r11

        push rax
        RDTSC
        mov [T1H],edx
        mov [T1L],eax
        pop rax

        ;This is the easy way:
        mov rax,qword[T1L]
        sub rax,qword[T0L]

        lea rdi,[TSCdisplayend2]
        call utoa
        retq



section '.data' data readable writeable
;; 20 bytes per number because (length $ show $ 2^64) == 20
dummy dq 1
formatstring db '%s',0
  hello db 'hello',0
  _caption db 'Win64 assembly numto26sys',0
  _message db 13,10,'numto26sys 16384=      '
  _messageRest db '  TSC=                   0'
  TSCdisplayend1 db ' '
  _message2 db 'numto26sys_fast 16384=      '
  _messageRest2 db '  TSC=                   0'
  TSCdisplayend2 db 0
  junk db '                               '
  loop1c dq 0
  T0L dd 0
  T0H dd 0
  T1L dd 0
  T1H dd 0

section '.idata' import data readable
;section '.idata2' data readable import
        library kernel32, 'kernel32.dll', \
                        msvcrt,   'msvcrt.dll'
        import kernel32, ExitProcess, 'ExitProcess'
        import msvcrt, printf, 'printf', getchar, 'getchar'

  kernel_name db 'KERNEL32.DLL',0
  user_name db 'USER32.DLL',0

  _ExitProcess dw 0
    db 'ExitProcess',0
  _MessageBoxA dw 0
    db 'MessageBoxA',0