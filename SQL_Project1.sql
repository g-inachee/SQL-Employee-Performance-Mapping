CREATE DATABASE Employee;
USE Employee;

/*Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table, and make a list of employees and details of their department.*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT
FROM emp_record_table;

/*Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is Less Than 2, Greater Than 4 and Between 2 and 4*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING < 2
AND EMP_RATING > 4
OR EMP_RATING BETWEEN 2 AND 4; 

/*Add a column to combine first name and last name*/ 
ALTER TABLE Employee.emp_record_table
ADD COLUMN NAME VARCHAR (100)
GENERATED ALWAYS AS (CONCAT(FIRST_NAME, ' ', LAST_NAME));

DESCRIBE emp_record_table;

/*Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees in the Finance department from the employee table and then give the resultant column alias as NAME.*/
SELECT NAME, DEPT
FROM Employee.emp_record_table 
WHERE Dept = "Finance"; 

/*Write a query to list only those employees who have someone reporting to them. Also, show the number of reporters (including the President)*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, ROLE, DEPT, MANAGER_ID
FROM Employee.emp_record_table
WHERE MANAGER_ID IS NOT NULL
OR ROLE = "President";

/*Write a query to list down all the employees from the healthcare and finance departments using union. Take data from the employee record table.*/
SELECT FIRST_NAME, LAST_NAME, GENDER, ROLE, DEPT
FROM Employee.emp_record_table
WHERE DEPT = "HEALTHCARE"
UNION
SELECT FIRST_NAME, LAST_NAME, GENDER, ROLE, DEPT
FROM Employee.emp_record_table
WHERE DEPT = "FINANCE";

/*List down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, Dept, and EMP_RATING grouped by dept. Also include the respective employee rating with the max emp rating for the department.*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, EMP_RATING, MAX(EMP_RATING) OVER (PARTITION BY DEPT) AS MAX_EMP_RATING
FROM Employee.emp_record_table;

/*Write a query to calculate the minimum and the maximum salary of the employees in each role.*/
SELECT ROLE, MIN(SALARY) AS MINIMUM_SALARY, MAX(SALARY) AS MAXIMUM_SALARY
FROM Employee.emp_record_table
GROUP BY ROLE;

/*Write a query to assign ranks to each employee based on their experience.*/
SELECT FIRST_NAME, LAST_NAME, EXP,
RANK() OVER (ORDER BY EXP DESC) AS EMP_RANK
FROM Employee.emp_record_table;

/*Write a query to create a view that displays employees in various countries whose salary is more than six thousand.*/
CREATE VIEW EMP_SALARY_MORE_THAN_6K AS
SELECT FIRST_NAME, LAST_NAME, COUNTRY, SALARY
FROM Employee.emp_record_table
WHERE SALARY>6000;

SELECT*FROM EMP_SALARY_MORE_THAN_6K;

/*Write a nested query to find employees with experience of more than ten years.*/ 
SELECT EMP_ID, FIRST_NAME, LAST_NAME, EXP 
FROM Employee.emp_record_table
WHERE EXP IN 
(
SELECT EXP 
FROM Employee.emp_record_table
WHERE EXP >10 
);

/*Write a query to create a stored procedure to retrieve the details of the employees whose experience is more than three years.*/
DELIMITER //
CREATE PROCEDURE MORETHAN3YRS() 
BEGIN
	SELECT*FROM Employee.emp_record_table
    WHERE EXP>3
    ORDER BY EXP DESC;
END //

CALL MORETHAN3YRS();

/*Write a query using stored functions in the project table to check whether the job profile assigned to each employee in the data science team matches the organization’s set standard.*/
DELIMITER // 
CREATE FUNCTION DATA_SCIENCE_TEAM (EXP INT)
RETURNS VARCHAR(100) deterministic
BEGIN 
DECLARE DATA_SCIENCE_TEAM VARCHAR (100); 
IF EXP <= 2 THEN SET DATA_SCIENCE_TEAM = 'JUNIOR DATA SCIENTIST'; 
ELSEIF EXP BETWEEN 2 AND 5 THEN SET DATA_SCIENCE_TEAM = 'ASSOCIATE DATA SCIENTIST';
ELSEIF EXP BETWEEN 5 AND 10 THEN SET DATA_SCIENCE_TEAM = 'SENIOR DATA SCIENTIST'; 
ELSEIF EXP BETWEEN 10 AND 12 THEN SET DATA_SCIENCE_TEAM = 'LEAD DATA SCIENTIST';
ELSEIF EXP BETWEEN 12 AND 16 THEN SET DATA_SCIENCE_TEAM = 'MANAGER';
END IF; RETURN (DATA_SCIENCE_TEAM); END// DELIMITER //
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DATA_SCIENCE_TEAM (EXP) AS ROLE, DEPT, EXP, COUNTRY, CONTINENT 
FROM Employee.emp_record_table
ORDER BY EXP;

/*Create an index to improve the cost and performance of the query to find the employee whose FIRST_NAME is ‘Eric’ in the employee table after checking the execution plan*/
ALTER TABLE Employee.emp_record_table
MODIFY EMP_ID VARCHAR (4) NOT NULL, 
MODIFY FIRST_NAME VARCHAR (100) NOT NULL, 
MODIFY LAST_NAME VARCHAR (100) NOT NULL,
MODIFY ROLE VARCHAR (100) NOT NULL,
MODIFY DEPT VARCHAR (100) NOT NULL,
MODIFY COUNTRY VARCHAR (100) NOT NULL,
MODIFY CONTINENT VARCHAR (100) NOT NULL,
MODIFY MANAGER_ID VARCHAR (4),
MODIFY PROJ_ID VARCHAR (4);

CREATE TABLE Execution_Plan (
EMP_ID VARCHAR (4) NOT NULL,
FIRST_NAME VARCHAR (100) NOT NULL,
LAST_NAME VARCHAR (100) NOT NULL, 
ROLE VARCHAR (100) NOT NULL,
DEPT VARCHAR (100) NOT NULL,
COUNTRY VARCHAR (100) NOT NULL, 
CONTINENT VARCHAR (100) NOT NULL,
MANAGER_ID VARCHAR (4), 
PROJ_ID VARCHAR (4)
);

ALTER TABLE Employee.Execution_Plan
ADD COLUMN Gender VARCHAR (1) NOT NULL,
ADD COLUMN EXP INT, 
ADD COLUMN SALARY INT,
ADD COLUMN EMP_RATING INT; 

INSERT INTO Employee.Execution_Plan (EMP_ID, FIRST_NAME, LAST_NAME, GENDER, ROLE, DEPT, EXP, COUNTRY, CONTINENT, SALARY, EMP_RATING, MANAGER_ID, PROJ_ID)
VALUES
("E005", "Eric", "Hoffman", "M", "LEAD DATA SCIENTIST", "FINANCE", "11", "USA", "NORTH AMERICA", "8500", "3", "E103", "P105");

SELECT*FROM Employee.Execution_Plan WHERE FIRST_NAME = 'Eric';

CREATE INDEX Emp_Index on Execution_Plan (FIRST_NAME);
SELECT*FROM Employee.Execution_Plan WHERE FIRST_NAME='Eric';

/*Write a query to calculate the bonus for all the employees, based on their ratings and salaries (Use the formula: 5% of salary * employee rating).*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, ROLE, DEPT, EXP, COUNTRY, CONTINENT, SALARY, EMP_RATING, (SALARY*0.05)*EMP_RATING AS EMP_BONUS
FROM Employee.emp_record_table;

/*Write a query to calculate the average salary distribution based on the continent and country. Take data from the employee record table.*/
SELECT COUNTRY, AVG(SALARY) AS AVERAGE_SALARY, COUNT(EMP_ID)
FROM Employee.emp_record_table
GROUP BY COUNTRY WITH ROLLUP;