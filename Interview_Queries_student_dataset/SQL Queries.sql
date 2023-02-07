Use demo;
select * from users;
select * from batches;
select * from student_batch_maps;
select * from instructor_batch_maps;
select * from sessions;
select * from attendances;
select * from tests;
select * from test_scores;

/* 1.Calculate the average rating given by students to each teacher for each session created. Also, provide the batch name for which session was conducted. */

select s.id,b.name as batch,u.name as instructor,round(avg(rating),2) as average_rating
from sessions s 
join attendances a on a.session_id=s.id
join batches b on s.batch_id=b.id
join users u on u.id=s.conducted_by
group by 1,2,3
order by 1;

/*2.Find the attendance percentage for each session for each batch. 
Also mention the batch name and users name who has conduct that session */

With total_students as
(
select batch_id,count(1) as tot_students 
from student_batch_maps
where active=1
group by 1
order by 1
),multiple_batch_students as
(
select active.user_id as student_id,active.batch_id as active_batch,inactive.batch_id as inactive_batch
from student_batch_maps active 
join student_batch_maps inactive
on active.user_id= inactive.user_id
where active.active=1 and inactive.active=0

),students_present as
(
select session_id,count(1) as students_present
from attendances a
join sessions s on s.id=a.session_id
where (a.student_id,s.batch_id) not in (select student_id,inactive_batch from multiple_batch_students)
group by 1
order by 1
)

select sp.session_id,ts.batch_id,b.name as batch_name,u.name as instructor_name,tot_students,students_present,round((students_present/tot_students)*100.0,2) as attendence_percentage
from sessions s 
join students_present sp on sp.session_id=s.id
join total_students ts on s.batch_id=ts.batch_id
join batches b on b.id=s.batch_id
join users u on u.id=s.conducted_by;
        
/*3.What is the average marks scored by each student in all the tests the student had appeared?*/

select user_id as student,round(avg(ts.score),2) as Average_score
from test_scores ts 
group by 1
order by 1; 

/* 4.A student is passed when he scores 40 percent of total marks in a test. Find out how many students passed in each test. 
Also mention the batch name for that test.*/

SELECT 
    ts.test_id, b.name AS batch, COUNT(1) AS students_passed
FROM
    tests t
        LEFT JOIN
    test_scores ts ON t.id = ts.test_id
        JOIN
    users u ON u.id = ts.user_id
        JOIN
    batches b ON b.id = t.batch_id
WHERE
    ((ts.score / t.total_mark) * 100.0) >= 40
GROUP BY ts.test_id , b.name
ORDER BY 1;

select *
from tests t
left join test_scores ts on t.id = ts.test_id;


/*5.A student can be transferred from one batch to another batch. If he is transferred from batch a to batch b.
batch b’s active=true and batch a’s active=false in student_batch_maps.
 At a time, one student can be active in one batch only.
 One Student can not be transferred more than four times. Calculate each students attendance percentage for all the sessions created 
 for his past batch. Consider only those sessions for which he was active in that past batch.*/

with total_sessions as
		(select SBM.user_id as student_id, count(1) as total_sessions_per_student
		from student_batch_maps SBM
		join sessions s on s.batch_id = SBM.batch_id
		where SBM.active = false
		group by SBM.user_id
		order by 1),
	multiple_batch_students as
		(select inactive.user_id, inactive.batch_id as inactive_batch, active.batch_id  as active_batch
		from student_batch_maps active
		join student_batch_maps inactive on active.user_id = inactive.user_id
		where active.active = true
		and inactive.active = false),
	attended_sessions as
		(select student_id, count(1) as sessions_attended_by_student
		from attendances a
		join sessions s on s.id = a.session_id
		where (a.student_id, s.batch_id)  in (select user_id, inactive_batch from multiple_batch_students)
		group by student_id)
select u.name as student
, round((coalesce(sessions_attended_by_student,0)/total_sessions_per_student) * 100.0,2) as student_attendence_percentage
from total_sessions TS
left join attended_sessions ATTS on ATTS.student_id = TS.student_id
join users u on u.id = TS.student_id
order by 1;

 /* 6. What is the average percentage of marks scored by each student in all the tests the student had appeared? */
 
with cte as 
(
SELECT u.name as students,sum(ts.score)/sum(t.total_mark)*100.0 as percentage_marks
FROM tests t
LEFT JOIN test_scores ts ON t.id = ts.test_id
JOIN users u ON u.id = ts.user_id
group by 1
order by 1
)

select students,round(avg(percentage_marks),2) as avg_percentage_marks from cte
group by 1
order by 1;
 

 
/*7. A student is passed when he scores 40 percent of total marks in a test. Find out how many percentage of students have passed in each test. 
Also mention the batch name for that test. */

with total_students as
(
SELECT test_id,COUNT(1) AS total_students
FROM test_scores
group by 1
),students_passed as
(
SELECT ts.test_id, b.name AS batch, COUNT(1) AS students_passed
FROM tests t
LEFT JOIN test_scores ts ON t.id = ts.test_id
JOIN users u ON u.id = ts.user_id
JOIN batches b ON b.id = t.batch_id
WHERE ((ts.score / t.total_mark) * 100.0) >= 40
GROUP BY 1,2
ORDER BY 1
)

select tst.test_id,sp.batch,tst.total_students,sp.students_passed,concat(round(sp.students_passed/tst.total_students*100.0,2),'%') as Percentage_students_passed
from total_students tst join students_passed sp
on tst.test_id=sp.test_id
group by 1,2,3,4
order by 1;

/* 8. A student can be transferred from one batch to another batch. If he is transferred from batch a to batch b. 
batch b’s active=true and batch a’s active=false in student_batch_maps.
At a time, one student can be active in one batch only. One Student can not be transferred more than four times.
Calculate each students attendance percentage for all the sessions. */

select * from users;
select * from batches;
select * from student_batch_maps;
select * from instructor_batch_maps;
select * from sessions;
select * from attendances;
select * from tests;
select * from test_scores;

With total_sessions_per_student as
(
select sbm.user_id as student_id,count(*) as total_sessions_per_student
from sessions s
join student_batch_maps  sbm on s.batch_id=sbm.batch_id
group by 1
order by 1
),multiple_batch_students as
(
select active.user_id as student_id,active.batch_id as active_batch,inactive.batch_id as inactive_batch
from student_batch_maps active 
join student_batch_maps inactive
on active.user_id= inactive.user_id
where active.active=1 and inactive.active=0

),sessions_attended_per_student as
(
select a.student_id,count(1) as sessions_attended_per_student
from attendances a
join sessions s on s.id=a.session_id
where (a.student_id,s.batch_id) not in (select student_id,inactive_batch from multiple_batch_students)
group by 1
order by 1
)

select TS.student_id,u.name as student_name,total_sessions_per_student,sessions_attended_per_student,
round((coalesce(sessions_attended_per_student,0)/total_sessions_per_student)*100.0,2) as attendence_percentage
from total_sessions_per_student TS
left join sessions_attended_per_student SA on TS.student_id=SA.student_id
join users u on u.id=TS.student_id



