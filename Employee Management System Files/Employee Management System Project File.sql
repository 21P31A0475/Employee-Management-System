CREATE DATABASE Employee_Management;
USE Employee_Management;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
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

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

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

SELECT * FROM JobDepartment;
SELECT * FROM SalaryBonus;
SELECT * FROM Employee;
SELECT * FROM Qualification;
SELECT * FROM Leaves;
SELECT * FROM Payroll;

-- 1. EMPLOYEE INSIGHTS 

# a) How many unique employees are currently in the system?

SELECT 
    COUNT(DISTINCT (emp_ID)) AS Unique_employees
FROM
    employee;

# b) Which departments have the highest number of employees?

SELECT 
    j.jobdept, COUNT(e.emp_id) AS No_of_employees
FROM
    JobDepartment j
        JOIN
    Employee e ON j.Job_ID = e.Job_ID
GROUP BY jobdept
ORDER BY No_of_employees DESC;

# c) What is the average salary per department?

SELECT 
    j.jobdept AS Department, AVG(s.amount) AS Average_Salary
FROM
    JobDepartment j
        JOIN
    SalaryBonus s ON j.Job_ID = s.Job_ID
GROUP BY Department;

# d) Who are the top 5 highest-paid employees?

SELECT 
    e.emp_ID,
    CONCAT(firstname," ",lastname) AS Employees,
    s.amount AS highest_amount
FROM
    Employee e
        JOIN
    SalaryBonus s ON e.Job_ID = s.Job_ID
ORDER BY highest_amount DESC
LIMIT 5;

# e) What is the total salary expenditure across the company?

SELECT 
    SUM(annual+bonus) AS Total_Salary
FROM
    SalaryBonus;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS

## a) How many different job roles exist in each department?

SELECT 
    jobdept AS Department, COUNT(DISTINCT name) AS Job_Roles
FROM
    JobDepartment
GROUP BY jobdept;

## b) What is the average salary range per department?

SELECT 
    j.jobdept AS Department,
    ROUND(AVG(s.amount)) AS Avg_Salary,
    MIN(s.amount) AS Min_Salary,
    MAX(s.amount) AS Max_Salary
FROM
    JobDepartment j
        INNER JOIN
    SalaryBonus s ON j.Job_ID = s.Job_ID
GROUP BY j.jobdept;

## c) Which job roles offer the highest salary?

SELECT 
    jd.jobdept AS Department,jd.name AS Job_Roles, sb.amount AS highest_salary
FROM
    JobDepartment jd
        INNER JOIN
    SalaryBonus sb ON jd.Job_ID = sb.Job_ID
ORDER BY highest_salary DESC;

## d) Which departments have the highest total salary allocation?

SELECT 
    j.jobdept AS Department,
    SUM(sb.amount) AS Highest_Total_Salary
FROM
    JobDepartment j
        INNER JOIN
    SalaryBonus sb ON j.Job_ID = sb.Job_ID
GROUP BY Department
ORDER BY Highest_Total_Salary DESC;

-- 3. QUALIFICATION AND SKILLS ANALYSIS

## a) How many employees have at least one qualification listed?

SELECT 
    COUNT(DISTINCT e.emp_ID) AS Emp_Qualification
FROM
    Qualification q
        JOIN
    Employee e ON e.emp_ID = q.emp_ID;

## b) Which positions require the most qualifications?

SELECT 
    q.Position, COUNT(q.Requirements) AS Requirement_Count
FROM
    Qualification q
GROUP BY q.Position;

## c) Which employees have the highest number of qualifications?

SELECT 
    e.emp_ID,
    CONCAT(firstname," ",lastname) AS Employees,
    COUNT(q.QualID) AS No_of_qualifications
FROM
    Employee e
        JOIN
    Qualification q ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID , e.firstname , e.lastname
ORDER BY No_of_qualifications DESC;

-- 4. LEAVE AND ABSENCE PATTERNS

## a) Which year had the most employees taking leaves?

SELECT * FROM Leaves;
SELECT 
    EXTRACT(YEAR FROM l.date) AS Most_Leaves_In_Year,
    COUNT(DISTINCT e.emp_ID) AS Employee_Count
FROM
    Leaves l
        JOIN
    Employee e ON l.emp_ID = e.emp_ID
GROUP BY Most_Leaves_In_Year
ORDER BY Most_Leaves_In_Year DESC;

## b) What is the average number of leave days taken by its employees per department?

SELECT 
    jd.jobdept AS Department,
    ROUND(COUNT(DISTINCT l.leave_ID) / COUNT(DISTINCT e.emp_ID)) AS leave_days_by_emp
FROM
    Employee e
        JOIN
    Leaves l ON e.emp_ID = l.emp_ID
        LEFT JOIN
    JobDepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY Department;

## c) Which employees have taken the most leaves?

SELECT 
    e.emp_ID,
    CONCAT_WS(' ',firstname,lastname) AS Employees,
    COUNT(l.leave_ID) AS most_leaves
FROM
    Employee e
        JOIN
    Leaves l ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID , e.firstname , e.lastname
ORDER BY Most_leaves DESC;

## d) What is the total number of leave days taken company-wide?

SELECT COUNT(date) AS Total_Leave_Days
FROM Leaves;

## e) How do leave days correlate with payroll amounts?

SELECT 
    l.emp_ID,
    COUNT(l.date) AS Leave_Days,
    SUM(total_amount) AS Total_Amount
FROM
    Leaves l
        JOIN
    Payroll pr ON l.emp_ID = pr.emp_ID
GROUP BY l.emp_ID;


-- 5. PAYROLL AND COMPENSATION ANALYSIS

## a) What is the total monthly payroll processed?

SELECT 
    DATE_FORMAT(date, '%Y-%m') AS Month_Payroll,
    SUM(total_amount) AS Total_Monthly_Payroll
FROM
    Payroll
GROUP BY Month_Payroll;

## b) What is the average bonus given per department?

SELECT 
    jobdept AS Department, ROUND(AVG(sb.bonus),2) AS Avg_Bonus
FROM
    JobDepartment jd
        JOIN
    SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY Department;

## c) Which department receives the highest total bonuses?

SELECT 
    jobdept AS Department, SUM(bonus) AS Total_Bonus
FROM
    JobDepartment jd
        INNER JOIN
    SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY Department
ORDER BY Total_Bonus DESC
LIMIT 1;

## d) What is the average value of total_amount after considering leave deductions?

SELECT 
    AVG(total_amount) AS Avg_Leave_Deductions
FROM
    Payroll;

