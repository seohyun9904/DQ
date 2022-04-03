-- inner join
select t.term_id, t.term_name, c.cust_name
from terminal t
join customer c
on t.term_id = c.term_id;

-- left outer join
select t.term_id, t.term_name, c.cust_name
from terminal t
left outer join customer c
on t.term_id = c.term_id;

-- right outer join
select t.term_id, t.term_name, c.cust_name
from terminal t
right outer join customer c
on t.term_id = c.term_id;

-- full outer join
select t.term_id, t.term_name, c.cust_name
from terminal t
full outer join  customer c
on t.term_id = c.term_id;

-- left union right = full outer join
-- union은 중복된 행 하나만 출력 union all은 중복된 행 두번 모두 출력
select t.term_id, t.term_name, c.cust_name
from terminal t
left outer join customer c
on t.term_id = c.term_id
UNION
select t.term_id, t.term_name, c.cust_name
from terminal t
right outer join customer c
on t.term_id = c.term_id;

-- intersect(교집합)
select t.term_id, t.term_name, c.cust_name
from terminal t
left outer join customer c
on t.term_id = c.term_id
INTERSECT
select t.term_id, t.term_name, c.cust_name
from terminal t
right outer join customer c
on t.term_id = c.term_id;

-- EXCEPT(차집합) / left, right outer join
-- 앞의 SQL 결과에서 뒤의 결과를 뺀 차집합
select * from terminal t
EXCEPT
select * from customer c
order by term_id;

select t.term_id, t.term_name, c.cust_name
from terminal t
left outer join customer c
on t.term_id = c.term_id;

select t.term_id, t.term_name, c.cust_name
from terminal t
right outer join customer c
on t.term_id = c.term_id;

select t.term_id, t.term_name, c.cust_name
from terminal t
left outer join customer c
on t.term_id = c.term_id
EXCEPT
select t.term_id, t.term_name, c.cust_name
from terminal t
right outer join customer c
on t.term_id = c.term_id;

-- cross join (모든 경우의 수)
select ename, dname
from emp
cross join dept
order by ename;

-- self join
select p.ename 사원, e.ename 관리자
from emp e
join emp p
on e.empno = p.mgr;

-- 72번
select c.cust_id, c.cust_name, t.term_id, t.term_name, o.os_id, o.os_name
from customer c
left outer join terminal t
on c.cust_id in (11000, 12000) and c.term_id = t.term_id
left outer join os o
on t.os_id = o.os_id
order by c.cust_id;

-- group by , having
select count(ename), deptno
from emp
group by deptno
having deptno >= 20;

-- scalar subquery
select ename, empno, mgr, (select ename from emp where e.mgr = empno)
from emp e;
-- ERROR
select ename, empno, mgr, (select ename from emp where mgr = e.empno)
from emp e;
-- subquery를 self join으로 하는 방법
SELECT e.ename, e.empno, e.mgr, p.ename
from emp e
left outer join emp p
on e.mgr = p.empno;

-- inlineview subquery
-- 물리적 실체 X
select e1.ename, e1.empno, e1.mgr
from (
    select ename, empno, mgr
    from emp
    where empno > 7800
) e1;

drop table student2;
