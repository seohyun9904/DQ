create table student2 (
    S_ID varchar(5) primary key,
    S_NM varchar(20)
);

create table course2 (
    C_ID varchar(5) primary key,
    C_NM varchar(10)
);

create table study2 (
    S_ID varchar(5),
    C_ID varchar(5),
    CHASU int
);

alter table study2
add CONSTRAINT FK_study_student
foreign key (S_ID) references student2(S_ID);

alter table study2
add CONSTRAINT FK_study_course2
foreign key (C_ID) references course2(C_ID);

insert into student2 values('001', '기민용'),('002','이현석'),('003','김정식'),('004','강정식');
insert into course2 values('001', 'Database'),('002', 'Java');
insert into study2 values ('001','001',1);
insert into study2 values ('001','001',3);
insert into study2 values ('001','002',2);
insert into study2 values ('002','001',1);
insert into study2 values ('002','001',2);
insert into study2 values ('002','001',3);
insert into study2 values ('003','002',1);
insert into study2 values ('003','002',2);
insert into study2 values ('004','001',1);




with student2 as
(
    select '001' s_id, '기민용', s_nm from dual
    union all select '002', '이현석' from dual
    union all select '003', '김정식' from dual
    union all select '004', '김정식' from dual
)
, course2 as
(
    select '001' c_id, 'Database', c_nm from dual
    union all select '002', 'Java' from dual
)
, study2 as
(
    select '001', s_id, '001', c_id, 1 chasu from dual
    union all select '001', '001', 3 from dual
    union all select '001', '002', 2 from dual
    union all select '002', '001', 1 from dual
    union all select '002', '001', 2 from dual
    union all select '002', '001', 3 from dua
    union all select '003', '002', 1 from dua
    union all select '003', '002', 2 from dual
    union all select '004', '001', 1 from dual
    
);

select * from student2;
select * from course2;
select * from study2;

-- 정답
select case when b.c_id = '001' then a.s_id end as ID
     , case when b.c_id = '001' then a.s_nm end as 성명
     , b.c_nm as 스터디
     , min(case when c.chasu = 1 then 'O' end) as "1차"
     , min(case when c.chasu = 2 then 'O' end) as "2차"
     , min(case when c.chasu = 3 then 'O' end) as "3차"
     , count(c.s_id) as 참여횟수
from student2 a
cross join course2 b
left outer join study2 c
    on a.s_id = c.s_id
    and b.c_id = c.c_id
group by a.s_id, a.s_nm, b.c_id, b.c_nm
order by a.s_id, b.c_id;

-- 1단계 조인 (inner join)
select a.s_id, a.s_nm, b.c_id, b.c_nm, c.chasu
from student2 a, course2 b, study2 c
where a.s_id = c.s_id
and b.c_id = c.c_id
order by a.s_id, b.c_id, c.chasu;

-- 2단계 행을 열로
select a.s_id, a.s_nm, b.c_id, b.c_nm
     , min(case when c.chasu = 1 then 'O' end) as "1차"
     , min(case when c.chasu = 2 then 'O' end) as "2차"
     , min(case when c.chasu = 3 then 'O' end) as "3차"
     , count(c.s_id) as 참여횟수
from student2 a, course2 b, study2 c
where a.s_id = c.s_id
and b.c_id = c.c_id
group by a.s_id, a.s_nm, b.c_id, b.c_nm
order by a.s_id, b.c_id;

-- 4단계 하나의 테이블 
select a.s_id, a.s_nm, a.c_id, a.c_nm
     , min(case when c.chasu = 1 then 'O' end) as "1차"
     , min(case when c.chasu = 2 then 'O' end) as "2차"
     , min(case when c.chasu = 3 then 'O' end) as "3차"
     , count(c.s_id) as 참여횟수
from (select a.s_id, a.s_nm, b.c_id, b.c_nm
        from student2 a, course2 b) as a, study2 c
where a.s_id = c.s_id
and a.c_id = c.c_id
group by a.s_id, a.s_nm, a.c_id, a.c_nm
order by a.s_id, a.c_id;

select a.s_id, a.s_nm, b.c_id, b.c_nm
     , min(case when c.chasu = 1 then 'O' end) as "1차"
     , min(case when c.chasu = 2 then 'O' end) as "2차"
     , min(case when c.chasu = 3 then 'O' end) as "3차"
     , count(c.s_id) as 참여횟수
from student2 a
cross join course2 b
inner join study2 c
on a.s_id = c.s_id
and b.c_id = c.c_id
group by a.s_id, a.s_nm, b.c_id, b.c_nm
order by a.s_id, b.c_id;


-- 2번 사원의 급여 합계 및 평균
-- 부서들의 합계 포함
select deptno, empno, sum(sal) sal
from emp
group by rollup(deptno, empno)
order by deptno;

-- 부서들의 합계 제외
select deptno, empno, sum(sal) sal
from emp
group by deptno, rollup(empno)
order by deptno;

select deptno, empno, sum(sal) sal
from emp
group by deptno, rollup(empno, ename)
order by deptno;

select deptno, empno, case when ename = 0 then '합계' end ename
from emp;

-- DECODE(GROUP_ID(), 0, NVL(ename, '합계'), '평균') ename
-- case when ename is null then '합계' else '평균' end ename

select deptno, empno
    case when ename is nall (select empno with )
from emp
gropup by deptno, rollup(empno, enam);

SELECT deptno, empno
    , CASE x WHEN 0 THEN coalesce(ename, '합계') ELSE '평균' END ename
    , CASE x WHEN 0 THEN SUM(sal) ELSE ROUND(AVG(sal*1.), 2) END sal
    FROM (SELECT deptno, 0 x, empno, ename, sal FROM emp) a
GROUP BY GROUPING SETS ((deptno, x, empno, ename), (deptno, x), (deptno));

-- 3번 랭킹 쿼리

create table emp_rank (
    empno varchar(5),
    deptno varchar(5),
    point int
);

insert into emp_rank values('1','10',100),('2','10',90),('3','10',80),('4','20',100),
('5','20',90),('6','20',80),('7','30',95),('8','30',85),('9','30',95);

select * from emp_rank;

select e.empno, e.deptno, e.point, count(p.empno) +1 as rk_all
from emp_rank e
left outer join emp_rank p
on e.point < p.point
group by e.empno, e.deptno, e.point
order by rk_all, e.empno;

select e.empno, e.deptno, e.point, count(p.empno) +1 as rk_all
from emp_rank e
left outer join emp_rank p
on e.point < p.point and e.deptno = p.deptno
group by e.empno, e.deptno, e.point
order by deptno, rk_all, empno;

select e.empno, e.deptno, e.point, count(case e.deptno when p.deptno then 1 end) +1 as rk_dept
from emp_rank e
left outer join emp_rank p
on e.point < p.point
group by e.empno, e.deptno, e.point
order by deptno, rk_dept, empno;

-- left outer join을 사용했을 때
select e.empno, e.deptno, e.point, count(p.empno) +1 as rk_all, count(case e.deptno when p.deptno then 1 end) +1 as rk_dept
from emp_rank e
left outer join emp_rank p
on e.point < p.point
group by e.empno, e.deptno, e.point
order by deptno, rk_dept, empno;

-- 스칼라 서브쿼리를 사용했을 때
select e.empno, e.deptno, e.point
    , (select count(*) from emp_rank p where e.point < p.point) +1 as rk_all
    , (select count(*) from emp_rank p where e.point < p.point and e.deptno = p.deptno) +1 as rk_dept
from emp_rank e
group by e.empno, e.deptno, e.point
order by deptno, rk_dept, empno;

-- 분석함수를 사용했을 경우
select empno, deptno, point
    , rank() over(order by point desc) rk_all
    , rank() over(partition by deptno order by point desc) rk_dept
from emp_rank
order by deptno, rk_dept, empno;

-- 4번
create table T(
    NO int,
    DT varchar(10)
);

insert into T values(100,'20090101'),(100,'20090102'),(100,'20090103'),(100,'20090105'),(100,'20090106')
,(100,'20090109'),(100,'20090120'),(200,'20090101'),(200,'20090102'),(200,'20090103'),(200,'20090104')
,(200,'20090131'),(200,'20090201');

select * from t;

select dt_d.no, dt_d.dt from_dt, dt_t.dt to_dt
from t as dt_d, t as dt_t
where dt_d.no = dt_t.no;

select dt_t.no, min(dt_t.dt) from_dt, max(dt_t.dt) to_dt, count(*) cnt
from (select * from t order by no, dt) as dt_t
group by no, to_date(dt, 'yyyymmdd')
order by no, from_dt;



-- 5번
create table IPTABLE(
    no int,
    ip varchar(20)
);

select * from iptable;

insert into iptable values(1,'10.100.10.1'),(2,'10.100.1.10'),(3,'100.10.1.10'),(4,'100.10.1.20'),(5,'2.10.1.140');

SELECT row_number() over() rn, ip
    FROM iptable
ORDER by ip;

SELECT row_number() over() rn, ip
    FROM iptable
ORDER BY REGEXP_REPLACE(REPLACE('.'||ip, '.', '.00'), '([^.]{3}(\.|$))|.', '\1');

-- 경우의 수 구하기
create table code_base (
    code varchar(3)
);


insert into code_base values('A'),('B'),('C');
select * from code_base;

select c1.code code1, c2.code code2
from code_base c1, code_base c2;

select c1.code code1, c2.code code2
from code_base c1, code_base c2
where c1.code < c2.code;

select code
from code_base
union ALL
select c1.code || '-' || c2.code
from code_base c1, code_base c2
where c1.code < c2.code
union ALL
select c1.code || '-' || c2.code || '-' || c3.code
from code_base c1, code_base c2, code_base c3
where c1.code < c2.code
and c2.code < c3.code
;

select code
select substr(sys_connect_by_path(code,'-'),2) code
    from code_base;

-- 날짜별 모든 코드에 대한 자료 채우기
create table code(
    cd int,
    nm varchar(10)
);

create table data(
    dt varchar(10),
    cd int,
    v int
);

insert into code values(1,'마이크로'),(2,'소프트'),(3,'웨어');
insert into data values('20120101', 1, 10),('20120101', 2, 20),('20120101', 2, 21),('20120101', 2, 22),('20120101', 3, 30)
,('20120102', 1, 10),('20120102', 3, 30),('20120104', 1, 10),('20120104', 2, 40),('20120105', 3, 50);

select * from code;
select * from data;

SELECT d.dt, c.nm, v
FROM code c
left outer join data d
on c.cd = d.cd;

select sum(v)
from data
group by dt, cd;

select d.dt
    , (case when c.nm is null then '소계' else c.nm end) nm
    , (case when sum(d.v) is null then 0 else sum(d.v) end) v
from code c
left outer join data d
on c.cd = d.cd
group by d.dt, rollup((c.cd, c.nm))
order by d.dt;

select a.dt
    , (case when c.nm is null then '소계' else c.nm end) nm
    , (case when sum(d.v) is null then 0 else sum(d.v) end) v
from (select distinct dt from data) a
cross join code c
left outer join data d
on a.dt = d.dt
and c.cd = d.cd
group by a.dt, rollup((c.cd, c.nm))
order by a.dt, c.cd;

-- 조건에 따른 누적합계 구하기
create table sum7(
    SEQ int,
    AMT int
);

select * from sum7;

select seq, amt
    , sum(amt) over(order by seq) result
from sum7;

select seq, amt
    -- GREATEST(expr1, expr2 ...) 여러 expr 중에 가장 최대값인 것을 반환
    , GREATEST(0, sum(amt) over(order by seq)) result
from sum7;


with t1(seq, amt, result) as
(
select seq, amt
    , greatest(0,amt) result
from sum7
where seq = 1
union all
select m.seq, m.amt
    , greatest(0, s.result + m.amt) result
from t1 s, sum7 m
where s.seq + 1 = m.seq
)
select * from t1;

-- 분석함수의 이해
-- current row(현재 행), n preceding(n행 앞), n following(n행 뒤)
-- unbounded preceding(이전행 전부), unbounded following(이후행 전부)
-- over(order by 칼럼 rows between start and end)
create table over_table(
    yyyymm varchar(10),
    amt int
);

insert into over_table values('201201',100),('201202',200),('201203',300),('201204',400),('201205',500),('201206',600),
('201207',700),('201208',800),('201209',900),('201210',100),('201211',200),('201212',300);

select * from over_table;

-- 행 단위
select yyyymm, amt
    , sum(amt) over(order by yyyymm rows between 3 preceding and 1 preceding) as amt_pre3
    , sum(amt) over(order by yyyymm rows between 1 following and 3 following) as amt_fol3
from over_table;

-- 시간 단위
select yyyymm, amt
    , sum(amt) over(order by to_date(yyyymm,'yyyymm') range between interval '3' month preceding and interval '1' month preceding) as amt_pre3
    , sum(amt) over(order by to_date(yyyymm,'yyyymm') range between interval '1' month following and interval '3' month following) as amt_fol3
from over_table;


select a.yyyymm, a.amt
    , sum(case when b.yyyymm < a.yyyymm then b.amt end) amt_pre3
    , sum(case when b.yyyymm > a.yyyymm then b.amt end) amt_fol3
from over_table a, over_table b
where
group by a.yyyymm, a.amt
order by a.yyyymm;

-- 그룹별(홀수행/짝수행) 데이터만 검색하기
-- partition by
create table group_table(
    grp int,
    nm varchar(1)
);

insert into group_table VALUES(1,'A'),(1,'B'),(1,'C'),(2,'D'),(2,'E'),(3,'F')
,(4,'G'),(4,'H'),(4,'I'),(4,'J');

select * from group_table;

select t.grp, t.nm
from (select nm, grp
        , row_number() over(partition by grp order by nm) rn
        from group_table) t
where mod(rn,-2) =1;

select job, sum(sal)
from emp
group by rollup(job);

SELECT empno, ename, deptno, sal,       
       SUM(sal) OVER () all_sum,
       SUM(sal) OVER (PARTITION BY deptno) dept_sum,
       SUM(sal) OVER (PARTITION BY deptno ORDER BY empno) nujuk_sum
FROM emp;

-- 숫자를 한글로 변환하기
create table hangeul (
    AMT varchar(100)
);

drop table hangeul;
insert into hangeul values('123456789012345'),('29000'),('309840');
select * from hangeul;

SELECT amt, LPAD(amt,16,'0') v FROM hangeul; --LPAD(지정된 문자열을 원하는 길이로 맞추는데 이때 부족한 문자를 왼쪽에 채움)

SELECT amt
    , substr(v, 1,4) 조 -- SUBSTR(문자열 자르기) (문자열, 시작위치, 길이)
    , substr(v, 5,4) 억
    , substr(v, 9,4) 만
    , substr(v, 13,4) 일
FROM (SELECT amt, LPAD(amt,16,'0') v from hangeul) h
;

SELECT amt
    , translate
    ( substr(v, 1,1)||case when substr(v, 1,1) = '0' then '' else '천' end -- || 문자열 합치기
   || substr(v, 2,1)||case when substr(v, 2,1) = '0' then '' else '백' end
   || substr(v, 3,1)||case when substr(v, 3,1) = '0' then '' else '십' end
   || substr(v, 4,1)||case when substr(v, 1,4) = '0000' then '' else '조' end
   || substr(v, 5,1)||case when substr(v, 5,1) = '0' then '' else '천' end
   || substr(v, 6,1)||case when substr(v, 6,1) = '0' then '' else '백' end
   || substr(v, 7,1)||case when substr(v, 7,1) = '0' then '' else '십' end
   || substr(v, 8,1)||case when substr(v, 5,4) = '0000' then '' else '억' end
   || substr(v, 9,1)||case when substr(v, 9,1) = '0' then '' else '천' end
   || substr(v,10,1)||case when substr(v,10,1) = '0' then '' else '백' end
   || substr(v,11,1)||case when substr(v,11,1) = '0' then '' else '십' end
   || substr(v,12,1)||case when substr(v, 9,4) = '0000' then '' else '만' end
   || substr(v,13,1)||case when substr(v,13,1) = '0' then '' else '천' end
   || substr(v,14,1)||case when substr(v,14,1) = '0' then '' else '백' end
   || substr(v,15,1)||case when substr(v,15,1) = '0' then '' else '십' end
   || substr(v,16,1)
    , '1234567890', '일이삼사오육칠팔구') v -- translate(문자열, 대상문자, 변환문자) 변환문자가 없을 경우 제거됨
FROM (SELECT amt, LPAD(amt,16,'0') v from hangeul) h
;


SELECT amt,
    substr(v, 1,1)||case when substr(v, 1,1) = '0' then '' else '천' end -- || 문자열 합치기
   || substr(v, 2,1)||case when substr(v, 2,1) = '0' then '' else '백' end
   || substr(v, 3,1)||case when substr(v, 3,1) = '0' then '' else '십' end
   || substr(v, 4,1)||case when substr(v, 4,1) = '0' then '' else '조' end
   || substr(v, 5,1)||case when substr(v, 5,1) = '0' then '' else '천' end
   || substr(v, 6,1)||case when substr(v, 6,1) = '0' then '' else '백' end
   || substr(v, 7,1)||case when substr(v, 7,1) = '0' then '' else '십' end
   || substr(v, 8,1)||case when substr(v, 8,1) = '0' then '' else '억' end
   || substr(v, 9,1)||case when substr(v, 9,1) = '0' then '' else '천' end
   || substr(v,10,1)||case when substr(v,10,1) = '0' then '' else '백' end
   || substr(v,11,1)||case when substr(v,11,1) = '0' then '' else '십' end
   || substr(v,12,1)||case when substr(v,12,1) = '0' then '' else '억' end
   || substr(v,13,1)||case when substr(v,13,1) = '0' then '' else '천' end
   || substr(v,14,1)||case when substr(v,14,1) = '0' then '' else '백' end
   || substr(v,15,1)||case when substr(v,15,1) = '0' then '' else '십' end
   || substr(v,16,1) v -- translate(문자열, 대상문자, 변환문자) 변환문자가 없을 경우 제거됨
FROM (SELECT amt, LPAD(amt,16,'0') v from hangeul) h
;

-- PIVOT UNPIVOT
create table pivot_table(
    c varchar(1),
    v int
);

insert into pivot_table values('A',1),('B',2),('C',3),('D',4),('E',5),('F',6),('G',7),('H',8)
,('I',9),('J',10),('K',11),('L',12),('M',13),('N',14),('O',15),('P',16),('Q',17),('R',18),('S',19),('T',20)
,('U',21),('V',22),('W',23),('X',24),('Y',25),('Z',26);

select * from pivot_table;

/*
orcle 버전
SELECT level v
FROM dual
connect by level < 26

postgresql 버전
SELECT level v
FROM generate_series(1,26) level;
*/

SELECT c,  to_char(v,'999999') v, ceil(v/7) + 1 gb1, mod(v-1, 7)+1 gb3
FROM pivot_table;

select (case when gb2 = 1 then c else v end) v
    , ceil(v / 7) gb1
    , gb2
    , mod(v - 1, 7) + 1 gb3
from pivot_table
    , (select level gb2 from generate_series(1,2) level) as s
order by c;


select *
from ( select c
, to_char(v, '999999') v
, ceil(v / 7) gb1
, mod(v - 1, 7) + 1 gb3
from pivot_table
) s
unpivot (v for gb2 in (c as 1, v as 2))
;