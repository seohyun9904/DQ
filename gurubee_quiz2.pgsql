-- 연속된 수 하나로 합치기
create table lv_table (
    lv int
);,(2)

insert into lv_table values(1),(2),(3),(4),(5),(6),(8),(10),(11),(12),(13),(14)
,(16),(17),(18),(19),(20),(21),(26),(27),(28),(29),(30)
,(31),(32),(34),(35),(37),(38),(39),(40);

select * from lv_table;

select lv, row_number() over(order by lv) rn, lv - row_number() over(order by lv) grp
from lv_table
order by lv;

select min(lv) lv_from
    , max(lv) lv_to
    , count(*) cnt
    , min(lv) || case when count(*) = 1 then '' else '~'||max(lv) end v
from (select lv
    , row_number() over(order by lv) rn
    , lv - row_number() over(order by lv) grp
    from lv_table) a
group by grp
order by lv_from
;

select grp grp1
    , cnt
    , case when cnt <5 then lv end grp2
    , min(lv) || case when count(*) = 1 then '' else '~'||max(lv) end v
from (select lv
    , row_number() over(order by lv) rn
    , lv - row_number() over(order by lv) grp
    , count(*) over(partition by lv - )
    from lv_table) a
group by grp, cnt, case when cnt < 5 then lv END
order by lv
;

-- 이용 요금에 대한 납부
create table 요금 (
    u_id varchar(5),
    ym varchar(10),
    p_amt int
);

create table 납부 (
    u_id varchar(5),
    ym varchar(10),
    i_amt int
);

insert into 요금 values('001', '201201', 200),('001', '201202', 200),('001', '201203', 200),('001', '201204', 200),('001', '201205', 200)
,('002', '201202', 300),('002', '201203', 300),('002', '201204', 300),('002', '201205', 300);

insert into 납부 values('001', '201203', 300),('001', '201204', 400),('002', '201203', 400)
,('002', '201205', 500),('002', '201210', 100),('002', '201212', 200);

select * from 요금;
select * from 납부;

select u_id
    , ym
    , p_amt
    , sum(p_amt) over(PARTITION by u_id order by ym) p_amt_s
from 요금
;

select u_id
    , ym
    , i_amt
    , sum(i_amt) over(PARTITION by u_id order by ym) i_amt_s
from 납부
;

select *
from (select u_id, ym, p_amt, sum(p_amt)
    over(PARTITION by u_id order by ym) p_amt_s
    from 요금) a
left outer join (select u_id, ym, i_amt, sum(i_amt)
    over(PARTITION by u_id order by ym) i_amt_s
    from 납부) b
on a.u_id = b.u_id
and a.p_amt_s - a.p_amt < b.i_amt_s
and a.p_amt_s > b.i_amt_s - b.i_amt
order by a.u_id, a.ym, b.ym
;

select a.u_id, a.ym, a.p_amt
     , MONTHS_BETWEEN( TO_DATE(b.ym, 'yyyymm')
                     , TO_DATE(a.ym, 'yyyymm')
                     ) m
     , LEAST( p_amt
            , i_amt
            , p_amt_s - i_amt_s + i_amt
            , i_amt_s - p_amt_s + p_amt
            ) v
from (select u_id, ym, p_amt, sum(p_amt)
    over(PARTITION by u_id order by ym) p_amt_s
    from 요금) a
left outer join (select u_id, ym, i_amt, sum(i_amt)
    over(PARTITION by u_id order by ym) i_amt_s
    from 납부) b
on a.u_id = b.u_id
and a.p_amt_s - a.p_amt < b.i_amt_s
and a.p_amt_s > b.i_amt_s - b.i_amt
order by a.u_id, a.ym, b.ym
;

select 
    extract(year from age(current_date, '2012-12-09')) * 12
    + 
    extract(month from age(current_date, '2012-12-09'))
;



-- 숫자를 영문으로 표기
select amt,
    trim(
        case when substr(v, 1,3) = '0' then '' else to_char(to_date(substr(v,1,3),'j'),'Jsp "Trillion" ') end
        || case when substr(v, 4,3) = '0' then '' else to_char(to_date(substr(v,4,3),'j'),'Jsp "Brillion" ') end
        || case when substr(v, 7,3) = '0' then '' else to_char(to_date(substr(v,7,3),'j'),'Jsp "Mrillion" ') end
        || case when substr(v, 10,0) = '0' then '' else to_char(to_date(substr(v,10),'j'),'Jsp') end
    ) v
from (SELECT amt, LPAD(amt,15,'0') v FROM hangeul) a
;

SELECT TO_CHAR(amt, 'J') J
     , TO_CHAR(amt, 'Jsp') Jsp
  FROM hangeul
;


-- 기간 분할 검색

CREATE TABLE 기간 AS
  SELECT 1 id, '20120901' sdt, '20130531' edt, 6250 amt, 25 cnt
  UNION ALL SELECT 2, '20130401', '20130831', 5500, 20
  UNION ALL SELECT 3, '20130501', '20140430', 5000, 15
  UNION ALL SELECT 4, '20150101', '20151231', 1000, 10;

drop table 기간;
SELECT * FROM t;

SELECT TO_CHAR(sdt, 'yyyymmdd') sdt
     , TO_CHAR(edt, 'yyyymmdd') edt
     , amt
     , cnt
FROM (SELECT sdt
           , LEAD(sdt - 1) OVER(ORDER BY sdt) edt
           , SUM(SUM(amt)) OVER(ORDER BY sdt) amt
           , SUM(SUM(cnt)) OVER(ORDER BY sdt) cnt
        FROM (SELECT case when lv = 1 then to_date(sdt, 'yyyymmdd') else to_date(edt, 'yyyymmdd') + 1 end sdt
                 , case when lv = 1 then amt else -amt end amt
                 , case when lv = 1 then cnt else -cnt end cnt
            FROM 기간
            , (SELECT level lv FROM generate_series(1,2) level) a
            ) b
        GROUP BY sdt
    ) c
 WHERE amt != 0
;


-- 기간 병합 검색

SELECT id
     , sdt
     , edt
     , LAG(edt) OVER(ORDER BY sdt, edt) lag_edt
     , CASE WHEN LAG(edt) OVER(ORDER BY sdt, edt) >= sdt
            THEN 0 ELSE 1 END flag
  FROM 기간
 ORDER BY sdt, edt
;

SELECT MIN(sdt) sdt
     , MAX(edt) edt
  FROM (
        SELECT sdt
             , edt
             , SUM(flag) OVER(ORDER BY sdt, edt) grp
          FROM (
                SELECT sdt
                     , edt
                     , CASE WHEN MAX(edt) OVER(ORDER BY sdt, edt
                                 ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                                 ) >= sdt
                            THEN 0 ELSE 1 END flag
                  FROM 기간
                ) a
        ) b
 GROUP BY grp
 ORDER BY grp
;

-- 다 대 다 데이터의 수량 배분
create table suju (
    id varchar(1) PRIMARY KEY,
    cd varchar(2),
    cnt int,
    dt varchar(10)
);


create table ipgo(
    id varchar(1) PRIMARY KEY,
    cd varchar(2),
    cnt int,
    dt varchar(10)
);

insert into suju values('A', '01', 4, '20110101'),('B', '01', 2, '20110103')
,('C', '02', 4, '20110101'),('D', '02', 2, '20110103'),('E', '03', 4, '20110101'),('F', '04', 2, '20110103');

insert into ipgo values('X', '01', 6, '20110101'),('Y', '02', 3, '20110103')
,('Z', '02', 3, '20110104'),('P', '02', 4, '20110105'),('Q', '03', 2, '20110102'),('R', '03', 3, '20110103');


select * from suju;
select * from ipgo;

SELECT *
FROM suju s, ipgo i
where s.id = i.id
;

select *
from (select s.*
    , sum(cnt) over(partition by cd order by dt) s_cnt
    from suju s) s,
    (select i.*
    , sum(cnt) over(partition by cd order by dt) s_cnt
    from ipgo i) i
where s.cd = i.cd
;

select s.*
    , sum(cnt) over(partition by cd order by dt) - cnt b_cnt
    , sum(cnt) over(partition by cd order by dt) s_cnt
from suju s
;

select i.*
    , sum(cnt) over(partition by cd order by dt) - cnt b_cnt
    , sum(cnt) over(partition by cd order by dt) s_cnt
from ipgo i
;

select s.cd 
    , s.id 
    , least( s.cnt -- 입고가 수주를 포함, 수량 배분 방법: A 수량
           , i.cnt -- 수주가 입고를 포함, 수량 배분 방법: B 수량
           , s.s_cnt - i.s_cnt + i.cnt -- 수주 시작 후 입고가 겹치는 경우: 수주 종료 - 입고 시작
           , i.s_cnt - s.s_cnt + s.cnt) cnt -- 입고 시작후 수주가 겹치는 경우: 입고 종료 - 수주 시작
    , i.id
from (select s.*
    , sum(cnt) over(partition by cd order by dt) s_cnt
    from suju s) s,
    (select i.*
    , sum(cnt) over(partition by cd order by dt) s_cnt
    from ipgo i) i
where s.cd = i.cd
and s.s_cnt > i.s_cnt - i.cnt
and i.s_cnt > s.s_cnt - s.cnt
order by s.cd, s.dt, i.dt
;

-- 계층구조의 이해
SELECT empno
     , ename
     , LEVEL lv
     , mgr
     , PRIOR ename mgr_name
     , SUBSTR(SYS_CONNECT_BY_PATH(ename, '-'), 2) enames
  FROM emp
 START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr
 ORDER SIBLINGS BY empno
;

with recursive t1 (empno, ename, lv, mgr, mgr_ename, enames, empnos) as (
    SELECT empno
     , ename
     , 1 lv
     , mgr
     , '' mgr_ename
     , ename enames
     , TO_CHAR(empno,'9999') empnos
    FROM emp
    WHERE mgr IS NULL
    UNION ALL
    SELECT t2.empno
     , t2.ename
     , t1.lv + 1 lv
     , t2.mgr
     , '' || t1.ename mgr_ename
     , t1.enames || '-' || t2.ename enames
     , t1.empnos || '-' || t2.empno empnos
    FROM t1, emp t2
    WHERE t1.empno = t2.mgr
)
select *
from t1
order by empnos
;

select empno, ename, mgr
from emp
;

ALTER table emp
ALTER column ename type varchar;

-- 당구대
create table danggu(
    no int,
    stm varchar,
    etm varchar
);

insert into danggu values(1,'11:30','12:30'),(2,'12:30','13:40'),(3, '12:50', '13:30'),(4, '13:00', '14:20'),(1, '13:30', '14:20'),(3, '15:00', '16:00')
,(1, '15:30', '16:30'),(2, '15:30', '16:30'),(4, '15:30', '16:50'),(1, '17:00', '18:00'),(3, '17:30', '18:30'),(4, '17:30', '19:00'),(2, '18:00', '19:00'),(3, '19:30', '20:30');

SELECT case when s = 1 then stm else etm end stm
     , no, s
  FROM danggu
     , (SELECT 3-LEVEL*2 s FROM generate_series(1,2) level) m
 ORDER BY stm, s
;



-- 웹사이트 방문 기록
CREATE TABLE web_log
AS
SELECT '111' id, 'www.gurubee.net' site, '11:10' tm
UNION ALL SELECT '111', 'www.gurubee.net', '11:11'
UNION ALL SELECT '111', 'www.imaso.co.kr', '11:12'
UNION ALL SELECT '111', 'www.imaso.co.kr', '11:13'
UNION ALL SELECT '111', 'www.gurubee.net', '11:14'
UNION ALL SELECT '222', 'www.gurubee.net', '11:11'
UNION ALL SELECT '222', 'www.imaso.co.kr', '11:12'
UNION ALL SELECT '222', 'www.imaso.co.kr', '11:13'
UNION ALL SELECT '222', 'www.imaso.co.kr', '11:14'
;

select * from web_log
order by id, tm, site;

select id, site, min(tm), count(*)
from web_log
group by id, site
;


select id, lag(site) over(partition by id) grp, site, min(tm), count(site)
from web_log
group by id, site
;

select id, site, tm
    , lag(site) over(partition by id order by tm)
    , case when lag(site) over(partition by id order by tm) = site then 0 else 1 end lag_cnt
from web_log
;

select id, grp, site, min(tm) tm, count(*) cnt
from (select id, site, tm
        , sum(lag_cnt) over(partition by id order by tm) grp
    from (select id, site, tm
    , lag(site) over(partition by id order by tm)
    , case when lag(site) over(partition by id order by tm) = site then 0 else 1 end lag_cnt
    from web_log) x ) s
group by id, grp, site
order by id, grp, site;

-- 근무 종료시간을 구하는 사용자 함수 생성
CREATE TABLE t_holiday
AS
SELECT '20140101' dt
UNION ALL SELECT '20140130'
UNION ALL SELECT '20140131'
UNION ALL SELECT '20140201'
UNION ALL SELECT '20140301'
UNION ALL SELECT '20140505'
UNION ALL SELECT '20140506'
UNION ALL SELECT '20140606'
;

select * from t_holiday;

with recursive t as(
    SELECT 1 no, '2014/01/01 12:30' t, 2 h 
    UNION ALL SELECT 2, '2014/01/30 12:30', 4 
    UNION ALL SELECT 3, '2014/03/04 07:30', 2 
    UNION ALL SELECT 4, '2014/03/04 12:30', 2 
    UNION ALL SELECT 5, '2014/03/04 18:30', 2 
    UNION ALL SELECT 6, '2014/03/04 09:30', 5 
    UNION ALL SELECT 7, '2014/03/07 17:00', 2
)
select no, t, h, f_Quiz(t,h) x
from t;

-- 목록과 함께 평균,최대,최소 값 구하기
CREATE TABLE list_table
 AS
 SELECT '20140101' dt, 9 v1, 2 v2, 9 v3, 9 v4, 'N' yn
 UNION ALL SELECT '20140102', 9.9, 2.2, 9, 9, 'N'
 UNION ALL SELECT '20140103', 9.8, 2.3, 9, 9, 'N'
 UNION ALL SELECT '20140104', 9.7, 2.4, 9, 9, 'N'
 UNION ALL SELECT '20140105', 9.6, 2.5, 9, 9, 'N'
 UNION ALL SELECT '20140106', 9.5, 2.6, 5, 5, 'Y'
 UNION ALL SELECT '20140107', 9.4, 2.7, 5, 5, 'Y'
 UNION ALL SELECT '20140108', 9.3, 2.8, 5, 5, 'Y'
 UNION ALL SELECT '20140109', 9.2, 2.9, 5, 5, 'Y'
 UNION ALL SELECT '20140110', 9.1, 3.0, 5, 5, 'Y';

SELECT * FROM list_table;

select dt, min(v1), min(v2), min(v3), min(v4)
from list_table
group by rollup(dt)
order by dt;

/*select coalesce(dt, coalesce(yn,'전체') ||' '||
        case when gid = 0 then '평균값' when gid = 1 then '최대값' when gid = 2 then '최소값' end) dt
        , v1, v2, v3, v4, yn*/

select dt
    , round(avg(v1), 2) v1 -- round(a,b) a의 값을 소수점 b자리까지 반올림
    , round(avg(v2), 2) v2
    , round(avg(v3), 2) v3
    , round(avg(v4), 2) v4
    , yn
    , GROUPING(yn) g1 -- null인 경우 1 반환, 아닌 경우 0 반환
    , GROUPING(dt) g2
    --, GROUPING_id(yn, dt) gid
from list_table
group by rollup(yn, dt)
order by dt, yn
;

-- 계층구조의 응용 
with recursive t1 (empno, ename, lv, mgr, mgr_ename, enames, empnos, sal, sum_sal) as (
    SELECT empno
     , ename
     , 1 lv
     , mgr
     , '' mgr_ename
     , ename enames
     , TO_CHAR(empno,'9999') empnos
     , sal
     , (select sum(sal) from emp) sum_sal
    FROM emp
    WHERE mgr IS NULL
    UNION ALL
    SELECT t2.empno
     , t2.ename
     , t1.lv + 1 lv
     , t2.mgr
     , '' || t1.ename mgr_ename
     , t1.enames || '-' || t2.ename enames
     , t1.empnos || '-' || t2.empno empnos
     , t2.sal
     , t1.sal
    FROM t1, emp t2
    WHERE t1.empno = t2.mgr
)
select *
from t1
order by empnos
;

-- 중복 할인금액 구하기
CREATE TABLE sale
AS
SELECT 1 seq, 2000 amt, NULL rat
UNION ALL SELECT 2, NULL,   10
UNION ALL SELECT 3, 3000, NULL
UNION ALL SELECT 4, NULL,   20;
 
SELECT * FROM sale;

select seq, amt, rat
    , 20000 = sum(dc) over(order by seq) + dc prc
    , dc
    , 20000 - sum(dc) over(order by seq) rem
from (select seq, amt, rat
        , coalesce(amt, 20000 * rat / 100) dc
        from sale
        ) s
;

with recursive t1(seq, amt, rat, prc, dc, rem) as (
    select seq
        , amt
        , rat
        , 20000 prc
        , coalesce(amt, 20000 * rat / 100) dc
        , 20000 - coalesce(amt, 20000 * rat / 100) rem
    from sale
    where seq = 1
    union all
    select a.seq
        , a.amt
        , a.rat
        , b.rem prc
        , coalesce(a.amt, b.rem * a. rat / 100) dc
        , b.rem - coalesce(a.amt, b.rem * a.rat / 100) rem
    from sale a
        , t1 b
    where a.seq = b.seq + 1
)
select * from t1
;

-- 예산 범위 안에서 과일 장바구니 조합
CREATE TABLE fruit
AS
SELECT 1 cod, '배' nam, 5000 amt
UNION ALL SELECT 2, '사과', 3000
UNION ALL SELECT 3, '딸기', 2000
UNION ALL SELECT 4, '참외', 2000
UNION ALL SELECT 5, '자두', 1000;
 
SELECT * FROM fruit;

select , f.amt
from fruit f
join fruit t
on f.cod = t.cod;

with recursive t1(cod, nam, amt, cnt, nams, tot) as(
    select cod, nam, amt
        , 1 cnt
        , cast(nam as varchar(4000)) nams
        , amt tot
    from fruit
    where amt <= 5000
    union all
    select c.cod, c.nam, c.amt
        , case when p.cod = c.cod then p.cnt + 1 else 1 end cnt
        , case when p.cod = c.cod
        then regexp_replace(p.nams, '[*][0-9]+$')||'*'||(p.cnt+1)
        else p.nams||'+'||c.nam end nams
        , p.tot + c.amt tot
    from fruit c
        , t1 p
    where p.tot + c.amt <= 5000
    and p.cod <= c.cod
)
select nams
from t1
where tot = 5000
;

-- 계층 구조 응용 쿼리
CREATE TABLE ball
AS
SELECT '농구공' pcd, '축구공' cd,  1 v
UNION ALL SELECT '축구공', '배구공', 2
UNION ALL SELECT '배구공', '야구공', 3
UNION ALL SELECT '야구공', '골프공', 4
UNION ALL SELECT '골프공', '탁구공', 5;
 
SELECT * FROM ball;

with recursive t1 as (
    select pcd lv1
         , cd lv2             
    from ball
    where v = 1
    union all 
    select t1.lv1
         , t1.lv2
    from t1, ball
    where t1.lv1 = ball.cd
)
select lv1, lv2
from t1;

select lv
    , path
    , v
    , round(exp(sum(ln(v)) over(order by lv))) x
from (select pcd, cd, v
            , level lv
      from ball
)

-- 전기 요금 계산
create table code_t
as
select 0 s, 100 e, 410 v1, 60.7 v2
union all select 100, 200, 910, 125.9
union all select 200, 300, 1600, 187.9
union all select 300, 400, 3850, 280.6
union all select 400, 500, 7300, 417.7
union all select 500, 9999, 12940, 709.5;

CREATE TABLE use_t 
AS
SELECT 1 id, 90 kwh
UNION ALL SELECT 2, 120
UNION ALL SELECT 3, 240
UNION ALL SELECT 4, 360
UNION ALL SELECT 5, 480
UNION ALL SELECT 6, 600;

select * from code_t; 
SELECT * FROM use_t;

select *
from use_t u
   , code_t c
where u.kwh > c.s
and u.kwh <= c.e
order by id
;

select *
from use_t u
   , code_t c
where u.kwh > c.s
order by id
;

SELECT u.id
     , u.kwh
     , CASE WHEN u.kwh <= c.e
            THEN u.kwh - c.s
            ELSE c.e - c.s
             END v
     , c.v1
     , c.v2
FROM use_t u
   , code_t c
WHERE u.kwh > c.s
ORDER BY id, s
;

SELECT u.id
     , u.kwh
     , LEAST(u.kwh, c.e) - c.s v
     , c.v1
     , c.v2
FROM use_t u
   , code_t c
WHERE u.kwh > c.s
ORDER BY id, s
;

select u.id
     , u.kwh
     , trunc(max(v1) + sum
         ((least(u.kwh, c.e) - c.s) * v2)
     , -1) amt
from use_t u
   , code_t c
where c.s < u.kwh
group by u.id, u.kwh
order by id
;

-- 5일 연속 결석여부
CREATE TABLE check_table
AS
SELECT 'A' id, '20141103' dt, 1 st
UNION ALL SELECT 'A', '20141104', 1
UNION ALL SELECT 'A', '20141105', 2
UNION ALL SELECT 'A', '20141106', 2
UNION ALL SELECT 'A', '20141107', 1
UNION ALL SELECT 'A', '20141110', 2
UNION ALL SELECT 'A', '20141111', 2
UNION ALL SELECT 'A', '20141112', 2
UNION ALL SELECT 'A', '20141113', 1
UNION ALL SELECT 'A', '20141114', 1
UNION ALL SELECT 'B', '20141103', 1
UNION ALL SELECT 'B', '20141104', 1
UNION ALL SELECT 'B', '20141105', 2
UNION ALL SELECT 'B', '20141106', 2
UNION ALL SELECT 'B', '20141107', 2
UNION ALL SELECT 'B', '20141110', 2
UNION ALL SELECT 'B', '20141111', 2
UNION ALL SELECT 'B', '20141112', 2
UNION ALL SELECT 'B', '20141113', 1
UNION ALL SELECT 'B', '20141114', 1;
 
SELECT * FROM check_table;


select id, count(case when st=2 then 1 end) cnt
from check_table
group by id
order by id
;

select id
    , min(dt) sdt
    , max(dt) edt
    , count(*) cnt
    , st
    , rn1 - rn2 grp
from (select id, dt, st
            , row_number() over(partition by id order by dt) rn1
            , row_number() over(partition by id, st order by dt) rn2
    from check_table) a
group by id, st, rn1 - rn2
order by id, sdt
;

select id
     , max(
         case when cnt >= 5 then 'Y' else 'N' end
     ) yn
from (select id
            , count(*) cnt
        from (select id, dt, st
                , row_number() over(partition by id order by dt) rn1
                , row_number() over(partition by id, st order by dt) rn2
                from check_table
                ) a
            group by id, st, rn1-rn2
            ) b
group by id
order by id
;

-- 이진 문자열 논리 연산
create table munja_table
as
select 1 no, '000111000111' v
union all select 2, '111100001111';

select * from munja_table;

select no, lv
    , substr(v, lv, 1) v
from munja_table
   , (select level lv from GENERATE_SERIES(1,12) level) a
order by no, lv
;

-- 개미수열
with recursive t(n,v) as
    (select 1 n
          , 1 v
    union ALL
    select n + 1
         , case when v = 1
    where n = 9)

with recursive t(n,v) as
(
    select 1,1
    union all
    select n+1 as n
    , v + n + 1 as v
    from t
    where n + 1 <= 10
)
select * from t
;

select n
    , sum(n) over(order by n) as v1
    , (n+1) * n / 2 as v2
from (select level n from generate_series(1,10) level) a
;

with recursive ant_t(n, v, x) as
(
    select 1 n
    , cast('1' as varchar(100)) v
    , cast('' as varchar(100)) x
    union all
    select coalesce(x, n, n+1) n
        , coalesce(x, substr(v, 1, 1)
                      ||length(regexp_substr(v, '^(.)(\1)*'))        
                    , v||substr(x, 1, 1)
                       ||length(regexp_substr(x, '^(.)(\1)*'))
                    ) v
        , regexp_replace(nvl(x,v), '^(.)(\1)*') x
    from ant_t
    where COALESCE(x, n+1, n) <= 9
)
select * from t;

-- 일별 누적 접속자 통계 구하기
create table jubsok
as
SELECT '20150801' dt, 1 id
UNION ALL SELECT '20150801', 2
UNION ALL SELECT '20150801', 1
UNION ALL SELECT '20150802', 1
UNION ALL SELECT '20150802', 2
UNION ALL SELECT '20150802', 2
UNION ALL SELECT '20150803', 3
UNION ALL SELECT '20150804', 4
UNION ALL SELECT '20150804', 1
UNION ALL SELECT '20150805', 1;

select * from jubsok;

select dt
     , count(dt) 접속건수
     , count(distinct id) 접속자수
     , sum(count(*)) over(order by dt) 누적접속건수
from jubsok
group by dt
order by dt
;

select dt
     , id
     , case when row_number() over(partition by id order by dt) = 1 then 1 end x
from jubsok
;

select dt
     , count(dt) 접속건수
     , count(distinct id) 접속자수
     , sum(count(*)) over(order by dt) 누적접속건수
     , sum(count(x)) over(order by dt) 누적접속자수
from (select dt, id
           , case when row_number() over(partition by id order by dt) = 1 then 1 end x
      from jubsok
) s
group by dt
order by dt
;

-- 파이프 연결하기
CREATE TABLE pipe
AS
SELECT '01' id, 1 s_x, 3 s_y, 4 s_z, 1 e_x, 2 e_y, 4 e_z
UNION ALL SELECT '02', 2, 8, 7, 8, 8, 7
UNION ALL SELECT '03', 1, 4, 6, 1, 4, 5
UNION ALL SELECT '04', 1, 6, 7, 1, 5, 7
UNION ALL SELECT '05', 9, 1, 4, 3, 1, 4
UNION ALL SELECT '06', 6, 1, 1, 7, 1, 0
UNION ALL SELECT '07', 4, 1, 3, 5, 1, 2
UNION ALL SELECT '08', 2, 8, 7, 1, 6, 7
UNION ALL SELECT '09', 1, 5, 7, 1, 4, 6
UNION ALL SELECT '10', 8, 8, 7, 8, 7, 7
UNION ALL SELECT '11', 1, 2, 4, 2, 1, 4
UNION ALL SELECT '12', 3, 1, 4, 4, 1, 3
UNION ALL SELECT '13', 5, 1, 2, 6, 1, 1
UNION ALL SELECT '14', 1, 4, 5, 1, 3, 4;
 
SELECT * FROM pipe;

select *
from pipe a
where not exists (select 1
                  from pipe
                  where e_x = a.s_x
                    and e_y = a.s_y
                    and e_z = a.s_z
                 )
;

-- 구분자로 나누어 행,열 바꾸기
CREATE TABLE p_table
AS
SELECT 1 no, '1:10|2:11|3:12|4:15' v
UNION ALL SELECT 2, '1:17|3:15|4:25'
UNION ALL SELECT 3, '2:11|4:15'     
UNION ALL SELECT 4, '1:10|2:21|4:19';
 
SELECT * FROM p_table;

select substr(v, 0, 5) "1"
     , substr(v, 6, 4) "2"
     , substr(v, 11, 4) "3"
     , substr(v, 16, 4) "4"
from p_table
;

select substring(unnest(regexp_matches(v, '1:[^|]+')) ,3) as "1"
,substring(unnest(regexp_matches(v, '2:[^|]+')) ,3) as "2"
,substring(unnest(regexp_matches(v, '3:[^|]+')) ,3) as "3"
,substring(unnest(regexp_matches(v, '4:[^|]+')) ,3) as "4"
from p_table
;

select regexp_matches(v, '1:[^|]+')
from p_table
;

select unnest(regexp_matches(v, '1:[^|]+'))
from p_table
;

select substring(unnest(regexp_matches(v, '1:[^|]+')) ,3) as "1"
from p_table
;

-- 공통점이 가장 많은 친구 찾기
CREATE TABLE friend
AS
SELECT '마농' nm, '사과' c1, '배' c2, '자두' c3, '딸기' c4
UNION ALL
SELECT '재석', '배'  , '수박'  , '바나나', ''    
UNION ALL
SELECT '정식', '메론', '바나나', '자두'  , '딸기'
UNION ALL
SELECT '마소', '메론', ''    , ''      , ''    
UNION ALL
SELECT '민용', '배'  , '자두'  , '사과'  , '딸기'
UNION ALL
SELECT '혜연', '자두', '딸기'  , '사과'  , '배'  
UNION ALL
SELECT '수지', '오디', '코코넛', '두리안', '머루';
 
SELECT * FROM friend;

-- 달력 만들기
with recursive calender as(
    select dateadd(d, 0, '201503'+'01') dt
    union all
    select dateadd(d, 1, dt) dt
    from calender
    where dt + 1 < dateadd(m, 1, '201503' + '01')
)
select *
from calender
;


-- 지뢰 찾기
WITH recursive mine AS
(
SELECT min(case when x=1 then z end) x1
     , min(case when x=1 then z end) x1
     , min(case when x=1 then z end) x1
     , min(case when x=1 then z end) x1
     , min(case when x=1 then z end) x1
  FROM (SELECT CEIL(lv / 5) x
             , MOD(lv-1, 5) + 1 y
             , CASE WHEN
                    ROW_NUMBER() OVER(
                    ORDER BY random())
                    <= 10 THEN '*' END z
          FROM (select level lv from generate_series(1,25) level) a
        ) b
 GROUP BY y
)
SELECT COALESCE(x1, SUM(NVL(LENGTH(    x1||x2), 0))
               OVER(ORDER BY 1
               ROWS BETWEEN 1 PRECEDING
                        AND 1 FOLLOWING)) x1
     , NVL(x2, SUM(NVL(LENGTH(x1||x2||x3), 0))
               OVER(ORDER BY 1
               ROWS BETWEEN 1 PRECEDING
                        AND 1 FOLLOWING)) x2
     , NVL(x3, SUM(NVL(LENGTH(x2||x3||x4), 0))
               OVER(ORDER BY 1
               ROWS BETWEEN 1 PRECEDING
                        AND 1 FOLLOWING)) x3
     , NVL(x4, SUM(NVL(LENGTH(x3||x4||x5), 0))
               OVER(ORDER BY 1
               ROWS BETWEEN 1 PRECEDING
                        AND 1 FOLLOWING)) x4
     , NVL(x5, SUM(NVL(LENGTH(x4||x5    ), 0))
               OVER(ORDER BY 1
               ROWS BETWEEN 1 PRECEDING
                        AND 1 FOLLOWING)) x5
  FROM mine
;



-- 시험실 좌석도 배치
SELECT min(case when x=1 then v end) v1
     , min(case when x=2 then v end) v2
     , min(case when x=3 then v end) v3
     , min(case when x=4 then v end) v4
     , min(case when x=5 then v end) v5
  FROM (SELECT v
             , x
             , ROW_NUMBER() OVER(PARTITION BY x ORDER BY v) y
         FROM (SELECT v
                    , NTILE(5) OVER(ORDER BY v) x
                 FROM (SELECT LEVEL v FROM generate_series(1,30) level) a
              ) b
       ) c
 GROUP BY y
 ORDER BY 1
;