-- euler92b.sql
-- pre-aggregated solution to euler problem #92 in SQL
-- That is, for each number 1 to 10 million, find sum of squares of digits for that number
-- then group by those sums and find count(*) for each group
-- Recursion then only needs to be performed on a few hundred sum-squared-digits values
-- (496), so this only takes 2 seconds.
go
use tempdb
go
drop table ssdcache
go
drop table digits
go
drop table sqdigits
go
create table digits(d int primary key clustered)
go
insert digits select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all 
			  select 5 union all select 6 union all select 7 union all select 8 union all select 9
go
create table sqdigits(d int primary key clustered)
go
insert sqdigits select 0 union all select 1 union all select 4 union all select 9 union all select 16 union all 
				select 25 union all select 36 union all select 49 union all select 64 union all select 81
go
drop table ssd
go
create table ssd(s int, c int)
go
declare @t0 datetime
declare @t1 datetime
declare @elapsed float
set @t0=getdate()
create table ssdcache (n int primary key clustered, s int)
insert ssdcache
select n = d2.d*100+d1.d*10+d0.d, s=d2.d*d2.d+d1.d*d1.d+d0.d*d0.d
from digits d2, digits d1, digits d0	 
where d2.d + d1.d + d0.d > 0
--declare @sc2 binary(1000)
--set @sc2=0x00
--update ssdcache
--set @sc2=substring(@sc2,1,n)+cast(char(s)as binary(1))+substring(@sc2,n+2,999)
----print  @sc2
--;with numbers as (
--	select 
--		n = d6.d*1000000 + d5.d*100000 + d4.d*10000 + d3.d*1000 
--			+ d2.d*100 + d1.d*10 + d0.d
--			, d6.d d6, d5.d d5, d4.d d4, d3.d d3
--			, d2.d d2, d1.d d1, d0.d d0
--	from digits d6, digits d5, digits d4, digits d3
--				  , digits d2, digits d1, digits d0
--)
--insert ssd 
--select s = d6*d6+d5*d5+d4*d4+d3*d3+d2*d2+d1*d1+d0*d0 , c=count(*) 
--from numbers
--group by d6*d6+d5*d5+d4*d4+d3*d3+d2*d2+d1*d1+d0*d0

-- using sqdigits saves 0.2 seconds 
insert ssd 
select s = a.d + b.d + c.d + d.d + e.d + f.d + g.d, c=count(*) 
from sqdigits a, sqdigits b, sqdigits c, sqdigits d, sqdigits e, sqdigits f, sqdigits g 
group by a.d + b.d + c.d + d.d + e.d + f.d + g.d 

;with ssdrecurse as (
	select level = 0, s, c
	from ssd
  union all 
	select r.level + 1, 
	--cast(SUBSTRING(@sc2, r.s+1, 1)as int) 
	c.s, r.c 
	from ssdrecurse r 
	join ssdcache c	on r.s = c.n and r.s != 1 and r.s != 89
	--where r.s != 1 and r.s != 89 and r.s != 0
)
select sum(c)
from ssdrecurse
where s = 89
option (maxrecursion 0)
set @t1=getdate()
set @elapsed = datediff(ms,@t0,@t1)*1e-3
print 'elapsed='+convert(varchar(12),@elapsed)+' seconds'
-- result: 8581146
-- time: 00:13:49 again 
--  14:!2
-- 13:08 with a clustered index on digits
-- 	Intel(R) Core(TM) i7-3740QM CPU @ 2.70GHz
-- 2.2 seconds with pre-aggregation
-- 2.173 seconds with binary(1000) cache (no real/substantial savings)
-- elapsed=7.16 seconds on QTC-DB045D\DEVDEV001
-- 2.8 seconds on QTCDB025DA\DBSQL025DA 
-- 4 seconds on TAC_DBDEV003