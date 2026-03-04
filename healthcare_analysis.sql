CREATE DATABASE healthcare_project ; 
use healthcare_project ; 
drop table healthcare_data ; 

-- total rows --
select count(*) as total_rows 
from healthcare_data ; 

-- total columns -- 
describe healthcare_data ; 

-- sample data -- 
select * from healthcare_data limit 10 ; 

-- Distinct Departments -- 
select distinct department 
from healthcare_data ; 

-- Date Range -- 
SELECT 
    MIN(Admission_Date) AS First_Admission,
    MAX(Admission_Date) AS Last_Admission
FROM healthcare_data;

-- Gender Distribution Check -- 
select gender , count(*) as total
from healthcare_data 
group by gender ; 

-- PHASE 2 DATA QUALITY CHECK -- 
-- CHECKING MISSING VALUES -- 
-- AGE -- 
SELECT COUNT(*) AS MISSING_AGE 
FROM HEALTHCARE_DATA 
WHERE AGE IS NULL ; 

-- DEPARTMENT MISSING -- 
SELECT COUNT(*) AS Missing_Department
FROM healthcare_data
WHERE Department IS NULL;

-- MISSING ADMISSION DATE -- 
SELECT COUNT(*) AS Missing_Admission_Date
FROM healthcare_data
WHERE Admission_Date IS NULL;

-- CHECKING IF THERE IS DUPLICATE PATIENT ID -- 
SELECT PATIENT_ID , COUNT(*) AS CNT 
FROM HEALTHCARE_DATA 
GROUP BY PATIENT_ID 
HAVING COUNT(*) > 1 ; 

-- Logical Error Check -- 
SELECT *
FROM healthcare_data
WHERE Discharge_Date < Admission_Date;

-- VALUE DISTRIBUTION CHECK -- 
SELECT DISTINCT Readmitted
FROM healthcare_data;

-------- ✅ PHASE 3 – Core Business Metrics --------
-- HOSPITAL SCALE -- 
-- TOTAL PATIENTS -- 
Select  count(*) as total_patients 
from healthcare_data ;

-- total revenue -- 
select sum(treatment_cost) as total_revenue 
from healthcare_data ; 

-- average treatment cost -- 
select avg(treatment_cost) as avg_cost 
from healthcare_data ; 

-- avg length of stay -- 
select avg(length_of_stay) as avg_stay 
from healthcare_data ; 

-- 2️ ] Department Performance -- 

-- department with most patients --
select department , count(patient_id) as number_of_patients 
from healthcare_data 
group by department limit 1 ; 

-- department with most revenue -- 
select department , max(treatment_cost) as highest_revenue 
from healthcare_data 
group by department limit 1  ; 

-- department with most longest avg stay -- 
with DeptStay as ( 
select department , avg(length_of_stay) as avg_stay 
from healthcare_data 
group by department ) 
select department , avg_stay 
from DeptStay 
where avg_stay = ( Select max(avg_stay) from DeptStay);

-- 3️ Patient Quality Metrics--
-- Overall readmission rate -- 
SELECT 
    ROUND(
        (SUM(CASE WHEN Readmitted = 'Yes' THEN 1 ELSE 0 END) 
        / COUNT(*)) * 100,
    2) AS readmission_rate_percentage
FROM healthcare_data;

-- department with most readmission -- 
SELECT 
    Department,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN Readmitted = 'Yes' THEN 1 ELSE 0 END) AS readmitted_patients,
    ROUND(
        (SUM(CASE WHEN Readmitted = 'Yes' THEN 1 ELSE 0 END) 
        / COUNT(*)) * 100,
    2) AS readmission_rate_percentage
FROM healthcare_data
GROUP BY Department
ORDER BY readmission_rate_percentage DESC;

-- 1️ Department Summary Table --
CREATE VIEW department_summary AS 
SELECT 
    department,  
    COUNT(*) AS total_patients,
    SUM(treatment_cost) AS total_revenue,
    ROUND(AVG(treatment_cost), 2) AS avg_cost, 
    ROUND(AVG(length_of_stay), 2) AS avg_stay, 
    SUM(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) AS total_readmitted, 
    ROUND((SUM(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS readmission_rate_percentage 
FROM healthcare_data 
GROUP BY department;

select * from department_summary ; 


-- AGE GROUP SUMMARY -- 
Create View Age_group_summary as 
SELECT AGE_GROUP , 
COUNT(*) AS total_patients,
    SUM(Treatment_Cost) AS total_revenue,
    ROUND(AVG(Treatment_Cost), 2) AS avg_cost,
    ROUND(AVG(Length_of_Stay), 2) AS avg_stay,
    SUM(CASE WHEN Readmitted = 'Yes' THEN 1 ELSE 0 END) AS total_readmitted,
    ROUND(
        (SUM(CASE WHEN Readmitted = 'Yes' THEN 1 ELSE 0 END) 
        / COUNT(*)) * 100,
    2) AS readmission_rate_percentage
    FROM ( SELECT * , CASE WHEN AGE between 0 and 18 then '0-18' 
    WHEN Age BETWEEN 19 AND 40 THEN '19-40'
            WHEN Age BETWEEN 41 AND 60 THEN '41-60'
            ELSE '60+'
        END AS Age_Group
    FROM healthcare_data
) AS age_bucketed_data
GROUP BY Age_Group
ORDER BY total_patients DESC;

select*from age_group_summary ;



-- MONTHLY SUMMARY TABLE -- 
CREATE VIEW monthly_summary as 
SELECT DATE_FORMAT(admission_date, '%b-%Y') AS month_year , 
COUNT(*) AS total_patients,
    SUM(treatment_cost) AS total_revenue,
    ROUND(AVG(treatment_cost), 2) AS avg_cost, 
    ROUND(AVG(length_of_stay), 2) AS avg_stay, 
    SUM(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) AS total_readmitted, 
    ROUND((SUM(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS readmission_rate_percentage 
FROM healthcare_data 
group by month_year ;

select*from monthly_summary ; 


-- Simple Kpi table -- 
create view simple_kpi as 
select department , 
COUNT(*) AS total_patients,
    SUM(treatment_cost) AS total_revenue,
    ROUND(AVG(treatment_cost), 2) AS avg_cost, 
    ROUND(AVG(length_of_stay), 2) AS avg_stay
    from healthcare_data 
    group by department ; 
    
select* from simple_kpi ;

