-- 1. <스터디 가입현황>
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



-- 3. <오라클 랭킹 쿼리>
select empno, deptno, point
    , rank() over(order by point desc) rk_all
    , rank() over(partition by deptno order by point desc) rk_dept
from emp_rank
group by deptno, empno, point
order by deptno, point desc
;



-- 4. <연속된 날짜를 하나의 그룹으로 표현>
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