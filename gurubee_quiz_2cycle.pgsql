-- 1. <스터디 가입현황>
select *
from student
;

select *
from course
;

select *
from study
;

SELECT s_id, s_nm, c_nm
FROM student s
cross join course c
;

SELECT s.s_id, s.s_nm, c.c_nm
     , min(case when t.chasu = 1 then 'O' end) "1차"
     , min(case when t.chasu = 2 then 'O' end) "2차"
     , min(case when t.chasu = 3 then 'O' end) "3차"
     , count(case when chasu notnull then 1 end) "참여횟수"
FROM student s
cross join course c
left outer join study t
on s.s_id = t.s_id
and c.c_id = t.c_id
group by s.s_id, s.s_nm, c.c_nm
;

SELECT case when c.c_id = '001' then s.s_id end "ID"
     , case when c.c_id = '001' then s.s_nm end "성명"
     , c.c_nm "스터디"
     , min(case when t.chasu = 1 then 'O' end) "1차"
     , min(case when t.chasu = 2 then 'O' end) "2차"
     , min(case when t.chasu = 3 then 'O' end) "3차"
     , count(case when chasu notnull then 1 end) "참여횟수"
FROM student s
cross join course c
left outer join study t
on s.s_id = t.s_id
and c.c_id = t.c_id
group by s.s_id, s.s_nm, c.c_id, c.c_nm
order by s.s_id, s.s_nm
;



-- 2. <사원의 급여 합계 및 평균>
select * from emp;

select distinct deptno, empno
     , case grouping(deptno) when 0 then coalesce(ename, '합계') else '평균' end ename
     , case grouping(deptno) when 0 then sum(sal) else avg(sal) end sal
from emp
group by deptno, rollup(deptno, (empno, ename), sal)
order by deptno, empno
;



-- 3. <랭킹 쿼리>
select * from emp_rank;

select empno, deptno, point
    , rank() over(order by point desc) rk_all
    , rank() over(partition by deptno order by point desc) rk_dept
from emp_rank
group by deptno, empno, point
order by deptno, point desc
;



-- 4. <연속된 날짜를 하나의 그룹으로 표현>
select * from t;

select no
     , min(dt) from_dt
     , max(dt) to_dt
     , count(*) cnt
from (select no, dt
           , sum(a) over(partition by no order by dt) g
      from (select no, dt
                 , case lag(dt) over(partition by no order by dt)
                 when to_char(to_date(dt, 'yyyymmdd') - 1, 'yyyymmdd')
                 then 0
                 else 1 end a
            from t
      )b
)c
group by no, g
order by no, from_dt
;



-- 6. <경우의 수 구하기>
select * from code_base;
drop table code_base;
CREATE TABLE code_base AS
(
    SELECT 'A' code
    UNION ALL SELECT 'B'
    UNION ALL SELECT 'C'
);
 
-- 순서와 무관한 경우의 수
select code
from code_base
union all
select a.code||'-'||b.code
from code_base a, code_base b
where a.code < b.code
union ALL
select a.code||'-'||b.code||'-'||c.code
from code_base a, code_base b, code_base c
where a.code < b.code
and b.code < c.code
;

-- 순서까지 고려한 경우의 수
with recursive t as (
     select code
     from code_base
     union all
     select a.code||'-'||b.code
     from code_base a, code_base b
     where a.code < b.code or b.code < a.code
     union all
     select a.code||'-'||b.code||'-'||c.code
     from code_base a, code_base b, code_base c
     where a.code != b.code
     and a.code != c.code
     and b.code != c.code
)
select code
from t
;



-- 10. <오라클 계층구조 쿼리의 이해>
select * from emp;

with recursive t as(
     select empno
          , ename
          , 1 lv
          , mgr
          , '' mgr_ename
          , ename enames
     from emp
     where mgr is null
     union all
     select emp.empno
          , emp.ename
          , t.lv + 1 lv
          , emp.mgr
          , '' || t.ename mgr_ename
          , t.enames || '-' || emp.ename enames
     from t, emp
     where t.empno = emp.mgr
)

select *
from t
;

ALTER table emp
ALTER column ename type varchar;



-- 11. <숫자를 한글로 변환하기>
select amt
      , translate(substr(v, 1, 1) || case when substr(v, 1, 1) = '0' then '' else '천' end
     || substr(v, 2, 1) || case when substr(v, 2, 1) = '0' then '' else '백' end
     || substr(v, 3, 1) || case when substr(v, 3, 1) = '0' then '' else '십' end
     || substr(v, 4, 1) || case when substr(v, 1, 4) = '0000' then '' else '조' end
     || substr(v, 5, 1) || case when substr(v, 5, 1) = '0' then '' else '천' end
     || substr(v, 6, 1) || case when substr(v, 6, 1) = '0' then '' else '백' end
     || substr(v, 7, 1) || case when substr(v, 7, 1) = '0' then '' else '십' end
     || substr(v, 8, 1) || case when substr(v, 5, 4) = '0000' then '' else '억' end
     || substr(v, 9, 1) || case when substr(v, 9, 1) = '0' then '' else '천' end
     || substr(v, 10, 1) || case when substr(v, 10, 1) = '0' then '' else '백' end
     || substr(v, 11, 1) || case when substr(v, 11, 1) = '0' then '' else '십' end
     || substr(v, 12, 1) || case when substr(v, 9, 4) = '0000' then '' else '만' end
     || substr(v, 13, 1) || case when substr(v, 13, 1) = '0' then '' else '천' end
     || substr(v, 14, 1) || case when substr(v, 14, 1) = '0' then '' else '백' end
     || substr(v, 15, 1) || case when substr(v, 15, 1) = '0' then '' else '십' end
     || substr(v, 16, 1), '1234567890', '일이삼사오육칠팔구') v
from (select amt, lpad(amt, 16, '0') v from hangeul) a;



-- 12. <오라클 계층구조 쿼리의 응용>
select empno, ename, mgr, sal from emp;

with recursive t as(
     select 1 lv

          , ename
          , ename enames
          , sal
          , sum(sal) sum_sal
     from emp
     where mgr is null
     union all
     select t.lv + 1 lv
          , emp.ename
          , t.enames || '-' || emp.ename enames
          , emp.sal sal
          , t.sal sum_sal
     from t, emp
     where t.empno = emp.mgr
)

select *
from t

;



-- 13. <시험실 좌석 배치도>
select min(case when x = 1 then v end) v1
     , min(case when x = 2 then v end) v2
     , min(case when x = 3 then v end) v3
     , min(case when x = 4 then v end) v4
     , min(case when x = 5 then v end) v5
from (select v
     , x
     , row_number() over(partition by x order by v) y  
     from (select v
                , ntile(5) over(order by v) x
          from (select level v from generate_series(1,30) level) a
          ) b
     ) c
group by y
order by 1
;



-- 15. <숫자를 영문으로 표기>
select *
from hangeul;

select amt
     , trim(case when substr(v,1,3) = '0' then '' else to_char(to_date(substr(v,1,3),'j'),'Jsp "Trillion" ') end
     || case when substr(v,4,3) = '0' then '' else to_char(to_date(substr(v,4,3),'j'),'Jsp "Billion" ') end
     || case when substr(v,7,3) = '0' then '' else to_char(to_date(substr(v,7,3),'j'),'Jsp "Million" ') end
     || case when substr(v,10,0) = '0' then '' else to_char(to_date(substr(v,10),'j'),'Jsp')end)
from (select amt, lpad(amt, 15, '0') v from hangeul) a
;


-- 16. <그룹별 (홀수/짝수)행 데이터만 검색하기>
-- 홀수행
select a.grp, a.nm
from (select grp
          , nm
          , row_number() over(partition by grp order by nm) rn
     from group_table) a
where mod(rn,-2) = 1;

-- 짝수행
select a.grp, a.nm
from (select grp
          , nm
          , row_number() over(partition by grp order by nm) rn
     from group_table) a
where mod(rn,-2) = 0;



-- 17. <분석함수의 이해>
select *
from over_table;

select yyyymm
     , amt
     , sum(amt) over(order by yyyymm rows between 3 preceding and 1 preceding) as amt_pre3
     , sum(amt) over(order by yyyymm rows between 1 following and 3 following) as amt_fol3
from over_table
;


-- 18. <연속된 수를 하나로 합치기>
SELECT lv
     , rn
     , count(*) over(partition by lv-rn) cnt
from (select lv
           , row_number() over(order by lv) rn
     from lv_table) a
;

select row_number() over(order by min(lv)) rn
     , min(lv)||case when count(*) = 1 then '' else '~'||max(lv) end v
from (select lv
          , rn
          , lv - rn grp
          , count(*) over(partition by lv-rn) cnt
     from (select lv
               , row_number() over(order by lv) rn
          from lv_table) a
     ) b
group by grp, case when cnt < 5 then lv end
;

SELECT rn
     , v
     , ceil(rn/4.0) x
     , mod(rn, 4) y
FROM (select row_number() over(order by min(lv)) rn
     , min(lv)||case when count(*) = 1 then '' else '~'||max(lv) end v
from (select lv
          , rn
          , lv - rn grp
          , count(*) over(partition by lv-rn) cnt
     from (select lv
               , row_number() over(order by lv) rn
          from lv_table) a
     ) b
group by grp, case when cnt < 5 then lv end
) c
;

SELECT min(case when mod(rn,4) = 1 then v end) v1
     , min(case when mod(rn,4) = 2 then v end) v2
     , min(case when mod(rn,4) = 3 then v end) v3
     , min(case when mod(rn,4) = 0 then v end) v4
FROM (select row_number() over(order by min(lv)) rn
     , min(lv)||case when count(*) = 1 then '' else '~'||max(lv) end v
from (select lv
          , rn
          , lv - rn grp
          , count(*) over(partition by lv-rn) cnt
     from (select lv
               , row_number() over(order by lv) rn
          from lv_table) a
          ) b
     group by grp, case when cnt < 5 then lv end
     ) c
GROUP BY CEIL(rn / 4.0)
ORDER BY CEIL(rn / 4.0)
;



-- 19. <이용요금에 대한 납부현황 구하기>
select *
from 요금
;

select *
from 납부
;



-- 20. <지뢰찾기>
select ceil(level / 5.1) x
     , mod(level-1, 5) +1 y
     , case when row_number() over(order by random()) <= 10 then '*' end z
from generate_series(1,25) level
;


SELECT min(case when x = 1 then z end) x1
     , min(case when x = 2 then z end) x2
     , min(case when x = 3 then z end) x3
     , min(case when x = 4 then z end) x4
     , min(case when x = 5 then z end) x5
FROM (select ceil(level / 5.1) x
          , mod(level-1, 5) +1 y
          , case when row_number() over(order by random()) <= 10 then '*' end z
     from generate_series(1,25) level) a
group by y
;



-- 21. <다 대 다 데이터의 수량 배분>
select * from suju;
select * from ipgo;

select s.id, s.cd
from suju s, ipgo i
where s.cd = i.cd
;