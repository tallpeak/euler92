! Copyright (C) 2016 Aaron West.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.ranges sequences prettyprint ;
IN: euler1

: is-multiple-of-3-or-5 ( n -- ? )
  dup  3 mod  0 =
  swap 5 mod  0 =
  or ; inline

: euler1 ( n -- m )
  [1,b] [ is-multiple-of-3-or-5 ] filter sum ;

: euler1_main ( -- ) 1000 euler1 . ;

MAIN: euler1_main
