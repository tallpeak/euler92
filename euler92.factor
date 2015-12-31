! Copyright (C) 2015 Aaron West
! See http://factorcode.org/license.txt for BSD license.
! "execute benchmark-euler92 to run." write nl
! First version was about 16 seconds.
! This version executes in 3.7 seconds on i5-4300u
! About 4x faster for adding memoize, provided that I run sum-squared-digits
! first on large numbers, so that only small numbers are memoized. 
USING: kernel math math.ranges sequences
       prettyprint tools.time memoize io ;
IN: euler92

: sum-squared-digits ( n -- sum_squared_digits_of_n )
  [ dup 0 > ]              ! while the result of division is nonzero
    [ 10 /mod dup * ]      ! use divmod to get the next quotient and remainder 
      produce sum nip ; inline  ! produce is like unfold
  
MEMO: until1or89 ( n -- 1or89 )
  [ dup 89 = over 1 = or ]                    ! is the last result 1 or 89 ?
    [ sum-squared-digits ] until ; inline     ! keep looping until 1 or 89

: euler92 ( n -- m )
  [1,b]   ! input sequence
  0       ! initial accumulator
  [ sum-squared-digits until1or89 89 = 1 0 ? + ] reduce  ;

: benchmark-euler92 ( -- ) [ 10000000 euler92 . ] time ;

MAIN: benchmark-euler92
