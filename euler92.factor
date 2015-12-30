! Copyright (C) 2015 Aaron West
! See http://factorcode.org/license.txt for BSD license.
! "execute benchmark-euler92 to run." write nl
! deploy not working, says no-vocab-main
USING: kernel math math.ranges sequences
       prettyprint tools.time io ;
IN: euler92

: sum-squared-digits ( n -- m )
  [ dup 0 > ] [ 10 /mod dup * ] produce sum nip ; inline
  
: until1or89 ( n -- m )
    [ dup 89 = over 1 = or ] [ sum-squared-digits ] until ; inline

: euler92 ( n -- m ) [1,b] [ until1or89 89 = ] filter length ;

: benchmark-euler92 ( -- ) [ 10000000 euler92 . ] time ;

MAIN: benchmark-euler92
