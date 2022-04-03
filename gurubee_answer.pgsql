-- 1. <스터디 가입현황?>
select a.s_id, a.s_nm, a.c_id, a.c_nm
     , min(case when c.chasu = 1 then 'O' end) as "1차"
     , min(case when c.chasu = 2 then 'O' end) as "2차"
     , min(case when c.chasu = 3 then 'O' end) as "3차"
     , count(c.s_id) as 참여횟수
from (select a.s_id, a.s_nm, b.c_id, b.c_nm
        from student a, course b) as a, study c
where a.s_id = c.s_id
and a.c_id = c.c_id
group by a.s_id, a.s_nm, a.c_id, a.c_nm
order by a.s_id, a.c_id;

select case when b.c_id = '001' then a.s_id end "ID"
     , case when b.c_id = '001' then a.s_nm end "성명"
     , b.c_nm "스터디"
     , min(case when c.chasu = 1 then 'O' end) as "1차"
     , min(case when c.chasu = 2 then 'O' end) as "2차"
     , min(case when c.chasu = 3 then 'O' end) as "3차"
     , count(c.s_id) as 참여횟수
from student a
cross join course b
inner join study c
on a.s_id = c.s_id
and b.c_id = c.c_id
group by a.s_id, a.s_nm, b.c_id, b.c_nm
order by a.s_id, b.c_id;



-- 2. <사원의 급여 합계 및 평균>
select deptno, empno
    , case x when 0 then coalesce(ename, '합계') else '평균' end ename
    , case x when 0 then sum(sal) else round(avg(sal*1.), 2) end sal
    from (select deptno, 0 x, empno, ename, sal from emp) a
group by grouping sets ((deptno, x, empno, ename), (deptno, x), (deptno));



-- 3. <랭킹 쿼리>
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



-- 5. <IP 목록 정렬하기>
SELECT row_number() over() rn, ip
    FROM iptable
ORDER BY REGEXP_REPLACE(REPLACE('.'||ip, '.', '.00'), '([^.]{3}(\.|$))|.', '\1');



-- 6. <경우의 수 구하기>
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



-- 7. <조건에 따른 누적합계 구하기>
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



-- 8. <날짜별 모든 코드에 대한 자료 채우기>
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



-- 10. <계층구조 쿼리의 이해>
with recursive t1 (empno, ename, lv, mgr, mgr_ename, enames, empnos) as (
    select empno
     , ename
     , 1 lv
     , mgr
     , '' mgr_ename
     , ename enames
     , TO_CHAR(empno,'9999') empnos
    from emp
    where mgr is null
    union all
    select t2.empno
     , t2.ename
     , t1.lv + 1 lv
     , t2.mgr
     , '' || t1.ename mgr_ename
     , t1.enames || '-' || t2.ename enames
     , t1.empnos || '-' || t2.empno empnos
    from t1, emp t2
    where t1.empno = t2.mgr
)
select *
from t1
order by empnos
;



-- 11. <숫자를 한글로 변환하기>
SELECT amt
    , translate
    ( substr(v, 1,1)||case when substr(v, 1,1) = '0' then '' else '천' end
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
    , '1234567890', '일이삼사오육칠팔구') v
FROM (SELECT amt, LPAD(amt,16,'0') v from hangeul) h
;



-- 12. <오라클 계층구조 쿼리의 응용>
with recursive t1 (empno, ename, lv, mgr, mgr_ename, enames, empnos, sal, sum_sal) as (
    select empno
     , ename
     , 1 lv
     , mgr
     , '' mgr_ename
     , ename enames
     , TO_CHAR(empno,'9999') empnos
     , sal
     , (select sum(sal) from emp) sum_sal
    from emp
    where mgr is null
    union all
    select t2.empno
     , t2.ename
     , t1.lv + 1 lv
     , t2.mgr
     , '' || t1.ename mgr_ename
     , t1.enames || '-' || t2.ename enames
     , t1.empnos || '-' || t2.empno empnos
     , t2.sal
     , t1.sal
    from t1, emp t2
    where t1.empno = t2.mgr
)
select *
from t1
order by empnos
;



-- 13. <시험실 좌석 배치도>
select min(case when x=1 then v end) v1
     , min(case when x=2 then v end) v2
     , min(case when x=3 then v end) v3
     , min(case when x=4 then v end) v4
     , min(case when x=5 then v end) v5
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



-- 15. <숫자를 영문으로 변환하기>
select amt,
    trim(
        case when substr(v, 1,3) = '0' then '' else to_char(to_date(substr(v,1,3),'j'),'Jsp "Trillion" ') end
        || case when substr(v, 4,3) = '0' then '' else to_char(to_date(substr(v,4,3),'j'),'Jsp "Brillion" ') end
        || case when substr(v, 7,3) = '0' then '' else to_char(to_date(substr(v,7,3),'j'),'Jsp "Mrillion" ') end
        || case when substr(v, 10,0) = '0' then '' else to_char(to_date(substr(v,10),'j'),'Jsp') end
    ) v
from (SELECT amt, LPAD(amt,15,'0') v FROM hangeul) a
;



-- 16. <그룹별(홀수/짝수)행 데이터만 검색하기>
-- 홀수행 검색
select t.grp, t.nm
from (select nm, grp
        , row_number() over(partition by grp order by nm) rn
        from group_table) t
where mod(rn,-2) = 1;

-- 짝수행 검색
select t.grp, t.nm
from (select nm, grp
        , row_number() over(partition by grp order by nm) rn
        from group_table) t
where mod(rn,-2) = 0;



-- 17. <분석함수의 이해>
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



-- 21. <다 대 다 데이터의 수량 배분>
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



-- 22. <기간 분할 검색>
select TO_CHAR(sdt, 'yyyymmdd') sdt
     , TO_CHAR(edt, 'yyyymmdd') edt
     , amt
     , cnt
from (select sdt
           , lead(sdt - 1) over(order by sdt) edt
           , sum(sum(amt)) over(order by sdt) amt
           , sum(sum(cnt)) over(order by sdt) cnt
        from (select case when lv = 1 then to_date(sdt, 'yyyymmdd') else to_date(edt, 'yyyymmdd') + 1 end sdt
                 , case when lv = 1 then amt else -amt end amt
                 , case when lv = 1 then cnt else -cnt end cnt
            from 기간
            , (select level lv from generate_series(1,2) level) a
            ) b
        group by sdt
    ) c
where amt != 0
;




-- 23. <기간 병합 검색>
select min(sdt) sdt
     , max(edt) edt
from (select sdt
           , edt
           , sum(flag) over(order by sdt, edt) grp
        from (select sdt
                    , edt
                    , case when max(edt) over(order by sdt, edt
                                 rows between unbounded PRECEDING AND 1 PRECEDING
                                 ) >= sdt
                            then 0 else 1 end flag
                  from 기간
                ) a
        ) b
group by grp
;



-- 27. <웹사이트 접속 로그 분석>
select id, grp, site, min(tm) tm, count(*) cnt
from (select id, site, tm
        , sum(lag_cnt) over(partition by id order by tm) grp
    from (select id, site, tm
    , lag(site) over(partition by id order by tm)
    , case when lag(site) over(partition by id order by tm) = site then 0 else 1 end lag_cnt
    from web_log) x ) s
group by id, grp, site
order by id, grp, site;



-- 33. <중복 할인 금액 구하기>
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



-- 34. <5일 연속 결석 여부 구하기>
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



-- 35. <전기요금 계산>
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



-- 40. <일별 누적 접속자 통계 구하기>
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



-- 41. <구분자로 나누어 행,열 바꾸기>
select substring(unnest(regexp_matches(v, '1:[^|]+')) ,3) as "1"
,substring(unnest(regexp_matches(v, '2:[^|]+')) ,3) as "2"
,substring(unnest(regexp_matches(v, '3:[^|]+')) ,3) as "3"
,substring(unnest(regexp_matches(v, '4:[^|]+')) ,3) as "4"
from p_table
;