create database Team_PS_company;
use Team_PS_company;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);

select * from jobdepartment;

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

select * from salarybonus;

-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

select * from employee;

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

select * from qualification;

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

select * from leaves;

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

select * from payroll;

desc employee;

desc leaves;

desc jobdepartment;

desc payroll;

desc qualification;

desc salarybonus;

-- problem statement 
-- provide insights such as payroll calculation, leave tracking, and department-specific job roles.
-- The goal is to streamline HR operations, ensuring that all relevant employee data is accessible 
-- and accurately updated across different modules.

-- Employee insights 
-- How many unique employees are currently in the system?

select distinct count(*) as Emp_Count
from employee;

-- Which departments have the highest number of employees?
select j.jobdept , count(*) as emp_count
from jobdepartment j
join employee e 
on e.job_id = j.job_id
group by j.jobdept
order by count(*) desc
limit 3;

-- What is the average salary per department?
select j.jobdept ,round(avg(p.total_amount),2) as avg_salary
from jobdepartment j 
join payroll p 
on p.job_id = j.job_id
group by jobdept;

-- Who are the top 5 highest-paid employees? 
select e.firstname,e.lastname ,p.total_amount 
from employee e 
join payroll p 
on p.emp_id = e.emp_id 
order by total_amount desc 
limit 5 ;



-- jobrole analysis
-- How many different job roles exist in each department?

select Jobdept , 
count(distinct name) as Distinct_job_role_count 
from jobdepartment 
group by jobdept
order by Distinct_job_role_count desc ;

-- job dept, job role with more than 50000 salary
select  jobdept,name as job_role ,amount 
 from jobdepartment j
 join salarybonus s
 on s.job_id = j.job_id
 where amount > 50000
 group by jobdept;

-- Which job roles offer the highest salary?
SELECT 
    name as Job_Role,salaryrange
FROM jobdepartment
GROUP BY jobdept
order by salaryrange desc;

-- Which departments have the highest total salary allocation?
SELECT 
    jobdept,salaryrange
FROM jobdepartment
GROUP BY jobdept
order by salaryrange desc;

-- Qualification and skills 
-- How many employees have at least one qualification listed?

SELECT COUNT(DISTINCT Emp_ID) AS Total_Employees_With_Qualifications
FROM Qualification;

-- Which positions require the most qualifications?

SELECT Position,
COUNT(*) AS Qualification_Count
FROM Qualification
GROUP BY Position
ORDER BY Qualification_Count DESC;

-- Which employees have the highest number of qualifications?

SELECT firstname,lastname,age, 
COUNT(*) AS Qualification_Count
FROM Qualification q
join employee e 
on e.emp_ID = q.emp_ID
GROUP BY Emp_ID
ORDER BY Qualification_Count DESC
LIMIT 5; 

-- Which year had the most employees taking leaves?

select month(date) as Month_ , 
monthname(date) as month_name, 
count(leave_id) as Emp_count
from leaves 
group by month(date) 
order by Emp_count desc;

-- What is the average number of leave days taken by its employees per department?

SELECT j.JobDept, 
COUNT(l.leave_id) / COUNT(DISTINCT e.emp_id)
AS Avg_Leave_Days_Per_Employee
FROM jobdepartment j
JOIN employee e ON j.Job_ID = e.job_id
LEFT JOIN leaves l ON e.emp_id = l.emp_id
GROUP BY j.JobDept;

-- Which employees have taken the most leaves?

select e.emp_id , 
concat_ws(' ',firstname,lastname) as full_name , 
count(leave_id) as leaves_count
from employee e 
join leaves l 
on e.emp_id = l.emp_id 
group by emp_id 
order by count(leave_ID) desc ; 

-- What is the total number of leave days taken company-wide?

select count(distinct leave_id) as total_leaves_count
from leaves ;

-- How do leave days correlate with payroll amounts?

-- Payroll analysis 
-- What is the total monthly payroll processed?

select monthname(date) as month_name ,
sum(total_amount) as total_amount 
from payroll ;

-- What is the average bonus given per department?

select j.jobdept , 
round(avg(bonus),2) as avg_bonus 
from salarybonus s
join jobdepartment j 
on j.job_id = s.job_id 
group by j.jobdept 
order by avg_bonus desc; 

-- Which department receives the highest total bonuses?

select j.jobdept , 
round(sum(bonus),2) as total_bonus 
from salarybonus s
join jobdepartment j 
on j.job_id = s.job_id 
group by j.jobdept 
order by total_bonus desc;



 

