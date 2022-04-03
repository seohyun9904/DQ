CREATE TABLE emp(
    empno  text PRIMARY KEY,     
    ename  text not null,
    job    text not null,
    mgr    int,
    hiredate date,
    sal    int,
    comm int,
    deptno text);

create table dept(
    deptno int primary key,
    dname varchar(50) not null
);


select * from emp;
select * from dept;

drop table emp;
drop table dept;

insert into emp (empno, ename, job, hiredate, sal, deptno) values('7839', 'KING', 'PRESIDENT', '81-11-17', '5000', '10');
insert into emp (empno, ename, job, mgr, hiredate, sal, deptno) values('7698', 'BLAKE', 'MANAGER', '7839', '81-05-01', 2850, '30');
insert into emp (empno, ename, job, mgr, hiredate, sal, deptno) values('7782', 'CLARK', 'MANAGER', '7839', '81-05-09', 2450, '10');
insert into emp (empno, ename, job, mgr, hiredate, sal, deptno) values('7566', 'JONES', 'MANAGER', '7839', '81-04-01', 2975, '20');
insert into emp values('7654', 'MARTIN', 'SALESMAN', '7698', '81-09-10', 1250, 1400, '30');
insert into emp values('7499', 'ALLEN', 'SALESMAN', '7698', '81-02-11', 1600, 300, '30');
insert into emp values('7844', 'TURNER', 'SALESMAN', '7698', '81-08-21', 1500, 0, '30');
insert into emp (empno, ename, job, mgr, hiredate, sal, deptno) values('7900', 'JAMES', 'CLERK', '7698', '81-12-11', 950, '30');
insert into emp (empno, ename, job, mgr, hiredate, sal, deptno) values('7521', 'WARD', 'SALESMAN', '7698', '81-02-23', 1250, '30');
insert into emp (empno, ename, job, mgr, hiredate, sal, deptno) values('7902', 'FORD', 'ANALYST', '7566', '81-12-11', 3000, '20');
insert into emp (empno, ename, job, mgr, hiredate, sal, deptno) values('7369', 'SMITH', 'CLERK', '7902', '80-12-09', 800, '20');
insert into emp (empno, ename, job, mgr, hiredate, sal, deptno) values('7788', 'SCOTT', 'ANALYST', '7566', '82-12-22', 3000, '20');

insert into dept values(10, '기획');
insert into dept values(20, '마케팅');
insert into dept values(30, '개발');

CREATE TABLE DEPT
       (DEPTNO numeric,
        DNAME VARCHAR(14),
        LOC VARCHAR(13) );



INSERT INTO DEPT VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO DEPT VALUES (20, 'RESEARCH',   'DALLAS');
INSERT INTO DEPT VALUES (30, 'SALES',      'CHICAGO');
INSERT INTO DEPT VALUES (40, 'OPERATIONS', 'BOSTON');


CREATE TABLE EMP (
 EMPNO               numeric NOT NULL,
 ENAME               VARCHAR(10),
 JOB                 VARCHAR(9),
 MGR                 numeric ,
 HIREDATE            DATE,
 SAL                 numeric,
 COMM                numeric,
 DEPTNO              numeric );



INSERT INTO EMP VALUES (7839,'KING','PRESIDENT',NULL,'81-11-17',5000,NULL,10);
INSERT INTO EMP VALUES (7698,'BLAKE','MANAGER',7839,'81-05-01',2850,NULL,30);
INSERT INTO EMP VALUES (7782,'CLARK','MANAGER',7839,'81-05-09',2450,NULL,10);
INSERT INTO EMP VALUES (7566,'JONES','MANAGER',7839,'81-04-01',2975,NULL,20);
INSERT INTO EMP VALUES (7654,'MARTIN','SALESMAN',7698,'81-09-10',1250,1400,30);
INSERT INTO EMP VALUES (7499,'ALLEN','SALESMAN',7698,'81-02-11',1600,300,30);
INSERT INTO EMP VALUES (7844,'TURNER','SALESMAN',7698,'81-08-21',1500,0,30);
INSERT INTO EMP VALUES (7900,'JAMES','CLERK',7698,'81-12-11',950,NULL,30);
INSERT INTO EMP VALUES (7521,'WARD','SALESMAN',7698,'81-02-23',1250,500,30);
INSERT INTO EMP VALUES (7902,'FORD','ANALYST',7566,'81-12-11',3000,NULL,20);
INSERT INTO EMP VALUES (7369,'SMITH','CLERK',7902,'80-12-09',800,NULL,20);
INSERT INTO EMP VALUES (7788,'SCOTT','ANALYST',7566,'82-12-22',3000,NULL,20);
INSERT INTO EMP VALUES (7876,'ADAMS','CLERK',7788,'83-01-15',1100,NULL,20);
INSERT INTO EMP VALUES (7934,'MILLER','CLERK',7782,'82-01-11',1300,NULL,10);

create table os (
    os_id int primary key,
    os_name varchar(10) not null
);

create table terminal (
    term_id int primary key,
    term_name varchar(10) not null,
    os_id int not null
);

create table customer (
    cust_id int primary key,
    cust_name varchar(10) not null,
    term_id int
);


insert into os values(100, 'Android');
insert into os values(200, 'iOS');
insert into os values(300, 'Bada');

insert into terminal values(1000, 'A1000', 100);
insert into terminal values(2000, 'B2000', 100);
insert into terminal values(3000, 'C3000', 200);
insert into terminal values(4000, 'D3000', 300);

insert into customer values(11000, '홍길동', 1000);
insert into customer (cust_id, cust_name) values(12000, '강감찬');
insert into customer (cust_id, cust_name) values(13000, '이순신');
insert into customer values(14000, '안중근', 3000);
insert into customer values(15000, '고길동', 4000);
insert into customer values(16000, '이대로', 4000);

select * from os;
select * from terminal;
select * from customer;
