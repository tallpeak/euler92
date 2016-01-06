! Copyright (C) 2015 Aaron West
! See http://factorcode.org/license.txt for BSD license.
! This version uses code from hello-unicode
! This version executes in 3.7 seconds on i5-4300u
! About 4x faster for adding memoize, provided that I run sum-squared-digits
! first on large numbers, so that only small numbers are memoized. 
USING: kernel math math.ranges sequences
       prettyprint tools.time memoize io
       accessors ui.gadgets.panes ui.gadgets.borders ui io.styles 
       math.parser ;
IN: euler92

: sum-squared-digits ( n -- sum_squared_digits_of_n )
  [ dup 0 > ]              ! while the result of division is nonzero
    [ 10 /mod dup * ]      ! use divmod to get the next quotient and remainder 
      produce sum nip ; inline  ! produce is like unfold
  
MEMO: until1or89 ( n -- 1or89 )
  [ dup 89 = over 1 = or ]                    ! is the last result 1 or 89 ?
    [ sum-squared-digits ] until ; inline     ! keep looping until 1 or 89

: euler92 ( b -- count_of_89 )
  [1,b]   ! input sequence
  0       ! initial accumulator
  [ sum-squared-digits     ! don't memoize the big numbers 
    until1or89 89 =   
    1 0 ?
    + ] reduce  ;

: benchmark-euler92 ( -- ) [ 10000000 euler92 . ] time ;
: show-euler92 ( -- ) 
    10000000 euler92 number>string print ;
: <euler92-gadget> ( -- gadget )
    [
        { { font-size 24 } } [
            [ show-euler92 ] benchmark 1e-9 * "took: " write number>string write " seconds" write 
        ] with-style
    ] make-pane { 10 10 } <border> ;

MAIN-WINDOW: gui-euler92 { { title "euler92" } }
    <euler92-gadget> >>gadgets ;

! MAIN: benchmark-euler92
