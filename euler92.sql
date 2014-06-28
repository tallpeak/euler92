-- brute force solution to euler problem #92 in SQL
-- estimated 1600 seconds
-- euler92

go
drop table ssdcache
go
create table ssdcache (n smallint primary key clustered, s int)
;with digits(d) as (
	select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all 
	select 5 union all select 6 union all select 7 union all select 8 union all select 9
)insert ssdcache
select n = d2.d*100+d1.d*10+d0.d, s=d2.d*d2.d+d1.d*d1.d+d0.d*d0.d
from digits d2, digits d1, digits d0	 
where d2.d + d1.d + d0.d > 0

;with digits(d) as (
	select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all 
	select 5 union all select 6 union all select 7 union all select 8 union all select 9
), numbers as (
	select 
		n = d6.d*1000000 + d5.d*100000 + d4.d*10000 + d3.d*1000 
			+ d2.d*100 + d1.d*10 + d0.d
			, d6.d d6, d5.d d5, d4.d d4, d3.d d3
			, d2.d d2, d1.d d1, d0.d d0
	from digits d6, digits d5, digits d4, digits d3
				  , digits d2, digits d1, digits d0
---	order by 1
), ssd as (
	select n, s = d6*d6+d5*d5+d4*d4+d3*d3+d2*d2+d1*d1+d0*d0  
	from numbers
), ssdrecurse as (
	select level = 0, n, s
	from ssd
  union all 
	select r.level + 1, r.n, c.s 
	from ssdrecurse r join ssdcache c
	on r.s = c.n and r.s != 1 and r.s != 89
)
select count(*)
from ssdrecurse
where s = 89
option (maxrecursion 0)
-- result: 8581146
-- time: 00:14:01 (about 700 times slower than assembler or C or C++ or Scala)
-- time: 00:13:49 second time
-- 	Intel(R) Core(TM) i7-3740QM CPU @ 2.70GHz
