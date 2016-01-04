! Copyright (C) 2016 Aaron West.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.ranges sequences prettyprint ;
IN: euler1

: multOf3or5_a ( n -- ? )
  dup  3 mod  0 =
  swap 5 mod  0 =
  or ; inline

: multOf ( n m -- ? ) mod 0 = ; inline

: multOf3or5 ( n -- ? )
  [ 3 multOf ] [ 5 multOf ] bi 
  or ; inline

: euler1 ( n -- m )
  1000 iota [ multOf3or5 ] filter sum number>string print ;

MAIN: euler1

euler1
