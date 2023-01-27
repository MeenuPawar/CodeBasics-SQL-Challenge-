Use demo;

#1. Write a SQL Query to fetch all the duplicate records in a table.

create table users
(
user_id int primary key,
user_name varchar(30) not null,
email varchar(50));

insert into users values
(1, 'Sumit', 'sumit@gmail.com'),
(2, 'Reshma', 'reshma@gmail.com'),
(3, 'Farhana', 'farhana@gmail.com'),
(4, 'Robin', 'robin@gmail.com'),
(5, 'Robin', 'robin@gmail.com');

select * from users;

with cte as
(
select * ,
row_number() over(partition by user_name order by user_id) as row_id
from users 
)

select * from cte where row_id>1;

# 2. Write a SQL query to fetch the second last record from employee table.

create table employee
( emp_ID int primary key
, emp_NAME varchar(50) not null
, DEPT_NAME varchar(50)
, SALARY int);

insert into employee values(101, 'Mohan', 'Admin', 4000);
insert into employee values(102, 'Rajkumar', 'HR', 3000);
insert into employee values(103, 'Akbar', 'IT', 4000);
insert into employee values(104, 'Dorvin', 'Finance', 6500);
insert into employee values(105, 'Rohit', 'HR', 3000);
insert into employee values(106, 'Rajesh',  'Finance', 5000);
insert into employee values(107, 'Preet', 'HR', 7000);
insert into employee values(108, 'Maryam', 'Admin', 4000);
insert into employee values(109, 'Sanjay', 'IT', 6500);
insert into employee values(110, 'Vasudha', 'IT', 7000);
insert into employee values(111, 'Melinda', 'IT', 8000);
insert into employee values(112, 'Komal', 'IT', 10000);
insert into employee values(113, 'Gautham', 'Admin', 2000);
insert into employee values(114, 'Manisha', 'HR', 3000);
insert into employee values(115, 'Chandni', 'IT', 4500);
insert into employee values(116, 'Satya', 'Finance', 6500);
insert into employee values(117, 'Adarsh', 'HR', 3500);
insert into employee values(118, 'Tejaswi', 'Finance', 5500);
insert into employee values(119, 'Cory', 'HR', 8000);
insert into employee values(120, 'Monica', 'Admin', 5000);
insert into employee values(121, 'Rosalin', 'IT', 6000);
insert into employee values(122, 'Ibrahim', 'IT', 8000);
insert into employee values(123, 'Vikram', 'IT', 8000);
insert into employee values(124, 'Dheeraj', 'IT', 11000);

select * from employee;
with cte as
(
select * ,
row_number() over( order by emp_ID desc) as row_id
from employee 
)

select * from cte where row_id=2;

/* 3. Write a SQL query to display only the details of employees who either earn the highest salary or
 the lowest salary in each department from the employee table. */
 
drop table employee;
create table employee
( emp_ID int primary key
, emp_NAME varchar(50) not null
, DEPT_NAME varchar(50)
, SALARY int);

insert into employee values(101, 'Mohan', 'Admin', 4000);
insert into employee values(102, 'Rajkumar', 'HR', 3000);
insert into employee values(103, 'Akbar', 'IT', 4000);
insert into employee values(104, 'Dorvin', 'Finance', 6500);
insert into employee values(105, 'Rohit', 'HR', 3000);
insert into employee values(106, 'Rajesh',  'Finance', 5000);
insert into employee values(107, 'Preet', 'HR', 7000);
insert into employee values(108, 'Maryam', 'Admin', 4000);
insert into employee values(109, 'Sanjay', 'IT', 6500);
insert into employee values(110, 'Vasudha', 'IT', 7000);
insert into employee values(111, 'Melinda', 'IT', 8000);
insert into employee values(112, 'Komal', 'IT', 10000);
insert into employee values(113, 'Gautham', 'Admin', 2000);
insert into employee values(114, 'Manisha', 'HR', 3000);
insert into employee values(115, 'Chandni', 'IT', 4500);
insert into employee values(116, 'Satya', 'Finance', 6500);
insert into employee values(117, 'Adarsh', 'HR', 3500);
insert into employee values(118, 'Tejaswi', 'Finance', 5500);
insert into employee values(119, 'Cory', 'HR', 8000);
insert into employee values(120, 'Monica', 'Admin', 5000);
insert into employee values(121, 'Rosalin', 'IT', 6000);
insert into employee values(122, 'Ibrahim', 'IT', 8000);
insert into employee values(123, 'Vikram', 'IT', 8000);
insert into employee values(124, 'Dheeraj', 'IT', 11000);

select * from employee;

Select * from
 (
Select *,max(salary) over(partition by DEPT_NAME) Max_Salary,
min(salary) over(partition by DEPT_NAME) min_Salary
from employee 
) a
where ((a.SALARY=a.Max_Salary) or (a.SALARY=a.min_Salary));

# 4. From the doctors table, fetch the details of doctors who work in the same hospital but in different specialty.

CREATE table doctors
(
id int primary key,
name varchar(50) not null,
speciality varchar(100),
hospital varchar(50),
city varchar(50),
consultation_fee int
);

insert into doctors values
(1, 'Dr. Shashank', 'Ayurveda', 'Apollo Hospital', 'Bangalore', 2500),
(2, 'Dr. Abdul', 'Homeopathy', 'Fortis Hospital', 'Bangalore', 2000),
(3, 'Dr. Shwetha', 'Homeopathy', 'KMC Hospital', 'Manipal', 1000),
(4, 'Dr. Murphy', 'Dermatology', 'KMC Hospital', 'Manipal', 1500),
(5, 'Dr. Farhana', 'Physician', 'Gleneagles Hospital', 'Bangalore', 1700),
(6, 'Dr. Maryam', 'Physician', 'Gleneagles Hospital', 'Bangalore', 1500);

select * from doctors;

select d1.name,d1.speciality,d1.hospital from doctors d1
cross join doctors d2
where d1.hospital=d2.hospital and d1.id<>d2.id and d1.speciality<>d2.speciality;

/*--Sub Question:

Now find the doctors who work in same hospital irrespective of their speciality.*/

select d1.name,d1.speciality,d1.hospital from doctors d1
cross join doctors d2
where d1.hospital=d2.hospital and d1.id<>d2.id;

# 5. From the login_details table, fetch the users who logged in consecutively 3 or more times.

create table login_details(
login_id int primary key,
user_name varchar(50) not null,
login_date date);

insert into login_details values
(101, 'Michael', current_date),
(102, 'James', current_date),
(103, 'Stewart', current_date+1),
(104, 'Stewart', current_date+1),
(105, 'Stewart', current_date+1),
(106, 'Michael', current_date+2),
(107, 'Michael', current_date+2),
(108, 'Stewart', current_date+3),
(109, 'Stewart', current_date+3),
(110, 'James', current_date+4),
(111, 'James', current_date+4),
(112, 'James', current_date+5),
(113, 'James', current_date+6);

select * from login_details 
order by login_date;

with cte as 
(
select *,lead(user_name) over(partition by login_date)  as repeated_2_times,
lead(user_name,2) over(partition by login_date) as repeated_3_times
from login_details
order by login_date
)

select repeated_3_times from cte where repeated_3_times is not NUll;

/* 6. From the students table, write a SQL query to interchange the adjacent student names.*/

create table students
(
id int primary key,
student_name varchar(50) not null
);

insert into students values
(1, 'James'),
(2, 'Michael'),
(3, 'George'),
(4, 'Stewart'),
(5, 'Robin');

select * from students;

select * ,
case
when id%2=0 then 
lag(student_name) over(order by id) 
else
lead(student_name,1,student_name) over(order by id) end as new_student_name
from students;

/*7. From the weather table, fetch all the records when London had extremely cold temperature for 3 consecutive days or more.*/

create table weather
(
id int,
city varchar(50),
temperature int,
day date
);

insert into weather values
(1, 'London', -1, STR_TO_DATE('2021-01-01','%Y-%m-%d')),
(2, 'London', -2, STR_TO_DATE('2021-01-02','%Y-%m-%d')),
(3, 'London', 4, STR_TO_DATE('2021-01-03','%Y-%m-%d')),
(4, 'London', 1, STR_TO_DATE('2021-01-04','%Y-%m-%d')),
(5, 'London', -2, STR_TO_DATE('2021-01-05','%Y-%m-%d')),
(6, 'London', -5, STR_TO_DATE('2021-01-06','%Y-%m-%d')),
(7, 'London', -7, STR_TO_DATE('2021-01-07','%Y-%m-%d')),
(8, 'London', 5, STR_TO_DATE('2021-01-08','%Y-%m-%d'));

select * from weather;

with cte as
(
select *,
	case 	when temperature<0 
			and lead(temperature) over(order by day) < 0
            and lead(temperature,2) over(order by day) < 0
            then 'yes' 
            when temperature<0 
			and lag(temperature) over(order by day) <0
            and lead(temperature) over(order by day) <0
			then 'yes'
            when temperature<0 
			and lag(temperature) over(order by day) <0
            and lag(temperature,2) over(order by day) <0
			then 'yes' else 'NO' 
	end as repeated_days_with_cold_temp
from weather
)
select id,city,temperature from cte where repeated_days_with_cold_temp='yes';

/* 8. From the following 3 tables (event_category, physician_speciality, patient_treatment), write a SQL query 
to get the histogram of specialties of the unique physicians who have done the procedures but never did prescribe anything.*/
 
create table event_category
(
  event_name varchar(50),
  category varchar(100)
);
     
create table physician_speciality
(
  physician_id int,
  speciality varchar(50)
);

create table patient_treatment
(
  patient_id int,
  event_name varchar(50),
  physician_id int
);
        
insert into event_category values ('Chemotherapy','Procedure');
insert into event_category values ('Radiation','Procedure');
insert into event_category values ('Immunosuppressants','Prescription');
insert into event_category values ('BTKI','Prescription');
insert into event_category values ('Biopsy','Test');

insert into physician_speciality values (1000,'Radiologist');
insert into physician_speciality values (2000,'Oncologist');
insert into physician_speciality values (3000,'Hermatologist');
insert into physician_speciality values (4000,'Oncologist');
insert into physician_speciality values (5000,'Pathologist');
insert into physician_speciality values (6000,'Oncologist');

insert into patient_treatment values (1,'Radiation', 1000);
insert into patient_treatment values (2,'Chemotherapy', 2000);
insert into patient_treatment values (1,'Biopsy', 1000);
insert into patient_treatment values (3,'Immunosuppressants', 2000);
insert into patient_treatment values (4,'BTKI', 3000);
insert into patient_treatment values (5,'Radiation', 4000);
insert into patient_treatment values (4,'Chemotherapy', 2000);
insert into patient_treatment values (1,'Biopsy', 5000);
insert into patient_treatment values (6,'Chemotherapy', 6000);

select * from patient_treatment;
select * from event_category;
select * from physician_speciality;

with master_table as 
(
select pt.*,ec.category,ps.speciality from patient_treatment pt
left outer join EVENT_CATEGORY ec on pt.event_name=ec.event_name
left outer join PHYSICIAN_SPECIALITY ps on pt.physician_id=ps.physician_id
) 


select speciality,count(distinct event_name) from
(
select distinct physician_id,category,speciality,event_name,patient_id from 
(
select pt.*,ec.category,ps.speciality from patient_treatment pt
left outer join EVENT_CATEGORY ec on pt.event_name=ec.event_name
left outer join PHYSICIAN_SPECIALITY ps on pt.physician_id=ps.physician_id
)master_table where category<>'Prescription' and category='Procedure'
)x
group by 1
order by 2 desc;
 
select ps.speciality, count(1) as speciality_count
from patient_treatment pt
join event_category ec on ec.event_name = pt.event_name
join physician_speciality ps on ps.physician_id = pt.physician_id
where ec.category = 'Procedure'
and pt.physician_id not in (select pt2.physician_id
							from patient_treatment pt2
							join event_category ec on ec.event_name = pt2.event_name
							where ec.category in ('Prescription'))
group by ps.speciality;

/* 9. Find the top 2 accounts with the maximum number of unique patients on a monthly basis.*/

create table patient_logs
(
  account_id int,
  date date,
  patient_id int
);

insert into patient_logs values (1, STR_TO_DATE('02-01-2020','%d-%m-%Y'), 100);
insert into patient_logs values (1, STR_TO_DATE('27-01-2020','%d-%m-%Y'), 200);
insert into patient_logs values (2, STR_TO_DATE('01-01-2020','%d-%m-%Y'), 300);
insert into patient_logs values (2, STR_TO_DATE('21-01-2020','%d-%m-%Y'), 400);
insert into patient_logs values (2, STR_TO_DATE('21-01-2020','%d-%m-%Y'), 300);
insert into patient_logs values (2, STR_TO_DATE('01-01-2020','%d-%m-%Y'), 500);
insert into patient_logs values (3, STR_TO_DATE('20-01-2020','%d-%m-%Y'), 400);
insert into patient_logs values (1, STR_TO_DATE('04-03-2020','%d-%m-%Y'), 500);
insert into patient_logs values (3, STR_TO_DATE('20-01-2020','%d-%m-%Y'), 450);

select * from patient_logs;

With monthly_data as
(
select distinct date_format(date,'%M') as months,account_id,patient_id from patient_logs
),no_of_patients as
(
select months,account_id,count(patient_id) as no_of_patients from monthly_data group by 1,2
),rank_data as
(
select months,account_id,no_of_patients,dense_rank() over(partition by months order by no_of_patients desc,account_id ) as rnk from no_of_patients
)

select * from rank_data where rnk in (1,2);

/*10. SQL Query to fetch “N” consecutive records from a table based on a certain condition*/

drop table if exists weather cascade;
create table if not exists weather
	(
		id 	int primary key,
		city varchar(50) not null,
		temperature int not null,
		day date not null
	);
    

delete from weather;
insert into weather values
	(1, 'London', -1, STR_TO_DATE('2021-01-01','%Y-%m-%d')),
	(2, 'London', -2, STR_TO_DATE('2021-01-02','%Y-%m-%d')),
	(3, 'London', 4, STR_TO_DATE('2021-01-03','%Y-%m-%d')),
	(4, 'London', 1, STR_TO_DATE('2021-01-04','%Y-%m-%d')),
	(5, 'London', -2, STR_TO_DATE('2021-01-05','%Y-%m-%d')),
	(6, 'London', -5, STR_TO_DATE('2021-01-06','%Y-%m-%d')),
	(7, 'London', -7, STR_TO_DATE('2021-01-07','%Y-%m-%d')),
	(8, 'London', 5, STR_TO_DATE('2021-01-08','%Y-%m-%d')),
	(9, 'London', -20, STR_TO_DATE('2021-01-09','%Y-%m-%d')),
	(10, 'London', 20, STR_TO_DATE('2021-01-10','%Y-%m-%d')),
	(11, 'London', 22, STR_TO_DATE('2021-01-11','%Y-%m-%d')),
	(12, 'London', -1, STR_TO_DATE('2021-01-12','%Y-%m-%dd')),
	(13, 'London', -2, STR_TO_DATE('2021-01-13','%Y-%m-%d')),
	(14, 'London', -2, STR_TO_DATE('2021-01-14','%Y-%m-%d')),
	(15, 'London', -4, STR_TO_DATE('2021-01-15','%Y-%m-%dd')),
	(16, 'London', -9, STR_TO_DATE('2021-01-16','%Y-%m-%d')),
	(17, 'London', 0, STR_TO_DATE('2021-01-17','%Y-%m-%d')),
	(18, 'London', -10, STR_TO_DATE('2021-01-18','%Y-%m-%d')),
	(19, 'London', -11, STR_TO_DATE('2021-01-19','%Y-%m-%d')),
	(20, 'London', -12, STR_TO_DATE('2021-01-20','%Y-%m-%d')),
	(21, 'London', -11, STR_TO_DATE('2021-01-21','%Y-%m-%d'));
COMMIT;

select * from weather;

# 10a. when the table has a primary key

with t1 as 
(
select *,id-dense_rank() over(order by id) as rnk from weather where temperature<0
),
t2 as
(
select *,count(*) over (partition by rnk order by rnk) as cnt from t1 
)

select id, city, temperature, day from t2 where cnt=5;


/* -- Query 10b
-- Finding n consecutive records where temperature is below zero. And table does not have primary key.*/


create or replace view vw_weather as
select city, temperature from weather;

with t1 as
(
select row_number() over() as id ,city,temperature from vw_weather
),
t2 as 
(
select *,id-rank() over(order by id) as rnk from t1 where temperature <0
),
t3 as
(
select *,count(*) over(partition by rnk order by rnk) as cnt from t2
)

select city, temperature from t3 where cnt=4;

/*-- Query 10c
-- Finding n consecutive records with consecutive date value.*/

create table if not exists orders
  (
    order_id    varchar(20) primary key,
    order_date  date        not null
);

insert into orders values
  ('ORD1001', str_to_date('2021-Jan-01','%Y-%b-%d')),
  ('ORD1002', str_to_date('2021-Feb-01','%Y-%b-%d')),
  ('ORD1003', str_to_date('2021-Feb-02','%Y-%b-%d')),
  ('ORD1004', str_to_date('2021-Feb-03','%Y-%b-%d')),
  ('ORD1005', str_to_date('2021-Mar-01','%Y-%b-%d')),
  ('ORD1006', str_to_date('2021-Jun-01','%Y-%b-%d')),
  ('ORD1007', str_to_date('2021-Dec-25','%Y-%b-%d')),
  ('ORD1008', str_to_date('2021-Dec-26','%Y-%b-%d'));
  
  select count(*) from orders;
  
with t1 as
(
select *,row_number() over(order by order_date) as rnk ,
order_date -row_number() over(order by order_date) as diff from orders
),
t3 as
(
select *,count(*) over(partition by diff order by diff) as cnt from t1
)

select order_id,order_date from t3 where cnt>1;