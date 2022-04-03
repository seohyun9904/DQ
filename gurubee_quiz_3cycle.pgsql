-- 40. <일별 누적 접속자 통계 구하기>

select *
from jubsok
;

select dt
    , count(dt) 접속건수
    , count(distinct id) 접속자수
    , sum(count(*)) over(order by dt)
    , sum(count(x)) over(order by dt)
from (select dt
            ,id
            ,case when row_number() over(partition by id order by dt) = 1 then 1 end x
      from jubsok
) a
group by dt
order by dt
;

-- ??. <전기 요금 계산>
select *
from code_t
;

select *
from use_t
;

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

select u.id
    , u.kwh
    -- 사용량 종료보다 작다면 사용량 - 시작, 그렇지 않으면 종료 - 시작
    -- 구간별 사용량 = 작은 값(사용량, 종료) - 시작
    , case when u.kwh <= c.e then u.kwh - c.s else c.e - c.s end v
    , c.v1
    , c.v2
from use_t u
    , code_t c
where u.kwh > c.s
order by id, s
;

select u.id
    , u.kwh
    , least(u.kwh, c.e) - c.s v -- 최솟값을 반환
    , c.v1
    , c.v2
from use_t u
    , code_t c
where u.kwh > c.s
order by id, s
;

select u.id
    , u.kwh
    , trunc( max(v1) +
            sum((least(u.kwh, c.e) - c.s) * v2), -1) amt
from use_t u
    , code_t c
where u.kwh > c.s
group by u.id, u.kwh
order by id
;

-- <근무 종료 시간을 구하는 사용자 함수 생성(재귀함수)>
select *
from t_holiday
;

WITH RECURSIVE t AS
( 
SELECT 1 no, '2014/01/01 12:30' t, 2 h 
UNION ALL SELECT 2, '2014/01/30 12:30', 4 
UNION ALL SELECT 3, '2014/03/04 07:30', 2 
UNION ALL SELECT 4, '2014/03/04 12:30', 2 
UNION ALL SELECT 5, '2014/03/04 18:30', 2 
UNION ALL SELECT 6, '2014/03/04 09:30', 5 
UNION ALL SELECT 7, '2014/03/07 17:00', 2 
) 
SELECT no, t, h 
     , f_Quiz(t, h) x
FROM t 
;

select no, t, h

-- 기간 병합 검색
select *
from 기간
;

select min(sdt) sdt
    , max(edt) edt
from (
      select sdt
           , edt
           , sum(flag) over(order by sdt, edt) grp
      from (
            select sdt
                 , edt
                 , case when max(edt) over(order by sdt, edt
                                            rows between unbounded preceding and 1 preceding) >= sdt
                        then 0 else 1 end flag
            from 기간
      ) a
) b
group by grp
order by grp
;

select 